import React from 'react';
import {
  BookOpen,
  Bookmark,
  BookmarkCheck,
  Languages,
  ListOrdered,
  Mic,
  Sparkles,
  Heart,
  MoonStar,
  X,
} from 'lucide-react';
import { useApp } from '../../context/AppContext';

export const DrawerMenu: React.FC = () => {
  const {
    isDrawerOpen,
    setIsDrawerOpen,
    isDark,
    openModal,
    saveBookmark,
    bookmarkedPage,
    jumpToPage,
    showToast,
    currentSurah,
  } = useApp();

  if (!isDrawerOpen) return null;

  const handleSaveBookmark = () => {
    saveBookmark();
    setIsDrawerOpen(false);
  };

  const handleJumpToBookmark = () => {
    if (bookmarkedPage) {
      jumpToPage(bookmarkedPage);
      showToast(`تم الانتقال إلى العلامة المحفوظة (صفحة ${bookmarkedPage})`, 'info');
    } else {
      showToast('لا توجد علامة محفوظة حالياً', 'error');
    }
    setIsDrawerOpen(false);
  };

  const handleCurrentTafsir = () => {
    openModal('tafsir_details', {
      number: currentSurah.number,
      name: currentSurah.name_ar,
    });
  };

  const menuItems = [
    {
      title: 'فهرس السور',
      icon: BookOpen,
      action: () => openModal('surah_index'),
    },
    {
      title: 'حفظ علامة',
      icon: Bookmark,
      action: handleSaveBookmark,
    },
    {
      title: 'انتقال إلى العلامة',
      icon: BookmarkCheck,
      action: handleJumpToBookmark,
      badge: bookmarkedPage ? `صفحة ${bookmarkedPage}` : undefined,
    },
    {
      title: 'تفسير الصفحة الحالية',
      icon: Languages,
      action: handleCurrentTafsir,
    },
    {
      title: 'فهرس التفسير (كل السور)',
      icon: ListOrdered,
      action: () => openModal('tafsir_index'),
    },
    {
      title: 'الشيخ محمد صديق المنشاوي',
      icon: Mic,
      action: () => openModal('reciter'),
    },
    {
      title: 'الأذكار',
      icon: Sparkles,
      action: () => openModal('azkar'),
    },
    {
      title: 'الأدعية المستجابة',
      icon: Heart,
      action: () => openModal('duas'),
    },
    {
      title: 'اتجاه القبلة والصلاة',
      icon: MoonStar,
      action: () => {
        setIsDrawerOpen(false);
        openModal('qibla');
      },
    },
    {
      title: 'الاستماع إلى الأذان',
      icon: Mic,
      action: () => {
        setIsDrawerOpen(false);
        openModal('adhan');
      },
    },
    {
      title: 'فضل ليلة القدر',
      icon: MoonStar,
      action: () => openModal('laylat_al_qadr'),
    },
  ];

  return (
    <div className="fixed inset-0 z-50 flex">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/60 backdrop-blur-xs transition-opacity"
        onClick={() => setIsDrawerOpen(false)}
      />

      {/* Drawer content (slides in from right in RTL) */}
      <div
        className="relative mr-auto w-full max-w-[320px] h-full shadow-2xl flex flex-col z-10 transition-transform duration-300"
        style={{
          backgroundColor: isDark ? '#141A2E' : '#ffffff',
        }}
      >
        {/* Header matching Flutter DrawerHeader */}
        <div
          className="p-6 flex flex-col items-center justify-center relative shadow-sm"
          style={{
            backgroundColor: isDark ? '#101626' : '#B7935F',
          }}
        >
          <button
            onClick={() => setIsDrawerOpen(false)}
            className="absolute top-4 left-4 p-1 rounded-full text-white/80 hover:text-white hover:bg-black/10 transition-colors"
            title="إغلاق"
            aria-label="إغلاق"
          >
            <X className="w-5 h-5" />
          </button>

          <img
            src="/assets/images/1.png"
            alt="Islami Logo"
            className="h-20 w-auto object-contain drop-shadow-md mb-2"
            onError={(e) => {
              (e.currentTarget as HTMLImageElement).src = '/1.png';
            }}
          />
          <h2 className="text-xl font-bold text-white tracking-wide">إسلامي</h2>
          <p className="text-xs text-white/80 mt-0.5">رفيقك الإيماني اليومي</p>
        </div>

        {/* Menu list */}
        <div className="flex-1 overflow-y-auto py-2 divide-y divide-[#B7935F]/10 dark:divide-white/5">
          {menuItems.map((item, idx) => {
            const Icon = item.icon;
            return (
              <button
                key={idx}
                onClick={item.action}
                className="w-full px-5 py-3.5 flex items-center justify-between text-right hover:bg-[#B7935F]/10 dark:hover:bg-white/5 transition-colors group focus:outline-none"
              >
                <div className="flex items-center gap-3.5">
                  <div
                    className="p-2 rounded-xl transition-colors"
                    style={{
                      color: isDark ? '#facc10' : '#B7935F',
                      backgroundColor: isDark ? 'rgba(250, 204, 16, 0.1)' : 'rgba(183, 147, 95, 0.1)',
                    }}
                  >
                    <Icon className="w-5 h-5" />
                  </div>
                  <span className="font-bold text-sm sm:text-base text-gray-800 dark:text-gray-100 group-hover:text-[#B7935F] dark:group-hover:text-[#facc10] transition-colors">
                    {item.title}
                  </span>
                </div>

                {item.badge && (
                  <span className="text-xs px-2.5 py-0.5 rounded-full font-medium bg-[#B7935F]/20 text-[#B7935F] dark:bg-[#facc10]/20 dark:text-[#facc10]">
                    {item.badge}
                  </span>
                )}
              </button>
            );
          })}
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-[#B7935F]/15 text-center text-xs text-gray-400 dark:text-gray-500">
          تطبيق إسلامي • الإصدار 1.0.0
        </div>
      </div>
    </div>
  );
};
