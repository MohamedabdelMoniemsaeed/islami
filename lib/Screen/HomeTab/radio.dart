import 'package:flutter/material.dart';
import 'package:islami/models/radio_model.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/images.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

class RadioTab extends StatefulWidget {
  const RadioTab({super.key});

  @override
  State<RadioTab> createState() => _RadioTabState();
}

class _RadioTabState extends State<RadioTab> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();
  List<RadioItem> _radios = [];
  bool _isLoadingRadio = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAudioSession();
    _loadRadios();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> _loadRadios() async {
    try {
      final response = await _apiService.getRadios();
      if (mounted) {
        setState(() {
          _radios = response.radios;
          _isLoadingRadio = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading radios: $e");
      if (mounted) setState(() => _isLoadingRadio = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause(RadioItem radio) async {
    try {
      if (_audioPlayer.playing && _audioPlayer.audioSource != null) {
        final currentSource = _audioPlayer.audioSource;
        if (currentSource is UriAudioSource && currentSource.uri.toString() == radio.url) {
          await _audioPlayer.pause();
          return;
        }
      }

      _showInfo("جاري الاتصال بالبث المباشر...");

      // محاولة التشغيل مع وبدون MediaItem لضمان العمل
      try {
        final audioSource = AudioSource.uri(
          Uri.parse(radio.url),
          tag: MediaItem(
            id: radio.id.toString(),
            album: "إذاعة القرآن الكريم",
            title: radio.name,
            artUri: Uri.parse("https://quran.yousefheiba.com/assets/images/radio.png"),
          ),
        );
        await _audioPlayer.setAudioSource(audioSource);
      } catch (e) {
        // إذا فشل نظام الخلفية، نشغل الرابط بشكل عادي
        await _audioPlayer.setUrl(radio.url);
      }
      
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Radio Play Error: $e");
      _showError("تعذر تشغيل الإذاعة حالياً. تأكد من اتصالك بالإنترنت.");
    }
  }

  void _showInfo(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    return Column(
      children: [
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.yellow, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(AppImage.radioPage),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          "إذاعة القرآن الكريم",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: provider.isDarkMode() ? AppColors.blackDark : AppColors.yellow,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _isLoadingRadio
              ? const Center(child: CircularProgressIndicator(color: AppColors.yellow))
              : _radios.isEmpty
                  ? Center(
                      child: Text(
                        "لا توجد إذاعات متاحة حالياً",
                        style: TextStyle(color: provider.isDarkMode() ? Colors.white : Colors.black),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _radios.length,
                      itemBuilder: (context, index) {
                        final radio = _radios[index];
                        return StreamBuilder<PlayerState>(
                          stream: _audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final isThisPlaying = playerState?.playing ?? false;
                            final isCurrent = _audioPlayer.audioSource != null && 
                                             (_audioPlayer.audioSource as UriAudioSource).uri.toString() == radio.url;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: provider.isDarkMode() 
                                    ? AppColors.yellowDark.withOpacity(0.8) 
                                    : Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: (isCurrent && isThisPlaying) ? AppColors.yellow : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  radio.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: provider.isDarkMode() ? Colors.white : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    (isCurrent && isThisPlaying) ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                    color: AppColors.yellow,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    setState(() => _currentIndex = index);
                                    _playPause(radio);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}


