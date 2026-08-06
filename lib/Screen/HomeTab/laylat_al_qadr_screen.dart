import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class LaylatAlQadrScreen extends StatefulWidget {
  static const String routeName = "LaylatAlQadr";
  const LaylatAlQadrScreen({super.key});

  @override
  State<LaylatAlQadrScreen> createState() => _LaylatAlQadrScreenState();
}

class _LaylatAlQadrScreenState extends State<LaylatAlQadrScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("فضل ليلة القدر"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _apiService.getLaylatAlQadr(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
          }
          if (snapshot.hasError) {
            return const Center(child: Text("خطأ في تحميل البيانات"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("لا توجد بيانات متاحة"));
          }

          final data = snapshot.data!;
          // نفترض أن الـ API يرجع حقول مثل title و content أو description
          String content = data['content'] ?? data['description'] ?? "لا توجد تفاصيل";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/quran.png', // أو أي أيقونة مناسبة
                    height: 120,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: provider.isDarkMode() ? AppColors.yellowDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.yellow.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Text(
                    content,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 19,
                      height: 1.8,
                      color: provider.isDarkMode() ? Colors.white : Colors.black87,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
