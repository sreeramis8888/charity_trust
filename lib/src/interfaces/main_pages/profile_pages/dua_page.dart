import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class DuaPage extends StatefulWidget {
  const DuaPage({super.key});

  @override
  State<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  static const _pdfAssetPath = 'assets/pdf/edited_azkar_malayalam.pdf';

  late final PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openAsset(_pdfAssetPath),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

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
        title: Text('dua'.tr(), style: kSubHeadingM),
      ),
      body: Column(
        children: [
          Expanded(
            child: PdfView(
              controller: _pdfController,
              scrollDirection: Axis.vertical,
              builders: PdfViewBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                documentLoaderBuilder: (_) => const Center(
                  child: LoadingAnimation(),
                ),
                pageLoaderBuilder: (_) => const Center(
                  child: LoadingAnimation(),
                ),
                errorBuilder: (_, error) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      error.toString(),
                      style:
                          kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          PdfPageNumber(
            controller: _pdfController,
            builder: (_, loadingState, page, pagesCount) {
              if (loadingState != PdfLoadingState.success ||
                  pagesCount == null) {
                return const SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                color: kWhite,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  '$page / $pagesCount',
                  style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
