import React, { useState } from 'react';
import { X, Search, Languages, ChevronLeft } from 'lucide-react';
import { SURAHS_LIST } from '../../data/surahs';
import { useApp } from '../../context/AppContext';

export const TafsirIndexModal: React.FC = () => {
  const { isDark, openModal, closeModal } = useApp();
  const [searchTerm, setSearchTerm] = useState('');

  const filteredSurahs = SURAHS_LIST.filter(
    (s) =>
      s.name_ar.includes(searchTerm.trim()) ||
      s.number.toString() === searchTerm.trim()
  );

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div
        className="w-full max-w-lg h-[90vh] rounded-3xl shadow-2xl flex flex-col overflow-hidden border border-[#B7935F]/30"
        style={{ backgroundColor: isDark ? '#141A2E' : '#ffffff' }}
      >
        {/* Header */}
        <div className="p-4 sm:p-5 flex items-center justify-between border-b border-[#B7935F]/20 bg-[#B7935F]/10 dark:bg-white/5">
          <div className="flex items-center gap-2 text-[#B7935F] dark:text-[#facc10]">
            <Languages className="w-6 h-6" />
            <h2 className="text-xl font-bold">فهرس التفسير الميسر</h2>
          </div>
          <button
            onClick={closeModal}
            className="p-1.5 rounded-full hover:bg-black/10 dark:hover:bg-white/10 text-gray-500 hover:text-gray-800 dark:hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Search */}
        <div className="p-3 border-b border-[#B7935F]/15">
          <div className="relative flex items-center">
            <Search className="w-4 h-4 absolute right-3 text-gray-400" />
            <input
              type="text"
              placeholder="ابحث عن اسم السورة لعرض تفسيرها..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pr-9 pl-3 py-2 rounded-xl text-sm border border-[#B7935F]/30 bg-black/5 dark:bg-white/5 text-gray-800 dark:text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-1 focus:ring-[#B7935F]"
            />
          </div>
        </div>

        {/* Surahs List for Tafsir */}
        <div className="flex-1 overflow-y-auto divide-y divide-[#B7935F]/10 dark:divide-white/5 p-2">
          {filteredSurahs.map((surah) => (
            <button
              key={surah.number}
              onClick={() => openModal('tafsir_details', { number: surah.number, name: surah.name_ar })}
              className="w-full p-3 flex items-center justify-between text-right hover:bg-[#B7935F]/10 dark:hover:bg-white/5 rounded-xl transition-colors group focus:outline-none"
            >
              <div className="flex items-center gap-3">
                <div
                  className="w-9 h-9 rounded-full flex items-center justify-center font-bold text-sm text-white shrink-0 shadow-xs"
                  style={{ backgroundColor: '#B7935F' }}
                >
                  {surah.number}
                </div>
                <div>
                  <h3 className="text-lg font-bold text-gray-800 dark:text-gray-100 group-hover:text-[#B7935F] dark:group-hover:text-[#facc10] transition-colors">
                    سورة {surah.name_ar}
                  </h3>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    {surah.type === 'Meccan' ? 'مكية' : 'مدنية'} • آياتها: {surah.ayat_count}
                  </p>
                </div>
              </div>

              <div className="p-1 rounded-full text-[#B7935F] dark:text-[#facc10] group-hover:-translate-x-1 transition-transform">
                <ChevronLeft className="w-5 h-5 stroke-[2]" />
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};
