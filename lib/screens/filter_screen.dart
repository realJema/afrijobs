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
  String? _selectedType;
  String? _selectedTown;
  String? _selectedRegion;
  List<String> _selectedTags = [];
  RangeValues _salaryRange = const RangeValues(0, 200);
  Map<String, List<String>> _townsByRegion = {};
  bool _isLoading = true;

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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final towns = await _jobService.getTowns();
      setState(() {
        _townsByRegion = towns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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
                _selectedTags = [];
                _salaryRange = const RangeValues(0, 200);
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
                const Text(
                  'Job Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    hintText: 'Select job type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                    DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                    DropdownMenuItem(value: 'Contract', child: Text('Contract')),
                    DropdownMenuItem(value: 'Internship', child: Text('Internship')),
                    DropdownMenuItem(value: 'Freelance', child: Text('Freelance')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
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
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(
                    hintText: 'Select region',
                    border: OutlineInputBorder(),
                  ),
                  items: _townsByRegion.keys
                      .map((region) => DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value;
                      _selectedTown = null;
                    });
                  },
                ),
                if (_selectedRegion != null) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedTown,
                    decoration: const InputDecoration(
                      hintText: 'Select town',
                      border: OutlineInputBorder(),
                    ),
                    items: _townsByRegion[_selectedRegion]!
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
                const SizedBox(height: 24),
                const Text(
                  'Salary Range (in thousands)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
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
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                JobFilters(
                  type: _selectedType,
                  town: _selectedTown,
                  region: _selectedRegion,
                  tags: _selectedTags,
                  minSalary: _salaryRange.start.round().toString(),
                  maxSalary: _salaryRange.end.round().toString(),
                ),
              );
            },
            child: const Text('Apply Filters'),
          ),
        ),
      ),
    );
  }
}
