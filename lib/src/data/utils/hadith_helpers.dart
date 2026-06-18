import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hadith/hadith.dart';

const kHadithCollectionOrder = [
  Collection.bukhari,
  Collection.muslim,
  Collection.abudawud,
  Collection.tirmidhi,
  Collection.nasai,
  Collection.ibnmajah,
];

class HadithCollectionInfo {
  final String titleEn;
  final String titleAr;
  final int totalHadith;

  const HadithCollectionInfo({
    required this.titleEn,
    required this.titleAr,
    required this.totalHadith,
  });
}

const kHadithCollectionInfo = {
  Collection.bukhari: HadithCollectionInfo(
    titleEn: 'Sahih al-Bukhari',
    titleAr: 'صحيح البخاري',
    totalHadith: 7277,
  ),
  Collection.muslim: HadithCollectionInfo(
    titleEn: 'Sahih Muslim',
    titleAr: 'صحيح مسلم',
    totalHadith: 7459,
  ),
  Collection.abudawud: HadithCollectionInfo(
    titleEn: 'Sunan Abi Dawud',
    titleAr: 'سنن أبي داود',
    totalHadith: 5276,
  ),
  Collection.tirmidhi: HadithCollectionInfo(
    titleEn: "Jami` at-Tirmidhi",
    titleAr: 'جامع الترمذي',
    totalHadith: 4053,
  ),
  Collection.nasai: HadithCollectionInfo(
    titleEn: "Sunan an-Nasa'i",
    titleAr: 'سنن النسائي',
    totalHadith: 5768,
  ),
  Collection.ibnmajah: HadithCollectionInfo(
    titleEn: 'Sunan Ibn Majah',
    titleAr: 'سنن ابن ماجه',
    totalHadith: 4345,
  ),
};

Languages hadithLanguageForLocale(BuildContext context) {
  return Languages.en;
}

String collectionTitle(Collection collection, BuildContext context) {
  final info = kHadithCollectionInfo[collection];
  if (info == null) return collection.name;

  return context.locale.languageCode == 'ar' ? info.titleAr : info.titleEn;
}

String collectionArabicTitle(Collection collection) {
  return kHadithCollectionInfo[collection]?.titleAr ?? collection.name;
}

String bookName(Book book, Languages language) {
  for (final entry in book.book) {
    if (entry.lang == language.name) {
      return entry.name;
    }
  }
  return book.book.first.name;
}

HadithData? hadithDataForLanguage(Hadith hadith, Languages language) {
  for (final entry in hadith.hadith) {
    if (entry.lang == language.name) {
      return entry;
    }
  }
  return hadith.hadith.isNotEmpty ? hadith.hadith.first : null;
}

HadithData? arabicHadithData(Hadith hadith) {
  return hadithDataForLanguage(hadith, Languages.ar);
}

String cleanHadithBody(String body) {
  var text = body;
  text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
  text = text.replaceAll(RegExp(r'\[[^\]]*\]'), '');
  text = text.replaceAll('&nbsp;', ' ');
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text;
}

String? primaryGrade(HadithData? data) {
  if (data == null || data.grades.isEmpty) return null;
  return data.grades.first.grade;
}
