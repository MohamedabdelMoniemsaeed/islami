import React from 'react';
import { X, Sparkles } from 'lucide-react';
import { useApp } from '../../context/AppContext';

export const AzkarModal: React.FC = () => {
  const { closeModal, isDark } = useApp();

  const azkarList = [
    { title: 'أذكار الصباح', text: 'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له...' },
    { title: 'أذكار المساء', text: 'أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له...' },
    { title: 'أذكار النوم', text: 'باسمك ربي وضعت جنبي وبك أرفعه، إن أمسكت نفسي فارحمنا وإن أرسلتها فاحفظها...' },
    { title: 'الرقية الشرعية', text: 'أعوذ بالله السميع العليم من الشيطان الرجيم من همزه ونفخه ونفثه...' },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div
        className="w-full max-w-lg rounded-3xl p-5 shadow-2xl border border-[#B7935F]/30 overflow-hidden relative max-h-[85vh] flex flex-col"
        style={{ backgroundColor: isDark ? '#141A2E' : '#ffffff' }}
      >
        <div className="flex items-center justify-between pb-3 border-b border-[#B7935F]/20 mb-3">
          <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
            <Sparkles className="w-6 h-6" />
            <h2 className="text-xl font-bold">حصن المسلم - الأذكار</h2>
          </div>
          <button
            onClick={closeModal}
            className="p-1.5 rounded-full hover:bg-black/5 dark:hover:bg-white/10 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto space-y-3 pr-1">
          {azkarList.map((item, idx) => (
            <div key={idx} className="p-4 rounded-2xl bg-white/70 dark:bg-white/5 border border-[#B7935F]/15 space-y-2">
              <h3 className="font-bold text-sm text-[#B7935F] dark:text-[#facc10]">{item.title}</h3>
              <p className="text-xs leading-relaxed text-gray-700 dark:text-gray-200 font-serif">
                {item.text}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
