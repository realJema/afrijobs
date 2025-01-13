import 'package:flutter/material.dart';
import '../models/job_filters.dart';
import '../services/job_service.dart';

class FilterScreen extends StatefulWidget {
  final JobFilters initialFilters;
  final Map<String, List<String>> townsByRegion;
  final List<String> jobTypes;
  final List<String> availableTags;

  const FilterScreen({
    super.key,
    required this.initialFilters,
    required this.townsByRegion,
    required this.jobTypes,
    required this.availableTags,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final JobService _jobService = JobService();
  String? _selectedType;
  String? _selectedTown;
  String? _selectedRegion;
  String? _selectedDateRange;
  List<String> _selectedTags = [];
  RangeValues _salaryRange = const RangeValues(0, 200);
  RangeValues _applicantsRange = const RangeValues(0, 100);
  bool _isLoading = false;

  final List<String> _dateRanges = [
    'Last 24 hours',
    'Last week',
    'Last 30 days',
    'All time',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilters.type;
    _selectedTown = widget.initialFilters.town;
    _selectedRegion = widget.initialFilters.region;
    _selectedTags = List.from(widget.initialFilters.tags);
    _salaryRange = RangeValues(
      double.tryParse(widget.initialFilters.minSalary ?? '0') ?? 0,
      double.tryParse(widget.initialFilters.maxSalary ?? '200') ?? 200,
    );
  }

  void _onRegionChanged(String? region) {
    setState(() {
      _selectedRegion = region;
      // Reset town if region changes
      if (_selectedTown != null && !widget.townsByRegion[region]!.contains(_selectedTown)) {
        _selectedTown = null;
      }
    });
  }

  void _applyFilters() {
    final filters = JobFilters(
      type: _selectedType,
      town: _selectedTown,
      region: _selectedRegion,
      tags: _selectedTags,
      minSalary: _salaryRange.start.toStringAsFixed(0),
      maxSalary: _salaryRange.end.toStringAsFixed(0),
      dateRange: _selectedDateRange,
      minApplicants: _applicantsRange.start.round().toString(),
      maxApplicants: _applicantsRange.end.round().toString(),
    );
    Navigator.pop(context, filters);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Jobs'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedTown = null;
                _selectedRegion = null;
                _selectedDateRange = null;
                _selectedTags = [];
                _salaryRange = const RangeValues(0, 200);
                _applicantsRange = const RangeValues(0, 100);
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Date Range Filter
                _buildSectionTitle('Date Posted'),
                DropdownButtonFormField<String>(
                  value: _selectedDateRange,
                  decoration: const InputDecoration(
                    hintText: 'Select time range',
                    border: OutlineInputBorder(),
                  ),
                  items: _dateRanges
                      .map((range) => DropdownMenuItem(
                            value: range,
                            child: Text(range),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDateRange = value;
                    });
                  },
                ),

                // Job Type Filter
                _buildSectionTitle('Job Type'),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    hintText: 'Select job type',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.jobTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),

                // Location Filter
                _buildSectionTitle('Location'),
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(
                    hintText: 'Select region',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.townsByRegion.keys
                      .map((region) => DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          ))
                      .toList(),
                  onChanged: _onRegionChanged,
                ),
                if (_selectedRegion != null) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedTown,
                    decoration: const InputDecoration(
                      hintText: 'Select town',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.townsByRegion[_selectedRegion]!
                        .map((town) => DropdownMenuItem(
                              value: town,
                              child: Text(town),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTown = value;
                      });
                    },
                  ),
                ],

                // Salary Range Filter
                _buildSectionTitle('Salary Range (in thousands)'),
                RangeSlider(
                  values: _salaryRange,
                  min: 0,
                  max: 200,
                  divisions: 20,
                  labels: RangeLabels(
                    '\$${_salaryRange.start.round()}K',
                    '\$${_salaryRange.end.round()}K',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _salaryRange = values;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${_salaryRange.start.round()}K',
                          style: TextStyle(color: Colors.grey[600])),
                      Text('\$${_salaryRange.end.round()}K',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),

                // Applicants Range Filter
                _buildSectionTitle('Number of Applicants'),
                RangeSlider(
                  values: _applicantsRange,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  labels: RangeLabels(
                    '${_applicantsRange.start.round()}',
                    '${_applicantsRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _applicantsRange = values;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_applicantsRange.start.round()}',
                          style: TextStyle(color: Colors.grey[600])),
                      Text('${_applicantsRange.end.round()}',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),

                // Skills/Tags Filter
                _buildSectionTitle('Skills'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D4A3E),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Apply Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
