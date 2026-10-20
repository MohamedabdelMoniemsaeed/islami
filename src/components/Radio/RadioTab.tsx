import React, { useState, useEffect, useRef } from 'react';
import { Play, Pause, Volume2, VolumeX, Radio as RadioIcon, Loader2 } from 'lucide-react';
import { RadioItem } from '../../types';
import { fetchRadios } from '../../services/api';
import { useApp } from '../../context/AppContext';

export const RadioTab: React.FC = () => {
  const { isDark, showToast } = useApp();
  const [radios, setRadios] = useState<RadioItem[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [activeRadioId, setActiveRadioId] = useState<number | null>(null);
  const [isPlaying, setIsPlaying] = useState<boolean>(false);
  const [isBuffering, setIsBuffering] = useState<boolean>(false);
  const [volume, setVolume] = useState<number>(0.85);
  const [isMuted, setIsMuted] = useState<boolean>(false);

  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    let mounted = true;
    fetchRadios().then((data) => {
      if (mounted) {
        setRadios(data);
        setLoading(false);
      }
    });
    return () => {
      mounted = false;
    };
  }, []);

  // Audio setup
  useEffect(() => {
    const audio = new Audio();
    audioRef.current = audio;

    const handlePlaying = () => {
      setIsPlaying(true);
      setIsBuffering(false);
    };

    const handleWaiting = () => {
      setIsBuffering(true);
    };

    const handlePause = () => {
      setIsPlaying(false);
      setIsBuffering(false);
    };

    const handleError = () => {
      setIsPlaying(false);
      setIsBuffering(false);
      showToast('تعذر تشغيل هذه الإذاعة حالياً. جرب إذاعة أخرى.', 'error');
    };

    audio.addEventListener('playing', handlePlaying);
    audio.addEventListener('waiting', handleWaiting);
    audio.addEventListener('pause', handlePause);
    audio.addEventListener('error', handleError);

    return () => {
      audio.pause();
      audio.removeEventListener('playing', handlePlaying);
      audio.removeEventListener('waiting', handleWaiting);
      audio.removeEventListener('pause', handlePause);
      audio.removeEventListener('error', handleError);
      audio.src = '';
    };
  }, []);

  const handlePlayToggle = (radio: RadioItem) => {
    if (!audioRef.current) return;

    if (activeRadioId === radio.id && isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      setActiveRadioId(radio.id);
      setIsBuffering(true);
      showToast(`جاري الاتصال بـ ${radio.name}...`, 'info');

      audioRef.current.src = radio.url;
      audioRef.current.volume = isMuted ? 0 : volume;
      audioRef.current
        .play()
        .then(() => {
          setIsPlaying(true);
          setIsBuffering(false);
        })
        .catch((err) => {
          console.error('Audio play error:', err);
          setIsPlaying(false);
          setIsBuffering(false);
          showToast('تعذر تشغيل الإذاعة، يرجى التحقق من الاتصال بالإنترنت', 'error');
        });
    }
  };

  const handleVolumeChange = (newVol: number) => {
    setVolume(newVol);
    if (audioRef.current) {
      audioRef.current.volume = newVol;
    }
    if (isMuted && newVol > 0) {
      setIsMuted(false);
    }
  };

  const toggleMute = () => {
    if (!audioRef.current) return;
    if (isMuted) {
      audioRef.current.volume = volume;
      setIsMuted(false);
    } else {
      audioRef.current.volume = 0;
      setIsMuted(true);
    }
  };

  return (
    <div className="flex flex-col items-center w-full max-w-xl mx-auto px-4 pb-28 pt-2">
      {/* Top Banner Matching Flutter App */}
      <div className="w-full max-w-md mx-auto my-3 p-1 rounded-[25px] border-3 border-[#B7935F] shadow-lg shadow-[#B7935F]/20 overflow-hidden bg-white/50 dark:bg-[#141A2E]/50">
        <img
          src="/assets/images/radio1.jpeg"
          alt="إذاعة القرآن الكريم"
          className="w-full h-44 sm:h-52 object-cover rounded-[20px]"
          onError={(e) => {
            (e.currentTarget as HTMLImageElement).src = '/assets/images/radio.png';
          }}
        />
      </div>

      <h1 className="text-2xl sm:text-3xl font-bold my-2 text-center text-[#B7935F] dark:text-[#facc10]">
        إذاعة القرآن الكريم
      </h1>
      <p className="text-xs text-gray-500 dark:text-gray-400 mb-4 text-center">
        بث مباشر متواصل على مدار الساعة لأعذب التلاوات
      </p>

      {/* Volume Controls */}
      <div className="w-full max-w-md flex items-center justify-between px-4 py-2 bg-white/70 dark:bg-[#141A2E]/70 backdrop-blur-xs rounded-2xl border border-[#B7935F]/20 mb-4">
        <div className="flex items-center gap-2">
          <button
            onClick={toggleMute}
            className="p-1.5 rounded-full hover:bg-black/5 dark:hover:bg-white/10 text-[#B7935F] dark:text-[#facc10]"
          >
            {isMuted || volume === 0 ? <VolumeX className="w-5 h-5" /> : <Volume2 className="w-5 h-5" />}
          </button>
          <input
            type="range"
            min="0"
            max="1"
            step="0.05"
            value={isMuted ? 0 : volume}
            onChange={(e) => handleVolumeChange(parseFloat(e.target.value))}
            className="w-24 sm:w-32 accent-[#B7935F] dark:accent-[#facc10] cursor-pointer"
          />
        </div>

        {isPlaying && (
          <div className="flex items-center gap-1.5 text-xs font-bold text-green-600 dark:text-green-400">
            <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
            <span>البث يعمل الآن</span>
          </div>
        )}
      </div>

      {/* Radios List */}
      <div className="w-full max-w-md space-y-3">
        {loading ? (
          <div className="flex flex-col items-center justify-center py-12 gap-3">
            <Loader2 className="w-8 h-8 text-[#B7935F] animate-spin" />
            <span className="text-sm text-gray-500">جاري تحميل قنوات الإذاعة...</span>
          </div>
        ) : radios.length === 0 ? (
          <div className="text-center py-10 text-gray-500">لا توجد إذاعات متاحة حالياً</div>
        ) : (
          radios.map((radio) => {
            const isCurrent = activeRadioId === radio.id;
            const isCurrentPlaying = isCurrent && isPlaying;

            return (
              <div
                key={radio.id}
                className={`flex items-center justify-between p-4 rounded-2xl transition-all duration-300 shadow-xs ${
                  isDark ? 'bg-[#141A2E]/80 text-white' : 'bg-white/80 text-gray-800'
                } border-2 ${
                  isCurrentPlaying ? 'border-[#B7935F] dark:border-[#facc10] shadow-md shadow-[#B7935F]/20' : 'border-transparent'
                }`}
              >
                <div className="flex items-center gap-3">
                  <div
                    className={`w-10 h-10 rounded-full flex items-center justify-center ${
                      isCurrentPlaying
                        ? 'bg-[#B7935F] dark:bg-[#facc10] text-white dark:text-[#141A2E]'
                        : 'bg-[#B7935F]/15 dark:bg-[#facc10]/15 text-[#B7935F] dark:text-[#facc10]'
                    }`}
                  >
                    <RadioIcon className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="font-bold text-base leading-snug">{radio.name}</h3>
                    <p className="text-xs text-gray-400">بث صوتي مباشر</p>
                  </div>
                </div>

                <button
                  onClick={() => handlePlayToggle(radio)}
                  className="p-2 rounded-full text-[#B7935F] dark:text-[#facc10] hover:scale-105 active:scale-95 transition-transform"
                  title={isCurrentPlaying ? 'إيقاف مؤقت' : 'تشغيل'}
                  aria-label={radio.name}
                >
                  {isCurrent && isBuffering ? (
                    <Loader2 className="w-9 h-9 animate-spin" />
                  ) : isCurrentPlaying ? (
                    <Pause className="w-9 h-9 fill-current" />
                  ) : (
                    <Play className="w-9 h-9 fill-current" />
                  )}
                </button>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};
