import React, { useState, useEffect } from 'react';
import { MapPin, Bell, BellRing, RefreshCw, Loader2 } from 'lucide-react';
import { PrayerTimes } from '../../types';
import { fetchPrayerTimes } from '../../services/api';
import { useApp } from '../../context/AppContext';

export const PrayerTimesTab: React.FC = () => {
  const { isDark, showToast } = useApp();
  const [times, setTimes] = useState<PrayerTimes | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [notificationsEnabled, setNotificationsEnabled] = useState<boolean>(() => {
    return localStorage.getItem('islami_prayer_notifications') === 'true';
  });

  const loadData = () => {
    setLoading(true);
    fetchPrayerTimes().then((data) => {
      setTimes(data);
      setLoading(false);
    });
  };

  useEffect(() => {
    loadData();
  }, []);

  const toggleNotifications = async () => {
    if (!notificationsEnabled) {
      if ('Notification' in window) {
        const permission = await Notification.requestPermission();
        if (permission === 'granted') {
          setNotificationsEnabled(true);
          localStorage.setItem('islami_prayer_notifications', 'true');
          showToast('تم تفعيل تنبيهات الأذان بنجاح', 'success');
          new Notification('إسلامي', {
            body: 'تم تفعيل التنبيهات لمواقيت الصلاة اليومية',
            icon: '/assets/images/quran.png',
          });
        } else {
          showToast('يرجى السماح بالإشعارات من إعدادات المتصفح', 'error');
        }
      } else {
        showToast('المتصفح لا يدعم الإشعارات المباشرة', 'error');
      }
    } else {
      setNotificationsEnabled(false);
      localStorage.setItem('islami_prayer_notifications', 'false');
      showToast('تم إلغاء تنبيهات الأذان', 'info');
    }
  };

  const formatTime = (timeStr: string) => {
    if (!timeStr) return { time: '--:--', period: '' };
    // Check if timeStr is 24h format like "04:36" or already has AM/PM
    const parts = timeStr.trim().split(' ');
    if (parts.length > 1) {
      return { time: parts[0], period: parts[1] };
    }
    const [h, m] = timeStr.split(':').map(Number);
    if (isNaN(h)) return { time: timeStr, period: '' };
    const period = h >= 12 ? 'م' : 'ص';
    const hour12 = h % 12 || 12;
    return {
      time: `${hour12.toString().padStart(2, '0')}:${(m || 0).toString().padStart(2, '0')}`,
      period,
    };
  };

  const prayers = times
    ? [
        { name: 'الفجر', key: 'fajr', timeStr: times.fajr },
        { name: 'الشروق', key: 'sunrise', timeStr: times.sunrise },
        { name: 'الظهر', key: 'dhuhr', timeStr: times.dhuhr },
        { name: 'العصر', key: 'asr', timeStr: times.asr },
        { name: 'المغرب', key: 'maghrib', timeStr: times.maghrib },
        { name: 'العشاء', key: 'isha', timeStr: times.isha },
      ]
    : [];

  return (
    <div className="flex flex-col items-center w-full max-w-xl mx-auto px-4 pb-28 pt-2">
      {/* Header matching Flutter App */}
      <div className="flex items-center justify-between w-full max-w-md my-2">
        <button
          onClick={toggleNotifications}
          className={`p-2 rounded-full border transition-colors ${
            notificationsEnabled
              ? 'bg-[#B7935F]/20 border-[#B7935F] text-[#B7935F] dark:text-[#facc10]'
              : 'border-gray-300 dark:border-gray-700 text-gray-400 hover:text-gray-600'
          }`}
          title={notificationsEnabled ? 'تنبيهات الأذان مفعلة' : 'تفعيل تنبيهات الأذان'}
        >
          {notificationsEnabled ? <BellRing className="w-5 h-5" /> : <Bell className="w-5 h-5" />}
        </button>

        <h1 className="text-3xl font-bold text-[#B7935F] dark:text-[#facc10]">
          مواقيت الصلاة
        </h1>

        <button
          onClick={loadData}
          className="p-2 rounded-full border border-gray-300 dark:border-gray-700 text-gray-400 hover:text-[#B7935F] transition-colors"
          title="تحديث المواقيت"
        >
          <RefreshCw className="w-5 h-5" />
        </button>
      </div>

      {loading ? (
        <div className="flex flex-col items-center justify-center py-20 gap-3">
          <Loader2 className="w-8 h-8 text-[#B7935F] animate-spin" />
          <span className="text-sm text-gray-500">جاري تحميل مواقيت الصلاة...</span>
        </div>
      ) : times ? (
        <div className="w-full max-w-md flex flex-col items-center">
          {/* Hijri & Gregorian Dates */}
          <div className="text-center my-1">
            <h2 className="text-lg font-bold text-[#B7935F] dark:text-[#facc10]">
              {times.dayAr} - {times.dateHijri} هـ
            </h2>
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5">{times.dateEn}</p>
            <div className="flex items-center justify-center gap-1 mt-1 text-xs text-gray-500 dark:text-gray-400">
              <MapPin className="w-3.5 h-3.5 text-[#B7935F]" />
              <span>
                {times.region}, {times.country}
              </span>
            </div>
          </div>

          {/* Prayer Cards matching Flutter _buildPrayerItem */}
          <div className="w-full space-y-2.5 mt-4">
            {prayers.map((prayer) => {
              const { time, period } = formatTime(prayer.timeStr);

              return (
                <div
                  key={prayer.key}
                  className={`w-full flex items-center justify-between px-6 py-3.5 rounded-[20px] border-[1.5px] border-[#B7935F] shadow-sm transition-all duration-200 ${
                    isDark ? 'bg-[#141A2E]/70 text-white' : 'bg-white/90 text-gray-900'
                  }`}
                >
                  <span className="text-2xl font-bold text-[#B7935F] dark:text-[#facc10]">
                    {prayer.name}
                  </span>

                  <div className="flex items-baseline gap-1.5" dir="ltr">
                    <span className="text-2xl font-bold tracking-wider">{time}</span>
                    <span className="text-sm font-semibold opacity-75">{period}</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      ) : (
        <div className="text-center py-12 text-gray-500">حدث خطأ في تحميل البيانات</div>
      )}
    </div>
  );
};
