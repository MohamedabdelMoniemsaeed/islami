import React, { useState, useEffect } from 'react';
import { Compass, MapPin, Navigation, Info, CheckCircle2, ShieldCheck, AlertCircle, Crosshair } from 'lucide-react';
import { useApp } from '../../context/AppContext';

interface CityCoord {
  name: string;
  country: string;
  lat: number;
  lng: number;
}

const POPULAR_CITIES: CityCoord[] = [
  { name: 'القاهرة', country: 'مصر', lat: 30.0444, lng: 31.2357 },
  { name: 'الإسكندرية', country: 'مصر', lat: 31.2001, lng: 29.9187 },
  { name: 'الجيزة', country: 'مصر', lat: 30.0131, lng: 31.2089 },
  { name: 'طنطا', country: 'مصر', lat: 30.7865, lng: 31.0004 },
  { name: 'المنصورة', country: 'مصر', lat: 31.0409, lng: 31.3785 },
  { name: 'أسوان', country: 'مصر', lat: 24.0889, lng: 32.8998 },
  { name: 'مكة المكرمة', country: 'السعودية', lat: 21.4225, lng: 39.8262 },
  { name: 'المدينة المنورة', country: 'السعودية', lat: 24.4672, lng: 39.6111 },
  { name: 'الرياض', country: 'السعودية', lat: 24.7136, lng: 46.6753 },
  { name: 'جدة', country: 'السعودية', lat: 21.5433, lng: 39.1728 },
  { name: 'القدس الشريف', country: 'فلسطين', lat: 31.7683, lng: 35.2137 },
  { name: 'دبي', country: 'الإمارات', lat: 25.2048, lng: 55.2708 },
  { name: 'أبوظبي', country: 'الإمارات', lat: 24.4539, lng: 54.3773 },
  { name: 'الكويت', country: 'الكويت', lat: 29.3759, lng: 47.9774 },
  { name: 'الدوحة', country: 'قطر', lat: 25.2854, lng: 51.5310 },
  { name: 'المنامة', country: 'البحرين', lat: 26.2285, lng: 50.5860 },
  { name: 'مسقط', country: 'عمان', lat: 23.5880, lng: 58.3829 },
  { name: 'عمّان', country: 'الأردن', lat: 31.9454, lng: 35.9284 },
  { name: 'بغداد', country: 'العراق', lat: 33.3152, lng: 44.3661 },
  { name: 'دمشق', country: 'سوريا', lat: 33.5138, lng: 36.2765 },
  { name: 'بيروت', country: 'لبنان', lat: 33.8938, lng: 35.5018 },
  { name: 'طرابلس', country: 'ليبيا', lat: 32.8872, lng: 13.1913 },
  { name: 'تونس', country: 'تونس', lat: 36.8065, lng: 10.1815 },
  { name: 'الجزائر', country: 'الجزائر', lat: 36.7538, lng: 3.0588 },
  { name: 'الرباط', country: 'المغرب', lat: 34.0209, lng: -6.8416 },
  { name: 'الدار البيضاء', country: 'المغرب', lat: 33.5731, lng: -7.5898 },
  { name: 'إسطنبول', country: 'تركيا', lat: 41.0082, lng: 28.9784 },
];

function calculateQibla(lat: number, lng: number): number {
  const phiK = (21.422487 * Math.PI) / 180.0;
  const lambdaK = (39.826206 * Math.PI) / 180.0;
  const phi = (lat * Math.PI) / 180.0;
  const lambda = (lng * Math.PI) / 180.0;

  const y = Math.sin(lambdaK - lambda);
  const x = Math.cos(phi) * Math.tan(phiK) - Math.sin(phi) * Math.cos(lambdaK - lambda);

  let qibla = (Math.atan2(y, x) * 180.0) / Math.PI;
  return Math.round((qibla + 360) % 360);
}

function calculateDistance(lat: number, lng: number): number {
  const R = 6371; // Earth radius in km
  const dLat = ((21.422487 - lat) * Math.PI) / 180;
  const dLon = ((39.826206 - lng) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat * Math.PI) / 180) *
      Math.cos((21.422487 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c);
}

export const QiblaCompass: React.FC = () => {
  const { isDark, showToast } = useApp();

  // Load saved GPS coordinates if already granted before
  const [selectedCity, setSelectedCity] = useState<CityCoord>(() => {
    const saved = localStorage.getItem('islami_user_gps');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch {
        // ignore
      }
    }
    return POPULAR_CITIES[0];
  });

  const [deviceHeading, setDeviceHeading] = useState<number>(0);
  const [hasCompassSupport, setHasCompassSupport] = useState<boolean>(false);
  const [isLocating, setIsLocating] = useState<boolean>(false);
  const [gpsGranted, setGpsGranted] = useState<boolean>(() => {
    return localStorage.getItem('islami_user_gps') !== null;
  });
  const [permissionError, setPermissionError] = useState<string | null>(null);

  const qiblaAngle = calculateQibla(selectedCity.lat, selectedCity.lng);
  const distanceToKaaba = calculateDistance(selectedCity.lat, selectedCity.lng);

  // Compass needle rotation: Qibla angle relative to device heading
  const needleRotation = (qiblaAngle - deviceHeading + 360) % 360;
  // Is user facing Qibla within ±5 degrees?
  const isAligned = hasCompassSupport && (needleRotation <= 6 || needleRotation >= 354);

  // Device orientation listener for mobile devices
  useEffect(() => {
    const handleOrientation = (e: DeviceOrientationEvent) => {
      let heading: number | null = null;
      if ('webkitCompassHeading' in e && typeof (e as any).webkitCompassHeading === 'number') {
        heading = (e as any).webkitCompassHeading;
      } else if (e.alpha !== null) {
        heading = 360 - e.alpha;
      }

      if (heading !== null && !isNaN(heading)) {
        setDeviceHeading(Math.round(heading));
        setHasCompassSupport(true);
      }
    };

    if (window.DeviceOrientationEvent) {
      window.addEventListener('deviceorientation', handleOrientation, true);
    }

    return () => {
      if (window.DeviceOrientationEvent) {
        window.removeEventListener('deviceorientation', handleOrientation, true);
      }
    };
  }, []);

  // Request GPS Permission explicitly
  const requestGPSPermission = () => {
    if (!('geolocation' in navigator)) {
      setPermissionError('متصفحك لا يدعم خاصية تحديد الموقع الجغرافي (GPS)');
      showToast('خاصية تحديد الموقع غير مدعومة في متصفحك', 'error');
      return;
    }

    setIsLocating(true);
    setPermissionError(null);
    showToast('جاري طلب إذن الوصول إلى الـ GPS وتحديد موقعك...', 'info');

    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setIsLocating(false);
        const { latitude, longitude } = pos.coords;
        const gpsCity: CityCoord = {
          name: 'موقعي الحالي (GPS)',
          country: `${latitude.toFixed(2)}°, ${longitude.toFixed(2)}°`,
          lat: latitude,
          lng: longitude,
        };
        setSelectedCity(gpsCity);
        setGpsGranted(true);
        localStorage.setItem('islami_user_gps', JSON.stringify(gpsCity));
        showToast('تم السماح بالوصول لموقعك وحساب زاوية القبلة بدقة فائقة ✓', 'success');
      },
      (err) => {
        setIsLocating(false);
        let errorMsg = 'تعذر الوصول لموقعك عبر الـ GPS';
        if (err.code === err.PERMISSION_DENIED) {
          errorMsg = 'تم رفض إذن الـ GPS. يرجى السماح بالموقع من إعدادات المتصفح / الهاتف.';
        } else if (err.code === err.POSITION_UNAVAILABLE) {
          errorMsg = 'إشارة الـ GPS غير متوفرة حالياً، يرجى تفعيل الموقع في هاتفك.';
        } else if (err.code === err.TIMEOUT) {
          errorMsg = 'استغرق طلب الـ GPS وقتاً طويلاً. يرجى المحاولة ثانية.';
        }
        setPermissionError(errorMsg);
        showToast(errorMsg, 'error');
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0,
      }
    );
  };

  return (
    <div className="flex flex-col items-center w-full max-w-md mx-auto py-2">
      {/* Explicit GPS Permission Card */}
      {!gpsGranted ? (
        <div className="w-full p-4 rounded-2xl bg-gradient-to-r from-[#B7935F]/20 via-[#B7935F]/10 to-transparent border-2 border-[#B7935F] shadow-sm mb-4 space-y-2.5">
          <div className="flex items-start gap-3">
            <div className="p-2.5 rounded-xl bg-[#B7935F] text-white shrink-0 mt-0.5">
              <Crosshair className="w-5 h-5 animate-spin-slow" />
            </div>
            <div>
              <h3 className="font-bold text-sm text-gray-800 dark:text-gray-100">
                إذن الوصول إلى الموقع (GPS)
              </h3>
              <p className="text-xs text-gray-600 dark:text-gray-300 mt-0.5 leading-relaxed">
                اضغط لتفعيل إذن الـ GPS لتوجيه بوصلة القبلة وحساب مواقيت الصلاة بدقة لموقعك الحالي.
              </p>
            </div>
          </div>

          <button
            onClick={requestGPSPermission}
            disabled={isLocating}
            className="w-full py-2.5 px-4 rounded-xl text-xs font-bold text-white shadow-md active:scale-98 transition-all flex items-center justify-center gap-2 hover:brightness-105"
            style={{ backgroundColor: '#B7935F' }}
          >
            <Navigation className={`w-4 h-4 ${isLocating ? 'animate-spin' : ''}`} />
            <span>{isLocating ? 'جاري طلب إذن الـ GPS...' : 'السماح بالوصول إلى الـ GPS وتحديد موقعي'}</span>
          </button>

          {permissionError && (
            <div className="flex items-center gap-1.5 text-[11px] text-red-600 dark:text-red-400 font-medium pt-1">
              <AlertCircle className="w-3.5 h-3.5 shrink-0" />
              <span>{permissionError}</span>
            </div>
          )}
        </div>
      ) : (
        <div className="w-full p-2.5 px-3.5 rounded-2xl bg-green-500/15 border border-green-500/30 text-green-700 dark:text-green-300 flex items-center justify-between text-xs font-bold mb-3">
          <div className="flex items-center gap-2">
            <ShieldCheck className="w-4 h-4 text-green-600 dark:text-green-400" />
            <span>الموقع محدد بدقة عالية عبر الـ GPS</span>
          </div>
          <button
            onClick={requestGPSPermission}
            disabled={isLocating}
            className="text-[11px] underline opacity-80 hover:opacity-100"
          >
            تحديث الموقع
          </button>
        </div>
      )}

      {/* City Selector (Manual selection fallback) */}
      <div className="w-full flex items-center justify-between gap-2 p-2.5 rounded-2xl bg-white/80 dark:bg-[#141A2E]/80 backdrop-blur-md border border-[#B7935F]/20 mb-3 shadow-xs">
        <div className="flex items-center gap-2 flex-1">
          <MapPin className="w-4 h-4 text-[#B7935F] dark:text-[#facc10] shrink-0" />
          <select
            value={selectedCity.name}
            onChange={(e) => {
              const city = POPULAR_CITIES.find((c) => c.name === e.target.value);
              if (city) {
                setSelectedCity(city);
                setGpsGranted(false);
              }
            }}
            className="w-full bg-transparent text-xs font-bold text-gray-800 dark:text-gray-100 focus:outline-none cursor-pointer"
          >
            {gpsGranted && (
              <option value="موقعي الحالي (GPS)">
                موقعي الحالي عبر الـ GPS ({selectedCity.lat.toFixed(2)}°, {selectedCity.lng.toFixed(2)}°)
              </option>
            )}
            {POPULAR_CITIES.map((c) => (
              <option key={c.name} value={c.name} className="dark:bg-[#141A2E] text-gray-800 dark:text-gray-100">
                {c.name} - {c.country}
              </option>
            ))}
          </select>
        </div>

        <button
          onClick={requestGPSPermission}
          disabled={isLocating}
          className="px-3 py-1.5 rounded-xl text-xs font-bold bg-[#B7935F]/15 dark:bg-[#facc10]/15 text-[#B7935F] dark:text-[#facc10] hover:bg-[#B7935F]/25 flex items-center gap-1 active:scale-95 transition-all shrink-0"
          title="تحديد الموقع عبر الـ GPS"
        >
          <Navigation className={`w-3.5 h-3.5 ${isLocating ? 'animate-spin' : ''}`} />
          <span>{isLocating ? 'تحديد...' : 'GPS'}</span>
        </button>
      </div>

      {/* Alignment Status Banner */}
      {isAligned ? (
        <div className="w-full p-2.5 rounded-xl bg-green-500/15 border border-green-500/40 text-green-700 dark:text-green-300 flex items-center justify-center gap-2 text-xs font-bold mb-3 animate-pulse">
          <CheckCircle2 className="w-4 h-4 text-green-500" />
          <span>أنت الآن في اتجاه القبلة الصحيح تماماً 🕋</span>
        </div>
      ) : (
        <div className="w-full p-2.5 rounded-xl bg-[#B7935F]/10 dark:bg-[#facc10]/10 border border-[#B7935F]/20 text-[#B7935F] dark:text-[#facc10] flex items-center justify-between text-xs font-semibold mb-3">
          <div className="flex items-center gap-1.5">
            <Compass className="w-4 h-4" />
            <span>زاوية القبلة: {qiblaAngle}° من الشمال</span>
          </div>
          <span className="text-[11px] opacity-80">{distanceToKaaba.toLocaleString('ar-EG')} كم إلى الكعبة</span>
        </div>
      )}

      {/* Main Interactive Compass Rose */}
      <div className="relative w-64 h-64 sm:w-72 sm:h-72 my-2 flex items-center justify-center">
        {/* Outer Ring with Degrees and Islamic Pattern Border */}
        <div
          className={`absolute inset-0 rounded-full border-4 shadow-2xl transition-all duration-300 flex items-center justify-center ${
            isAligned
              ? 'border-green-500 shadow-green-500/30'
              : 'border-[#B7935F] dark:border-[#facc10] shadow-[#B7935F]/20'
          }`}
          style={{
            backgroundColor: isDark ? 'rgba(20, 26, 46, 0.85)' : 'rgba(255, 255, 255, 0.85)',
          }}
        >
          {/* Compass Cardinal Points */}
          <span className="absolute top-2 text-sm font-extrabold text-red-500">ش (N)</span>
          <span className="absolute bottom-2 text-xs font-bold text-gray-400">ج (S)</span>
          <span className="absolute right-3 text-xs font-bold text-gray-400">ق (E)</span>
          <span className="absolute left-3 text-xs font-bold text-gray-400">غ (W)</span>

          {/* Dial ticks */}
          <div className="absolute inset-5 rounded-full border border-dashed border-[#B7935F]/30 pointer-events-none" />

          {/* Kaaba Position on Dial */}
          <div
            className="absolute inset-0 flex items-center justify-center pointer-events-none transition-transform duration-300"
            style={{ transform: `rotate(${qiblaAngle}deg)` }}
          >
            <div className="absolute -top-1 flex flex-col items-center">
              <span className="text-xl filter drop-shadow">🕋</span>
              <span className="text-[10px] font-bold text-[#B7935F] dark:text-[#facc10] bg-white/80 dark:bg-[#141A2E]/80 px-1 rounded shadow-xs">
                القبلة
              </span>
            </div>
          </div>

          {/* Compass Needle */}
          <div
            className="absolute inset-0 flex items-center justify-center pointer-events-none transition-transform duration-300 ease-out"
            style={{ transform: `rotate(${needleRotation}deg)` }}
          >
            {/* Upper needle pointing to Kaaba */}
            <div className="w-3 h-28 flex flex-col items-center -translate-y-12">
              <div
                className="w-0 h-0 border-l-[8px] border-l-transparent border-r-[8px] border-r-transparent border-b-[40px] drop-shadow-md"
                style={{
                  borderBottomColor: isAligned ? '#22c55e' : '#B7935F',
                }}
              />
              <div
                className="w-1.5 h-16"
                style={{
                  backgroundColor: isAligned ? '#22c55e' : '#B7935F',
                }}
              />
            </div>
            {/* Center Pivot Pin */}
            <div className="absolute w-6 h-6 rounded-full bg-[#141A2E] dark:bg-[#facc10] border-2 border-white shadow-md z-10 flex items-center justify-center">
              <div className="w-2 h-2 rounded-full bg-[#B7935F] dark:bg-[#141A2E]" />
            </div>
          </div>
        </div>
      </div>

      {/* Instructions */}
      <div className="w-full p-3.5 rounded-2xl bg-white/70 dark:bg-[#141A2E]/70 backdrop-blur-md border border-[#B7935F]/20 text-xs text-gray-600 dark:text-gray-300 space-y-1 text-right mt-2">
        <div className="flex items-center gap-1.5 font-bold text-[#B7935F] dark:text-[#facc10]">
          <Info className="w-4 h-4" />
          <span>إرشادات الاستخدام:</span>
        </div>
        <p className="leading-relaxed">
          1. اسمح بالوصول للـ GPS لتحديد موقعك الجغرافي الحالي بدقة متناهية.
        </p>
        <p className="leading-relaxed">
          2. ضع الهاتف في وضع أفقي مستوٍ وأدر الهاتف حتى يتطابق السهم الذهبي مع رمز الكعبة المشرفة 🕋.
        </p>
      </div>
    </div>
  );
};
