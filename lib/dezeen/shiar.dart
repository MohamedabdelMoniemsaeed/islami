import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

/// أسماء الأجزاء الثلاثين من القرآن الكريم
const List<String> kJuzNames = [
  "آلم", "سيسألون", "تلك الرسل", "لن تنالوا", "والملائكة",
  "لا يستطيع", "وإذا سمعوا", "وقد وصفناه", "قال الملأ", "وأعطى",
  "يعتذرون", "وما من دابة", "وما أبرئ", "رب إني", "سبحان الذي",
  "قال المشركون", "اقترب للناس", "قد أفلح", "قال ألم", "أمن يجيب",
  "اتل ما أوحي", "ومن يقنت", "وما لي", "فمن أظلم", "إليكم كتابنا",
  "حم", "حم", "قد أفلح", "تبارك الذي", "عم يتساءلون",
];

class AppProvider extends ChangeNotifier {
  final String _lang = "ar";
  ThemeMode _mode = ThemeMode.light;
  List<dynamic> _surahs = [];
  int _currentQuranPage = 0;
  int? _bookmarkedPage;
  int _jumpRequests = 0;

  // ترتيب أيقونات صفحة الوجهات
  List<String> _destinationOrder = [
    'quran', 'radio', 'prayer', 'settings',
    'surah_index', 'tafsir_index', 'reciter',
    'azkar', 'duas',
  ];

  // مشغل الصوت المشترك
  late final AudioPlayer _audioPlayer;
  int? _currentPlayingIndex;
  int? _currentReciterId;
  String _currentReciterName = "";
  String _currentTrackTitle = "";
  bool _isRadioPlaying = false;
  String? _currentRadioUrl;

  bool _audioInitialized = false;

  String get lang => _lang;
  ThemeMode get mode => _mode;
  List<dynamic> get surahs => _surahs;
  int get currentQuranPage => _currentQuranPage;
  int? get bookmarkedPage => _bookmarkedPage;
  int get jumpRequests => _jumpRequests;
  List<String> get destinationOrder => _destinationOrder;
  AudioPlayer get audioPlayer => _audioPlayer;
  int? get currentPlayingIndex => _currentPlayingIndex;
  int? get currentReciterId => _currentReciterId;
  String get currentReciterName => _currentReciterName;
  String get currentTrackTitle => _currentTrackTitle;
  bool get isRadioPlaying => _isRadioPlaying;
  String? get currentRadioUrl => _currentRadioUrl;
  bool get isAudioInitialized => _audioInitialized;

  AppProvider() {
    _audioPlayer = AudioPlayer();
    _initAudio();
    loadBookmark();
    loadDestinationOrder();
    loadTheme();
  }

  Future<void> _initAudio() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _audioInitialized = true;

      _audioPlayer.playerStateStream.listen((state) {
        debugPrint("🎵 Player state: playing=${state.playing}, processing=${state.processingState}");
      });

      startPrayerMonitoring();
    } catch (e) {
      debugPrint("❌ AudioSession init error: $e");
    }
  }

  void changeTheme(ThemeMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    saveTheme();
    notifyListeners();
  }

  bool isDarkMode() => _mode == ThemeMode.dark;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('theme_dark');
    _mode = (saved ?? false) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_dark', _mode == ThemeMode.dark);
  }

  void updateQuranPage(int page) {
    _currentQuranPage = page;
    notifyListeners();
  }

  void requestJumpToPage(int page) {
    _currentQuranPage = page;
    _jumpRequests++;
    notifyListeners();
  }

  Future<void> saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_bookmark', _currentQuranPage);
    _bookmarkedPage = _currentQuranPage;
    notifyListeners();
  }

  Future<void> loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarkedPage = prefs.getInt('quran_bookmark');
    notifyListeners();
  }

  Future<void> clearBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quran_bookmark');
    _bookmarkedPage = null;
    notifyListeners();
  }

  Future<void> loadSurahs() async {
    if (_surahs.isNotEmpty) return;
    try {
      final dynamic data = await ApiService().getSurahsList();
      if (data is List) {
        _surahs = data;
      } else if (data is Map) {
        if (data.containsKey('value')) {
          _surahs = data['value'];
        } else if (data.containsKey('surahs')) {
          _surahs = data['surahs'];
        } else if (data.containsKey('data')) {
          _surahs = data['data'];
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading surahs in provider: $e");
    }
  }

  Future<void> loadDestinationOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('destination_order');
    if (saved != null && saved.length == _destinationOrder.length) {
      _destinationOrder = saved;
      notifyListeners();
    }
  }

  Future<void> saveDestinationOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('destination_order', order);
    _destinationOrder = order;
    notifyListeners();
  }

  void reorderDestination(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final list = List<String>.from(_destinationOrder);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _destinationOrder = list;
    notifyListeners();
    saveDestinationOrder(list);
  }

  Future<void> _ensureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await session.setActive(true);
  }

  // ===== مشغل الصوت =====
  Future<void> playTrack({
    required String url,
    required int reciterId,
    required int trackIndex,
    required String title,
    required String album,
  }) async {
    try {
      await _ensureAudioSession();
      if (_audioPlayer.playing && _currentReciterId == reciterId && _currentPlayingIndex == trackIndex) {
        await _audioPlayer.pause();
        notifyListeners();
        return;
      }

      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: '$reciterId-$trackIndex',
            album: album,
            title: title.isEmpty ? 'تلاوة قرآنية' : title,
            artUri: Uri.parse('asset:///assets/images/quran.png'),
          ),
        ),
      );

      _currentReciterId = reciterId;
      _currentPlayingIndex = trackIndex;
      _currentTrackTitle = title;
      _currentReciterName = album;
      _isRadioPlaying = false;
      _currentRadioUrl = null;

      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ playTrack error: $e");
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text("خطأ في تشغيل الصوت: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// تشغيل بث إذاعي (live stream)
  Future<void> playRadio(String url, String name) async {
    try {
      await _ensureAudioSession();

      // إيقاف أي صوت حالي تماماً قبل البدء
      await _audioPlayer.stop();

      _isRadioPlaying = true;
      _currentRadioUrl = url;

      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            album: 'إذاعة القرآن الكريم',
            title: name.isEmpty ? 'إذاعة مباشرة' : name,
            artUri: Uri.parse('asset:///assets/images/radio.png'),
          ),
        ),
      );

      // زيادة مهلة الانتظار للبث المباشر
      await _audioPlayer.play().timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception("تأخر الاتصال بالسيرفر، يرجى المحاولة مرة أخرى");
      });

      notifyListeners();
    } catch (e) {
      debugPrint("❌ playRadio error: $e");
      _isRadioPlaying = false;
      _currentRadioUrl = null;
      notifyListeners();

      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text("تعذر تشغيل الإذاعة: ${e.toString().split(':').last}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // حالة الأذان التلقائي ومراقبة مواقيت الصلاة
  Timer? _prayerMonitorTimer;
  PrayerTimes? _cachedPrayerTimes;
  String? _lastPlayedAdhanKey;

  void updateCachedPrayerTimes(PrayerTimes times) {
    _cachedPrayerTimes = times;
  }

  /// تشغيل الأذان بصوت المؤذن المختار
  Future<void> playAdhan({
    required String soundId,
    required String prayerName,
  }) async {
    await _ensureAudioSession();
    try {
      final soundNum = soundId.replaceAll(RegExp(r'[^0-9]'), '');
      final assetPath = 'assets/sounds/${soundNum.isEmpty ? '1' : soundNum}.mp3';

      await _audioPlayer.setAudioSource(
        AudioSource.asset(
          assetPath,
          tag: MediaItem(
            id: 'adhan-$soundId',
            album: 'أذان الصلوات الخمس',
            title: 'أذان صلاة $prayerName',
            artUri: Uri.parse('asset:///assets/images/quran.png'),
          ),
        ),
      );

      _currentReciterId = null;
      _currentPlayingIndex = null;
      _currentTrackTitle = 'أذان صلاة $prayerName';
      _currentReciterName = 'نداء الصلاة';
      _isRadioPlaying = false;
      _currentRadioUrl = null;

      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();
      notifyListeners();

      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.volume_up, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'حان الآن موعد أذان صلاة $prayerName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFF5A623),
            duration: const Duration(seconds: 15),
            action: SnackBarAction(
              label: 'إيقاف',
              textColor: Colors.white,
              onPressed: () => stopTrack(),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ playAdhan error: $e");
    }
  }

  void startPrayerMonitoring() {
    _prayerMonitorTimer?.cancel();
    checkPrayerTimesAndTriggerNow();
    _prayerMonitorTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      checkPrayerTimesAndTriggerNow();
    });
  }

  /// فحص فوري للمواقيت وتشغيل الأذان تلقائياً إذا حان الوقت
  Future<void> checkPrayerTimesAndTriggerNow() async {
    try {
      final now = DateTime.now();
      final today = DateFormat("yyyy-MM-dd").format(now);

      if (_cachedPrayerTimes == null || _cachedPrayerTimes!.dateEn != today) {
        try {
          final fetched = await ApiService().getPrayerTimes();
          _cachedPrayerTimes = fetched;
          // إعادة جدولة منبهات وإشعارات الأذان عند تحديث المواقيت
          NotificationService().scheduleEnabledPrayers(fetched);
        } catch (_) {}
      }

      final times = _cachedPrayerTimes;
      if (times == null) return;

      final notificationService = NotificationService();
      final isMaster = await notificationService.isMasterAdhanEnabled();
      if (!isMaster) return;

      final enabled = await notificationService.getEnabledPrayers();
      if (enabled.isEmpty) return;

      final timesByPrayer = {
        'fajr': times.fajr,
        'dhuhr': times.dhuhr,
        'asr': times.asr,
        'maghrib': times.maghrib,
        'isha': times.isha,
      };

      for (final prayer in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
        if (!enabled.contains(prayer)) continue;
        final timeStr = timesByPrayer[prayer];
        if (timeStr == null || timeStr.isEmpty) continue;

        try {
          final prayerDateTime = _parsePrayerDateTime(today, timeStr);
          if (prayerDateTime == null) continue;

          final diff = now.difference(prayerDateTime);
          final key = '${today}_$prayer';

          // الصلاة حانت خلال آخر 90 ثانية ولم تؤذن بعد
          if (diff.inSeconds >= 0 && diff.inSeconds < 90 && _lastPlayedAdhanKey != key) {
            _lastPlayedAdhanKey = key;
            final soundId = await notificationService.getAdhanSound();
            final prayerName = NotificationService.prayerNames[prayer] ?? prayer;
            await playAdhan(soundId: soundId, prayerName: prayerName);
            break;
          }
        } catch (e) {
          debugPrint("Error checking prayer $prayer: $e");
        }
      }
    } catch (e) {
      debugPrint("Prayer monitor check error: $e");
    }
  }

  DateTime? _parsePrayerDateTime(String dateStr, String timeStr) {
    if (timeStr.isEmpty) return null;
    final cleanTime = timeStr.replaceAll(RegExp(r'\s*\([A-Za-z\s]+\)\s*'), '').trim();
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(cleanTime);
    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        try {
          int year, month, day;
          if (parts[0].length == 4) {
            year = int.parse(parts[0]);
            month = int.parse(parts[1]);
            day = int.parse(parts[2]);
          } else {
            day = int.parse(parts[0]);
            month = int.parse(parts[1]);
            year = int.parse(parts[2]);
          }
          return DateTime(year, month, day, hour, minute);
        } catch (_) {}
      }
    }
    return null;
  }

  Future<void> pauseTrack() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      notifyListeners();
    }
  }

  Future<void> stopTrack() async {
    await _audioPlayer.stop();
    _currentPlayingIndex = null;
    _currentReciterId = null;
    _isRadioPlaying = false;
    _currentRadioUrl = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _prayerMonitorTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final navigatorKey = GlobalKey<NavigatorState>();
