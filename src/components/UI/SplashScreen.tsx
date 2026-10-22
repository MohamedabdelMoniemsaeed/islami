import React, { useState, useEffect } from 'react';

interface SplashScreenProps {
  onFinish?: () => void;
}

export const SplashScreen: React.FC<SplashScreenProps> = ({ onFinish }) => {
  const [visible, setVisible] = useState<boolean>(true);
  const [fadingOut, setFadingOut] = useState<boolean>(false);

  useEffect(() => {
    // Start fade out at 1.7 seconds, fully disappear at 2.0 seconds
    const fadeTimer = setTimeout(() => {
      setFadingOut(true);
    }, 1700);

    const finishTimer = setTimeout(() => {
      setVisible(false);
      if (onFinish) onFinish();
    }, 2000);

    return () => {
      clearTimeout(fadeTimer);
      clearTimeout(finishTimer);
    };
  }, [onFinish]);

  if (!visible) return null;

  return (
    <div
      className={`fixed inset-0 z-[9999] flex flex-col items-center justify-center bg-white dark:bg-[#141A2E] transition-opacity duration-300 pointer-events-none select-none ${
        fadingOut ? 'opacity-0' : 'opacity-100 animate-fade-in'
      }`}
    >
      <div className="relative flex flex-col items-center justify-center p-6 max-w-sm sm:max-w-md w-full">
        <img
          src="/assets/images/2.png"
          alt="إسلامي"
          className="w-full max-h-[75vh] object-contain drop-shadow-2xl animate-scale-up"
          onError={(e) => {
            (e.currentTarget as HTMLImageElement).src = '/2.png';
          }}
        />
        <div className="mt-4 flex items-center gap-2">
          <span className="w-2 h-2 rounded-full bg-[#B7935F] animate-ping" />
          <span className="text-xs font-bold text-[#B7935F] dark:text-[#facc10] tracking-wider">
            إسلامي
          </span>
        </div>
      </div>
    </div>
  );
};
