import React, { useState, useEffect } from 'react';
import { X, Heart, ArrowRight, Copy, Check, Loader2 } from 'lucide-react';
import { DuasCategory } from '../../types';
import { fetchDuas } from '../../services/api';
import { useApp } from '../../context/AppContext';

export const DuasModal: React.FC = () => {
  const { isDark, closeModal, showToast } = useApp();
  const [categories, setCategories] = useState<DuasCategory[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [selectedCategory, setSelectedCategory] = useState<DuasCategory | null>(null);
  const [copiedIndex, setCopiedIndex] = useState<number | null>(null);

  useEffect(() => {
    let mounted = true;
    fetchDuas().then((data) => {
      if (mounted) {
        setCategories(data);
        setLoading(false);
      }
    });
    return () => {
      mounted = false;
    };
  }, []);

  const handleCopy = (text: string, idx: number) => {
    navigator.clipboard.writeText(text);
    setCopiedIndex(idx);
    showToast('تم نسخ الدعاء إلى الحافظة', 'success');
    setTimeout(() => {
      setCopiedIndex(null);
    }, 2000);
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
                title="رجوع لأقسام الأدعية"
              >
                <ArrowRight className="w-5 h-5" />
              </button>
            )}
            <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
              <Heart className="w-6 h-6" />
              <h2 className="text-xl font-bold">
                {selectedCategory ? selectedCategory.categoryName : 'الأدعية المستجابة'}
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
              <span className="text-sm text-gray-500">جاري تحميل الأدعية...</span>
            </div>
          ) : !selectedCategory ? (
            /* Category Selection */
            <div className="space-y-3">
              <p className="text-xs text-gray-500 dark:text-gray-400 mb-4 text-center">
                اختر قسماً لعرض الأدعية القرآنية والنبوية المأثورة
              </p>
              {categories.map((cat, idx) => (
                <button
                  key={idx}
                  onClick={() => setSelectedCategory(cat)}
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
            /* Duas List */
            <div className="space-y-4">
              {selectedCategory.duas.map((item, idx) => (
                <div
                  key={idx}
                  className={`relative p-5 rounded-2xl border transition-all ${
                    isDark ? 'bg-black/40 border-[#B7935F]/30' : 'bg-gray-50/90 border-[#B7935F]/30'
                  }`}
                >
                  <button
                    onClick={() => handleCopy(item.text, idx)}
                    className="absolute top-3 left-3 p-1.5 rounded-lg hover:bg-black/5 dark:hover:bg-white/10 text-gray-400 hover:text-[#B7935F] transition-colors"
                    title="نسخ الدعاء"
                  >
                    {copiedIndex === idx ? <Check className="w-4 h-4 text-green-500" /> : <Copy className="w-4 h-4" />}
                  </button>

                  <p className="font-quran text-xl sm:text-2xl font-bold leading-relaxed text-center py-2 text-gray-800 dark:text-gray-100">
                    "{item.text}"
                  </p>

                  {item.description && (
                    <p className="text-xs text-[#B7935F] dark:text-[#facc10] text-center mt-2">
                      {item.description}
                    </p>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
