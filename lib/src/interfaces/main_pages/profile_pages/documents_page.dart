import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/document_model.dart';
import 'package:Annujoom/src/data/providers/documents_provider.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/document_viewer_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  IconData _iconFor(DocumentModel doc) {
    switch (doc.kind) {
      case DocumentKind.pdf:
        return Icons.picture_as_pdf_outlined;
      case DocumentKind.image:
        return Icons.image_outlined;
      case DocumentKind.text:
        return Icons.article_outlined;
      case DocumentKind.office:
        return Icons.table_chart_outlined;
      case DocumentKind.unknown:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(appDocumentsProvider);

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
        title: Text('documents'.tr(), style: kBodyTitleM),
      ),
      body: documentsAsync.when(
        data: (documents) {
          if (documents.isEmpty) {
            return Center(
              child: Text(
                'noDocumentsFound'.tr(),
                style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            color: kPrimaryColor,
            onRefresh: () async {
              ref.invalidate(appDocumentsProvider);
              await ref.read(appDocumentsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              itemCount: documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final document = documents[index];
                return Material(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DocumentViewerPage(
                            document: document,
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _iconFor(document),
                              color: kPrimaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  document.title,
                                  style: kSmallerTitleSB,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (document.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    document.description,
                                    style: kSmallerTitleR.copyWith(
                                      color: kSecondaryTextColor,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (document.formattedFileSize.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    document.formattedFileSize,
                                    style: kSmallerTitleR.copyWith(
                                      color: kSecondaryTextColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: kSecondaryTextColor.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: LoadingAnimation()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'errorLoadingDocuments'.tr(),
                  style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(appDocumentsProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhite,
                  ),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
