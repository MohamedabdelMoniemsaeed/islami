import 'package:flutter/material.dart';
import 'package:islami/models/radio_model.dart';
import 'package:islami/models/tafsir_model.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/sura_name.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

class RadioTab extends StatefulWidget {
  const RadioTab({super.key});

  @override
  State<RadioTab> createState() => _RadioTabState();
}

class _RadioTabState extends State<RadioTab> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();
  bool _isPlaying = false;
  RadioItem? _quranRadio;
  bool _isLoadingRadio = true;

  @override
  void initState() {
    super.initState();
    _loadQuranRadio();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    // تفعيل وضع الخلفية
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> _loadQuranRadio() async {
    try {
      final response = await _apiService.getRadios();
      if (response.radios.isNotEmpty) {
        _quranRadio = response.radios.firstWhere(
          (e) => e.name.contains("القاهرة"),
          orElse: () => response.radios.first,
        );
      }
    } catch (e) {
      debugPrint("Error loading radio: $e");
    } finally {
      if (mounted) setState(() => _isLoadingRadio = false);
    }
  }

  @override
  void dispose() {
    // لا نغلق الراديو هنا ليبقى يعمل في الخلفية إذا كان المستخدم يريد ذلك
    // لكن نحتاج للتأكد من عدم تسريب الذاكرة
    super.dispose();
  }

  Future<void> _playPause() async {
    if (_quranRadio == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(_quranRadio!.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    return Column(
      children: [
        // قسم الراديو (الجزء العلوي الثابت)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: provider.isDarkMode() ? AppColors.yellowDark : Colors.white,
            border: const Border(bottom: BorderSide(color: AppColors.yellow, width: 2)),
          ),
          child: Column(
            children: [
              Image.asset(AppImage.radioPage, height: 120),
              const SizedBox(height: 10),
              if (_isLoadingRadio)
                const CircularProgressIndicator(color: AppColors.yellow)
              else if (_quranRadio != null) ...[
                Text(
                  _quranRadio!.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _playPause,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  ),
                  icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                  label: Text(_isPlaying ? "إيقاف" : "تشغيل"),
                ),
              ]
            ],
          ),
        ),

        // قسم التفسير (القائمة السفلية)
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "التفسير الميسر",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.yellow),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: SuraName.listSuraName.length,
                  separatorBuilder: (context, index) => const Divider(color: AppColors.yellow, thickness: 0.5),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        SuraName.listSuraName[index],
                        style: TextStyle(color: provider.isDarkMode() ? Colors.white : Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () => _showTafsirDialog(context, index + 1, SuraName.listSuraName[index], provider.isDarkMode()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTafsirDialog(BuildContext context, int suraNumber, String suraName, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.yellowDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text("تفسير سورة $suraName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.yellow)),
              const Divider(color: AppColors.yellow),
              Expanded(
                child: FutureBuilder<TafsirResponse>(
                  future: _apiService.getTafsir(suraNumber),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("خطأ في تحميل التفسير"));
                    }
                    final tafsirList = snapshot.data!.result;
                    return ListView.builder(
                      itemCount: tafsirList.length,
                      itemBuilder: (context, index) {
                        final item = tafsirList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text("الآية (${item.aya})", style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                              Text(item.arabicText, style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : Colors.black87), textDirection: TextDirection.rtl),
                              Text(item.translation, style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black54), textDirection: TextDirection.rtl),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
