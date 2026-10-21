import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';

class LaylatAlQadrScreen extends StatefulWidget {
  static const String routeName = '/laylat-al-qadr';
  const LaylatAlQadrScreen({super.key});

  @override
  State<LaylatAlQadrScreen> createState() => _LaylatAlQadrScreenState();
}

class _LaylatAlQadrScreenState extends State<LaylatAlQadrScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _apiService.getLaylatAlQadr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ليلة القدر')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? {};
          final title = data['title'] ?? 'ليلة القدر';
          final desc = data['description'] ?? 'خير من ألف شهر';

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.nightlight_round, size: 80, color: Color(0xFFE2BE7F)),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE2BE7F)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 18, height: 1.6),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
