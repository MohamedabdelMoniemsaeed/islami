import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/duas_model.dart';

class DuasScreen extends StatefulWidget {
  static const String routeName = '/duas';
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  final ApiService _apiService = ApiService();
  late Future<DuasResponse> _duasFuture;

  @override
  void initState() {
    super.initState();
    _duasFuture = _apiService.getDuas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأدعية المستجابة')),
      body: FutureBuilder<DuasResponse>(
        future: _duasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.duas.isEmpty) {
            return const Center(child: Text('لا توجد أدعية متاحة حالياً'));
          }

          final duas = snapshot.data!.duas;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: duas.length,
            itemBuilder: (context, index) {
              final dua = duas[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dua.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE2BE7F), fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dua.content,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
