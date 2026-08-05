import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/images.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class ReciterAudioScreen extends StatefulWidget {
  static const String routeName = "ReciterAudio";
  final int reciterId;

  const ReciterAudioScreen({super.key, required this.reciterId});

  @override
  State<ReciterAudioScreen> createState() => _ReciterAudioScreenState();
}

class _ReciterAudioScreenState extends State<ReciterAudioScreen> {
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, dynamic> _reciterData = {};
  bool _isLoading = true;
  int? _currentPlayingIndex;

  @override
  void initState() {
    super.initState();
    _loadReciterAudio();
  }

  Future<void> _loadReciterAudio() async {
    try {
      final data = await _apiService.getReciterAudio(widget.reciterId);
      if (mounted) {
        setState(() {
          _reciterData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTrack(int index) async {
    final track = _reciterData['audio_urls'][index];
    final String url = track['audio_url'];
    final String title = track['surah_name_ar'];

    try {
      if (_audioPlayer.playing && _currentPlayingIndex == index) {
        await _audioPlayer.pause();
      } else {
        final audioSource = AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: 'reciter_${widget.reciterId}_$index',
            album: _reciterData['reciter_name'] ?? "المصحف المرتل",
            title: title,
            artUri: Uri.parse("https://quran.yousefheiba.com/assets/images/quran.png"),
          ),
        );
        await _audioPlayer.setAudioSource(audioSource);
        await _audioPlayer.play();
        setState(() {
          _currentPlayingIndex = index;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في التشغيل: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final String reciterName = _reciterData['reciter_name'] ?? "الشيخ محمد صديق المنشاوي";
    final List<dynamic> tracks = _reciterData['audio_urls'] ?? [];

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            provider.isDarkMode() ? AppImage.backgroundDark : AppImage.backgroundHome
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(reciterName, style: TextStyle(
            color: provider.isDarkMode() ? AppColors.blackDark : Colors.black,
            fontWeight: FontWeight.bold
          )),
          centerTitle: true,
          iconTheme: IconThemeData(color: provider.isDarkMode() ? AppColors.blackDark : Colors.black),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.yellow))
            : tracks.isEmpty
                ? const Center(child: Text("لا توجد تسجيلات متاحة"))
                : ListView.separated(
                    padding: const EdgeInsets.all(15),
                    itemCount: tracks.length,
                    separatorBuilder: (context, index) => Divider(color: AppColors.yellow.withOpacity(0.3)),
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return StreamBuilder<PlayerState>(
                        stream: _audioPlayer.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final isThisPlaying = playerState?.playing ?? false;
                          final bool isCurrent = _currentPlayingIndex == index;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.yellow,
                              child: Icon(
                                (isCurrent && isThisPlaying) ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              track['surah_name_ar'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: provider.isDarkMode() ? Colors.white : Colors.black,
                              ),
                            ),
                            subtitle: Text("سورة رقم ${track['surah_id']}", style: const TextStyle(color: Colors.grey)),
                            onTap: () => _playTrack(index),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
