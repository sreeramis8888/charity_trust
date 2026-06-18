import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/services/app_hadith_service.dart';
import 'package:Annujoom/src/data/utils/hadith_helpers.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hadith/hadith.dart';

class HadithBookPage extends StatelessWidget {
  final Collection collection;
  final int bookNumber;
  final String bookTitle;

  const HadithBookPage({
    super.key,
    required this.collection,
    required this.bookNumber,
    required this.bookTitle,
  });

  @override
  Widget build(BuildContext context) {
    final language = hadithLanguageForLocale(context);

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
        title: Text(bookTitle, style: kSubHeadingM),
      ),
      body: FutureBuilder<List<Hadith>>(
        future: AppHadithService.instance.getHadiths(collection, bookNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'hadithLoadError'.tr(),
                  textAlign: TextAlign.center,
                  style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                ),
              ),
            );
          }

          final hadiths = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            itemCount: hadiths.length,
            itemBuilder: (context, index) {
              final hadith = hadiths[index];
              final arabicData = arabicHadithData(hadith);
              final translationData = hadithDataForLanguage(hadith, language);
              final arabicText =
                  arabicData != null ? cleanHadithBody(arabicData.body) : null;
              final translatedText = translationData != null
                  ? cleanHadithBody(translationData.body)
                  : null;
              final grade =
                  primaryGrade(translationData) ?? primaryGrade(arabicData);
              final chapterTitle =
                  translationData?.chapterTitle ?? arabicData?.chapterTitle;

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
                            hadith.hadithNumber,
                            style: kSmallerTitleSB.copyWith(
                              color: const Color(0xFF0601B4),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (grade != null && grade.isNotEmpty) ...[
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
                              grade,
                              style: kSmallerTitleSB.copyWith(
                                color: kPrimaryColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (chapterTitle != null && chapterTitle.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        chapterTitle,
                        style: kSmallerTitleSB.copyWith(
                          color: kSecondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (arabicText != null && arabicText.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        arabicText,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiriQuran(
                          fontSize: 22,
                          color: kTextColor,
                          height: 1.8,
                        ),
                      ),
                    ],
                    if (translatedText != null &&
                        translatedText.isNotEmpty &&
                        translatedText != arabicText) ...[
                      const SizedBox(height: 12),
                      Text(
                        translatedText,
                        style: kSmallerTitleR.copyWith(
                          color: kSecondaryTextColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
