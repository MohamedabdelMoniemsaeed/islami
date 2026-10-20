import React from 'react';
import { BookOpen, Radio, Clock, Settings } from 'lucide-react';
import { TabType, useApp } from '../../context/AppContext';

export const BottomBar: React.FC = () => {
  const { activeTab, setActiveTab, isDark } = useApp();

  const navItems: { id: TabType; label: string; icon: React.FC<{ className?: string }> }[] = [
    { id: 'quran', label: 'المصحف', icon: BookOpen },
    { id: 'radio', label: 'الإذاعة', icon: Radio },
    { id: 'prayer', label: 'مواقيت', icon: Clock },
    { id: 'settings', label: 'الإعدادات', icon: Settings },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 z-30 pointer-events-none pb-4 pt-2 px-4 flex justify-center">
      <nav
        className="pointer-events-auto h-[68px] w-full max-w-md mx-auto rounded-[34px] px-3 flex items-center justify-around shadow-2xl transition-all duration-300 border border-[#B7935F]/20"
        style={{
          backgroundColor: isDark ? '#141A2E' : '#ffffff',
          boxShadow: isDark
            ? '0 10px 25px -5px rgba(0, 0, 0, 0.6), 0 8px 10px -6px rgba(250, 204, 16, 0.15)'
            : '0 10px 25px -5px rgba(0, 0, 0, 0.15), 0 8px 10px -6px rgba(183, 147, 95, 0.2)',
        }}
      >
        {navItems.map((item) => {
          const isSelected = activeTab === item.id;
          const Icon = item.icon;

          return (
            <button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              className="relative flex flex-col items-center justify-center transition-all duration-300 focus:outline-none"
              style={{ width: isSelected ? '58px' : '52px', height: isSelected ? '58px' : '52px' }}
            >
              {isSelected ? (
                <div
                  className="w-13 h-13 rounded-full flex flex-col items-center justify-center transition-transform duration-300 scale-105"
                  style={{
                    backgroundColor: isDark ? '#facc10' : '#B7935F',
                    boxShadow: isDark
                      ? '0 4px 14px 0 rgba(250, 204, 16, 0.45)'
                      : '0 4px 14px 0 rgba(183, 147, 95, 0.45)',
                  }}
                >
                  <Icon
                    className={`w-6 h-6 ${isDark ? 'text-[#141A2E]' : 'text-white'}`}
                  />
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center gap-0.5 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors">
                  <Icon className="w-5 h-5 stroke-[1.8]" />
                  <span className="text-[10px] font-medium leading-none">{item.label}</span>
                </div>
              )}
            </button>
          );
        })}
      </nav>
    </div>
  );
};
