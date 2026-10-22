import React, { useState, useEffect } from 'react';
import {
  MapPin,
  Bell,
  BellRing,
  RefreshCw,
  Loader2,
  Compass,
  Clock,
  Play,
  Volume2,
  Sparkles,
} from 'lucide-react';
import { PrayerTimes } from '../../types';
import { fetchPrayerTimes } from '../../services/api';
import { useApp } from '../../context/AppContext';
import { QiblaCompass } from './QiblaCompass';

export const PrayerTimesTab: React.FC = () => {
  const { isDark, showToast, openModal } = useApp();
  const [subView, setSubView] = useState<'prayers' | 'qibla'>('prayers');
  const [times, setTimes] = useState<PrayerTimes | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [notificationsEnabled, setNotificationsEnabled] = useState<boolean>(() => {
    return localStorage.getItem('islami_prayer_notifications') === 'true';
  });

  // Track enabled prayer alarms individually
  const [prayerAlarms, setPrayerAlarms] = useState<Record<string, boolean>>(() => {
    const saved = localStorage.getItem('islami_individual_prayer_alarms');
    return saved
      ? JSON.parse(saved)
      : { fajr: true, sunrise: false, dhuhr: true, asr: true, maghrib: true, isha: true };
  });

  // Countdown to next prayer
  const [nextPrayerInfo, setNextPrayerInfo] = useState<{
    name: string;
    remaining: string;
  } | null>(null);

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

  const toggleAlarm = (key: string) => {
    setPrayerAlarms((prev) => {
      const updated = { ...prev, [key]: !prev[key] };
      localStorage.setItem('islami_individual_prayer_alarms', JSON.stringify(updated));
      showToast(
        updated[key] ? 'تم تفعيل تنبيه هذا الوقت' : 'تم كتم تنبيه هذا الوقت',
        'info'
      );
      return updated;
    });
  };

  const toggleNotifications = async () => {
    if (!notificationsEnabled) {
      if ('Notification' in window) {
        const permission = await Notification.requestPermission();
        if (permission === 'granted') {
          setNotificationsEnabled(true);
          localStorage.setItem('islami_prayer_notifications', 'true');
          showToast('تم تفعيل تنبيهات الأذان بنجاح', 'success');
          new Notification('إسلامي', {
            body: 'تم تفعيل التنبيهات لمواقيت الصلاة والأذان',
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

  // Calculate next prayer countdown with live ticking seconds
  useEffect(() => {
    if (!times) return;

    const calcNext = () => {
      const now = new Date();
      const currentSeconds = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds();

      const raw = times.rawTimes;
      const prayerList = raw
        ? [
            { name: 'الفجر', key: 'fajr', time: raw.fajr },
            { name: 'الظهر', key: 'dhuhr', time: raw.dhuhr },
            { name: 'العصر', key: 'asr', time: raw.asr },
            { name: 'المغرب', key: 'maghrib', time: raw.maghrib },
            { name: 'العشاء', key: 'isha', time: raw.isha },
          ]
        : [
            { name: 'الفجر', key: 'fajr', time: '04:35' },
            { name: 'الظهر', key: 'dhuhr', time: '11:41' },
            { name: 'العصر', key: 'asr', time: '14:52' },
            { name: 'المغرب', key: 'maghrib', time: '17:17' },
            { name: 'العشاء', key: 'isha', time: '18:35' },
          ];

      for (const p of prayerList) {
        const [h, m] = p.time.split(':').map(Number);
        const pSeconds = h * 3600 + (m || 0) * 60;
        if (pSeconds > currentSeconds) {
          const diffSec = pSeconds - currentSeconds;
          const hours = Math.floor(diffSec / 3600);
          const mins = Math.floor((diffSec % 3600) / 60);
          const secs = diffSec % 60;
          setNextPrayerInfo({
            name: p.name,
            remaining: `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`,
          });
          return;
        }
      }

      // If all passed today, next is tomorrow's Fajr
      const [fh, fm] = (raw ? raw.fajr : '04:35').split(':').map(Number);
      const fajrTomorrowSec = 24 * 3600 + fh * 3600 + (fm || 0) * 60;
      const diffSec = fajrTomorrowSec - currentSeconds;
      const hours = Math.floor(diffSec / 3600);
      const mins = Math.floor((diffSec % 3600) / 60);
      const secs = diffSec % 60;
      setNextPrayerInfo({
        name: 'الفجر (غداً)',
        remaining: `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`,
      });
    };

    calcNext();
    const interval = setInterval(calcNext, 1000);
    return () => clearInterval(interval);
  }, [times]);

  return (
    <div className="flex flex-col items-center w-full max-w-xl mx-auto px-4 pb-28 pt-2">
      {/* Top Segment Switch: [مواقيت الصلاة والأذان] | [اتجاه القبلة] */}
      <div className="w-full max-w-md flex items-center justify-between p-1 bg-black/5 dark:bg-white/10 rounded-2xl mb-3 border border-[#B7935F]/20">
        <button
          onClick={() => setSubView('prayers')}
          className={`flex-1 py-2 px-3 rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-1.5 ${
            subView === 'prayers'
              ? 'bg-[#B7935F] text-white shadow-md'
              : 'text-gray-600 dark:text-gray-300 hover:text-black dark:hover:text-white'
          }`}
        >
          <Clock className="w-4 h-4" />
          <span>مواقيت الصلاة والأذان</span>
        </button>

        <button
          onClick={() => setSubView('qibla')}
          className={`flex-1 py-2 px-3 rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-1.5 ${
            subView === 'qibla'
              ? 'bg-[#B7935F] text-white shadow-md'
              : 'text-gray-600 dark:text-gray-300 hover:text-black dark:hover:text-white'
          }`}
        >
          <Compass className="w-4 h-4" />
          <span>اتجاه القبلة والصلاة</span>
        </button>
      </div>

      {subView === 'qibla' ? (
        <QiblaCompass />
      ) : (
        <>
          {/* Header Controls */}
          <div className="flex items-center justify-between w-full max-w-md my-1">
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

            <h1 className="text-2xl sm:text-3xl font-bold text-[#B7935F] dark:text-[#facc10]">
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
                <h2 className="text-base sm:text-lg font-bold text-[#B7935F] dark:text-[#facc10]">
                  {times.dayAr} - {times.dateHijri} هـ
                </h2>
                <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5">{times.dateEn}</p>
                <div className="flex items-center justify-center gap-2 mt-1.5 text-xs text-gray-500 dark:text-gray-400">
                  <div className="flex items-center gap-1">
                    <MapPin className="w-3.5 h-3.5 text-[#B7935F]" />
                    <span>
                      {times.region}, {times.country}
                    </span>
                  </div>
                  <button
                    onClick={() => setSubView('qibla')}
                    className="text-[10px] bg-[#B7935F]/15 dark:bg-[#facc10]/15 text-[#B7935F] dark:text-[#facc10] px-2 py-0.5 rounded-full font-bold hover:bg-[#B7935F]/25 transition-colors"
                  >
                    تحديد عبر GPS
                  </button>
                </div>
              </div>

              {/* Next Prayer Countdown & Adhan Button */}
              {nextPrayerInfo && (
                <div className="w-full my-3 p-3.5 rounded-2xl bg-gradient-to-r from-[#B7935F]/20 via-[#B7935F]/10 to-transparent border border-[#B7935F]/35 shadow-sm flex items-center justify-between">
                  <div>
                    <div className="flex items-center gap-1.5 text-xs text-gray-600 dark:text-gray-300">
                      <Clock className="w-4 h-4 text-[#B7935F]" />
                      <span>الصلاة القادمة:</span>
                      <strong className="text-[#B7935F] dark:text-[#facc10] text-sm">
                        صلاة {nextPrayerInfo.name}
                      </strong>
                    </div>
                    <div className="text-xs text-gray-500 dark:text-gray-400 mt-1" dir="ltr">
                      باقي <span className="font-mono font-bold text-sm text-gray-800 dark:text-gray-100">{nextPrayerInfo.remaining}</span>
                    </div>
                  </div>

                  {/* Play Adhan Button */}
                  <button
                    onClick={() => openModal('adhan')}
                    className="px-3 py-2 rounded-xl text-xs font-bold text-white shadow-md active:scale-95 transition-all flex items-center gap-1.5 hover:brightness-105"
                    style={{ backgroundColor: '#B7935F' }}
                    title="الاستماع إلى الأذان"
                  >
                    <Volume2 className="w-4 h-4" />
                    <span>سماع الأذان</span>
                  </button>
                </div>
              )}

              {/* Prayer Cards matching Flutter _buildPrayerItem */}
              <div className="w-full space-y-2 mt-2">
                {prayers.map((prayer) => {
                  const { time, period } = formatTime(prayer.timeStr);
                  const isAlarmOn = prayerAlarms[prayer.key] ?? true;

                  return (
                    <div
                      key={prayer.key}
                      className={`w-full flex items-center justify-between px-5 py-3 rounded-[20px] border-[1.5px] border-[#B7935F] shadow-xs transition-all duration-200 ${
                        isDark ? 'bg-[#141A2E]/80 text-white' : 'bg-white/90 text-gray-900'
                      }`}
                    >
                      <div className="flex items-center gap-3">
                        <button
                          onClick={() => toggleAlarm(prayer.key)}
                          className={`p-1.5 rounded-full transition-colors ${
                            isAlarmOn
                              ? 'text-[#B7935F] dark:text-[#facc10] hover:bg-[#B7935F]/10'
                              : 'text-gray-300 dark:text-gray-600 hover:text-gray-400'
                          }`}
                          title={isAlarmOn ? 'التنبيه مفعل' : 'التنبيه صامت'}
                        >
                          <Bell className={`w-4 h-4 ${isAlarmOn ? 'fill-current' : ''}`} />
                        </button>
                        <span className="text-xl sm:text-2xl font-bold text-[#B7935F] dark:text-[#facc10]">
                          {prayer.name}
                        </span>
                      </div>

                      <div className="flex items-baseline gap-1.5" dir="ltr">
                        <span className="text-xl sm:text-2xl font-bold tracking-wider">{time}</span>
                        <span className="text-xs sm:text-sm font-semibold opacity-75">{period}</span>
                      </div>
                    </div>
                  );
                })}
              </div>

              {/* Quick Adhan & Supplication Link */}
              <button
                onClick={() => openModal('adhan')}
                className="mt-4 w-full py-2.5 rounded-xl border border-[#B7935F]/30 bg-white/50 dark:bg-[#141A2E]/50 text-xs font-bold text-[#B7935F] dark:text-[#facc10] flex items-center justify-center gap-2 hover:bg-[#B7935F]/10 transition-colors"
              >
                <Sparkles className="w-4 h-4" />
                <span>الاستماع للأذان المكي ودعاء ما بعد الأذان</span>
              </button>
            </div>
          ) : (
            <div className="text-center py-12 text-gray-500">حدث خطأ في تحميل البيانات</div>
          )}
        </>
      )}
    </div>
  );
};
