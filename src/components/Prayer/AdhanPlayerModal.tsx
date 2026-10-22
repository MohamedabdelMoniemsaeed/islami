import React, { useState, useEffect, useRef } from 'react';
import { X, Play, Pause, Volume2, VolumeX, Bell, Music, Check, Sparkles } from 'lucide-react';
import { useApp } from '../../context/AppContext';

interface Muadhin {
  id: string;
  name: string;
  location: string;
  audioUrl: string;
}

const MUADHINS: Muadhin[] = [
  {
    id: 'makkah',
    name: 'أذان الحرم المكي الشريف',
    location: 'مكة المكرمة',
    audioUrl: '/assets/audio/adhan_makkah.mp3',
  },
  {
    id: 'tarateel',
    name: 'أذان المسجد النبوي الشريف',
    location: 'المدينة المنورة',
    audioUrl: 'https://qurango.net/radio/tarateel',
  },
];

export const AdhanPlayerModal: React.FC = () => {
  const { closeModal, isDark, showToast } = useApp();
  const [selectedMuadhin, setSelectedMuadhin] = useState<Muadhin>(MUADHINS[0]);
  const [isPlaying, setIsPlaying] = useState<boolean>(false);
  const [currentTime, setCurrentTime] = useState<number>(0);
  const [duration, setDuration] = useState<number>(0);
  const [volume, setVolume] = useState<number>(0.9);
  const [isMuted, setIsMuted] = useState<boolean>(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    const audio = new Audio();
    audioRef.current = audio;
    audio.src = selectedMuadhin.audioUrl;
    audio.volume = volume;

    const handleTimeUpdate = () => {
      setCurrentTime(audio.currentTime);
    };

    const handleLoadedMetadata = () => {
      setDuration(audio.duration || 0);
    };

    const handleEnded = () => {
      setIsPlaying(false);
      setCurrentTime(0);
    };

    audio.addEventListener('timeupdate', handleTimeUpdate);
    audio.addEventListener('loadedmetadata', handleLoadedMetadata);
    audio.addEventListener('ended', handleEnded);

    return () => {
      audio.pause();
      audio.removeEventListener('timeupdate', handleTimeUpdate);
      audio.removeEventListener('loadedmetadata', handleLoadedMetadata);
      audio.removeEventListener('ended', handleEnded);
      audio.src = '';
    };
  }, [selectedMuadhin]);

  const handlePlayToggle = () => {
    if (!audioRef.current) return;
    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      audioRef.current
        .play()
        .then(() => setIsPlaying(true))
        .catch(() => {
          setIsPlaying(false);
          showToast('تعذر تشغيل صوت الأذان حالياً', 'error');
        });
    }
  };

  const handleSeek = (seconds: number) => {
    if (audioRef.current) {
      audioRef.current.currentTime = seconds;
      setCurrentTime(seconds);
    }
  };

  const handleVolumeChange = (vol: number) => {
    setVolume(vol);
    if (audioRef.current) {
      audioRef.current.volume = vol;
    }
    if (isMuted && vol > 0) setIsMuted(false);
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

  const formatSecs = (sec: number) => {
    if (isNaN(sec) || !isFinite(sec)) return '00:00';
    const m = Math.floor(sec / 60);
    const s = Math.floor(sec % 60);
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div
        className="w-full max-w-lg rounded-3xl p-6 shadow-2xl border border-[#B7935F]/30 overflow-hidden relative max-h-[90vh] overflow-y-auto"
        style={{
          backgroundColor: isDark ? '#141A2E' : '#ffffff',
        }}
      >
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-[#B7935F]/20">
          <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
            <Bell className="w-6 h-6 animate-pulse" />
            <h2 className="text-xl font-bold">صوت الأذان المبارك</h2>
          </div>
          <button
            onClick={() => {
              if (audioRef.current) audioRef.current.pause();
              closeModal();
            }}
            className="p-1.5 rounded-full hover:bg-black/5 dark:hover:bg-white/10 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Muadhin Card */}
        <div className="my-5 p-4 rounded-2xl bg-[#B7935F]/10 dark:bg-[#facc10]/10 border border-[#B7935F]/25 flex items-center justify-between">
          <div>
            <h3 className="font-bold text-base text-gray-800 dark:text-gray-100">
              {selectedMuadhin.name}
            </h3>
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
              {selectedMuadhin.location} — صوت نقي عالي الجودة
            </p>
          </div>
          <div className="w-12 h-12 rounded-full bg-[#B7935F] dark:bg-[#facc10] text-white dark:text-[#141A2E] flex items-center justify-center shadow-md">
            <Music className="w-6 h-6" />
          </div>
        </div>

        {/* Progress Bar & Timing */}
        <div className="space-y-2 mb-4">
          <input
            type="range"
            min={0}
            max={duration || 100}
            value={currentTime}
            onChange={(e) => handleSeek(parseFloat(e.target.value))}
            className="w-full accent-[#B7935F] dark:accent-[#facc10] cursor-pointer"
          />
          <div className="flex items-center justify-between text-xs text-gray-400" dir="ltr">
            <span>{formatSecs(currentTime)}</span>
            <span>{formatSecs(duration)}</span>
          </div>
        </div>

        {/* Player Controls */}
        <div className="flex items-center justify-center gap-6 my-4">
          <button
            onClick={toggleMute}
            className="p-2 rounded-full text-gray-500 dark:text-gray-400 hover:text-[#B7935F]"
          >
            {isMuted ? <VolumeX className="w-5 h-5" /> : <Volume2 className="w-5 h-5" />}
          </button>

          <button
            onClick={handlePlayToggle}
            className="w-16 h-16 rounded-full flex items-center justify-center text-white shadow-xl transition-all duration-200 active:scale-95 hover:scale-105"
            style={{ backgroundColor: '#B7935F' }}
          >
            {isPlaying ? (
              <Pause className="w-8 h-8 fill-current" />
            ) : (
              <Play className="w-8 h-8 fill-current ml-0.5" />
            )}
          </button>

          <input
            type="range"
            min="0"
            max="1"
            step="0.05"
            value={isMuted ? 0 : volume}
            onChange={(e) => handleVolumeChange(parseFloat(e.target.value))}
            className="w-20 accent-[#B7935F] dark:accent-[#facc10] cursor-pointer"
          />
        </div>

        {/* Duaa After Adhan */}
        <div className="mt-5 p-4 rounded-2xl bg-white/70 dark:bg-[#141A2E]/70 border border-[#B7935F]/20 space-y-2 text-right">
          <div className="flex items-center gap-1.5 font-bold text-xs text-[#B7935F] dark:text-[#facc10]">
            <Sparkles className="w-4 h-4" />
            <span>دعاء ما بعد الأذان (سنة مؤكدة):</span>
          </div>
          <p className="text-xs leading-relaxed text-gray-700 dark:text-gray-200 font-serif text-justify">
            «اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلاَةِ القَائِمَةِ، آتِ مُحَمَّداً الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَاماً مَحْمُوداً الَّذِي وَعَدْتَهُ، [إِنَّكَ لاَ تُخْلِفُ المِيعَادَ]»
          </p>
          <p className="text-[11px] text-gray-400">
            فضل الدعاء: حلت له شفاعة النبي ﷺ يوم القيامة (صحيح البخاري).
          </p>
        </div>
      </div>
    </div>
  );
};
