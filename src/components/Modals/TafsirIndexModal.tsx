import React from 'react';
import { X, Languages } from 'lucide-react';
import { useApp } from '../../context/AppContext';
import { SURAHS_LIST } from '../../data/surahs';

export const TafsirIndexModal: React.FC = () => {
  const { closeModal, openModal, isDark } = useApp();

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div
        className="w-full max-w-lg rounded-3xl p-5 shadow-2xl border border-[#B7935F]/30 overflow-hidden relative max-h-[85vh] flex flex-col"
        style={{ backgroundColor: isDark ? '#141A2E' : '#ffffff' }}
      >
        <div className="flex items-center justify-between pb-3 border-b border-[#B7935F]/20 mb-3">
          <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
            <Languages className="w-6 h-6" />
            <h2 className="text-xl font-bold">فهرس التفسير الميسر</h2>
          </div>
          <button
            onClick={closeModal}
            className="p-1.5 rounded-full hover:bg-black/5 dark:hover:bg-white/10 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto space-y-2 pr-1">
          {SURAHS_LIST.map((surah) => (
            <button
              key={surah.number}
              onClick={() => {
                openModal('tafsir_details', { number: surah.number, name: surah.name_ar });
              }}
              className="w-full flex items-center justify-between p-3 rounded-2xl bg-white/70 dark:bg-white/5 border border-[#B7935F]/15 hover:border-[#B7935F] transition-all text-right group"
            >
              <div className="flex items-center gap-3">
                <span className="w-8 h-8 rounded-full bg-[#B7935F]/15 text-[#B7935F] dark:text-[#facc10] font-bold text-xs flex items-center justify-center shrink-0">
                  {surah.number}
                </span>
                <div>
                  <h3 className="font-bold text-sm text-gray-800 dark:text-gray-100 group-hover:text-[#B7935F]">
                    تفسير سورة {surah.name_ar}
                  </h3>
                  <p className="text-[11px] text-gray-400">التفسير الميسر المعتمد</p>
                </div>
              </div>
              <span className="text-xs font-semibold px-3 py-1 rounded-xl bg-[#B7935F] text-white">
                عرض
              </span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};
