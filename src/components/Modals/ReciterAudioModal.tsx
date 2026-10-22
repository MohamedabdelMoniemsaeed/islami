import React from 'react';
import { X, Mic, Play } from 'lucide-react';
import { useApp } from '../../context/AppContext';

export const ReciterAudioModal: React.FC = () => {
  const { closeModal, playRadio, isDark } = useApp();

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div
        className="w-full max-w-lg rounded-3xl p-5 shadow-2xl border border-[#B7935F]/30 overflow-hidden relative max-h-[85vh] flex flex-col"
        style={{ backgroundColor: isDark ? '#141A2E' : '#ffffff' }}
      >
        <div className="flex items-center justify-between pb-3 border-b border-[#B7935F]/20 mb-3">
          <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
            <Mic className="w-6 h-6" />
            <h2 className="text-xl font-bold">الشيخ محمد صديق المنشاوي</h2>
          </div>
          <button
            onClick={closeModal}
            className="p-1.5 rounded-full hover:bg-black/5 dark:hover:bg-white/10 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto space-y-3 pr-1 text-center py-4">
          <img
            src="https://i.pinimg.com/564x/52/95/ae/5295ae7c08e4ebdc7eda3ddb5c6c0a19.jpg"
            alt="المنشاوي"
            className="w-32 h-32 object-cover rounded-full mx-auto shadow-md border-2 border-[#B7935F]"
          />
          <h3 className="text-lg font-bold text-gray-800 dark:text-gray-100 mt-2">
            إذاعة القارئ الشيخ محمد صديق المنشاوي (المجود)
          </h3>
          <p className="text-xs text-gray-500 dark:text-gray-400 max-w-sm mx-auto">
            استمع إلى تلاوات خاشعة ومجودة بصوت الشيخ محمد صديق المنشاوي متواصلة على مدار الساعة.
          </p>
          <button
            onClick={() => {
              playRadio({
                id: 8888,
                name: "إذاعة الشيخ محمد صديق المنشاوي (المجود)",
                url: "https://qurango.net/radio/mohammed_siddiq_alminshawi_mojawwad"
              });
              closeModal();
            }}
            className="mt-4 px-6 py-3 rounded-2xl text-xs font-bold text-white shadow-lg active:scale-95 transition-all flex items-center justify-center gap-2 mx-auto hover:brightness-105"
            style={{ backgroundColor: '#B7935F' }}
          >
            <Play className="w-4 h-4 fill-current" />
            <span>تشغيل البث الآن</span>
          </button>
        </div>
      </div>
    </div>
  );
};
