import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;

class QuranSurahPage extends StatelessWidget {
  final int surahNumber;

  const QuranSurahPage({
    super.key,
    required this.surahNumber,
  });

  quran.Translation _translationForLocale(BuildContext context) {
    return context.locale.languageCode == 'ml'
        ? quran.Translation.mlAbdulHameed
        : quran.Translation.enSaheeh;
  }

  @override
  Widget build(BuildContext context) {
    final translation = _translationForLocale(context);
    final verseCount = quran.getVerseCount(surahNumber);
    final surahNameEnglish = quran.getSurahNameEnglish(surahNumber);
    final surahNameArabic = quran.getSurahNameArabic(surahNumber);
    final placeOfRevelation = quran.getPlaceOfRevelation(surahNumber);

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(surahNameEnglish, style: kBodyTitleM),
            Text(
              '$verseCount ${'verses'.tr()} · $placeOfRevelation',
              style: kSmallerTitleR.copyWith(
                color: kSecondaryTextColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        itemCount: verseCount + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      surahNameArabic,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiriQuran(
                        fontSize: 32,
                        color: kTextColor,
                        height: 1.4,
                      ),
                    ),
                    if (surahNumber != 9 && surahNumber != 1) ...[
                      const SizedBox(height: 12),
                      Text(
                        quran.basmala,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiriQuran(
                          fontSize: 22,
                          color: kTextColor,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          final verseNumber = index;
          final arabicVerse = quran.getVerse(
            surahNumber,
            verseNumber,
            verseEndSymbol: true,
          );
          final translatedVerse = quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: translation,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0601B4).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$verseNumber',
                        style: kSmallerTitleSB.copyWith(
                          color: const Color(0xFF0601B4),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (quran.isSajdahVerse(surahNumber, verseNumber)) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'sajdah'.tr(),
                          style: kSmallerTitleSB.copyWith(
                            color: kPrimaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  arabicVerse,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiriQuran(
                    fontSize: 22,
                    color: kTextColor,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  translatedVerse,
                  style: kSmallerTitleR.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
