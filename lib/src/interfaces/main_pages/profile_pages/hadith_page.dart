import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/utils/hadith_helpers.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/hadith_books_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithPage extends StatelessWidget {
  const HadithPage({super.key});

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
        title: Text('hadith'.tr(), style: kSubHeadingM),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        itemCount: kHadithCollectionOrder.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final collection = kHadithCollectionOrder[index];
          final info = kHadithCollectionInfo[collection];
          final title = collectionTitle(collection, context);
          final arabicTitle = collectionArabicTitle(collection);

          return Material(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HadithBooksPage(
                      collection: collection,
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
                        '${index + 1}',
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
                          Text(title, style: kSmallerTitleSB),
                          if (info != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${info.totalHadith} ${'hadiths'.tr()}',
                              style: kSmallerTitleR.copyWith(
                                color: kSecondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      arabicTitle,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiriQuran(
                        fontSize: 18,
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
