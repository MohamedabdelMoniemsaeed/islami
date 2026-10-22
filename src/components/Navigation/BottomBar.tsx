import React from 'react';
import { BookOpen, Radio, Clock, Settings } from 'lucide-react';
import { useApp, TabType } from '../../context/AppContext';

export const BottomBar: React.FC = () => {
  const { activeTab, setActiveTab, isDark } = useApp();

  const tabs: { id: TabType; label: string; icon: React.ComponentType<{ className?: string }> }[] = [
    { id: 'quran', label: 'المصحف', icon: BookOpen },
    { id: 'radio', label: 'الإذاعة', icon: Radio },
    { id: 'prayer', label: 'مواقيت الصلاة', icon: Clock },
    { id: 'settings', label: 'الإعدادات', icon: Settings },
  ];

  return (
    <nav
      className="fixed bottom-0 left-0 right-0 z-40 max-w-lg mx-auto border-t shadow-lg backdrop-blur-md rounded-t-2xl px-2 py-1.5 flex items-center justify-around"
      style={{
        backgroundColor: isDark ? 'rgba(16, 22, 38, 0.95)' : 'rgba(255, 255, 255, 0.95)',
        borderColor: isDark ? 'rgba(250, 204, 16, 0.2)' : 'rgba(183, 147, 95, 0.2)',
      }}
    >
      {tabs.map((tab) => {
        const Icon = tab.icon;
        const isActive = activeTab === tab.id;

        return (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`flex flex-col items-center gap-1 py-1.5 px-3 rounded-xl transition-all duration-200 ${
              isActive
                ? 'text-[#B7935F] dark:text-[#facc10] font-bold scale-105'
                : 'text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 font-medium'
            }`}
          >
            <Icon className={`w-5 h-5 ${isActive ? 'stroke-[2.5]' : 'stroke-2'}`} />
            <span className="text-[11px]">{tab.label}</span>
          </button>
        );
      })}
    </nav>
  );
};
