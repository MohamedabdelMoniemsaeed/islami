import React, { useState, useEffect, useRef } from 'react';
import { ChevronRight, ChevronLeft, Bookmark, ZoomIn, ZoomOut, RotateCcw, Share2, Layers } from 'lucide-react';
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
  } = useApp();

  const [zoomLevel, setZoomLevel] = useState<number>(1);
  const [touchStartX, setTouchStartX] = useState<number | null>(null);
  const [inputPage, setInputPage] = useState<string>(currentQuranPage.toString());
  const [imageLoaded, setImageLoaded] = useState<boolean>(false);
  const containerRef = useRef<HTMLDivElement>(null);

  // Sync input with page
  useEffect(() => {
    setInputPage(currentQuranPage.toString());
    setImageLoaded(false);
  }, [currentQuranPage]);

  // Preload next and previous pages for instant responsiveness
  useEffect(() => {
    const preloadPages = [currentQuranPage - 1, currentQuranPage + 1];
    preloadPages.forEach((p) => {
      if (p >= 1 && p <= 604) {
        const img = new Image();
        img.src = `/assets/images/quran/${p.toString().padStart(3, '0')}.png`;
      }
    });
  }, [currentQuranPage]);

  // Page turning: In Arabic Quran reading, flipping forward moves from right to left (next page is page+1)
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
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentQuranPage]);

  // Touch Swipe handlers
  const handleTouchStart = (e: React.TouchEvent) => {
    setTouchStartX(e.touches[0].clientX);
  };

  const handleTouchEnd = (e: React.TouchEvent) => {
    if (touchStartX === null) return;
    const touchEndX = e.changedTouches[0].clientX;
    const diff = touchStartX - touchEndX;

    // Minimum swipe threshold
    if (Math.abs(diff) > 50) {
      if (diff > 0) {
        // Swiped left -> next page
        nextPage();
      } else {
        // Swiped right -> prev page
        prevPage();
      }
    }
    setTouchStartX(null);
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
    <div className="relative flex flex-col h-[calc(100vh-140px)] w-full max-w-4xl mx-auto overflow-hidden">
      {/* Top Quran Bar: Quick jump and Surah info */}
      <div className="flex items-center justify-between px-3 py-1.5 bg-black/5 dark:bg-white/5 backdrop-blur-xs rounded-xl mx-2 my-1 text-xs">
        <button
          onClick={() => openModal('surah_index')}
          className="font-bold text-[#B7935F] dark:text-[#facc10] hover:underline flex items-center gap-1"
        >
          <span>سورة {currentSurah.name_ar}</span>
          <span className="opacity-70">({currentSurah.type === 'Meccan' ? 'مكية' : 'مدنية'})</span>
        </button>

        <form onSubmit={handleJumpSubmit} className="flex items-center gap-1.5">
          <span className="text-gray-500 dark:text-gray-400">صفحة:</span>
          <input
            type="number"
            min={1}
            max={604}
            value={inputPage}
            onChange={(e) => setInputPage(e.target.value)}
            className="w-14 text-center font-bold px-1.5 py-0.5 rounded border border-[#B7935F]/40 bg-white dark:bg-[#141A2E] text-gray-800 dark:text-gray-100 text-xs focus:ring-1 focus:ring-[#B7935F] outline-none"
          />
          <span className="text-gray-400 dark:text-gray-500">/ 604</span>
        </form>

        <div className="flex items-center gap-1">
          <button
            onClick={() => setZoomLevel((z) => Math.min(1.6, z + 0.15))}
            className="p-1 rounded hover:bg-black/10 dark:hover:bg-white/10 text-gray-600 dark:text-gray-300"
            title="تكبير"
          >
            <ZoomIn className="w-4 h-4" />
          </button>
          <button
            onClick={() => setZoomLevel((z) => Math.max(1, z - 0.15))}
            className="p-1 rounded hover:bg-black/10 dark:hover:bg-white/10 text-gray-600 dark:text-gray-300"
            title="تصغير"
          >
            <ZoomOut className="w-4 h-4" />
          </button>
          {zoomLevel > 1 && (
            <button
              onClick={() => setZoomLevel(1)}
              className="p-1 rounded hover:bg-black/10 dark:hover:bg-white/10 text-gray-600 dark:text-gray-300"
              title="إعادة ضبط"
            >
              <RotateCcw className="w-3.5 h-3.5" />
            </button>
          )}
        </div>
      </div>

      {/* Main Quran Page Canvas with Bookmark Ribbon */}
      <div
        ref={containerRef}
        onTouchStart={handleTouchStart}
        onTouchEnd={handleTouchEnd}
        className="relative flex-1 flex items-center justify-center p-1 sm:p-2 overflow-auto"
      >
        {/* Bookmark Ribbon matching Flutter design */}
        {isBookmarked && (
          <div
            className="absolute top-0 left-6 z-20 w-9 sm:w-10 h-20 sm:h-24 rounded-b-xl flex flex-col items-center justify-end pb-3 text-white shadow-lg animate-bounce"
            style={{
              backgroundColor: '#B7935F',
              boxShadow: '0 4px 15px rgba(0, 0, 0, 0.35)',
            }}
          >
            <Bookmark className="w-5 h-5 fill-white" />
          </div>
        )}

        {/* Quran Image Page */}
        <div
          className="relative max-h-full max-w-full flex items-center justify-center transition-transform duration-200"
          style={{ transform: `scale(${zoomLevel})` }}
        >
          {!imageLoaded && (
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="w-8 h-8 border-3 border-[#B7935F] border-t-transparent rounded-full animate-spin" />
            </div>
          )}

          <img
            src={`/assets/images/quran/${pageStr}.png`}
            alt={`القرآن الكريم صفحة ${currentQuranPage}`}
            onLoad={() => setImageLoaded(true)}
            className={`max-h-[75vh] w-auto max-w-full object-contain rounded-lg shadow-md transition-opacity duration-200 ${
              imageLoaded ? 'opacity-100' : 'opacity-0'
            }`}
            draggable={false}
          />
        </div>

        {/* Flank Navigation Buttons for desktop / tablet */}
        <button
          onClick={prevPage}
          disabled={currentQuranPage <= 1}
          className="absolute right-2 sm:right-4 z-10 p-2 sm:p-3 rounded-full bg-white/70 dark:bg-[#141A2E]/70 hover:bg-white dark:hover:bg-[#141A2E] shadow-md text-[#B7935F] dark:text-[#facc10] disabled:opacity-20 disabled:pointer-events-none transition-all active:scale-95"
          title="الصفحة السابقة"
          aria-label="الصفحة السابقة"
        >
          <ChevronRight className="w-6 h-6 stroke-[2.5]" />
        </button>

        <button
          onClick={nextPage}
          disabled={currentQuranPage >= 604}
          className="absolute left-2 sm:left-4 z-10 p-2 sm:p-3 rounded-full bg-white/70 dark:bg-[#141A2E]/70 hover:bg-white dark:hover:bg-[#141A2E] shadow-md text-[#B7935F] dark:text-[#facc10] disabled:opacity-20 disabled:pointer-events-none transition-all active:scale-95"
          title="الصفحة التالية"
          aria-label="الصفحة التالية"
        >
          <ChevronLeft className="w-6 h-6 stroke-[2.5]" />
        </button>
      </div>

      {/* Quick Bottom Control Slider */}
      <div className="px-4 py-1.5 flex items-center gap-3 bg-white/50 dark:bg-[#141A2E]/50 backdrop-blur-xs rounded-xl mx-2 mb-1">
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
