import React, { useState, useEffect, useRef } from 'react';
import { X, Play, Pause, Mic, Loader2, Volume2, RotateCcw } from 'lucide-react';
import { ReciterData, ReciterAudioTrack } from '../../types';
import { fetchReciterAudio } from '../../services/api';
import { useApp } from '../../context/AppContext';

export const ReciterAudioModal: React.FC = () => {
  const { isDark, closeModal, showToast } = useApp();
  const [reciterData, setReciterData] = useState<ReciterData | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [currentTrackIndex, setCurrentTrackIndex] = useState<number | null>(null);
  const [isPlaying, setIsPlaying] = useState<boolean>(false);
  const [progress, setProgress] = useState<number>(0);
  const [duration, setDuration] = useState<number>(0);

  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    let mounted = true;
    fetchReciterAudio(112).then((data) => {
      if (mounted) {
        setReciterData(data);
        setLoading(false);
      }
    });
    return () => {
      mounted = false;
    };
  }, []);

  useEffect(() => {
    const audio = new Audio();
    audioRef.current = audio;

    const handleTimeUpdate = () => {
      setProgress(audio.currentTime);
      setDuration(audio.duration || 0);
    };

    const handleEnded = () => {
      setIsPlaying(false);
      setProgress(0);
    };

    const handleError = () => {
      setIsPlaying(false);
      showToast('تعذر تشغيل هذا المقطع الصوتي', 'error');
    };

    audio.addEventListener('timeupdate', handleTimeUpdate);
    audio.addEventListener('ended', handleEnded);
    audio.addEventListener('error', handleError);

    return () => {
      audio.pause();
      audio.removeEventListener('timeupdate', handleTimeUpdate);
      audio.removeEventListener('ended', handleEnded);
      audio.removeEventListener('error', handleError);
      audio.src = '';
    };
  }, []);

  const handlePlayTrack = (index: number) => {
    if (!audioRef.current || !reciterData) return;

    if (currentTrackIndex === index && isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      const track = reciterData.audio_urls[index];
      setCurrentTrackIndex(index);
      audioRef.current.src = track.audio_url;
      audioRef.current
        .play()
        .then(() => {
          setIsPlaying(true);
        })
        .catch((e) => {
          console.error(e);
          setIsPlaying(false);
          showToast('تعذر تشغيل السورة، تأكد من الاتصال بالإنترنت', 'error');
        });
    }
  };

  const formatTime = (secs: number) => {
    if (isNaN(secs)) return '00:00';
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  };

  const handleSeek = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = parseFloat(e.target.value);
    setProgress(val);
    if (audioRef.current) {
      audioRef.current.currentTime = val;
    }
  };

  const activeTrack = currentTrackIndex !== null && reciterData ? reciterData.audio_urls[currentTrackIndex] : null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div
        className="w-full max-w-lg h-[90vh] rounded-3xl shadow-2xl flex flex-col overflow-hidden border border-[#B7935F]/30"
        style={{ backgroundColor: isDark ? '#141A2E' : '#ffffff' }}
      >
        {/* Header matching Flutter app */}
        <div className="p-4 sm:p-5 flex items-center justify-between border-b border-[#B7935F]/20 bg-[#B7935F]/10 dark:bg-white/5">
          <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
            <Mic className="w-6 h-6" />
            <h2 className="text-xl font-bold">
              {reciterData?.reciter_name || 'الشيخ محمد صديق المنشاوي'}
            </h2>
          </div>
          <button
            onClick={closeModal}
            className="p-1.5 rounded-full hover:bg-black/10 dark:hover:bg-white/10 text-gray-500 hover:text-gray-800 dark:hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Player Bar if playing */}
        {activeTrack && (
          <div className="p-4 border-b border-[#B7935F]/20 bg-[#B7935F]/15 dark:bg-[#facc10]/10 flex flex-col gap-2">
            <div className="flex items-center justify-between">
              <div>
                <h4 className="font-bold text-sm text-[#B7935F] dark:text-[#facc10]">
                  سورة {activeTrack.surah_name_ar}
                </h4>
                <span className="text-[11px] text-gray-500">
                  {formatTime(progress)} / {formatTime(duration)}
                </span>
              </div>
              <button
                onClick={() => handlePlayTrack(currentTrackIndex!)}
                className="w-10 h-10 rounded-full flex items-center justify-center text-white shadow-md active:scale-95 transition-transform"
                style={{ backgroundColor: '#B7935F' }}
              >
                {isPlaying ? <Pause className="w-5 h-5 fill-current" /> : <Play className="w-5 h-5 fill-current" />}
              </button>
            </div>
            <input
              type="range"
              min={0}
              max={duration || 100}
              value={progress}
              onChange={handleSeek}
              className="w-full accent-[#B7935F] dark:accent-[#facc10] cursor-pointer h-1.5"
            />
          </div>
        )}

        {/* Tracks List */}
        <div className="flex-1 overflow-y-auto divide-y divide-[#B7935F]/10 dark:divide-white/5 p-2">
          {loading ? (
            <div className="flex flex-col items-center justify-center py-20 gap-3">
              <Loader2 className="w-8 h-8 text-[#B7935F] animate-spin" />
              <span className="text-sm text-gray-500">جاري تحميل تلاوات الشيخ...</span>
            </div>
          ) : !reciterData || reciterData.audio_urls.length === 0 ? (
            <div className="text-center py-16 text-gray-400">لا توجد تسجيلات متاحة</div>
          ) : (
            reciterData.audio_urls.map((track, idx) => {
              const isCurrent = currentTrackIndex === idx;
              const isCurrentPlaying = isCurrent && isPlaying;

              return (
                <div
                  key={track.surah_id || idx}
                  className={`w-full p-3.5 flex items-center justify-between rounded-xl transition-colors ${
                    isCurrent ? 'bg-[#B7935F]/15 dark:bg-[#facc10]/15' : 'hover:bg-black/5 dark:hover:bg-white/5'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <button
                      onClick={() => handlePlayTrack(idx)}
                      className="w-10 h-10 rounded-full flex items-center justify-center text-white shadow-xs shrink-0 active:scale-95 transition-transform"
                      style={{ backgroundColor: '#B7935F' }}
                    >
                      {isCurrentPlaying ? (
                        <Pause className="w-5 h-5 fill-current" />
                      ) : (
                        <Play className="w-5 h-5 fill-current" />
                      )}
                    </button>
                    <div>
                      <h3 className="font-bold text-base text-gray-800 dark:text-gray-100">
                        سورة {track.surah_name_ar}
                      </h3>
                      <p className="text-xs text-gray-400">سورة رقم {track.surah_id}</p>
                    </div>
                  </div>

                  {isCurrentPlaying && (
                    <span className="text-xs px-2.5 py-1 rounded-full font-bold bg-[#B7935F]/20 text-[#B7935F] dark:bg-[#facc10]/20 dark:text-[#facc10] animate-pulse">
                      قيد الاستماع
                    </span>
                  )}
                </div>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
};
