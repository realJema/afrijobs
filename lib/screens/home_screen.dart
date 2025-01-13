import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/job_filters.dart';
import '../services/job_service.dart';
import '../widgets/job_card.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _jobService = JobService();
  final _searchController = TextEditingController();
  JobFilters _currentFilters = JobFilters();
  List<Job>? _jobs;
  String? _error;
  bool _isLoading = false;

  // Cache for filter data
  Map<String, List<String>> _townsByRegion = {};
  List<String> _jobTypes = [];
  List<String> _availableTags = [];
  bool _isFilterDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFilterData();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterData() async {
    if (_isFilterDataLoaded) return;

    try {
      final towns = await _jobService.getTowns();
      final jobTypes = await _jobService.getJobTypes();
      final tags = await _jobService.getTags();

      setState(() {
        _townsByRegion = towns;
        _jobTypes = jobTypes;
        _availableTags = tags;
        _isFilterDataLoaded = true;
      });
    } catch (e) {
      print('Error loading filter data: $e');
    }
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobs = await _jobService.getJobs(filters: _currentFilters);
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearch(String value) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(searchTerm: value);
    });
    _loadJobs();
  }

  Future<void> _showFilters() async {
    if (!_isFilterDataLoaded) {
      await _loadFilterData();
    }

    final result = await Navigator.push<JobFilters>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          initialFilters: _currentFilters,
          townsByRegion: _townsByRegion,
          jobTypes: _jobTypes,
          availableTags: _availableTags,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentFilters = result;
      });
      _loadJobs();
    }
  }

  Widget _buildFilterPill(String text, {required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.green[900],
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.green[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPills() {
    final List<Widget> pills = [];

    // Add search term pill
    if (_currentFilters.searchTerm != null && _currentFilters.searchTerm!.isNotEmpty) {
      pills.add(_buildFilterPill(
        'Search: ${_currentFilters.searchTerm}',
        onRemove: () {
          print('Removing search filter'); // Debug log
          setState(() {
            _currentFilters = _currentFilters.copyWith(searchTerm: null);
          });
          _loadJobs();
        },
      ));
    }

    // Add job type pill
    if (_currentFilters.type != null && _currentFilters.type!.isNotEmpty) {
      pills.add(_buildFilterPill(
        _currentFilters.type!,
        onRemove: () {
          print('Removing job type filter'); // Debug log
          setState(() {
            _currentFilters = _currentFilters.copyWith(type: null);
          });
          _loadJobs();
        },
      ));
    }

    // Add location pills
    if (_currentFilters.region != null && _currentFilters.region!.isNotEmpty) {
      pills.add(_buildFilterPill(
        'Region: ${_currentFilters.region}',
        onRemove: () {
          print('Removing region filter'); // Debug log
          setState(() {
            _currentFilters = _currentFilters.copyWith(region: null, town: null);
          });
          _loadJobs();
        },
      ));
    }
    if (_currentFilters.town != null && _currentFilters.town!.isNotEmpty) {
      pills.add(_buildFilterPill(
        'Town: ${_currentFilters.town}',
        onRemove: () {
          print('Removing town filter'); // Debug log
          setState(() {
            _currentFilters = _currentFilters.copyWith(town: null);
          });
          _loadJobs();
        },
      ));
    }

    // Add salary range pills
    final defaultMin = '0';
    final defaultMax = '200';
    if (_currentFilters.minSalary != null && 
        _currentFilters.minSalary!.isNotEmpty && 
        _currentFilters.minSalary != defaultMin) {
      pills.add(_buildFilterPill(
        'Min: \$${_currentFilters.minSalary}K',
        onRemove: () {
          print('Removing min salary filter'); // Debug log
          setState(() {
            _currentFilters = _currentFilters.copyWith(minSalary: defaultMin);
          });
          _loadJobs();
        },
      ));
    }
    if (_currentFilters.maxSalary != null && 
        _currentFilters.maxSalary!.isNotEmpty && 
        _currentFilters.maxSalary != defaultMax) {
      pills.add(_buildFilterPill(
        'Max: \$${_currentFilters.maxSalary}K',
        onRemove: () {
          print('Removing max salary filter'); // Debug log
          setState(() {
            _currentFilters = _currentFilters.copyWith(maxSalary: defaultMax);
          });
          _loadJobs();
        },
      ));
    }

    // Add date range pill
    if (_currentFilters.dateRange != null && _currentFilters.dateRange!.isNotEmpty) {
      pills.add(_buildFilterPill(
        'Date: ${_currentFilters.dateRange}',
        onRemove: () {
          print('Removing date range filter'); // Debug log
          setState(() {
            _currentFilters = _currentFilters.copyWith(dateRange: null);
          });
          _loadJobs();
        },
      ));
    }

    // Add tag pills
    for (final tag in _currentFilters.tags) {
      pills.add(_buildFilterPill(
        tag,
        onRemove: () {
          print('Removing tag filter: $tag'); // Debug log
          setState(() {
            final newTags = List<String>.from(_currentFilters.tags)..remove(tag);
            _currentFilters = _currentFilters.copyWith(tags: newTags);
          });
          _loadJobs();
        },
      ));
    }

    if (pills.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: pills,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top Bar (only menu and notification)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Navigate to post job screen
                        },
                        icon: const Icon(Icons.add, color: Color(0xFF2D4A3E)),
                        label: const Text(
                          'Post a job',
                          style: TextStyle(
                            color: Color(0xFF2D4A3E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage('https://placeholder.com/48x48'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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

                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    SliverFillRemaining(
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
                    )
                  else if (_jobs == null || _jobs!.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: Text('No jobs found')),
                    )
                  else ...[
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
                              _buildAnalyticItem('Available\nPositions', '${_jobs!.length}'),
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

                    // Jobs List
                    SliverPadding(
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
                    ),
                  ],
                ],
              ),
            ),
          ],
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
          GestureDetector(
            onTap: showFilters,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D4A3E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: Colors.white),
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
