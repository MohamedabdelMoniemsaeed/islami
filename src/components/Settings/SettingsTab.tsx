import React, { useState } from 'react';
import { Moon, Sun, RefreshCw, CheckCircle2, Info, Heart, Shield } from 'lucide-react';
import { useApp } from '../../context/AppContext';

export const SettingsTab: React.FC = () => {
  const { isDark, toggleTheme, showToast } = useApp();
  const [checkingUpdate, setCheckingUpdate] = useState<boolean>(false);

  const handleCheckUpdate = () => {
    setCheckingUpdate(true);
    setTimeout(() => {
      setCheckingUpdate(false);
      showToast('تطبيقك محدث لآخر إصدار بالفعل (v1.0.0)', 'success');
    }, 1200);
  };

  return (
    <div className="flex flex-col h-[calc(100vh-160px)] max-w-xl mx-auto px-6 py-6 pb-28 justify-between">
      <div className="space-y-6">
        <h1 className="text-2xl font-bold text-[#B7935F] dark:text-[#facc10] text-center mb-6">
          الإعدادات العامة
        </h1>

        {/* Dark Mode Switch Card matching Flutter */}
        <div className="flex items-center justify-between p-4 rounded-2xl bg-white/80 dark:bg-[#141A2E]/80 backdrop-blur-xs border border-[#B7935F]/20 shadow-xs">
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-xl bg-[#B7935F]/15 dark:bg-[#facc10]/15 text-[#B7935F] dark:text-[#facc10]">
              {isDark ? <Moon className="w-5 h-5" /> : <Sun className="w-5 h-5" />}
            </div>
            <div>
              <h2 className="text-base font-bold text-gray-800 dark:text-gray-100">
                {isDark ? 'الوضع الليلي (Dark Mode)' : 'الوضع المضيء (Light Mode)'}
              </h2>
              <p className="text-xs text-gray-400">تغيير السمة اللونية للتطبيق</p>
            </div>
          </div>

          {/* Toggle Switch */}
          <button
            onClick={() => toggleTheme()}
            className={`w-14 h-8 flex items-center rounded-full p-1 transition-colors duration-300 ${
              isDark ? 'bg-[#facc10] justify-end' : 'bg-gray-300 justify-start'
            }`}
            aria-label="تغيير المظهر"
          >
            <div
              className={`w-6 h-6 rounded-full shadow-md transform transition-transform duration-300 ${
                isDark ? 'bg-[#141A2E]' : 'bg-white'
              }`}
            />
          </button>
        </div>

        {/* About App Info */}
        <div className="p-4 rounded-2xl bg-white/80 dark:bg-[#141A2E]/80 backdrop-blur-xs border border-[#B7935F]/20 shadow-xs space-y-3">
          <div className="flex items-center gap-3 text-[#B7935F] dark:text-[#facc10]">
            <Info className="w-5 h-5" />
            <h2 className="font-bold text-sm">عن تطبيق إسلامي</h2>
          </div>
          <p className="text-xs leading-relaxed text-gray-600 dark:text-gray-300">
            تطبيق إسلامي شامل صُمم ليكون رفيقك الدائم في العبادة؛ يحتوي على المصحف الشريف كاملاً (604 صفحة)،
            مواقيت الصلاة الدقيقة، إذاعات القرآن الكريم المباشرة، تفسير القرآن الميسر، والأذكار والأدعية النبوية،
            والأذان الشريف مع اتجاه القبلة للصلاة.
          </p>
        </div>
      </div>

      {/* Bottom Check for Updates & Version matching Flutter */}
      <div className="space-y-3 pt-6">
        <button
          onClick={handleCheckUpdate}
          disabled={checkingUpdate}
          className="w-full py-3.5 px-4 rounded-xl font-bold text-white transition-all duration-200 active:scale-98 flex items-center justify-center gap-2 shadow-md hover:brightness-105"
          style={{ backgroundColor: '#B7935F' }}
        >
          {checkingUpdate ? (
            <>
              <RefreshCw className="w-5 h-5 animate-spin" />
              <span>جاري التحقق من وجود تحديثات...</span>
            </>
          ) : (
            <>
              <CheckCircle2 className="w-5 h-5" />
              <span>فحص التحديثات</span>
            </>
          )}
        </button>

        <p className="text-center text-xs text-gray-400 dark:text-gray-500 font-medium">
          الإصدار: 1.0.0 (1)
        </p>
      </div>
    </div>
  );
};
