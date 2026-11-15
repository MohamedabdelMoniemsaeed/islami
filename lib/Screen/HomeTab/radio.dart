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

  // بث مباشر مباشر من سيرفرات Holol — صيغ HLS (m3u8) تعمل بدون تحويل
  static const List<RadioItem> _islamicRadios = [
    RadioItem(id: 1, name: 'إذاعة أبو بكر الشاطري', url: 'https://backup.qurango.net/radio/shaik_abu_bakr_al_shatri'),
    RadioItem(id: 2, name: 'إذاعة أحمد خضر الطرابلسي', url: 'https://backup.qurango.net/radio/ahmad_khader_altarabulsi'),
    RadioItem(id: 3, name: 'إذاعة إبراهيم الأخضر', url: 'https://backup.qurango.net/radio/ibrahim_alakdar'),
    RadioItem(id: 4, name: 'إذاعة خالد الجليل', url: 'https://backup.qurango.net/radio/khalid_aljileel'),
    RadioItem(id: 5, name: 'إذاعة صلاح الهاشم', url: 'https://backup.qurango.net/radio/salah_alhashim'),
    RadioItem(id: 6, name: 'إذاعة صلاح بو خاطر', url: 'https://backup.qurango.net/radio/slaah_bukhatir'),
    RadioItem(id: 7, name: 'إذاعة عبدالباسط عبدالصمد', url: 'https://backup.qurango.net/radio/abdulbasit_abdulsamad_mojawwad'),
    RadioItem(id: 8, name: 'إذاعة عبد العزيز سحيم', url: 'https://backup.qurango.net/radio/a_sheim'),
    RadioItem(id: 9, name: 'إذاعة فارس عباد', url: 'https://backup.qurango.net/radio/fares_abbad'),
    RadioItem(id: 10, name: 'إذاعة ماهر المعيقلي', url: 'https://backup.qurango.net/radio/maher'),
    RadioItem(id: 11, name: 'إذاعة محمد صديق المنشاوي', url: 'https://backup.qurango.net/radio/mohammed_siddiq_alminshawi_mojawwad'),
    RadioItem(id: 12, name: 'إذاعة محمود خليل الحصري', url: 'https://backup.qurango.net/radio/mahmoud_khalil_alhussary_mojawwad'),
    RadioItem(id: 13, name: 'إذاعة محمود علي البنا', url: 'https://backup.qurango.net/radio/mahmoud_ali__albanna_mojawwad'),
    RadioItem(id: 14, name: 'إذاعة مشاري العفاسي', url: 'https://backup.qurango.net/radio/mishary_alafasi'),
    RadioItem(id: 15, name: 'إذاعة ناصر القطامي', url: 'https://backup.qurango.net/radio/nasser_alqatami'),
    RadioItem(id: 16, name: 'إذاعة نبيل الرفاعي', url: 'https://backup.qurango.net/radio/nabil_al_rifay'),
    RadioItem(id: 17, name: 'إذاعة هيثم الجدعاني', url: 'https://backup.qurango.net/radio/hitham_aljadani'),
    RadioItem(id: 18, name: 'إذاعة ياسر الدوسري', url: 'https://backup.qurango.net/radio/yasser_aldosari'),
    RadioItem(id: 19, name: 'إذاعة القرآن الكريم - القاهرة', url: 'https://n0e.radiojar.com/8s5u5tpdtwzuv'),
    RadioItem(id: 20, name: 'إذاعة السنة النبوية', url: 'https://n01.radiojar.com/x0vs2vzy6k0uv'),
    RadioItem(id: 21, name: 'إذاعة تلاوات خاشعة', url: 'https://backup.qurango.net/radio/salma'),
    RadioItem(id: 22, name: 'إذاعة الرقية الشرعية', url: 'https://backup.qurango.net/radio/roqiah'),
    RadioItem(id: 23, name: 'إذاعة تكبيرات العيد', url: 'https://backup.qurango.net/radio/eid'),
    RadioItem(id: 24, name: 'المختصر في تفسير القرآن', url: 'https://backup.qurango.net/radio/mukhtasartafsir'),
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
        subtitle: null,
        trailing: IconButton(
          icon: Icon(
            provider.isRadioPlaying &&
                    provider.currentRadioUrl == radio.url &&
                    provider.audioPlayer.playing
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled,
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

    return SingleChildScrollView(
      child: Column(
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: tiles.length,
            itemBuilder: (context, index) => tiles[index],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
