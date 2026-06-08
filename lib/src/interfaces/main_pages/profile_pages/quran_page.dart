import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/quran_surah_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('quran'.tr(), style: kSubHeadingM),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        itemCount: quran.totalSurahCount,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final surahNumber = index + 1;
          final verseCount = quran.getVerseCount(surahNumber);
          final placeOfRevelation = quran.getPlaceOfRevelation(surahNumber);

          return Material(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuranSurahPage(
                      surahNumber: surahNumber,
                    ),
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0601B4).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$surahNumber',
                        style: kSmallerTitleSB.copyWith(
                          color: const Color(0xFF0601B4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quran.getSurahNameEnglish(surahNumber),
                            style: kSmallerTitleSB,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$verseCount ${'verses'.tr()} · $placeOfRevelation',
                            style: kSmallerTitleR.copyWith(
                              color: kSecondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      quran.getSurahNameArabic(surahNumber),
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiriQuran(
                        fontSize: 20,
                        color: kTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
