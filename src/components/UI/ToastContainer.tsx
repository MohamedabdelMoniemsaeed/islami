import React from 'react';
import { useApp } from '../../context/AppContext';
import { CheckCircle2, AlertCircle, Info } from 'lucide-react';

export const ToastContainer: React.FC = () => {
  const { toasts } = useApp();

  if (toasts.length === 0) return null;

  return (
    <div className="fixed top-16 left-4 right-4 z-50 flex flex-col items-center gap-2 pointer-events-none max-w-sm mx-auto">
      {toasts.map((t) => (
        <div
          key={t.id}
          className={`w-full flex items-center gap-3 px-4 py-3 rounded-2xl shadow-xl text-white text-xs font-bold pointer-events-auto transition-all animate-slide-down ${
            t.type === 'success'
              ? 'bg-green-600'
              : t.type === 'error'
              ? 'bg-red-600'
              : 'bg-[#B7935F]'
          }`}
        >
          {t.type === 'success' && <CheckCircle2 className="w-5 h-5 shrink-0" />}
          {t.type === 'error' && <AlertCircle className="w-5 h-5 shrink-0" />}
          {t.type === 'info' && <Info className="w-5 h-5 shrink-0" />}
          <span className="flex-1">{t.text}</span>
        </div>
      ))}
    </div>
  );
};
