import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class EducationalPage extends StatefulWidget {
  const EducationalPage({super.key});

  @override
  State<EducationalPage> createState() => _EducationalPageState();
}

class _EducationalPageState extends State<EducationalPage> {
  List<dynamic> _diseases = [];
  List<dynamic> _healthyPlants = [];
  List<dynamic> _filteredDiseases = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final Set<String> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    _loadDiseaseData();
    _selectedCategories.add('All Plants');
  }

  // Loads JSON file (Plant Disease Data) 
  // Stores the data in JSON (healthy vs diseased) into the list variables (_diseases & _healthyplants)
  Future<void> _loadDiseaseData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/plant_diseases.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      setState(() {
        _diseases = data['diseases'];
        _healthyPlants = data['healthy_plants'];
        _filteredDiseases = _diseases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading disease data: $e');
    }
  }

  void _filterDiseases(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters(query, _selectedCategories);
    });
  }

  void _applyFilters(String query, Set<String> categories) {
    List<dynamic> filtered = _diseases;

    // Category Filter
    if (categories.isNotEmpty && !categories.contains('All Plants')) {
      filtered = filtered.where((disease) {
        return categories.contains(disease['host_plant']);
      }).toList();
    }

    // Search Filter
    if (query.isNotEmpty) {
      filtered = filtered.where((disease) {
        return disease['name'].toLowerCase().contains(query.toLowerCase()) ||
            disease['host_plant'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredDiseases = filtered;
    });
  }

  void _showDiseaseDetails(Map<String, dynamic> disease) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DiseaseDetailModal(disease: disease),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 75, 180, 94),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Plantly',
              style: TextStyle(
                fontFamily: 'Concert One',
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/logo.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Educational Page',
              style: TextStyle(
                fontFamily: 'Concert One',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterDiseases,
              decoration: InputDecoration(
                hintText: 'Search diseases or plants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Plant Categories
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('All Plants', Icons.grass),
                _buildCategoryChip('Apple', Icons.apple),
                _buildCategoryChip('Corn', Icons.grass_outlined),
                _buildCategoryChip('Grape', Icons.wine_bar),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredDiseases.length,
              itemBuilder: (context, index) {
                final disease = _filteredDiseases[index];
                return DiseaseCard(
                  disease: disease,
                  onTap: () => _showDiseaseDetails(disease),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    String filterValue = label == 'All Plants' ? label : label;
    bool isSelected = _selectedCategories.contains(filterValue);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, 
              size: 16, 
              color: isSelected ? Colors.white : Colors.black87
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        selected: isSelected,
        selectedColor: const Color.fromARGB(255, 75, 180, 94),
        checkmarkColor: Colors.white,
        onSelected: (bool selected) {
          setState(() {
            if (label == 'All Plants') {
              if (selected) {
                _selectedCategories.clear();
                _selectedCategories.add(filterValue);
              } else {
                _selectedCategories.remove(filterValue);
              }
            } else {
              _selectedCategories.remove('All Plants');
              
              if (selected) {
                _selectedCategories.add(filterValue);
              } else {
                _selectedCategories.remove(filterValue);
              }
              
              if (_selectedCategories.isEmpty) {
                _selectedCategories.add('All Plants');
              }
            }
            
            _applyFilters(_searchQuery, _selectedCategories);
          });
        },
      ),
    );
  }
}

class DiseaseCard extends StatelessWidget {
  final Map<String, dynamic> disease;
  final VoidCallback onTap;

  const DiseaseCard({
    required this.disease,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section (matches the plant image name with the id <make sure they are the same or won't work>)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.asset(
                'assets/plant_images/${disease['id']}.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          disease['host_plant'],
                          style: TextStyle(
                            color: Colors.green[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(disease['severity_level']),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          disease['severity_level'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    disease['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    disease['scientific_name'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    disease['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red[400]!;
      case 'moderate':
        return Colors.orange[400]!;
      case 'low':
        return Colors.yellow[700]!;
      default:
        return Colors.grey[400]!;
    }
  }
}

class DiseaseDetailModal extends StatelessWidget {
  final Map<String, dynamic> disease;

  const DiseaseDetailModal({
    required this.disease,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disease['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    disease['scientific_name'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection('Description', disease['description']),
                  _buildListSection('Symptoms', disease['symptoms']),
                  _buildConditionsSection(disease['conditions']),
                  _buildListSection('Management Tips', disease['management_tips']),
                  _buildListSection('Prevention', disease['prevention']),
                  const SizedBox(height: 16),
                  _buildInfoRow('Severity Level', disease['severity_level']),
                  _buildInfoRow('Economic Impact', disease['economic_impact']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildConditionsSection(Map<String, dynamic> conditions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Favorable Conditions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: conditions.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        '${entry.key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}