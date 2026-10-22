import { RadioItem, PrayerTimes, TafsirAyah } from '../types';
import { FALLBACK_RADIOS } from '../data/fallbackData';

export async function fetchRadios(): Promise<RadioItem[]> {
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 6000);
    const res = await fetch('https://mp3quran.net/api/v3/radios?language=ar', { signal: controller.signal });
    clearTimeout(timeout);
    if (res.ok) {
      const data = await res.json();
      if (data && Array.isArray(data.radios) && data.radios.length > 0) {
        const cairoRadio: RadioItem = {
          id: 99999,
          name: "إذاعة القرآن الكريم من القاهرة (بث مباشر 98.2 FM)",
          url: "https://radio.xecod.com/station/quran-cairo"
        };
        const remoteRadios: RadioItem[] = data.radios.map((item: any) => ({
          id: item.id,
          name: item.name,
          url: item.url
        }));
        return [cairoRadio, ...remoteRadios];
      }
    }
  } catch (e) {
    console.warn('Radio fetch error, using curated channels:', e);
  }

  return FALLBACK_RADIOS;
}

// Astronomical calculation for precise dynamic prayer times
function calculateSolarTimes(date: Date, lat: number, lng: number, tz: number) {
  const rad = Math.PI / 180;
  const deg = 180 / Math.PI;

  const d = date.getDate();
  const m = date.getMonth() + 1;
  const y = date.getFullYear();
  const a = Math.floor((14 - m) / 12);
  const Y = y + 4800 - a;
  const M = m + 12 * a - 3;
  const JDN = d + Math.floor((153 * M + 2) / 5) + 365 * Y + Math.floor(Y / 4) - Math.floor(Y / 100) + Math.floor(Y / 400) - 32045;
  const dJul = JDN - 2451545.0 + (12 - tz) / 24;

  const q = (280.459 + 0.98564736 * dJul) % 360;
  const g = (357.529 + 0.98560028 * dJul) % 360;
  const L = (q + 1.915 * Math.sin(g * rad) + 0.020 * Math.sin(2 * g * rad)) % 360;
  const e = 23.439 - 0.00000036 * dJul;

  const RA = (Math.atan2(Math.cos(e * rad) * Math.sin(L * rad), Math.cos(L * rad)) * deg) / 15;
  const cleanRA = (RA < 0 ? RA + 24 : RA);
  const decl = Math.asin(Math.sin(e * rad) * Math.sin(L * rad)) * deg;

  const EqT = (q / 15) - cleanRA;
  const noon = 12 + tz - (lng / 15) - EqT;

  function sunAngle(angle: number, isPM: boolean) {
    const cosH = (Math.sin(angle * rad) - Math.sin(lat * rad) * Math.sin(decl * rad)) / (Math.cos(lat * rad) * Math.cos(decl * rad));
    if (cosH > 1 || cosH < -1) return noon + (isPM ? 6 : -6);
    const H = Math.acos(cosH) * deg / 15;
    return isPM ? noon + H : noon - H;
  }

  const fajrHours = sunAngle(-19.5, false);
  const sunriseHours = sunAngle(-0.833, false);
  const dhuhrHours = noon + 2 / 60;
  const asrAngle = deg * Math.atan(1 + Math.tan(Math.abs(lat - decl) * rad));
  const asrHours = sunAngle(90 - asrAngle, true);
  const maghribHours = sunAngle(-0.833, true);
  const ishaHours = sunAngle(-17.5, true);

  function fmt24(hFloat: number) {
    const totalMin = Math.round(hFloat * 60);
    const h = Math.floor(totalMin / 60) % 24;
    const min = totalMin % 60;
    return `${h.toString().padStart(2, "0")}:${min.toString().padStart(2, "0")}`;
  }

  function fmt12(hFloat: number) {
    const totalMin = Math.round(hFloat * 60);
    const h24 = Math.floor(totalMin / 60) % 24;
    const min = totalMin % 60;
    const period = h24 >= 12 ? "م" : "ص";
    const h12 = h24 % 12 || 12;
    return `${h12.toString().padStart(2, "0")}:${min.toString().padStart(2, "0")} ${period}`;
  }

  return {
    raw: {
      fajr: fmt24(fajrHours),
      sunrise: fmt24(sunriseHours),
      dhuhr: fmt24(dhuhrHours),
      asr: fmt24(asrHours),
      maghrib: fmt24(maghribHours),
      isha: fmt24(ishaHours)
    },
    display: {
      fajr: fmt12(fajrHours),
      sunrise: fmt12(sunriseHours),
      dhuhr: fmt12(dhuhrHours),
      asr: fmt12(asrHours),
      maghrib: fmt12(maghribHours),
      isha: fmt12(ishaHours)
    }
  };
}

export async function fetchPrayerTimes(): Promise<PrayerTimes> {
  const now = new Date();

  // Check if user has saved GPS coordinates
  let lat = 30.0444;
  let lng = 31.2357;
  let region = 'القاهرة';
  let country = 'مصر';

  const savedGps = localStorage.getItem('islami_user_gps');
  if (savedGps) {
    try {
      const parsed = JSON.parse(savedGps);
      if (parsed.lat && parsed.lng) {
        lat = parsed.lat;
        lng = parsed.lng;
        region = parsed.name || 'موقعي الحالي';
        country = 'GPS دقيق';
      }
    } catch {
      // fallback to Cairo
    }
  }

  const tz = -(now.getTimezoneOffset() / 60);
  const calculated = calculateSolarTimes(now, lat, lng, tz);

  // Arabic date and day
  const daysAr = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  const monthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  const dayAr = daysAr[now.getDay()];
  const dateEn = `${now.getDate()} ${monthsAr[now.getMonth()]} ${now.getFullYear()}`;

  // Approximate Hijri date calculation
  const hijriYear = Math.floor((now.getFullYear() - 622) * (33 / 32));

  return {
    fajr: calculated.display.fajr,
    sunrise: calculated.display.sunrise,
    dhuhr: calculated.display.dhuhr,
    asr: calculated.display.asr,
    maghrib: calculated.display.maghrib,
    isha: calculated.display.isha,
    rawTimes: calculated.raw,
    dateHijri: `${hijriYear} هـ`,
    dateEn,
    dayAr,
    region,
    country
  };
}

export async function fetchTafsir(surahNumber: number): Promise<TafsirAyah[]> {
  return [
    { verse: 1, text: "التفسير الميسر: بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ - أبدأ قراءة القرآن مستعيناً باسم الله مستحضراً بركته." },
    { verse: 2, text: "التفسير الميسر: الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ - الثناء الثابت والكامل لله وحده خالق ومدبر العالمين." },
    { verse: 3, text: "التفسير الميسر: الرَّحْمَٰنِ الرَّحِيمِ - واسع الرحمة في الدنيا والآخرة." }
  ];
}
