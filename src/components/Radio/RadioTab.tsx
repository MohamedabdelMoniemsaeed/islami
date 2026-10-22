import React, { useState, useEffect } from 'react';
import { Play, Pause, Volume2, VolumeX, Radio as RadioIcon, Loader2, Search, Sparkles } from 'lucide-react';
import { RadioItem } from '../../types';
import { fetchRadios } from '../../services/api';
import { useApp } from '../../context/AppContext';

export const RadioTab: React.FC = () => {
  const {
    isDark,
    showToast,
    activeRadio,
    isRadioPlaying,
    isRadioBuffering,
    toggleRadio,
    radioVolume,
    setRadioVolume,
  } = useApp();

  const [radios, setRadios] = useState<RadioItem[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [selectedFilter, setSelectedFilter] = useState<string>('all');
  const [isMuted, setIsMuted] = useState<boolean>(false);

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

  const handleVolumeChange = (newVol: number) => {
    setRadioVolume(newVol);
    if (isMuted && newVol > 0) {
      setIsMuted(false);
    }
  };

  const toggleMute = () => {
    if (isMuted) {
      setRadioVolume(0.8);
      setIsMuted(false);
    } else {
      setRadioVolume(0);
      setIsMuted(true);
    }
  };

  const filteredRadios = radios.filter((radio) => {
    const matchesSearch = radio.name.toLowerCase().includes(searchQuery.toLowerCase());
    if (!matchesSearch) return false;

    if (selectedFilter === 'cairo') {
      return radio.name.includes('القاهرة') || radio.name.includes('مصر');
    }
    if (selectedFilter === 'sheikhs') {
      return radio.name.includes('الشيخ') || radio.name.includes('عبد الباسط') || radio.name.includes('المنشاوي') || radio.name.includes('الحصري');
    }
    if (selectedFilter === 'athkar') {
      return radio.name.includes('أذكار') || radio.name.includes('رقية') || radio.name.includes('تفسير');
    }
    return true;
  });

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

      <h1 className="text-2xl sm:text-3xl font-bold my-1 text-center text-[#B7935F] dark:text-[#facc10]">
        إذاعة القرآن الكريم
      </h1>
      <p className="text-xs text-gray-500 dark:text-gray-400 mb-3 text-center">
        بث مباشر متواصل على مدار الساعة لأعذب التلاوات والمحطات الإسلامية
      </p>

      {/* Volume & Active Playing Card */}
      <div className="w-full max-w-md p-3.5 bg-white/80 dark:bg-[#141A2E]/80 backdrop-blur-md rounded-2xl border border-[#B7935F]/25 shadow-sm mb-4 space-y-2.5">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <button
              onClick={toggleMute}
              className="p-1.5 rounded-full hover:bg-black/5 dark:hover:bg-white/10 text-[#B7935F] dark:text-[#facc10]"
              title={isMuted ? 'إلغاء الكتم' : 'كتم الصوت'}
            >
              {isMuted || radioVolume === 0 ? <VolumeX className="w-5 h-5" /> : <Volume2 className="w-5 h-5" />}
            </button>
            <input
              type="range"
              min="0"
              max="1"
              step="0.05"
              value={isMuted ? 0 : radioVolume}
              onChange={(e) => handleVolumeChange(parseFloat(e.target.value))}
              className="w-24 sm:w-32 accent-[#B7935F] dark:accent-[#facc10] cursor-pointer"
            />
          </div>

          {isRadioPlaying ? (
            <div className="flex items-center gap-2 text-xs font-bold text-green-600 dark:text-green-400">
              {/* Sound waves animation */}
              <div className="flex items-end gap-0.5 h-3">
                <span className="w-1 bg-green-500 rounded-full animate-bounce h-3" />
                <span className="w-1 bg-green-500 rounded-full animate-bounce [animation-delay:0.2s] h-2" />
                <span className="w-1 bg-green-500 rounded-full animate-bounce [animation-delay:0.4s] h-3.5" />
                <span className="w-1 bg-green-500 rounded-full animate-bounce [animation-delay:0.1s] h-2.5" />
              </div>
              <span>البث يعمل الآن</span>
            </div>
          ) : isRadioBuffering ? (
            <div className="flex items-center gap-1.5 text-xs text-[#B7935F] dark:text-[#facc10]">
              <Loader2 className="w-4 h-4 animate-spin" />
              <span>جاري الاتصال بالبث...</span>
            </div>
          ) : (
            <span className="text-xs text-gray-400">اختر محطة للبدء</span>
          )}
        </div>

        {activeRadio && (
          <div className="pt-2 border-t border-[#B7935F]/15 flex items-center justify-between text-xs">
            <span className="text-gray-500 dark:text-gray-400">المحطة الحالية:</span>
            <span className="font-bold text-[#B7935F] dark:text-[#facc10] truncate max-w-[200px]">
              {activeRadio.name}
            </span>
          </div>
        )}
      </div>

      {/* Search Bar */}
      <div className="w-full max-w-md relative mb-3">
        <Search className="w-4 h-4 absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="ابحث عن إذاعة، قارئ، أو شيخ..."
          className="w-full pl-4 pr-10 py-2.5 rounded-xl text-xs bg-white/70 dark:bg-[#141A2E]/70 border border-[#B7935F]/20 focus:outline-none focus:ring-2 focus:ring-[#B7935F] text-gray-800 dark:text-gray-100"
        />
      </div>

      {/* Category Filter Chips */}
      <div className="w-full max-w-md flex items-center gap-2 overflow-x-auto pb-2 mb-3 scrollbar-none">
        {[
          { id: 'all', label: 'جميع الإذاعات' },
          { id: 'cairo', label: 'إذاعة القاهرة' },
          { id: 'sheikhs', label: 'كبار القراء' },
          { id: 'athkar', label: 'أذكار وتفسير' },
        ].map((f) => (
          <button
            key={f.id}
            onClick={() => setSelectedFilter(f.id)}
            className={`px-3 py-1.5 rounded-full text-xs font-bold whitespace-nowrap transition-all ${
              selectedFilter === f.id
                ? 'bg-[#B7935F] text-white shadow-xs'
                : 'bg-white/60 dark:bg-[#141A2E]/60 text-gray-600 dark:text-gray-300 border border-[#B7935F]/20 hover:bg-black/5 dark:hover:bg-white/10'
            }`}
          >
            {f.label}
          </button>
        ))}
      </div>

      {/* Radios List */}
      <div className="w-full max-w-md space-y-2.5">
        {loading ? (
          <div className="flex flex-col items-center justify-center py-12 gap-3">
            <Loader2 className="w-8 h-8 text-[#B7935F] animate-spin" />
            <span className="text-sm text-gray-500">جاري تحميل قنوات الإذاعة المباشرة...</span>
          </div>
        ) : filteredRadios.length === 0 ? (
          <div className="text-center py-10 text-gray-500 text-xs">
            لم يتم العثور على إذاعات تطابق بحثك
          </div>
        ) : (
          filteredRadios.map((radio) => {
            const isCurrent = activeRadio?.id === radio.id;
            const isCurrentPlaying = isCurrent && isRadioPlaying;

            return (
              <div
                key={radio.id}
                className={`flex items-center justify-between p-3.5 rounded-2xl transition-all duration-300 shadow-xs ${
                  isDark ? 'bg-[#141A2E]/80 text-white' : 'bg-white/80 text-gray-800'
                } border-2 ${
                  isCurrentPlaying
                    ? 'border-[#B7935F] dark:border-[#facc10] shadow-md shadow-[#B7935F]/20 scale-[1.01]'
                    : isCurrent
                    ? 'border-[#B7935F]/50'
                    : 'border-transparent'
                }`}
              >
                <div className="flex items-center gap-3 overflow-hidden">
                  <div
                    className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 ${
                      isCurrentPlaying
                        ? 'bg-[#B7935F] dark:bg-[#facc10] text-white dark:text-[#141A2E]'
                        : 'bg-[#B7935F]/15 dark:bg-[#facc10]/15 text-[#B7935F] dark:text-[#facc10]'
                    }`}
                  >
                    <RadioIcon className="w-5 h-5" />
                  </div>
                  <div className="truncate">
                    <h3 className="font-bold text-sm leading-snug truncate">{radio.name}</h3>
                    <p className="text-[11px] text-gray-400">بث مباشر متواصل بجودة عالية</p>
                  </div>
                </div>

                <button
                  onClick={() => toggleRadio(radio)}
                  className="p-2 rounded-full text-[#B7935F] dark:text-[#facc10] hover:scale-105 active:scale-95 transition-transform shrink-0"
                  title={isCurrentPlaying ? 'إيقاف مؤقت' : 'تشغيل'}
                  aria-label={radio.name}
                >
                  {isCurrent && isRadioBuffering ? (
                    <Loader2 className="w-8 h-8 animate-spin" />
                  ) : isCurrentPlaying ? (
                    <Pause className="w-8 h-8 fill-current" />
                  ) : (
                    <Play className="w-8 h-8 fill-current" />
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
