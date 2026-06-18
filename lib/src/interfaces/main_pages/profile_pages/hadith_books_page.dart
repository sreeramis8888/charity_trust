import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/services/app_hadith_service.dart';
import 'package:Annujoom/src/data/utils/hadith_helpers.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/hadith_book_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hadith/hadith.dart';

class HadithBooksPage extends StatelessWidget {
  final Collection collection;

  const HadithBooksPage({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final language = hadithLanguageForLocale(context);
    final title = collectionTitle(collection, context);

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
        title: Text(title, style: kSubHeadingM),
      ),
      body: FutureBuilder<List<Book>>(
        future: AppHadithService.instance.getBooks(collection),
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

          final books = snapshot.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final book = books[index];
              final bookNumber = int.parse(book.bookNumber);
              final englishName = bookName(book, language);
              final arabicName = bookName(book, Languages.ar);

              return Material(
                color: kWhite,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HadithBookPage(
                          collection: collection,
                          bookNumber: bookNumber,
                          bookTitle: englishName,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                            book.bookNumber,
                            style: kSmallerTitleSB.copyWith(
                              color: const Color(0xFF0601B4),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(englishName, style: kSmallerTitleSB),
                              const SizedBox(height: 4),
                              Text(
                                '${book.numberOfHadith} ${'hadiths'.tr()}',
                                style: kSmallerTitleR.copyWith(
                                  color: kSecondaryTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            arabicName,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.amiriQuran(
                              fontSize: 16,
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
