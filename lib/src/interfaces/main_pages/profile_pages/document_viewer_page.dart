import 'dart:convert';

import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/document_model.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';

/// In-app document reader for every format accepted by the backend:
/// PDF, Word, Excel, plain text, CSV, and images.
class DocumentViewerPage extends StatefulWidget {
  final DocumentModel document;

  const DocumentViewerPage({
    super.key,
    required this.document,
  });

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  PdfController? _pdfController;
  String? _textContent;
  bool _loading = true;
  bool _officeWebLoading = true;
  String? _error;
  bool _useGoogleOfficeViewer = false;

  @override
  void initState() {
    super.initState();
    _openDocument();
  }

  Uri? get _officeViewerUri {
    final encoded = Uri.encodeComponent(widget.document.fileUrl);
    if (_useGoogleOfficeViewer) {
      return Uri.parse(
        'https://docs.google.com/gview?embedded=true&url=$encoded',
      );
    }
    return Uri.parse(
      'https://view.officeapps.live.com/op/embed.aspx?src=$encoded',
    );
  }

  Future<void> _openDocument() async {
    final url = widget.document.fileUrl.trim();
    if (url.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'documentOpenFailed'.tr();
      });
      return;
    }

    switch (widget.document.kind) {
      case DocumentKind.image:
      case DocumentKind.office:
      case DocumentKind.unknown:
        setState(() {
          _loading = false;
          _error = null;
          _officeWebLoading = widget.document.isOffice ||
              widget.document.kind == DocumentKind.unknown;
        });
        return;
      case DocumentKind.pdf:
        await _loadPdf(url);
        return;
      case DocumentKind.text:
        await _loadText(url);
        return;
    }
  }

  Future<void> _loadPdf(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 30),
          );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final controller = PdfController(
        document: PdfDocument.openData(response.bodyBytes),
      );

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _pdfController = controller;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'documentOpenFailed'.tr();
      });
    }
  }

  Future<void> _loadText(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 30),
          );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      // Prefer UTF-8; fall back to latin1 so CSV/export files still show.
      String content;
      try {
        content = utf8.decode(response.bodyBytes);
      } catch (_) {
        content = latin1.decode(response.bodyBytes);
      }

      if (!mounted) return;
      setState(() {
        _textContent = content;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'documentOpenFailed'.tr();
      });
    }
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.document.fileUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _retry() {
    _pdfController?.dispose();
    _pdfController = null;
    setState(() {
      _textContent = null;
      _loading = true;
      _officeWebLoading = true;
      _error = null;
      _useGoogleOfficeViewer = false;
    });
    _openDocument();
  }

  void _switchToGoogleViewer() {
    setState(() {
      _useGoogleOfficeViewer = true;
      _officeWebLoading = true;
      _error = null;
    });
  }

  @override
  void dispose() {
    _pdfController?.dispose();
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
        title: Text(
          widget.document.title,
          style: kSubHeadingM,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'openExternally'.tr(),
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new, color: kTextColor, size: 20),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: LoadingAnimation());
    }

    if (_error != null) {
      return _ErrorState(
        message: _error!,
        onRetry: _retry,
        onOpenExternally: _openExternally,
      );
    }

    switch (widget.document.kind) {
      case DocumentKind.image:
        return _ImageViewer(url: widget.document.fileUrl);
      case DocumentKind.pdf:
        return _PdfViewer(controller: _pdfController!);
      case DocumentKind.text:
        return _TextViewer(content: _textContent ?? '');
      case DocumentKind.office:
      case DocumentKind.unknown:
        return _OfficeWebViewer(
          viewerUri: _officeViewerUri!,
          isLoading: _officeWebLoading,
          onLoadingChanged: (loading) {
            if (!mounted) return;
            setState(() => _officeWebLoading = loading);
          },
          onFailed: () {
            if (!mounted) return;
            if (!_useGoogleOfficeViewer) {
              _switchToGoogleViewer();
              return;
            }
            setState(() {
              _error = 'documentOpenFailed'.tr();
            });
          },
        );
    }
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenExternally;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.onOpenExternally,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text('retry'.tr()),
            ),
            TextButton(
              onPressed: onOpenExternally,
              child: Text('openExternally'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String url;

  const _ImageViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: LoadingAnimation());
          },
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              'documentOpenFailed'.tr(),
              style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _PdfViewer extends StatelessWidget {
  final PdfController controller;

  const _PdfViewer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PdfView(
            controller: controller,
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
                    style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
        PdfPageNumber(
          controller: controller,
          builder: (_, loadingState, page, pagesCount) {
            if (loadingState != PdfLoadingState.success || pagesCount == null) {
              return const SizedBox.shrink();
            }

            return Container(
              width: double.infinity,
              color: kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '$page / $pagesCount',
                style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TextViewer extends StatelessWidget {
  final String content;

  const _TextViewer({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          content.isEmpty ? '—' : content,
          style: kSmallerTitleR.copyWith(
            color: kTextColor,
            height: 1.45,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _OfficeWebViewer extends StatefulWidget {
  final Uri viewerUri;
  final bool isLoading;
  final ValueChanged<bool> onLoadingChanged;
  final VoidCallback onFailed;

  const _OfficeWebViewer({
    required this.viewerUri,
    required this.isLoading,
    required this.onLoadingChanged,
    required this.onFailed,
  });

  @override
  State<_OfficeWebViewer> createState() => _OfficeWebViewerState();
}

class _OfficeWebViewerState extends State<_OfficeWebViewer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          key: ValueKey(widget.viewerUri.toString()),
          initialUrlRequest: URLRequest(url: WebUri.uri(widget.viewerUri)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
          ),
          onLoadStart: (_, __) => widget.onLoadingChanged(true),
          onLoadStop: (_, __) => widget.onLoadingChanged(false),
          onReceivedError: (_, __, ___) => widget.onFailed(),
          onReceivedHttpError: (_, __, response) {
            final statusCode = response.statusCode;
            if (statusCode != null && statusCode >= 400) {
              widget.onFailed();
            }
          },
        ),
        if (widget.isLoading)
          const ColoredBox(
            color: Color(0xFFF2F2F2),
            child: Center(child: LoadingAnimation()),
          ),
      ],
    );
  }
}
