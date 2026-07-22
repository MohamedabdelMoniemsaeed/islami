import 'package:flutter/material.dart';
import 'package:islami/models/radio_model.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/images.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuranRadio();
  }

  Future<void> _loadQuranRadio() async {
    try {
      final response = await _apiService.getRadios();
      // البحث عن إذاعة القرآن الكريم من القاهرة تحديداً أو أول إذاعة تحمل الاسم
      _quranRadio = response.radios.firstWhere(
        (element) => element.name.contains("القاهرة") || element.name.contains("القرآن الكريم"),
        orElse: () => response.radios.first,
      );
    } catch (e) {
      debugPrint("Error loading radio: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (_quranRadio == null) return;
    
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(_quranRadio!.url));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
    }

    if (_quranRadio == null) {
      return const Center(child: Text("تعذر تحميل الإذاعة"));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Image.asset(AppImage.icRadio, width: 300),
        const SizedBox(height: 40),
        Text(
          _quranRadio!.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 50),
        Center(
          child: IconButton(
            onPressed: _playPause,
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 100,
              color: provider.isDarkMode() ? AppColors.blackDark : AppColors.yellow,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
