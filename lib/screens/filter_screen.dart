import 'package:flutter/material.dart';
import '../models/job_filters.dart';
import '../services/job_service.dart';

class FilterScreen extends StatefulWidget {
  final JobFilters initialFilters;

  const FilterScreen({super.key, required this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final JobService _jobService = JobService();
  late String? _selectedType;
  late RangeValues _salaryRange;
  late List<String> _selectedTags;
  String? _selectedTown;
  Map<String, List<String>> _townsByRegion = {};
  List<String> _availableTypes = [];
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilters.type;
    _selectedTown = widget.initialFilters.location;
    _salaryRange = RangeValues(
      (widget.initialFilters.minSalary ?? 0).toDouble(),
      (widget.initialFilters.maxSalary ?? 200).toDouble(),
    );
    _selectedTags = List.from(widget.initialFilters.tags);
    _loadFilterOptions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    try {
      final types = await _jobService.getJobTypes();
      final tags = await _jobService.getTags();
      final towns = await _jobService.getTowns();
      setState(() {
        _availableTypes = types;
        _availableTags = tags;
        _townsByRegion = towns;
      });
    } catch (e) {
      print('Error loading filter options: $e');
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedTown = null;
      _salaryRange = const RangeValues(0, 200);
      _selectedTags = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Job Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableTypes.map((type) {
                final isSelected = type == _selectedType;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = selected ? type : null;
                      });
                    },
                  ),
                );
              }).toList(),
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedTown,
                hint: const Text('Select a town'),
                icon: const Icon(Icons.location_on_outlined),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All locations'),
                  ),
                  ..._townsByRegion.entries.expand((entry) => [
                        DropdownMenuItem(
                          enabled: false,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (town) => DropdownMenuItem(
                            value: town,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(town),
                            ),
                          ),
                        ),
                      ]),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTown = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Salary Range (K)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${_salaryRange.start.round()}K',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '\$${_salaryRange.end.round()}K',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              RangeSlider(
                values: _salaryRange,
                min: 0,
                max: 200,
                divisions: 20,
                activeColor: Theme.of(context).primaryColor,
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
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedTags.isNotEmpty)
                Text(
                  '${_selectedTags.length} selected',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
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
            onPressed: () {
              final filters = JobFilters(
                type: _selectedType,
                location: _selectedTown,
                minSalary: _salaryRange.start.round(),
                maxSalary: _salaryRange.end.round(),
                tags: _selectedTags,
              );
              Navigator.pop(context, filters);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Apply Filters'),
          ),
        ),
      ),
    );
  }
}
