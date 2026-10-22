import React, { createContext, useContext, useState, useEffect } from 'react';
import { getSurahForPage, SURAHS_LIST } from '../data/surahs';
import { RadioItem, SurahMeta } from '../types';

export type TabType = 'quran' | 'radio' | 'prayer' | 'settings';
export type ModalType =
  | 'surah_index'
  | 'tafsir_index'
  | 'tafsir_details'
  | 'reciter'
  | 'azkar'
  | 'duas'
  | 'laylat_al_qadr'
  | 'adhan'
  | 'qibla'
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

  // Quran Full Screen
  isQuranFullScreen: boolean;
  toggleQuranFullScreen: () => void;
  setIsQuranFullScreen: (v: boolean) => void;

  // Global Radio
  activeRadio: RadioItem | null;
  isRadioPlaying: boolean;
  isRadioBuffering: boolean;
  radioVolume: number;
  playRadio: (radio: RadioItem) => void;
  pauseRadio: () => void;
  toggleRadio: (radio: RadioItem) => void;
  setRadioVolume: (vol: number) => void;
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

  // Quran Full Screen State
  const [isQuranFullScreen, setIsQuranFullScreen] = useState<boolean>(false);
  const toggleQuranFullScreen = () => setIsQuranFullScreen(prev => !prev);

  // Global Persistent Radio State
  const [activeRadio, setActiveRadio] = useState<RadioItem | null>(null);
  const [isRadioPlaying, setIsRadioPlaying] = useState<boolean>(false);
  const [isRadioBuffering, setIsRadioBuffering] = useState<boolean>(false);
  const [radioVolume, setRadioVolumeState] = useState<number>(0.85);
  const radioAudioRef = React.useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    const audio = new Audio();
    audio.preload = 'none';
    radioAudioRef.current = audio;

    const handlePlaying = () => {
      setIsRadioPlaying(true);
      setIsRadioBuffering(false);
    };
    const handleWaiting = () => {
      setIsRadioBuffering(true);
    };
    const handlePause = () => {
      setIsRadioPlaying(false);
      setIsRadioBuffering(false);
    };
    const handleError = () => {
      setIsRadioPlaying(false);
      setIsRadioBuffering(false);
      showToast('تعذر الاتصال بهذه الإذاعة، جرب محطة أخرى', 'error');
    };

    audio.addEventListener('playing', handlePlaying);
    audio.addEventListener('waiting', handleWaiting);
    audio.addEventListener('pause', handlePause);
    audio.addEventListener('error', handleError);

    return () => {
      audio.pause();
      audio.removeEventListener('playing', handlePlaying);
      audio.removeEventListener('waiting', handleWaiting);
      audio.removeEventListener('pause', handlePause);
      audio.removeEventListener('error', handleError);
      audio.src = '';
    };
  }, []);

  const playRadio = (radio: RadioItem) => {
    if (!radioAudioRef.current) return;
    setActiveRadio(radio);
    setIsRadioBuffering(true);
    showToast(`جاري تشغيل ${radio.name}...`, 'info');

    radioAudioRef.current.src = radio.url;
    radioAudioRef.current.load();
    radioAudioRef.current.volume = radioVolume;
    radioAudioRef.current
      .play()
      .then(() => {
        setIsRadioPlaying(true);
        setIsRadioBuffering(false);
      })
      .catch((err) => {
        console.warn('Playback error:', err);
        setIsRadioPlaying(false);
        setIsRadioBuffering(false);
      });
  };

  const pauseRadio = () => {
    if (radioAudioRef.current) {
      radioAudioRef.current.pause();
      setIsRadioPlaying(false);
      setIsRadioBuffering(false);
    }
  };

  const toggleRadio = (radio: RadioItem) => {
    if (activeRadio?.id === radio.id && isRadioPlaying) {
      pauseRadio();
    } else {
      playRadio(radio);
    }
  };

  const setRadioVolume = (vol: number) => {
    setRadioVolumeState(vol);
    if (radioAudioRef.current) {
      radioAudioRef.current.volume = vol;
    }
  };

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
        isQuranFullScreen,
        toggleQuranFullScreen,
        setIsQuranFullScreen,
        activeRadio,
        isRadioPlaying,
        isRadioBuffering,
        radioVolume,
        playRadio,
        pauseRadio,
        toggleRadio,
        setRadioVolume,
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
