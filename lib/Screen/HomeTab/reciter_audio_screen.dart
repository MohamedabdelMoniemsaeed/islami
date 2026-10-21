import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/radio_model.dart';
import 'package:just_audio/just_audio.dart';

class ReciterAudioScreen extends StatefulWidget {
  static const String routeName = '/reciter-audio';
  final int reciterId;

  const ReciterAudioScreen({super.key, this.reciterId = 112});

  @override
  State<ReciterAudioScreen> createState() => _ReciterAudioScreenState();
}

class _ReciterAudioScreenState extends State<ReciterAudioScreen> {
  final ApiService _apiService = ApiService();
  late AudioPlayer _audioPlayer;
  late Future<RadioResponse> _radiosFuture;
  bool _isPlaying = false;
  String? _currentPlayingUrl;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _radiosFuture = _apiService.getRadios();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRadio(String url) async {
    try {
      if (_isPlaying && _currentPlayingUrl == url) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        setState(() {
          _isPlaying = true;
          _currentPlayingUrl = url;
        });
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إذاعة القرآن الكريم')),
      body: FutureBuilder<RadioResponse>(
        future: _radiosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.radios.isEmpty) {
            return const Center(child: Text('تعذر تحميل الإذاعات'));
          }

          final radios = snapshot.data!.radios;
          return ListView.builder(
            itemCount: radios.length,
            itemBuilder: (context, index) {
              final radio = radios[index];
              final isCurrentPlaying = _currentPlayingUrl == radio.url && _isPlaying;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE2BE7F),
                  child: Icon(
                    isCurrentPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                  ),
                ),
                title: Text(radio.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('بث مباشر'),
                trailing: IconButton(
                  icon: Icon(isCurrentPlaying ? Icons.stop : Icons.play_arrow),
                  color: const Color(0xFFE2BE7F),
                  onPressed: () => _playRadio(radio.url),
                ),
                onTap: () => _playRadio(radio.url),
              );
            },
          );
        },
      ),
    );
  }
}
