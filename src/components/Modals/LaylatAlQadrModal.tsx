import React, { useState, useEffect } from 'react';
import { X, MoonStar, Loader2, Sparkles } from 'lucide-react';
import { fetchLaylatAlQadr } from '../../services/api';
import { useApp } from '../../context/AppContext';

export const LaylatAlQadrModal: React.FC = () => {
  const { isDark, closeModal } = useApp();
  const [data, setData] = useState<{ title: string; content: string } | null>(null);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    let mounted = true;
    fetchLaylatAlQadr().then((res) => {
      if (mounted) {
        setData(res);
        setLoading(false);
      }
    });
    return () => {
      mounted = false;
    };
  }, []);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div
        className="w-full max-w-xl h-[90vh] rounded-3xl shadow-2xl flex flex-col overflow-hidden border border-[#B7935F]/30"
        style={{ backgroundColor: isDark ? '#141A2E' : '#ffffff' }}
      >
        {/* Header */}
        <div className="p-4 sm:p-5 flex items-center justify-between border-b border-[#B7935F]/20 bg-[#B7935F]/10 dark:bg-white/5">
          <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
            <MoonStar className="w-6 h-6" />
            <h2 className="text-xl font-bold">{data?.title || 'فضل ليلة القدر وأدعيتها'}</h2>
          </div>

          <button
            onClick={closeModal}
            className="p-1.5 rounded-full hover:bg-black/10 dark:hover:bg-white/10 text-gray-500 hover:text-gray-800 dark:hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content matching Flutter */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6 space-y-6">
          <div className="flex flex-col items-center justify-center pt-2">
            <img
              src="/assets/images/quran.png"
              alt="Quran"
              className="h-28 w-auto object-contain drop-shadow-md"
              onError={(e) => {
                (e.currentTarget as HTMLImageElement).src = '/web/favicon.png';
              }}
            />
          </div>

          {loading ? (
            <div className="flex flex-col items-center justify-center py-12 gap-3">
              <Loader2 className="w-8 h-8 text-[#B7935F] animate-spin" />
              <span className="text-sm text-gray-500">جاري تحميل البيانات...</span>
            </div>
          ) : (
            <div
              className={`p-6 rounded-2xl border shadow-sm ${
                isDark ? 'bg-black/40 border-[#B7935F]/40' : 'bg-gray-50/90 border-[#B7935F]/30'
              }`}
            >
              <div className="whitespace-pre-line text-base sm:text-lg leading-loose text-justify text-gray-800 dark:text-gray-100">
                {data?.content}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
