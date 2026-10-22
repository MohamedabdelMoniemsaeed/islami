import React, { useState, useEffect, useRef } from 'react';
import {
  ChevronRight,
  ChevronLeft,
  Bookmark,
  ZoomIn,
  ZoomOut,
  RotateCcw,
  Maximize2,
  Minimize2,
  BookOpen,
} from 'lucide-react';
import { useApp } from '../../context/AppContext';

export const QuranTab: React.FC = () => {
  const {
    currentQuranPage,
    setCurrentQuranPage,
    bookmarkedPage,
    saveBookmark,
    currentSurah,
    openModal,
    showToast,
    isQuranFullScreen,
    toggleQuranFullScreen,
  } = useApp();

  const [zoomLevel, setZoomLevel] = useState<number>(1);
  const [touchStartX, setTouchStartX] = useState<number | null>(null);
  const [touchStartY, setTouchStartY] = useState<number | null>(null);
  const [inputPage, setInputPage] = useState<string>(currentQuranPage.toString());
  const [imageLoaded, setImageLoaded] = useState<boolean>(false);
  const [showControls, setShowControls] = useState<boolean>(true);
  const containerRef = useRef<HTMLDivElement>(null);

  // Sync input with page
  useEffect(() => {
    setInputPage(currentQuranPage.toString());
    setImageLoaded(false);
  }, [currentQuranPage]);

  // Preload next and previous pages for instant zero-lag rendering
  useEffect(() => {
    const preloadPages = [currentQuranPage - 1, currentQuranPage + 1, currentQuranPage + 2];
    preloadPages.forEach((p) => {
      if (p >= 1 && p <= 604) {
        const img = new Image();
        img.src = `/assets/images/quran/${p.toString().padStart(3, '0')}.png`;
      }
    });
  }, [currentQuranPage]);

  // Page navigation: In Arabic Mushaf, next page is leftwards (page + 1)
  const nextPage = () => {
    if (currentQuranPage < 604) {
      setCurrentQuranPage(currentQuranPage + 1);
    }
  };

  const prevPage = () => {
    if (currentQuranPage > 1) {
      setCurrentQuranPage(currentQuranPage - 1);
    }
  };

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.target instanceof HTMLInputElement) return;
      if (e.key === 'ArrowLeft') {
        nextPage();
      } else if (e.key === 'ArrowRight') {
        prevPage();
      } else if (e.key === 'f' || e.key === 'F') {
        toggleQuranFullScreen();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentQuranPage]);

  // Touch Swipe handlers: Reversing direction so page 1 to 2 moves in authentic Arabic Mushaf direction
  const handleTouchStart = (e: React.TouchEvent) => {
    setTouchStartX(e.touches[0].clientX);
    setTouchStartY(e.touches[0].clientY);
  };

  const handleTouchEnd = (e: React.TouchEvent) => {
    if (touchStartX === null || touchStartY === null) return;
    const touchEndX = e.changedTouches[0].clientX;
    const touchEndY = e.changedTouches[0].clientY;
    const diffX = touchEndX - touchStartX;
    const diffY = touchEndY - touchStartY;

    // Horizontal swipe threshold
    if (Math.abs(diffX) > 35 && Math.abs(diffX) > Math.abs(diffY)) {
      if (diffX < 0) {
        // Swiped Right to Left -> Advance forward from page 1 to 2
        nextPage();
      } else {
        // Swiped Left to Right -> Go back to previous page
        prevPage();
      }
    }
    setTouchStartX(null);
    setTouchStartY(null);
  };

  const handleCenterTap = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const clickX = e.clientX - rect.left;
    const width = rect.width;

    // Left 22% -> next page (1 -> 2)
    if (clickX < width * 0.22) {
      nextPage();
      return;
    }
    // Right 22% -> prev page (2 -> 1)
    if (clickX > width * 0.78) {
      prevPage();
      return;
    }
    // Center 56% -> toggle controls overlay
    setShowControls((prev) => !prev);
  };

  const handleJumpSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const val = parseInt(inputPage, 10);
    if (!isNaN(val) && val >= 1 && val <= 604) {
      setCurrentQuranPage(val);
    } else {
      setInputPage(currentQuranPage.toString());
      showToast('الرجاء إدخال رقم صفحة بين 1 و 604', 'error');
    }
  };

  const pageStr = currentQuranPage.toString().padStart(3, '0');
  const isBookmarked = bookmarkedPage === currentQuranPage;

  return (
    <div
      className={`relative flex flex-col w-full mx-auto select-none transition-all duration-300 ${
        isQuranFullScreen
          ? 'fixed inset-0 z-50 bg-[#f8f9fa] dark:bg-[#0e1322] h-screen w-screen p-0 m-0 overflow-hidden'
          : 'h-[calc(100vh-130px)] sm:h-[calc(100vh-140px)] max-w-5xl overflow-hidden'
      }`}
    >
      {/* Top Quran Bar: Quick jump, Surah info, Bookmark, and Full Screen Toggle */}
      <div
        className={`flex items-center justify-between px-3 py-1.5 bg-white/90 dark:bg-[#141A2E]/90 backdrop-blur-md border border-[#B7935F]/20 rounded-xl mx-2 my-1 z-30 transition-all duration-300 shadow-xs ${
          isQuranFullScreen && !showControls ? '-translate-y-16 opacity-0 pointer-events-none' : 'translate-y-0 opacity-100'
        }`}
      >
        <button
          onClick={() => openModal('surah_index')}
          className="font-bold text-[#B7935F] dark:text-[#facc10] hover:underline flex items-center gap-1.5 text-xs sm:text-sm"
        >
          <BookOpen className="w-4 h-4" />
          <span>سورة {currentSurah.name_ar}</span>
          <span className="text-[10px] opacity-75 hidden sm:inline">
            ({currentSurah.type === 'Meccan' ? 'مكية' : 'مدنية'})
          </span>
        </button>

        <form onSubmit={handleJumpSubmit} className="flex items-center gap-1 text-xs">
          <span className="text-gray-500 dark:text-gray-400">صفحة:</span>
          <input
            type="number"
            min={1}
            max={604}
            value={inputPage}
            onChange={(e) => setInputPage(e.target.value)}
            className="w-13 text-center font-bold px-1 py-0.5 rounded border border-[#B7935F]/40 bg-white dark:bg-[#141A2E] text-gray-800 dark:text-gray-100 focus:ring-1 focus:ring-[#B7935F] outline-none"
          />
          <span className="text-gray-400 dark:text-gray-500">/ 604</span>
        </form>

        <div className="flex items-center gap-1">
          {/* Bookmark Button */}
          <button
            onClick={() => saveBookmark(currentQuranPage)}
            className={`p-1.5 rounded-lg border transition-all ${
              isBookmarked
                ? 'bg-[#B7935F] text-white border-[#B7935F]'
                : 'border-transparent text-gray-600 dark:text-gray-300 hover:bg-black/5 dark:hover:bg-white/10'
            }`}
            title={isBookmarked ? 'هذه الصفحة محفوظة كعلامة' : 'حفظ كعلامة قراءة'}
          >
            <Bookmark className={`w-4 h-4 ${isBookmarked ? 'fill-current' : ''}`} />
          </button>

          {/* Zoom Buttons */}
          <button
            onClick={() => setZoomLevel((z) => Math.min(1.8, z + 0.15))}
            className="p-1.5 rounded-lg hover:bg-black/5 dark:hover:bg-white/10 text-gray-600 dark:text-gray-300"
            title="تكبير"
          >
            <ZoomIn className="w-4 h-4" />
          </button>
          <button
            onClick={() => setZoomLevel((z) => Math.max(1, z - 0.15))}
            className="p-1.5 rounded-lg hover:bg-black/5 dark:hover:bg-white/10 text-gray-600 dark:text-gray-300"
            title="تصغير"
          >
            <ZoomOut className="w-4 h-4" />
          </button>

          {/* Full Screen Toggle Button */}
          <button
            onClick={toggleQuranFullScreen}
            className="p-1.5 rounded-lg bg-[#B7935F]/15 dark:bg-[#facc10]/15 text-[#B7935F] dark:text-[#facc10] hover:scale-105 active:scale-95 transition-transform"
            title={isQuranFullScreen ? 'الخروج من ملء الشاشة' : 'عرض ملء الصفحة بالكامل'}
          >
            {isQuranFullScreen ? <Minimize2 className="w-4 h-4" /> : <Maximize2 className="w-4 h-4" />}
          </button>
        </div>
      </div>

      {/* Main Full-Page Quran Display */}
      <div
        ref={containerRef}
        onTouchStart={handleTouchStart}
        onTouchEnd={handleTouchEnd}
        onClick={handleCenterTap}
        className={`relative flex-1 w-full flex items-center justify-center cursor-pointer overflow-hidden ${
          isQuranFullScreen ? 'h-full p-0' : 'p-1'
        }`}
      >
        {/* Bookmark Ribbon */}
        {isBookmarked && (
          <div
            className="absolute top-0 left-6 sm:left-10 z-20 w-8 sm:w-10 h-20 sm:h-24 rounded-b-xl flex flex-col items-center justify-end pb-3 text-white shadow-xl animate-bounce"
            style={{
              backgroundColor: '#B7935F',
              boxShadow: '0 4px 15px rgba(0, 0, 0, 0.4)',
            }}
          >
            <Bookmark className="w-5 h-5 fill-white" />
          </div>
        )}

        {/* The Quran Image: Takes full height & natural width without borders clipping */}
        <div
          className="relative h-full w-full flex items-center justify-center transition-transform duration-200"
          style={{ transform: `scale(${zoomLevel})` }}
        >
          {!imageLoaded && (
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-2">
              <div className="w-10 h-10 border-3 border-[#B7935F] border-t-transparent rounded-full animate-spin" />
              <span className="text-xs text-[#B7935F] font-bold">جاري فتح الصفحة {currentQuranPage}...</span>
            </div>
          )}

          <img
            src={`/assets/images/quran/${pageStr}.png`}
            alt={`القرآن الكريم صفحة ${currentQuranPage}`}
            onLoad={() => setImageLoaded(true)}
            className={`h-full w-auto max-w-full object-contain shadow-md rounded-md transition-opacity duration-200 ${
              imageLoaded ? 'opacity-100' : 'opacity-0'
            }`}
            draggable={false}
          />
        </div>

        {/* Left Arrow: Next page (advances forward from 1 to 2 in Arabic Mushaf) */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            nextPage();
          }}
          disabled={currentQuranPage >= 604}
          className={`absolute left-2 sm:left-4 z-20 p-2.5 rounded-full bg-white/80 dark:bg-[#141A2E]/80 hover:bg-white dark:hover:bg-[#141A2E] shadow-md text-[#B7935F] dark:text-[#facc10] disabled:opacity-0 transition-all active:scale-95 ${
            isQuranFullScreen && !showControls ? 'opacity-0 pointer-events-none' : 'opacity-85 hover:opacity-100'
          }`}
          title="الصفحة التالية (1 إلى 2)"
          aria-label="الصفحة التالية"
        >
          <ChevronLeft className="w-6 h-6 stroke-[2.5]" />
        </button>

        {/* Right Arrow: Previous page (goes back in Arabic Mushaf) */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            prevPage();
          }}
          disabled={currentQuranPage <= 1}
          className={`absolute right-2 sm:right-4 z-20 p-2.5 rounded-full bg-white/80 dark:bg-[#141A2E]/80 hover:bg-white dark:hover:bg-[#141A2E] shadow-md text-[#B7935F] dark:text-[#facc10] disabled:opacity-0 transition-all active:scale-95 ${
            isQuranFullScreen && !showControls ? 'opacity-0 pointer-events-none' : 'opacity-85 hover:opacity-100'
          }`}
          title="الصفحة السابقة"
          aria-label="الصفحة السابقة"
        >
          <ChevronRight className="w-6 h-6 stroke-[2.5]" />
        </button>
      </div>

      {/* Floating Bottom Slider & Page Navigation */}
      <div
        className={`px-4 py-2 flex items-center gap-3 bg-white/90 dark:bg-[#141A2E]/90 backdrop-blur-md rounded-xl mx-2 mb-1 border border-[#B7935F]/20 shadow-xs z-30 transition-all duration-300 ${
          isQuranFullScreen && !showControls ? 'translate-y-16 opacity-0 pointer-events-none' : 'translate-y-0 opacity-100'
        }`}
      >
        <span className="text-xs text-gray-500 font-bold min-w-[20px]">1</span>
        <input
          type="range"
          min={1}
          max={604}
          value={currentQuranPage}
          onChange={(e) => setCurrentQuranPage(parseInt(e.target.value, 10))}
          className="w-full accent-[#B7935F] dark:accent-[#facc10] cursor-pointer"
        />
        <span className="text-xs text-gray-500 font-bold min-w-[24px]">604</span>
      </div>
    </div>
  );
};
