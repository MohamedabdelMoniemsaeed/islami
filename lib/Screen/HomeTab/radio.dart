import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:islami/models/radio_model.dart';
import 'package:islami/services/cache_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';
import 'package:provider/provider.dart';
import 'package:islami/dezeen/shiar.dart';

class RadioTab extends StatefulWidget {
  const RadioTab({super.key});

  @override
  State<RadioTab> createState() => _RadioTabState();
}

class _RadioTabState extends State<RadioTab> {
  final CacheService _cacheService = CacheService();
  Set<int> _favoriteIds = {};

  // قائمة الإذاعات الإسلامية بث مباشر (HTTPS ومجربة عبر شبكة Mp3Quran و Mp3Islam الرسمية)
  static const List<RadioItem> _islamicRadios = [
    RadioItem(id: 1, name: 'إذاعة القرآن الكريم من القاهرة', url: 'https://stream.radiojar.com/8s5u5tpdtwzuv'),
    RadioItem(id: 2, name: 'راديو القرآن – محمد صديق المنشاوي', url: 'https://qurango.net/radio/mohammed_siddiq_alminshawi'),
    RadioItem(id: 3, name: 'إذاعة القرآن الكريم – مختارات تلاوات', url: 'https://qurango.net/radio/mix'),
    RadioItem(id: 4, name: 'إذاعة تراتيل قصار السور', url: 'https://qurango.net/radio/tarateel'),
    RadioItem(id: 5, name: 'راديو القرآن – عبد الباسط عبد الصمد (المجود)', url: 'https://qurango.net/radio/abdulbasit_abdulsamad_mojawwad'),
    RadioItem(id: 6, name: 'راديو القرآن – محمود خليل الحصري', url: 'https://qurango.net/radio/mahmoud_khalil_alhussary'),
    RadioItem(id: 7, name: 'راديو القرآن – محمد محمود الطبلاوي', url: 'https://qurango.net/radio/mohammad_altablaway'),
    RadioItem(id: 8, name: 'راديو القرآن – مشاري راشد العفاسي', url: 'https://radio.mp3islam.com/listen/mishary/radio.mp3'),
    RadioItem(id: 9, name: 'راديو القرآن – سعود الشريم', url: 'https://radio.mp3islam.com/listen/alshuraim/radio.mp3'),
    RadioItem(id: 10, name: 'إذاعة القرآن الكريم – الشارقة', url: 'https://l3.itworkscdn.net/smcquranlive/quranradiolive/icecast.audio'),
    RadioItem(id: 11, name: 'إذاعة القرآن الكريم – الكويت', url: 'https://radio.mp3islam.com/listen/quran_radio/radio.mp3'),
    RadioItem(id: 12, name: 'إذاعة القرآن الكريم – البحرين', url: 'https://5c7b683162943.streamlock.net/live/ngrp:radio-106-1_all/playlist.m3u8'),
    RadioItem(id: 13, name: 'إذاعة القرآن الكريم – عُمَان', url: 'https://partwota.cdn.mgmlcdn.com/quranrdoorg/quranrdo.stream_aac/chunklist.m3u8'),
    RadioItem(id: 14, name: 'إذاعة القرآن الكريم – الأردن', url: 'https://jrtv-live.ercdn.net/jrradio/quranradio.m3u8'),
    RadioItem(id: 15, name: 'إذاعة القرآن الكريم من مكة المكرمة', url: 'https://l3.itworkscdn.net/smcquranlive/quranradiolive/icecast.audio'),
    RadioItem(id: 16, name: 'إذاعة القرآن الكريم من المدينة المنورة', url: 'https://l3.itworkscdn.net/smcquranlive/quranradiolive/radio.mp3'),
    RadioItem(id: 17, name: 'إذاعة القرآن الكريم – تلاوات مختارة (القاهرة)', url: 'https://l3.itworkscdn.net/smcquranlive/quranradiolive/tilawah.mp3'),
    RadioItem(id: 18, name: 'إذاعة القرآن الكريم – تجويد (القاهرة)', url: 'https://l3.itworkscdn.net/smcquranlive/quranradiolive/tajweed.mp3'),
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
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

  Future<void> _playPause(RadioItem radio, AppProvider provider) async {
    if (!radio.url.startsWith('https://')) {
      _showError("رابط الإذاعة غير صالح");
      return;
    }
    final isPlayingSame = provider.isRadioPlaying && provider.currentRadioUrl == radio.url && provider.audioPlayer.playing;

    if (isPlayingSame) {
      await provider.pauseTrack();
      return;
    }

    if (provider.audioPlayer.playing) {
      // أي صوت آخر (تلاوة إلخ) → نوقفه ونبدأ الإذاعة
      await provider.stopTrack();
    }

    _showInfo("جاري الاتصال بالبث المباشر...");
    await provider.playRadio(radio.url, radio.name);
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
    final isCurrent = provider.isRadioPlaying && provider.currentRadioUrl == radio.url;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: provider.isDarkMode()
            ? AppColors.yellowDark.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: (isCurrent && provider.audioPlayer.playing) ? AppColors.yellow : Colors.transparent,
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
            (isCurrent && provider.audioPlayer.playing) ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: AppColors.yellow,
            size: 40,
          ),
          onPressed: () => _playPause(radio, provider),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

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
