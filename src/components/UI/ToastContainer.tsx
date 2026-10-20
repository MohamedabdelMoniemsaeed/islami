import React from 'react';
import { useApp } from '../../context/AppContext';
import { CheckCircle2, AlertCircle, Info } from 'lucide-react';

export const ToastContainer: React.FC = () => {
  const { toasts } = useApp();

  if (toasts.length === 0) return null;

  return (
    <div className="fixed top-16 left-0 right-0 z-50 flex flex-col items-center gap-2 pointer-events-none px-4">
      {toasts.map((toast) => {
        const isSuccess = toast.type === 'success';
        const isError = toast.type === 'error';

        return (
          <div
            key={toast.id}
            className={`pointer-events-auto flex items-center gap-2.5 px-4 py-2.5 rounded-xl shadow-lg text-sm font-bold text-white transition-all transform animate-in slide-in-from-top-2 duration-200 max-w-sm ${
              isSuccess
                ? 'bg-green-600'
                : isError
                ? 'bg-red-600'
                : 'bg-[#B7935F]'
            }`}
          >
            {isSuccess ? (
              <CheckCircle2 className="w-4 h-4 shrink-0" />
            ) : isError ? (
              <AlertCircle className="w-4 h-4 shrink-0" />
            ) : (
              <Info className="w-4 h-4 shrink-0" />
            )}
            <span>{toast.text}</span>
          </div>
        );
      })}
    </div>
  );
};
