import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/job_filters.dart';
import '../services/job_service.dart';
import '../widgets/job_card.dart';
import 'add_job_screen.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JobService _jobService = JobService();
  final TextEditingController _searchController = TextEditingController();
  final List<Job> _jobs = [];
  bool _isLoading = false;
  JobFilters _currentFilters = JobFilters();

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
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final jobs = await _jobService.getJobs(
        filters: JobFilters(
          search: _searchController.text,
          type: _currentFilters.type,
          minSalary: _currentFilters.minSalary,
          maxSalary: _currentFilters.maxSalary,
          tags: _currentFilters.tags,
          location: _currentFilters.location,
        ),
      );

      setState(() {
        _jobs.clear();
        _jobs.addAll(jobs);
      });
    } catch (e) {
      // TODO: Show error message
      print('Error loading jobs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openFilterScreen() async {
    final result = await Navigator.push<JobFilters>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          initialFilters: _currentFilters,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddJobScreen(),
            ),
          ).then((_) => _loadJobs());
        },
        icon: const Icon(Icons.add),
        label: const Text('Post a Job'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadJobs,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search jobs...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                        ),
                        onSubmitted: (_) => _loadJobs(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _openFilterScreen,
                      icon: Badge(
                        isLabelVisible: _currentFilters.isNotEmpty,
                        label: Text(_currentFilters.activeFilterCount.toString()),
                        child: const Icon(Icons.tune),
                      ),
                    ),
                  ],
                ),
              ),
              if (_currentFilters.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (_currentFilters.type != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(_currentFilters.type!),
                            onDeleted: () {
                              setState(() {
                                _currentFilters = JobFilters(
                                  search: _currentFilters.search,
                                  minSalary: _currentFilters.minSalary,
                                  maxSalary: _currentFilters.maxSalary,
                                  tags: _currentFilters.tags,
                                  location: _currentFilters.location,
                                );
                              });
                              _loadJobs();
                            },
                          ),
                        ),
                      if (_currentFilters.location != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            avatar: const Icon(Icons.location_on_outlined, size: 18),
                            label: Text(_currentFilters.location!),
                            onDeleted: () {
                              setState(() {
                                _currentFilters = JobFilters(
                                  search: _currentFilters.search,
                                  type: _currentFilters.type,
                                  minSalary: _currentFilters.minSalary,
                                  maxSalary: _currentFilters.maxSalary,
                                  tags: _currentFilters.tags,
                                );
                              });
                              _loadJobs();
                            },
                          ),
                        ),
                      if ((_currentFilters.minSalary != null && _currentFilters.minSalary != 0) || 
                          (_currentFilters.maxSalary != null && _currentFilters.maxSalary != 200))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(
                              '\$${_currentFilters.minSalary ?? 0}K - \$${_currentFilters.maxSalary ?? 200}K',
                            ),
                            onDeleted: () {
                              setState(() {
                                _currentFilters = JobFilters(
                                  search: _currentFilters.search,
                                  type: _currentFilters.type,
                                  tags: _currentFilters.tags,
                                  location: _currentFilters.location,
                                );
                              });
                              _loadJobs();
                            },
                          ),
                        ),
                      ..._currentFilters.tags.map(
                        (tag) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(tag),
                            onDeleted: () {
                              final newTags = List<String>.from(_currentFilters.tags)
                                ..remove(tag);
                              setState(() {
                                _currentFilters = JobFilters(
                                  search: _currentFilters.search,
                                  type: _currentFilters.type,
                                  minSalary: _currentFilters.minSalary,
                                  maxSalary: _currentFilters.maxSalary,
                                  tags: newTags,
                                  location: _currentFilters.location,
                                );
                              });
                              _loadJobs();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: 5, // Show 5 skeleton items
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              height: 160,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 16,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 16,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: List.generate(
                                      3,
                                      (index) => Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          height: 32,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : _jobs.isEmpty
                        ? const Center(
                            child: Text('No jobs found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _jobs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: JobCard(job: _jobs[index]),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
