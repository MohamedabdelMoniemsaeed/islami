import { SurahMeta } from '../types';

export const SURAHS_LIST: SurahMeta[] = [
  { number: 1, name_ar: 'الفاتحة', name_en: 'Al-Fatihah', type: 'Meccan', page_start: 1, page_end: 1, verses_count: 7 },
  { number: 2, name_ar: 'البقرة', name_en: 'Al-Baqarah', type: 'Medinan', page_start: 2, page_end: 49, verses_count: 286 },
  { number: 3, name_ar: 'آل عمران', name_en: 'Ali \'Imran', type: 'Medinan', page_start: 50, page_end: 76, verses_count: 200 },
  { number: 4, name_ar: 'النساء', name_en: 'An-Nisa\'', type: 'Medinan', page_start: 77, page_end: 106, verses_count: 176 },
  { number: 5, name_ar: 'المائدة', name_en: 'Al-Ma\'idah', type: 'Medinan', page_start: 106, page_end: 127, verses_count: 120 },
  { number: 6, name_ar: 'الأنعام', name_en: 'Al-An\'am', type: 'Meccan', page_start: 128, page_end: 150, verses_count: 165 },
  { number: 7, name_ar: 'الأعراف', name_en: 'Al-A\'raf', type: 'Meccan', page_start: 151, page_end: 176, verses_count: 206 },
  { number: 8, name_ar: 'الأنفال', name_en: 'Al-Anfal', type: 'Medinan', page_start: 177, page_end: 186, verses_count: 75 },
  { number: 9, name_ar: 'التوبة', name_en: 'At-Tawbah', type: 'Medinan', page_start: 187, page_end: 207, verses_count: 129 },
  { number: 10, name_ar: 'يونس', name_en: 'Yunus', type: 'Meccan', page_start: 208, page_end: 221, verses_count: 109 },
];

export function getSurahForPage(page: number): SurahMeta {
  const found = SURAHS_LIST.find(s => page >= s.page_start && page <= s.page_end);
  return found || SURAHS_LIST[0];
}
