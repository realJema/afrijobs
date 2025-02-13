import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/job_filters.dart';
import '../providers/filter_provider.dart';
import '../providers/profile_provider.dart';
import '../services/auth_service.dart';
import '../services/job_service.dart';
import '../widgets/job_card.dart';
import '../widgets/job_card_skeleton.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _jobService = JobService();
  final _searchController = TextEditingController();
  List<Job>? _jobs;
  String? _error;
  bool _isLoading = true;

  void _showFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilterScreen()),
    ).then((_) => _loadJobs());
  }

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final filters = context.read<FilterProvider>().filters;
      final jobs = await _jobService.getJobs(filters: filters);
      if (mounted) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch(String value) {
    final filterProvider = context.read<FilterProvider>();
    final currentFilters = filterProvider.filters;
    filterProvider.updateFilters(currentFilters.copyWith(searchTerm: value));
    _loadJobs();
  }

  Widget _buildFilterPills() {
    final filterProvider = context.watch<FilterProvider>();
    final filters = filterProvider.filters;
    final pills = <Widget>[];

    if (filters.type != null) {
      pills.add(_buildPill(
        filters.type!,
        () {
          filterProvider.updateFilters(filters.copyWith(type: null));
        },
      ));
    }

    if (filters.town != null) {
      pills.add(_buildPill(
        filters.town!,
        () {
          filterProvider.updateFilters(filters.copyWith(town: null, region: null));
        },
      ));
    }

    if (filters.dateRange != null) {
      pills.add(_buildPill(
        filters.dateRange!,
        () {
          filterProvider.updateFilters(filters.copyWith(dateRange: null));
        },
      ));
    }

    for (final tag in filters.tags) {
      pills.add(_buildPill(
        tag,
        () {
          final newTags = List<String>.from(filters.tags)..remove(tag);
          filterProvider.updateFilters(filters.copyWith(tags: newTags));
        },
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pills,
    );
  }

  Widget _buildPill(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2D4A3E),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildJobList() {
    if (_isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(16.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const JobCardSkeleton(),
            childCount: 5, // Show 5 skeleton items while loading
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJobs,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_jobs == null || _jobs!.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No jobs found')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: JobCard(job: _jobs![index]),
          ),
          childCount: _jobs!.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AfriJobs'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add-job');
            },
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2D4A3E)),
            label: const Text('Post Job'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF2D4A3E),
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: ClipOval(
                child: Consumer<ProfileProvider>(
                  builder: (context, provider, _) {
                    final profile = provider.profile;
                    if (profile != null && profile['avatar_url'] != null) {
                      return Image.network(
                        profile['avatar_url'],
                        fit: BoxFit.cover,
                      );
                    }
                    return const Icon(Icons.person);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Header Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('E, dd MMMM yyyy').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Let's Find Jobs\nOpportunity here",
                            style: TextStyle(
                              fontSize: 24,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sticky Search Bar
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickySearchBarDelegate(
                      searchController: _searchController,
                      onSearch: _onSearch,
                      showFilters: _showFilters,
                    ),
                  ),

                  // Filter Pills
                  SliverToBoxAdapter(
                    child: _buildFilterPills(),
                  ),
                  // Analytics Card
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D4A3E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAnalyticItem('Available\nPositions', '${_jobs?.length ?? 0}'),
                            Container(width: 1, height: 40, color: Colors.white24),
                            _buildAnalyticItem('Applied\nJobs', '0'),
                            Container(width: 1, height: 40, color: Colors.white24),
                            _buildAnalyticItem('Unread\nMessages', '0'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Recommendations Title
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Recommended Jobs',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  _buildJobList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback showFilters;

  const _StickySearchBarDelegate({
    required this.searchController,
    required this.onSearch,
    required this.showFilters,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search jobs...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: showFilters,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 80.0;

  @override
  double get minExtent => 80.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
