import React, { createContext, useContext, useState, useEffect } from 'react';
import { getSurahForPage, SURAHS_LIST } from '../data/surahs';
import { SurahMeta } from '../types';

export type TabType = 'quran' | 'radio' | 'prayer' | 'settings';
export type ModalType =
  | 'surah_index'
  | 'tafsir_index'
  | 'tafsir_details'
  | 'reciter'
  | 'azkar'
  | 'duas'
  | 'laylat_al_qadr'
  | null;

interface ToastState {
  id: number;
  text: string;
  type: 'success' | 'error' | 'info';
}

interface AppContextType {
  isDark: boolean;
  toggleTheme: (mode?: boolean) => void;
  activeTab: TabType;
  setActiveTab: (tab: TabType) => void;
  currentQuranPage: number; // 1-604
  setCurrentQuranPage: (page: number) => void;
  bookmarkedPage: number | null; // 1-604
  saveBookmark: (page?: number) => void;
  clearBookmark: () => void;
  jumpToPage: (page: number) => void;
  currentSurah: SurahMeta;
  activeModal: ModalType;
  openModal: (modal: ModalType, surahContext?: { number: number; name: string }) => void;
  closeModal: () => void;
  selectedSurahForTafsir: { number: number; name: string } | null;
  setSelectedSurahForTafsir: (s: { number: number; name: string } | null) => void;
  isDrawerOpen: boolean;
  setIsDrawerOpen: (open: boolean) => void;
  isOnline: boolean;
  toasts: ToastState[];
  showToast: (text: string, type?: 'success' | 'error' | 'info') => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isDark, setIsDark] = useState<boolean>(() => {
    const saved = localStorage.getItem('islami_theme');
    if (saved) return saved === 'dark';
    return false; // Flutter default is light
  });

  const [activeTab, setActiveTab] = useState<TabType>('quran');
  const [currentQuranPage, setCurrentQuranPage] = useState<number>(() => {
    const saved = localStorage.getItem('islami_current_page');
    return saved ? Math.max(1, Math.min(604, parseInt(saved, 10))) : 1;
  });

  const [bookmarkedPage, setBookmarkedPage] = useState<number | null>(() => {
    const saved = localStorage.getItem('quran_bookmark');
    return saved ? parseInt(saved, 10) : null;
  });

  const [activeModal, setActiveModal] = useState<ModalType>(null);
  const [selectedSurahForTafsir, setSelectedSurahForTafsir] = useState<{ number: number; name: string } | null>(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState<boolean>(false);
  const [isOnline, setIsOnline] = useState<boolean>(navigator.onLine);
  const [toasts, setToasts] = useState<ToastState[]>([]);

  // Apply dark class to html document
  useEffect(() => {
    if (isDark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
    localStorage.setItem('islami_theme', isDark ? 'dark' : 'light');
  }, [isDark]);

  // Persist current page
  useEffect(() => {
    localStorage.setItem('islami_current_page', currentQuranPage.toString());
  }, [currentQuranPage]);

  // Network listener
  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true);
      showToast('تم استعادة الاتصال بالإنترنت', 'success');
    };
    const handleOffline = () => {
      setIsOnline(false);
      showToast('انقطع الاتصال بالإنترنت', 'error');
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  const toggleTheme = (forcedMode?: boolean) => {
    setIsDark(prev => (forcedMode !== undefined ? forcedMode : !prev));
  };

  const showToast = (text: string, type: 'success' | 'error' | 'info' = 'info') => {
    const id = Date.now();
    setToasts(prev => [...prev, { id, text, type }]);
    setTimeout(() => {
      setToasts(prev => prev.filter(t => t.id !== id));
    }, 3500);
  };

  const saveBookmark = (page?: number) => {
    const target = page || currentQuranPage;
    setBookmarkedPage(target);
    localStorage.setItem('quran_bookmark', target.toString());
    showToast(`تم حفظ العلامة في الصفحة ${target} بنجاح`, 'success');
  };

  const clearBookmark = () => {
    setBookmarkedPage(null);
    localStorage.removeItem('quran_bookmark');
    showToast('تمت إزالة العلامة المحفوظة', 'info');
  };

  const jumpToPage = (page: number) => {
    const validPage = Math.max(1, Math.min(604, page));
    setCurrentQuranPage(validPage);
    setActiveTab('quran');
    setIsDrawerOpen(false);
    setActiveModal(null);
  };

  const openModal = (modal: ModalType, surahContext?: { number: number; name: string }) => {
    if (surahContext) {
      setSelectedSurahForTafsir(surahContext);
    }
    setActiveModal(modal);
    setIsDrawerOpen(false);
  };

  const closeModal = () => {
    setActiveModal(null);
  };

  const currentSurah = getSurahForPage(currentQuranPage);

  return (
    <AppContext.Provider
      value={{
        isDark,
        toggleTheme,
        activeTab,
        setActiveTab,
        currentQuranPage,
        setCurrentQuranPage,
        bookmarkedPage,
        saveBookmark,
        clearBookmark,
        jumpToPage,
        currentSurah,
        activeModal,
        openModal,
        closeModal,
        selectedSurahForTafsir,
        setSelectedSurahForTafsir,
        isDrawerOpen,
        setIsDrawerOpen,
        isOnline,
        toasts,
        showToast,
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};
