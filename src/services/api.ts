import { PrayerTimes, RadioItem, TafsirAyah, AzkarCategory, DuasCategory, ReciterData } from '../types';
import { FALLBACK_PRAYER_TIMES, FALLBACK_RADIOS, FALLBACK_AZKAR, FALLBACK_DUAS, LAYLAT_AL_QADR_CONTENT } from '../data/fallbackData';

const PRAYER_API = 'https://quran.yousefheiba.com/api/getPrayerTimes';
const RADIO_API = 'https://quran.yousefheiba.com/api/radio';
const TAFSIR_API = 'https://quranenc.com/api/v1/translation/sura/arabic_moyassar';
const AZKAR_API = 'https://quran.yousefheiba.com/api/azkar';
const DUAS_API = 'https://quran.yousefheiba.com/api/duas';
const SURAHS_LIST_API = 'https://quran.yousefheiba.com/api/surahs';
const RECITER_API = 'https://quran.yousefheiba.com/api/reciterAudio?reciter_id=';
const LAYLAT_AL_QADR_API = 'https://quran.yousefheiba.com/api/laylatAlQadr';

export async function fetchPrayerTimes(): Promise<PrayerTimes> {
  const cacheKey = 'islami_cache_prayer_times';
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 6000);
    const res = await fetch(PRAYER_API, { signal: controller.signal });
    clearTimeout(timeout);
    if (res.ok) {
      const json = await res.json();
      const prayerTimes = json.prayer_times || {};
      const date = json.date || {};
      const hijri = date.date_hijri || {};
      const data: PrayerTimes = {
        fajr: prayerTimes.Fajr || "04:36",
        sunrise: prayerTimes.Sunrise || "06:02",
        dhuhr: prayerTimes.Dhuhr || "11:42",
        asr: prayerTimes.Asr || "14:58",
        maghrib: prayerTimes.Maghrib || "17:21",
        isha: prayerTimes.Isha || "18:38",
        dateEn: date.date_en || new Date().toDateString(),
        dateHijri: hijri.date || "1446-04-18",
        dayAr: hijri.weekday?.ar || new Date().toLocaleDateString('ar-EG', { weekday: 'long' }),
        country: json.country || "مصر",
        region: json.region || "القاهرة",
      };
      localStorage.setItem(cacheKey, JSON.stringify(data));
      return data;
    }
  } catch (e) {
    console.warn('Failed to fetch prayer times live, checking cache:', e);
  }

  const cached = localStorage.getItem(cacheKey);
  if (cached) {
    try {
      return JSON.parse(cached);
    } catch {
      // ignore
    }
  }

  return FALLBACK_PRAYER_TIMES;
}

export async function fetchRadios(): Promise<RadioItem[]> {
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);
    const res = await fetch(RADIO_API, { signal: controller.signal });
    clearTimeout(timeout);
    if (res.ok) {
      const data = await res.json();
      if (Array.isArray(data)) {
        return data.map((item, idx) => ({
          id: item.id || idx + 1,
          name: item.name || "إذاعة القرآن الكريم",
          url: item.url || ""
        })).filter(r => r.url);
      } else if (data && data.radios && Array.isArray(data.radios)) {
        return data.radios;
      } else if (data && data.url) {
        return [{ id: 1, name: data.name || "إذاعة القرآن الكريم من القاهرة", url: data.url }];
      }
    }
  } catch (e) {
    console.warn('Radio fetch error, using curated channels:', e);
  }

  return FALLBACK_RADIOS;
}

export async function fetchTafsir(surahNumber: number): Promise<TafsirAyah[]> {
  const cacheKey = `islami_tafsir_${surahNumber}`;
  const cached = localStorage.getItem(cacheKey);
  if (cached) {
    try {
      return JSON.parse(cached);
    } catch {
      // ignore
    }
  }

  try {
    const res = await fetch(`${TAFSIR_API}/${surahNumber}`);
    if (res.ok) {
      const data = await res.json();
      if (data && data.result) {
        const result: TafsirAyah[] = data.result.map((item: any) => ({
          aya: item.aya,
          sura: surahNumber,
          arabic_text: item.arabic_text,
          translation: item.translation,
          footnotes: item.footnotes
        }));
        localStorage.setItem(cacheKey, JSON.stringify(result));
        return result;
      }
    }
  } catch (e) {
    console.warn(`Error fetching tafsir for surah ${surahNumber}:`, e);
  }

  return [];
}

export async function fetchAzkar(): Promise<AzkarCategory[]> {
  const cacheKey = 'islami_cache_azkar';
  try {
    const res = await fetch(AZKAR_API);
    if (res.ok) {
      const data = await res.json();
      if (data && data.categories) {
        localStorage.setItem(cacheKey, JSON.stringify(data.categories));
        return data.categories;
      }
    }
  } catch (e) {
    console.warn('Azkar fetch error, checking cache:', e);
  }

  const cached = localStorage.getItem(cacheKey);
  if (cached) {
    try {
      return JSON.parse(cached);
    } catch {
      // ignore
    }
  }

  return FALLBACK_AZKAR;
}

export async function fetchDuas(): Promise<DuasCategory[]> {
  const cacheKey = 'islami_cache_duas';
  try {
    const res = await fetch(DUAS_API);
    if (res.ok) {
      const data = await res.json();
      if (data && data.categories) {
        localStorage.setItem(cacheKey, JSON.stringify(data.categories));
        return data.categories;
      }
    }
  } catch (e) {
    console.warn('Duas fetch error, checking cache:', e);
  }

  const cached = localStorage.getItem(cacheKey);
  if (cached) {
    try {
      return JSON.parse(cached);
    } catch {
      // ignore
    }
  }

  return FALLBACK_DUAS;
}

export async function fetchReciterAudio(reciterId: number = 112): Promise<ReciterData> {
  const cacheKey = `islami_reciter_${reciterId}`;
  try {
    const res = await fetch(`${RECITER_API}${reciterId}`);
    if (res.ok) {
      const data = await res.json();
      if (data && data.audio_urls) {
        localStorage.setItem(cacheKey, JSON.stringify(data));
        return data;
      }
    }
  } catch (e) {
    console.warn('Reciter audio fetch error:', e);
  }

  const cached = localStorage.getItem(cacheKey);
  if (cached) {
    try {
      return JSON.parse(cached);
    } catch {
      // ignore
    }
  }

  // Fallback Minshawi audio tracks from mp3quran
  return {
    reciter_name: "الشيخ محمد صديق المنشاوي (المصحف المرتل)",
    audio_urls: [
      { surah_id: 1, surah_name_ar: "الفاتحة", audio_url: "https://server10.mp3quran.net/minsh/001.mp3" },
      { surah_id: 2, surah_name_ar: "البقرة", audio_url: "https://server10.mp3quran.net/minsh/002.mp3" },
      { surah_id: 3, surah_name_ar: "آل عمران", audio_url: "https://server10.mp3quran.net/minsh/003.mp3" },
      { surah_id: 18, surah_name_ar: "الكهف", audio_url: "https://server10.mp3quran.net/minsh/018.mp3" },
      { surah_id: 36, surah_name_ar: "يس", audio_url: "https://server10.mp3quran.net/minsh/036.mp3" },
      { surah_id: 55, surah_name_ar: "الرحمن", audio_url: "https://server10.mp3quran.net/minsh/055.mp3" },
      { surah_id: 56, surah_name_ar: "الواقعة", audio_url: "https://server10.mp3quran.net/minsh/056.mp3" },
      { surah_id: 67, surah_name_ar: "الملك", audio_url: "https://server10.mp3quran.net/minsh/067.mp3" },
      { surah_id: 112, surah_name_ar: "الإخلاص", audio_url: "https://server10.mp3quran.net/minsh/112.mp3" },
      { surah_id: 113, surah_name_ar: "الفلق", audio_url: "https://server10.mp3quran.net/minsh/113.mp3" },
      { surah_id: 114, surah_name_ar: "الناس", audio_url: "https://server10.mp3quran.net/minsh/114.mp3" }
    ]
  };
}

export async function fetchLaylatAlQadr(): Promise<{ title: string; content: string }> {
  try {
    const res = await fetch(LAYLAT_AL_QADR_API);
    if (res.ok) {
      const data = await res.json();
      return {
        title: data.title || LAYLAT_AL_QADR_CONTENT.title,
        content: data.content || data.description || LAYLAT_AL_QADR_CONTENT.content
      };
    }
  } catch (e) {
    console.warn('Laylat Al-Qadr API error:', e);
  }
  return LAYLAT_AL_QADR_CONTENT;
}
