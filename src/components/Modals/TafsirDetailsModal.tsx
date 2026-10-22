import React, { useState, useEffect } from 'react';
import { X, Languages, Loader2 } from 'lucide-react';
import { useApp } from '../../context/AppContext';
import { fetchTafsir } from '../../services/api';
import { TafsirAyah } from '../../types';

export const TafsirDetailsModal: React.FC = () => {
  const { closeModal, selectedSurahForTafsir, isDark } = useApp();
  const [tafsirList, setTafsirList] = useState<TafsirAyah[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  const surahNum = selectedSurahForTafsir?.number || 1;
  const surahName = selectedSurahForTafsir?.name || 'الفاتحة';

  useEffect(() => {
    let mounted = true;
    fetchTafsir(surahNum).then((data) => {
      if (mounted) {
        setTafsirList(data);
        setLoading(false);
      }
    });
    return () => {
      mounted = false;
    };
  }, [surahNum]);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div
        className="w-full max-w-lg rounded-3xl p-5 shadow-2xl border border-[#B7935F]/30 overflow-hidden relative max-h-[85vh] flex flex-col"
        style={{ backgroundColor: isDark ? '#141A2E' : '#ffffff' }}
      >
        <div className="flex items-center justify-between pb-3 border-b border-[#B7935F]/20 mb-3">
          <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
            <Languages className="w-6 h-6" />
            <h2 className="text-xl font-bold">تفسير سورة {surahName}</h2>
          </div>
          <button
            onClick={closeModal}
            className="p-1.5 rounded-full hover:bg-black/5 dark:hover:bg-white/10 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto space-y-3 pr-1">
          {loading ? (
            <div className="flex flex-col items-center justify-center py-16 gap-3">
              <Loader2 className="w-8 h-8 text-[#B7935F] animate-spin" />
              <span className="text-xs text-gray-500">جاري تحميل التفسير الميسر...</span>
            </div>
          ) : (
            tafsirList.map((item) => (
              <div
                key={item.verse}
                className="p-4 rounded-2xl bg-white/70 dark:bg-white/5 border border-[#B7935F]/15 space-y-1.5"
              >
                <span className="text-xs font-bold text-[#B7935F] dark:text-[#facc10]">
                  الآية {item.verse}
                </span>
                <p className="text-xs leading-relaxed text-gray-700 dark:text-gray-200 font-serif">
                  {item.text}
                </p>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
