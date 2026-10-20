import React from 'react';
import { Menu, Bookmark, BookmarkCheck, Moon, Sun, ChevronRight } from 'lucide-react';
import { useApp } from '../../context/AppContext';

export const TopNavbar: React.FC = () => {
  const {
    activeTab,
    isDark,
    toggleTheme,
    setIsDrawerOpen,
    currentQuranPage,
    currentSurah,
    bookmarkedPage,
    saveBookmark,
    openModal,
  } = useApp();

  const isCurrentBookmarked = bookmarkedPage === currentQuranPage;

  return (
    <header className="sticky top-0 z-30 px-4 py-3 flex items-center justify-between backdrop-blur-md bg-white/70 dark:bg-[#141A2E]/80 border-b border-[#B7935F]/20 transition-all duration-300">
      {/* Right side in RTL: Menu Drawer button */}
      <div className="flex items-center gap-3">
        <button
          onClick={() => setIsDrawerOpen(true)}
          className="p-2 rounded-full hover:bg-[#B7935F]/10 active:scale-95 transition-all text-[#B7935F] dark:text-[#facc10]"
          title="القائمة الرئيسية"
          aria-label="القائمة الرئيسية"
        >
          <Menu className="w-8 h-8 stroke-[2.2]" />
        </button>

        {activeTab === 'quran' ? (
          <div className="flex items-center gap-2">
            <button
              onClick={() => openModal('surah_index')}
              className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#B7935F]/15 dark:bg-[#facc10]/15 hover:bg-[#B7935F]/25 text-[#B7935F] dark:text-[#facc10] text-sm font-bold transition-colors"
            >
              <span>سورة {currentSurah.name_ar}</span>
              <span className="text-xs opacity-75">| صفحة {currentQuranPage}</span>
              <ChevronRight className="w-3.5 h-3.5 rotate-180" />
            </button>
          </div>
        ) : (
          <div className="text-lg font-bold text-[#B7935F] dark:text-[#facc10]">
            {activeTab === 'radio' && 'إذاعة القرآن الكريم'}
            {activeTab === 'prayer' && 'مواقيت الصلاة'}
            {activeTab === 'settings' && 'الإعدادات'}
          </div>
        )}
      </div>

      {/* Left side in RTL: Action buttons */}
      <div className="flex items-center gap-2">
        {activeTab === 'quran' && (
          <button
            onClick={() => saveBookmark()}
            className={`p-2 rounded-full transition-all active:scale-90 ${
              isCurrentBookmarked
                ? 'text-[#B7935F] bg-[#B7935F]/20 dark:text-[#facc10] dark:bg-[#facc10]/20'
                : 'text-gray-500 hover:text-[#B7935F] dark:text-gray-400 dark:hover:text-[#facc10]'
            }`}
            title={isCurrentBookmarked ? 'هذه الصفحة محفوظة كعلامة' : 'حفظ الصفحة كعلامة'}
          >
            {isCurrentBookmarked ? <BookmarkCheck className="w-6 h-6 fill-current" /> : <Bookmark className="w-6 h-6" />}
          </button>
        )}

        <button
          onClick={() => toggleTheme()}
          className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/10 text-gray-700 dark:text-gray-200 transition-colors"
          title={isDark ? 'الوضع المضيء' : 'الوضع الليلي'}
          aria-label="تغيير المظهر"
        >
          {isDark ? <Sun className="w-5 h-5 text-[#facc10]" /> : <Moon className="w-5 h-5 text-gray-700" />}
        </button>
      </div>
    </header>
  );
};
