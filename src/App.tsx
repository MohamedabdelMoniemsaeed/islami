import React from 'react';
import { useApp } from './context/AppContext';
import { TopNavbar } from './components/Navigation/TopNavbar';
import { BottomBar } from './components/Navigation/BottomBar';
import { DrawerMenu } from './components/Navigation/DrawerMenu';
import { QuranTab } from './components/Quran/QuranTab';
import { RadioTab } from './components/Radio/RadioTab';
import { PrayerTimesTab } from './components/Prayer/PrayerTimesTab';
import { SettingsTab } from './components/Settings/SettingsTab';
import { SurahIndexModal } from './components/Modals/SurahIndexModal';
import { TafsirIndexModal } from './components/Modals/TafsirIndexModal';
import { TafsirDetailsModal } from './components/Modals/TafsirDetailsModal';
import { ReciterAudioModal } from './components/Modals/ReciterAudioModal';
import { AzkarModal } from './components/Modals/AzkarModal';
import { DuasModal } from './components/Modals/DuasModal';
import { LaylatAlQadrModal } from './components/Modals/LaylatAlQadrModal';
import { ToastContainer } from './components/UI/ToastContainer';

export const App: React.FC = () => {
  const { isDark, activeTab, activeModal } = useApp();

  const bgImage = isDark ? '/assets/images/bgDark.png' : '/assets/images/bg3.png';

  return (
    <div
      className="min-h-screen w-full relative flex flex-col font-sans transition-all duration-300"
      style={{
        backgroundImage: `url(${bgImage})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat',
        backgroundAttachment: 'fixed',
      }}
    >
      {/* Background tint overlay for readability */}
      <div
        className={`absolute inset-0 pointer-events-none transition-colors duration-300 ${
          isDark ? 'bg-[#141A2E]/60' : 'bg-white/30'
        }`}
      />

      {/* Main App Container */}
      <div className="relative z-10 flex flex-col min-h-screen">
        <TopNavbar />

        <main className="flex-1 w-full flex flex-col">
          {activeTab === 'quran' && <QuranTab />}
          {activeTab === 'radio' && <RadioTab />}
          {activeTab === 'prayer' && <PrayerTimesTab />}
          {activeTab === 'settings' && <SettingsTab />}
        </main>

        <BottomBar />
      </div>

      {/* Slide-over Drawer Menu */}
      <DrawerMenu />

      {/* Modals & Subscreens */}
      {activeModal === 'surah_index' && <SurahIndexModal />}
      {activeModal === 'tafsir_index' && <TafsirIndexModal />}
      {activeModal === 'tafsir_details' && <TafsirDetailsModal />}
      {activeModal === 'reciter' && <ReciterAudioModal />}
      {activeModal === 'azkar' && <AzkarModal />}
      {activeModal === 'duas' && <DuasModal />}
      {activeModal === 'laylat_al_qadr' && <LaylatAlQadrModal />}

      {/* SnackBar Toasts */}
      <ToastContainer />
    </div>
  );
};

export default App;
