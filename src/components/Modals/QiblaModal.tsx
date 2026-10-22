import React from 'react';
import { X, Compass } from 'lucide-react';
import { useApp } from '../../context/AppContext';
import { QiblaCompass } from '../Prayer/QiblaCompass';

export const QiblaModal: React.FC = () => {
  const { closeModal, isDark } = useApp();

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div
        className="w-full max-w-lg rounded-3xl p-5 shadow-2xl border border-[#B7935F]/30 overflow-hidden relative max-h-[90vh] overflow-y-auto"
        style={{
          backgroundColor: isDark ? '#141A2E' : '#ffffff',
        }}
      >
        <div className="flex items-center justify-between pb-3 border-b border-[#B7935F]/20 mb-2">
          <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
            <Compass className="w-6 h-6 animate-spin-slow" />
            <h2 className="text-xl font-bold">اتجاه القبلة والصلاة</h2>
          </div>
          <button
            onClick={closeModal}
            className="p-1.5 rounded-full hover:bg-black/5 dark:hover:bg-white/10 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <QiblaCompass />
      </div>
    </div>
  );
};
