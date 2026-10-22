import React from 'react';
import { Menu, Moon, Sun } from 'lucide-react';
import { useApp } from '../../context/AppContext';

export const TopNavbar: React.FC = () => {
  const { isDark, toggleTheme, setIsDrawerOpen, currentSurah, currentQuranPage, activeTab } = useApp();

  return (
    <header className="sticky top-0 z-40 w-full bg-white/80 dark:bg-[#101626]/80 backdrop-blur-md border-b border-[#B7935F]/20 px-4 py-3 shadow-sm">
      <div className="max-w-4xl mx-auto flex items-center justify-between">
        <button
          onClick={() => setIsDrawerOpen(true)}
          className="p-2 rounded-xl text-[#B7935F] dark:text-[#facc10] hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
          title="القائمة الجانبية"
          aria-label="القائمة الجانبية"
        >
          <Menu className="w-6 h-6" />
        </button>

        <div className="flex items-center gap-2.5">
          <img
            src="/assets/images/1.png"
            alt="شعار إسلامي"
            className="w-9 h-9 object-contain drop-shadow-sm"
            onError={(e) => {
              (e.currentTarget as HTMLImageElement).src = '/1.png';
            }}
          />
          <div className="text-center">
            <h1 className="text-lg font-bold text-[#B7935F] dark:text-[#facc10] leading-tight">
              إسلامي
            </h1>
            {activeTab === 'quran' && (
              <span className="text-[10px] text-gray-500 dark:text-gray-400">
                سورة {currentSurah.name_ar} • ص {currentQuranPage}
              </span>
            )}
          </div>
        </div>

        <button
          onClick={() => toggleTheme()}
          className="p-2 rounded-xl text-[#B7935F] dark:text-[#facc10] hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
          title={isDark ? 'الوضع المضيء' : 'الوضع الليلي'}
          aria-label="تغيير المظهر"
        >
          {isDark ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
        </button>
      </div>
    </header>
  );
};
