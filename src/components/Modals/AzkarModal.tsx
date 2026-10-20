import React, { useState, useEffect } from 'react';
import { X, Sparkles, ArrowRight, CheckCircle2, RotateCcw, Loader2 } from 'lucide-react';
import { AzkarCategory } from '../../types';
import { fetchAzkar } from '../../services/api';
import { useApp } from '../../context/AppContext';

export const AzkarModal: React.FC = () => {
  const { isDark, closeModal } = useApp();
  const [categories, setCategories] = useState<AzkarCategory[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [selectedCategory, setSelectedCategory] = useState<AzkarCategory | null>(null);
  const [counters, setCounters] = useState<Record<number, number>>({});

  useEffect(() => {
    let mounted = true;
    fetchAzkar().then((data) => {
      if (mounted) {
        setCategories(data);
        setLoading(false);
      }
    });
    return () => {
      mounted = false;
    };
  }, []);

  const handleSelectCategory = (cat: AzkarCategory) => {
    setSelectedCategory(cat);
    // Initialize counters
    const initial: Record<number, number> = {};
    cat.azkar.forEach((item, idx) => {
      initial[idx] = parseInt(item.count, 10) || 1;
    });
    setCounters(initial);
  };

  const handleDecrement = (index: number) => {
    setCounters((prev) => {
      const current = prev[index] ?? 1;
      if (current > 0) {
        return { ...prev, [index]: current - 1 };
      }
      return prev;
    });
  };

  const handleResetCounter = (index: number, originalCount: string) => {
    setCounters((prev) => ({
      ...prev,
      [index]: parseInt(originalCount, 10) || 1,
    }));
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div
        className="w-full max-w-xl h-[92vh] rounded-3xl shadow-2xl flex flex-col overflow-hidden border border-[#B7935F]/30"
        style={{ backgroundColor: isDark ? '#141A2E' : '#ffffff' }}
      >
        {/* Header */}
        <div className="p-4 sm:p-5 flex items-center justify-between border-b border-[#B7935F]/20 bg-[#B7935F]/10 dark:bg-white/5">
          <div className="flex items-center gap-3">
            {selectedCategory && (
              <button
                onClick={() => setSelectedCategory(null)}
                className="p-1.5 rounded-full hover:bg-black/10 dark:hover:bg-white/10 text-[#B7935F] dark:text-[#facc10] transition-colors"
                title="رجوع لأقسام الأذكار"
              >
                <ArrowRight className="w-5 h-5" />
              </button>
            )}
            <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
              <Sparkles className="w-6 h-6" />
              <h2 className="text-xl font-bold">
                {selectedCategory ? selectedCategory.categoryName : 'الأذكار اليومية'}
              </h2>
            </div>
          </div>

          <button
            onClick={closeModal}
            className="p-1.5 rounded-full hover:bg-black/10 dark:hover:bg-white/10 text-gray-500 hover:text-gray-800 dark:hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6">
          {loading ? (
            <div className="flex flex-col items-center justify-center py-20 gap-3">
              <Loader2 className="w-8 h-8 text-[#B7935F] animate-spin" />
              <span className="text-sm text-gray-500">جاري تحميل الأذكار...</span>
            </div>
          ) : !selectedCategory ? (
            /* Category Selection */
            <div className="space-y-3">
              <p className="text-xs text-gray-500 dark:text-gray-400 mb-4 text-center">
                اختر قسماً لعرض الأذكار والتسبيح التفاعلي
              </p>
              {categories.map((cat, idx) => (
                <button
                  key={idx}
                  onClick={() => handleSelectCategory(cat)}
                  className={`w-full p-4.5 rounded-2xl border text-center font-bold text-lg sm:text-xl transition-all shadow-xs hover:scale-[1.01] active:scale-[0.99] focus:outline-none ${
                    isDark
                      ? 'bg-black/40 border-[#B7935F]/30 text-white hover:border-[#facc10]'
                      : 'bg-white border-[#B7935F]/30 text-gray-800 hover:border-[#B7935F]'
                  }`}
                >
                  {cat.categoryName}
                </button>
              ))}
            </div>
          ) : (
            /* Zekr List for Selected Category */
            <div className="space-y-4">
              {selectedCategory.azkar.map((item, idx) => {
                const countLeft = counters[idx] ?? (parseInt(item.count, 10) || 1);
                const isFinished = countLeft === 0;

                return (
                  <div
                    key={idx}
                    className={`p-5 rounded-2xl border transition-all ${
                      isFinished
                        ? 'opacity-80 bg-green-500/10 border-green-500/30'
                        : isDark
                        ? 'bg-black/40 border-[#B7935F]/30'
                        : 'bg-gray-50/90 border-[#B7935F]/30'
                    }`}
                  >
                    <p className="text-lg sm:text-xl font-bold leading-relaxed text-center mb-3 text-gray-800 dark:text-gray-100">
                      {item.zekr}
                    </p>

                    {item.description && (
                      <p className="text-xs sm:text-sm text-[#B7935F] dark:text-[#facc10] text-center mb-4 leading-normal">
                        {item.description}
                      </p>
                    )}

                    <div className="flex items-center justify-center gap-4 pt-2 border-t border-black/5 dark:border-white/5">
                      <button
                        onClick={() => handleDecrement(idx)}
                        disabled={isFinished}
                        className={`w-12 h-12 rounded-full flex items-center justify-center font-bold text-base shadow-md active:scale-90 transition-transform ${
                          isFinished
                            ? 'bg-green-600 text-white cursor-default'
                            : 'bg-[#B7935F] text-white hover:brightness-105'
                        }`}
                        title="انقر للتسبيح"
                      >
                        {isFinished ? <CheckCircle2 className="w-6 h-6" /> : countLeft}
                      </button>

                      {isFinished && (
                        <button
                          onClick={() => handleResetCounter(idx, item.count)}
                          className="p-2 rounded-full hover:bg-black/10 dark:hover:bg-white/10 text-gray-500 transition-colors"
                          title="إعادة التكرار"
                        >
                          <RotateCcw className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
