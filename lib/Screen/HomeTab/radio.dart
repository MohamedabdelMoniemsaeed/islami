import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:islami/models/radio_model.dart';
import 'package:islami/services/cache_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:islami/dezeen/shiar.dart';

class RadioTab extends StatefulWidget {
  const RadioTab({super.key});

  @override
  State<RadioTab> createState() => _RadioTabState();
}

class _RadioTabState extends State<RadioTab> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final CacheService _cacheService = CacheService();
  Set<int> _favoriteIds = {};

  // قائمة الإذاعات الإسلامية بث مباشر (https فقط لكي تعمل على iOS/Android)
  static const List<RadioItem> _islamicRadios = [
    RadioItem(id: 1, name: 'إذاعة القرآن الكريم من القاهرة', url: 'https://quran.yousefheiba.com/api/radio'),
    RadioItem(id: 2, name: 'إذاعة القرآن الكريم – القاهرة (بديل)', url: 'https://radio.xecod.com/station/quran-cairo'),
    RadioItem(id: 3, name: 'إذاعة القرآن الكريم – الشارقة', url: 'https://l3.itworkscdn.net/smcquranlive/quranradiolive/icecast.audio'),
    RadioItem(id: 4, name: 'إذاعة القرآن الكريم – البحرين', url: 'https://5c7b683162943.streamlock.net/live/ngrp:radio-106-1_all/playlist.m3u8'),
    RadioItem(id: 5, name: 'إذاعة القرآن الكريم – عُمَان', url: 'https://partwota.cdn.mgmlcdn.com/quranrdoorg/quranrdo.stream_aac/chunklist.m3u8'),
    RadioItem(id: 6, name: 'إذاعة القرآن الكريم – الأردن', url: 'https://jrtv-live.ercdn.net/jrradio/quranradio.m3u8'),
    RadioItem(id: 7, name: 'راديو القرآن – مشاري راشد العفاسي', url: 'https://radio.mp3islam.com/listen/mishary/radio.mp3'),
    RadioItem(id: 8, name: 'راديو القرآن – عبد الباسط عبد الصمد', url: 'https://radio.mp3islam.com/listen/abdulbasit/radio.mp3'),
    RadioItem(id: 9, name: 'راديو القرآن – سعود الشريم', url: 'https://radio.mp3islam.com/listen/alshuraim/radio.mp3'),
    RadioItem(id: 10, name: 'إذاعة القرآن الكريم – الكويت', url: 'https://radio.mp3islam.com/listen/quran_radio/radio.mp3'),
    RadioItem(id: 11, name: 'إذاعة القرآن الكريم – مصر', url: 'https://stream.radiojar.com/8s5u5tpdtwzuv'),
    RadioItem(id: 12, name: 'إذاعة القرآن الكريم – مختارات (Mp3Quran)', url: 'https://qurango.net/radio/mix'),
  ];

  @override
  void initState() {
    super.initState();
    _initAudioSession();
    _loadFavorites();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> _loadFavorites() async {
    final data = await _cacheService.getData(CacheService.keyRadioFavorites);
    if (data == null) return;
    try {
      final ids = json.decode(data);
      if (ids is List && mounted) {
        setState(() => _favoriteIds = ids.whereType<int>().toSet());
      }
    } catch (_) {
      // بيانات تالفة في الكاش: إعادة تعيين المفضلة
      if (mounted) setState(() => _favoriteIds = {});
    }
  }

  Future<void> _toggleFavorite(RadioItem radio) async {
    final isFav = _favoriteIds.contains(radio.id);
    setState(() {
      if (isFav) {
        _favoriteIds.remove(radio.id);
      } else {
        _favoriteIds.add(radio.id);
      }
    });
    await _cacheService.saveData(CacheService.keyRadioFavorites, json.encode(_favoriteIds.toList()));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause(RadioItem radio) async {
    if (!radio.url.startsWith('https://')) {
      _showError("رابط الإذاعة غير صالح");
      return;
    }
    try {
      if (_audioPlayer.playing && _audioPlayer.audioSource != null) {
        final currentSource = _audioPlayer.audioSource;
        if (currentSource is UriAudioSource && currentSource.uri.toString() == radio.url) {
          await _audioPlayer.pause();
          return;
        }
      }

      _showInfo("جاري الاتصال بالبث المباشر...");

      try {
        final audioSource = AudioSource.uri(
          Uri.parse(radio.url),
          tag: MediaItem(
            id: radio.id.toString(),
            album: radio.name,
            title: radio.name,
            artUri: Uri.parse("https://quran.yousefheiba.com/assets/images/radio.png"),
          ),
        );
        await _audioPlayer.setAudioSource(audioSource);
      } catch (e) {
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

  Widget _sectionHeader(String text, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: provider.isDarkMode() ? AppColors.blackDark : AppColors.yellow,
        ),
      ),
    );
  }

  Widget _radioTile(RadioItem radio, AppProvider provider) {
    final isFavorite = _favoriteIds.contains(radio.id);
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isThisPlaying = playerState?.playing ?? false;
        final isCurrent = _audioPlayer.audioSource != null &&
                         _audioPlayer.audioSource is UriAudioSource &&
                         (_audioPlayer.audioSource as UriAudioSource).uri.toString() == radio.url;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: provider.isDarkMode()
                ? AppColors.yellowDark.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: (isCurrent && isThisPlaying) ? AppColors.yellow : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            leading: IconButton(
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppColors.yellow,
                size: 30,
              ),
              onPressed: () => _toggleFavorite(radio),
            ),
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
                _playPause(radio);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    // المفضلة تظهر أول القائمة، ثم باقي الإذاعات
    final favorites = _islamicRadios.where((r) => _favoriteIds.contains(r.id)).toList();
    final others = _islamicRadios.where((r) => !_favoriteIds.contains(r.id)).toList();

    final tiles = <Widget>[];
    if (favorites.isNotEmpty) {
      tiles.add(_sectionHeader("المفضلة", provider));
      tiles.addAll(favorites.map((r) => _radioTile(r, provider)));
      if (others.isNotEmpty) {
        tiles.add(_sectionHeader("كل الإذاعات", provider));
      }
    }
    tiles.addAll(others.map((r) => _radioTile(r, provider)));

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
                  color: AppColors.yellow.withValues(alpha: 0.3),
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: tiles.length,
            itemBuilder: (context, index) => tiles[index],
          ),
        ),
      ],
    );
  }
}
