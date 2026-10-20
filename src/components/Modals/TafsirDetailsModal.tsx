import React, { useState, useEffect } from 'react';
import { X, ArrowRight, Loader2, BookOpen } from 'lucide-react';
import { TafsirAyah } from '../../types';
import { fetchTafsir } from '../../services/api';
import { useApp } from '../../context/AppContext';

export const TafsirDetailsModal: React.FC = () => {
  const { isDark, selectedSurahForTafsir, closeModal, openModal } = useApp();
  const [tafsirList, setTafsirList] = useState<TafsirAyah[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  const surahNumber = selectedSurahForTafsir?.number || 1;
  const surahName = selectedSurahForTafsir?.name || 'الفاتحة';

  useEffect(() => {
    let isMounted = true;
    setLoading(true);
    fetchTafsir(surahNumber).then((data) => {
      if (isMounted) {
        setTafsirList(data);
        setLoading(false);
      }
    });
    return () => {
      isMounted = false;
    };
  }, [surahNumber]);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div
        className="w-full max-w-2xl h-[92vh] rounded-3xl shadow-2xl flex flex-col overflow-hidden border border-[#B7935F]/30"
        style={{ backgroundColor: isDark ? '#141A2E' : '#ffffff' }}
      >
        {/* Header matching Flutter app */}
        <div className="p-4 sm:p-5 flex items-center justify-between border-b border-[#B7935F]/20 bg-[#B7935F]/10 dark:bg-white/5">
          <div className="flex items-center gap-3">
            <button
              onClick={() => openModal('tafsir_index')}
              className="p-1.5 rounded-full hover:bg-black/10 dark:hover:bg-white/10 text-[#B7935F] dark:text-[#facc10] transition-colors"
              title="رجوع لفهرس التفسير"
            >
              <ArrowRight className="w-5 h-5" />
            </button>
            <h2 className="text-xl font-bold text-gray-800 dark:text-gray-100">
              تفسير سورة {surahName}
            </h2>
          </div>

          <button
            onClick={closeModal}
            className="p-1.5 rounded-full hover:bg-black/10 dark:hover:bg-white/10 text-gray-500 hover:text-gray-800 dark:hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6 space-y-5">
          {loading ? (
            <div className="flex flex-col items-center justify-center py-24 gap-3">
              <Loader2 className="w-8 h-8 text-[#B7935F] animate-spin" />
              <span className="text-sm text-gray-500">جاري تحميل التفسير الميسر...</span>
            </div>
          ) : tafsirList.length === 0 ? (
            <div className="text-center py-20 text-gray-500">
              <BookOpen className="w-12 h-12 mx-auto text-gray-400 mb-3 opacity-60" />
              <p>التفسير غير متوفر حالياً بدون اتصال بالإنترنت</p>
            </div>
          ) : (
            tafsirList.map((item) => (
              <div
                key={item.aya}
                className={`p-5 rounded-2xl border shadow-sm transition-all ${
                  isDark ? 'bg-black/50 border-[#B7935F]/40' : 'bg-white/95 border-[#B7935F]/30'
                }`}
              >
                {/* Ayah number badge */}
                <div className="flex justify-end mb-3">
                  <span
                    className="px-3.5 py-1 rounded-lg text-xs font-bold text-white shadow-xs"
                    style={{ backgroundColor: '#B7935F' }}
                  >
                    الآية {item.aya}
                  </span>
                </div>

                {/* Quranic Ayah Text */}
                <p className="font-quran text-2xl sm:text-3xl text-center font-bold leading-loose mb-4 text-[#242424] dark:text-[#facc10]">
                  {item.arabic_text}
                </p>

                {/* Divider matching Flutter */}
                <hr className="border-[#B7935F]/40 my-3" />

                {/* Tafsir explanation */}
                <p className="text-base sm:text-lg leading-relaxed text-gray-700 dark:text-gray-200 text-justify">
                  {item.translation}
                </p>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
