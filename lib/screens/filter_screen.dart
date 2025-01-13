import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_filters.dart';
import '../services/job_service.dart';
import '../providers/filter_provider.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? _selectedType;
  String? _selectedTown;
  String? _selectedRegion;
  String? _selectedDateRange;
  List<String> _selectedTags = [];
  RangeValues _salaryRange = const RangeValues(0, 200);
  RangeValues _applicantsRange = const RangeValues(0, 100);

  final List<String> _dateRanges = [
    'Last 24 hours',
    'Last week',
    'Last 30 days',
    'All time',
  ];

  @override
  void initState() {
    super.initState();
    final currentFilters = context.read<FilterProvider>().filters;
    _selectedType = currentFilters.type;
    _selectedTown = currentFilters.town;
    _selectedRegion = currentFilters.region;
    _selectedTags = List.from(currentFilters.tags);
    _salaryRange = RangeValues(
      double.tryParse(currentFilters.minSalary ?? '0') ?? 0,
      double.tryParse(currentFilters.maxSalary ?? '200') ?? 200,
    );
  }

  void _updateFilters() {
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
    context.read<FilterProvider>().updateFilters(filters);
  }

  void _onRegionChanged(String? region) {
    setState(() {
      _selectedRegion = region;
      // Reset town if region changes
      if (_selectedTown != null && !context.read<FilterProvider>().townsByRegion[region]!.contains(_selectedTown)) {
        _selectedTown = null;
      }
    });
    _updateFilters();
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
    final filterProvider = context.watch<FilterProvider>();
    final townsByRegion = filterProvider.townsByRegion;
    final jobTypes = filterProvider.jobTypes;
    final availableTags = filterProvider.availableTags;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Jobs'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<FilterProvider>().clearAllFilters();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date Range Filter
          _buildSectionTitle('Date Posted'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dateRanges.map((range) {
              final isSelected = _selectedDateRange == range;
              return FilterChip(
                label: Text(range),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedDateRange = selected ? range : null;
                  });
                  _updateFilters();
                },
              );
            }).toList(),
          ),

          // Job Type Filter
          _buildSectionTitle('Job Type'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: jobTypes.map((type) {
              final isSelected = _selectedType == type;
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                  });
                  _updateFilters();
                },
              );
            }).toList(),
          ),

          // Location Filter
          _buildSectionTitle('Location'),
          DropdownButtonFormField<String>(
            value: _selectedRegion,
            decoration: const InputDecoration(
              hintText: 'Select region',
              border: OutlineInputBorder(),
            ),
            items: townsByRegion.keys
                .map((region) => DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    ))
                .toList(),
            onChanged: _onRegionChanged,
          ),
          if (_selectedRegion != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: townsByRegion[_selectedRegion]!.map((town) {
                final isSelected = _selectedTown == town;
                return FilterChip(
                  label: Text(town),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTown = selected ? town : null;
                    });
                    _updateFilters();
                  },
                );
              }).toList(),
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
              _updateFilters();
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
              _updateFilters();
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
            children: availableTags.map((tag) {
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
                  _updateFilters();
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
            onPressed: () {
              Navigator.pop(context);
            },
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
