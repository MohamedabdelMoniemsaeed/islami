export type TabType = 'quran' | 'radio' | 'prayer' | 'settings';

export interface SurahMeta {
  number: number;
  name_ar: string;
  name_en: string;
  type: 'Meccan' | 'Medinan';
  page_start: number;
  page_end: number;
  verses_count: number;
}

export interface RadioItem {
  id: number;
  name: string;
  url: string;
}

export interface PrayerTimes {
  fajr: string;
  sunrise: string;
  dhuhr: string;
  asr: string;
  maghrib: string;
  isha: string;
  rawTimes?: {
    fajr: string; // "HH:MM" (24h)
    sunrise: string;
    dhuhr: string;
    asr: string;
    maghrib: string;
    isha: string;
  };
  dateHijri: string;
  dateEn: string;
  dayAr: string;
  region: string;
  country: string;
}

export interface TafsirAyah {
  verse: number;
  text: string;
}
