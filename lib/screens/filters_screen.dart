import 'package:flutter/material.dart';
import '../models/job_filters.dart';
import '../services/filter_service.dart';
import '../widgets/filter_skeleton.dart';

class FiltersScreen extends StatefulWidget {
  final JobFilters initialFilters;
  final Function(JobFilters) onApplyFilters;

  const FiltersScreen({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
  });

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late JobFilters _filters;
  final FilterService _filterService = FilterService.instance;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filters = JobFilters();
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
      body: !_filterService.isInitialized
          ? const FilterSkeleton()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: DropdownButtonFormField<String>(
                        value: _filters.type,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          hintText: 'Select job type',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All job types'),
                          ),
                          ..._filterService.jobTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filters = _filters.copyWith(type: value);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: DropdownButtonFormField<String>(
                        value: _filters.town,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          hintText: 'Select location',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All locations'),
                          ),
                          ..._filterService.towns.map((town) {
                            return DropdownMenuItem(
                              value: town,
                              child: Text(town),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filters = _filters.copyWith(town: value);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Skills & Technologies',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filterService.tags.map((tag) {
                        final isSelected = _filters.tags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              final newTags = List<String>.from(_filters.tags);
                              if (selected) {
                                newTags.add(tag);
                              } else {
                                newTags.remove(tag);
                              }
                              _filters = _filters.copyWith(tags: newTags);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            widget.onApplyFilters(_filters);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Apply Filters'),
        ),
      ),
    );
  }
}
