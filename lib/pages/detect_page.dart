import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class DetectPage extends StatefulWidget {
  const DetectPage({super.key});

  @override
  _DetectPageState createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  File? filetPath;
  String label = "";
  double confidence = 0.0;
  Map<String, dynamic>? diseaseInfo;
  List<dynamic> _diseases = [];
  List<dynamic> _healthyPlants = [];

  @override
  void initState() {
    super.initState();
    _initializeTFLite();
    _loadDiseaseData();
  }

  Future<void> _initializeTFLite() async {
    await Tflite.loadModel(
      model: "assets/plant_models_40epoch.tflite",
      labels: "assets/label.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> _loadDiseaseData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/plant_diseases.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      setState(() {
        _diseases = data['diseases'];
        _healthyPlants = data['healthy_plants'];
      });
    } catch (e) {
      debugPrint('Error loading disease data: $e');
    }
  }

  void _findDiseaseInfo(String label) {
    try {
      diseaseInfo = _diseases.firstWhere(
        (disease) => disease['id'] == label,
        orElse: () => null,
      );

      if (diseaseInfo == null) {
        diseaseInfo = _healthyPlants.firstWhere(
          (plant) => plant['id'] == label,
          orElse: () => null,
        );

        if (diseaseInfo != null) {
          diseaseInfo!['description'] = "This plant appears to be healthy and is identified as ${diseaseInfo!['name']}.";
          diseaseInfo!['severity_level'] = "None";
        } else {
          diseaseInfo = {
            'name': 'Unknown Plant',
            'description': 'The plant could not be identified.',
            'severity_level': 'Unknown'
          };
        }
      }
    } catch (e) {
      debugPrint('Error finding disease info: $e');
      diseaseInfo = {
        'name': 'Unknown Plant',
        'description': 'An error occurred while identifying the plant.',
        'severity_level': 'Unknown'
      };
    }
  }

  Future<void> processImage(String imagePath) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      imageMean: 0.0,
      imageStd: 1.0,
      numResults: 5,
      threshold: 0.2,
      asynch: true,
    );

    if (recognitions == null || recognitions.isEmpty) {
      debugPrint("Recognition output is null or empty");
      setState(() {
        label = "Unknown";
        confidence = 0.0;
        diseaseInfo = null;
      });
      return;
    }

    setState(() {
      confidence = recognitions[0]['confidence'] * 100;
      label = recognitions[0]['label'];
      _findDiseaseInfo(label);
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    setState(() {
      filetPath = File(image.path);
    });
    await processImage(image.path);
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

  @override
  Widget build(BuildContext context) {
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
              'Detect Page',
              style: TextStyle(
                fontFamily: 'Concert One',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.grey[100],
                        child: filetPath == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Upload a Plant Image',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildActionButton(
                                        icon: Icons.camera_alt,
                                        label: 'Camera',
                                        onPressed: () => pickImage(ImageSource.camera),
                                      ),
                                      const SizedBox(width: 16),
                                      _buildActionButton(
                                        icon: Icons.photo_library,
                                        label: 'Gallery',
                                        onPressed: () => pickImage(ImageSource.gallery),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  Image.file(
                                    filetPath!,
                                    width: double.infinity,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    right: 16,
                                    child: FloatingActionButton(
                                      mini: true,
                                      onPressed: () => pickImage(ImageSource.gallery),
                                      backgroundColor: Colors.white,
                                      child: const Icon(Icons.refresh, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (label.isNotEmpty && diseaseInfo != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
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
                                    diseaseInfo!['host_plant'] ?? 'Healthy Plant',
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
                                    color: _getSeverityColor(
                                      diseaseInfo!['severity_level'] ?? 'unknown',
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${confidence.toStringAsFixed(1)}% Confident',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              diseaseInfo!['name'] ?? 'Healthy Plant',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (diseaseInfo!['severity_level'] != "None") ...[
                              const SizedBox(height: 8),
                              Text(
                                diseaseInfo!['description'] ?? 'No description available',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _showDetailedDiseaseInfo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 75, 180, 94),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Learn More',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 75, 180, 94),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }

  void _showDetailedDiseaseInfo() {
    if (diseaseInfo == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                      diseaseInfo!['name'] ?? 'Unknown Disease',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (diseaseInfo!['scientific_name'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        diseaseInfo!['scientific_name'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildSection('Description', diseaseInfo!['description'] ?? ''),
                    if (diseaseInfo!['symptoms'] != null)
                      _buildListSection('Symptoms', diseaseInfo!['symptoms']),
                    if (diseaseInfo!['conditions'] != null)
                      _buildConditionsSection(diseaseInfo!['conditions']),
                    if (diseaseInfo!['management_tips'] != null)
                      _buildListSection('Management Tips', diseaseInfo!['management_tips']),
                    if (diseaseInfo!['prevention'] != null)
                      _buildListSection('Prevention', diseaseInfo!['prevention']),
                    const SizedBox(height: 16),
                    _buildInfoRow('Severity Level', diseaseInfo!['severity_level'] ?? 'Unknown'),
                    _buildInfoRow('Economic Impact', diseaseInfo!['economic_impact'] ?? 'Unknown'),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
