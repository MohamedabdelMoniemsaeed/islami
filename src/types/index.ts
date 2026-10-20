export interface PrayerTimes {
  fajr: string;
  sunrise: string;
  dhuhr: string;
  asr: string;
  maghrib: string;
  isha: string;
  dateEn: string;
  dateHijri: string;
  dayAr: string;
  country: string;
  region: string;
}

export interface RadioItem {
  id: number;
  name: string;
  url: string;
}

export interface SurahMeta {
  number: number;
  name_ar: string;
  name_en?: string;
  type: 'Meccan' | 'Medinan';
  ayat_count: number;
  start_page: number;
}

export interface TafsirAyah {
  id?: number;
  sura: number;
  aya: number;
  arabic_text: string;
  translation: string;
  footnotes?: string;
}

export interface ZekrItem {
  category: string;
  count: string;
  description: string;
  reference?: string;
  zekr: string;
}

export interface AzkarCategory {
  categoryName: string;
  azkar: ZekrItem[];
}

export interface DuaItem {
  category: string;
  text: string;
  description?: string;
}

export interface DuasCategory {
  categoryName: string;
  duas: DuaItem[];
}

export interface ReciterAudioTrack {
  surah_id: number;
  surah_name_ar: string;
  audio_url: string;
}

export interface ReciterData {
  reciter_name: string;
  audio_urls: ReciterAudioTrack[];
}
