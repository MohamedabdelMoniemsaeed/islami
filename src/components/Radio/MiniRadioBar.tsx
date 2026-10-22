import React from 'react';
import { Play, Pause, Radio as RadioIcon, X, Volume2, Loader2 } from 'lucide-react';
import { useApp } from '../../context/AppContext';

export const MiniRadioBar: React.FC = () => {
  const {
    activeRadio,
    isRadioPlaying,
    isRadioBuffering,
    pauseRadio,
    playRadio,
    activeTab,
    setActiveTab,
    isDark,
  } = useApp();

  // If no radio is active or user is currently in the radio tab, don't show the mini floating bar
  if (!activeRadio || activeTab === 'radio') return null;

  return (
    <div className="fixed bottom-22 left-4 right-4 z-40 max-w-md mx-auto pointer-events-auto transition-all duration-300 animate-slide-up">
      <div
        className="flex items-center justify-between p-2.5 px-4 rounded-2xl border shadow-xl backdrop-blur-md"
        style={{
          backgroundColor: isDark ? 'rgba(20, 26, 46, 0.92)' : 'rgba(255, 255, 255, 0.92)',
          borderColor: isDark ? 'rgba(250, 204, 16, 0.35)' : 'rgba(183, 147, 95, 0.35)',
        }}
      >
        <button
          onClick={() => setActiveTab('radio')}
          className="flex items-center gap-3 overflow-hidden text-right flex-1"
        >
          <div
            className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 ${
              isRadioPlaying
                ? 'bg-[#B7935F] dark:bg-[#facc10] text-white dark:text-[#141A2E]'
                : 'bg-[#B7935F]/15 dark:bg-[#facc10]/15 text-[#B7935F] dark:text-[#facc10]'
            }`}
          >
            <RadioIcon className="w-4 h-4" />
          </div>
          <div className="truncate">
            <h4 className="text-xs font-bold text-gray-800 dark:text-gray-100 truncate">
              {activeRadio.name}
            </h4>
            <div className="flex items-center gap-1.5 text-[10px] text-green-600 dark:text-green-400">
              {isRadioPlaying && <span className="w-1.5 h-1.5 rounded-full bg-green-500 animate-ping" />}
              <span>{isRadioBuffering ? 'جاري التحميل...' : isRadioPlaying ? 'بث مباشر يعمل الآن' : 'متوقف'}</span>
            </div>
          </div>
        </button>

        <div className="flex items-center gap-1 shrink-0 mr-2">
          <button
            onClick={() => (isRadioPlaying ? pauseRadio() : playRadio(activeRadio))}
            className="p-2 rounded-full text-[#B7935F] dark:text-[#facc10] hover:scale-105 active:scale-95 transition-transform"
            aria-label={isRadioPlaying ? 'إيقاف' : 'تشغيل'}
          >
            {isRadioBuffering ? (
              <Loader2 className="w-6 h-6 animate-spin" />
            ) : isRadioPlaying ? (
              <Pause className="w-6 h-6 fill-current" />
            ) : (
              <Play className="w-6 h-6 fill-current" />
            )}
          </button>
          <button
            onClick={pauseRadio}
            className="p-1 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
            title="إغلاق البث"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
};
