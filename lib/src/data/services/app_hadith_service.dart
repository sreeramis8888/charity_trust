import 'dart:convert';

import 'package:Annujoom/src/data/utils/hadith_helpers.dart';
import 'package:flutter/services.dart';
import 'package:hadith/hadith.dart';

/// Flutter-compatible hadith loader using bundled assets.
///
/// The [HadithService] from the hadith package reads local files via dart:io,
/// which does not work on mobile. This service mirrors its API using rootBundle.
class AppHadithService {
  AppHadithService._();
  static final AppHadithService instance = AppHadithService._();

  final Map<Collection, List<Book>> _booksCache = {};
  final Map<Collection, Map<String, dynamic>> _hadithsCache = {};

  String _collectionName(Collection collection) => collection.name;

  String _assetPath(Collection collection, String file) {
    return 'assets/hadith/${_collectionName(collection)}/$file';
  }

  Future<List<Book>> getBooks(Collection collection) async {
    if (_booksCache.containsKey(collection)) {
      return _booksCache[collection]!;
    }

    final contents = await rootBundle.loadString(
      _assetPath(collection, 'books.json'),
    );
    final jsonData = jsonDecode(contents) as List<dynamic>;
    final books = jsonData.map((json) => Book.fromJson(json)).toList();
    _booksCache[collection] = books;
    return books;
  }

  Future<Map<String, dynamic>> _loadHadiths(Collection collection) async {
    if (_hadithsCache.containsKey(collection)) {
      return _hadithsCache[collection]!;
    }

    final contents = await rootBundle.loadString(
      _assetPath(collection, 'hadiths.json'),
    );
    final jsonData = jsonDecode(contents) as Map<String, dynamic>;
    _hadithsCache[collection] = jsonData;
    return jsonData;
  }

  Future<List<Collection>> getCollections() async {
    return kHadithCollectionOrder;
  }

  Future<Book> getBook(Collection collection, int bookNumber) async {
    final books = await getBooks(collection);
    return books.firstWhere(
      (book) => book.bookNumber == bookNumber.toString(),
      orElse: () => throw Exception(
        'Book number $bookNumber not found in $collection.',
      ),
    );
  }

  Future<List<Hadith>> getHadiths(Collection collection, int bookNumber) async {
    final hadithsData = await _loadHadiths(collection);
    final bookKey = bookNumber.toString();

    if (!hadithsData.containsKey(bookKey)) {
      throw Exception(
        'Hadiths not found for book number $bookNumber in $collection.',
      );
    }

    final hadithList = hadithsData[bookKey] as List<dynamic>;
    return hadithList.map((json) => Hadith.fromJson(json)).toList();
  }

  Future<Hadith?> getHadith(
    Collection collection,
    int bookNumber,
    int hadithNumber,
  ) async {
    final hadiths = await getHadiths(collection, bookNumber);
    for (final hadith in hadiths) {
      if (hadith.hadithNumber == hadithNumber.toString()) {
        return hadith;
      }
    }
    return null;
  }

  String getCollectionURL(Collection collection) {
    return 'https://sunnah.com/${_collectionName(collection)}';
  }

  String getBookURL(Collection collection, int bookNumber) {
    return '${getCollectionURL(collection)}/$bookNumber';
  }

  String getHadithURL(
    Collection collection,
    int bookNumber,
    int hadithNumber,
  ) {
    return '${getBookURL(collection, bookNumber)}/$hadithNumber';
  }
}
