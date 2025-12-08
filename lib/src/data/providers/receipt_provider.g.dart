// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Receipt service provider

@ProviderFor(receiptService)
const receiptServiceProvider = ReceiptServiceProvider._();

/// Receipt service provider

final class ReceiptServiceProvider
    extends $FunctionalProvider<ReceiptService, ReceiptService, ReceiptService>
    with $Provider<ReceiptService> {
  /// Receipt service provider
  const ReceiptServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'receiptServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$receiptServiceHash();

  @$internal
  @override
  $ProviderElement<ReceiptService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReceiptService create(Ref ref) {
    return receiptService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiptService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiptService>(value),
    );
  }
}

String _$receiptServiceHash() => r'a224491664cebf813454d2a9c90e3571e708442b';

/// Download receipt - returns file path

@ProviderFor(downloadReceipt)
const downloadReceiptProvider = DownloadReceiptFamily._();

/// Download receipt - returns file path

final class DownloadReceiptProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Download receipt - returns file path
  const DownloadReceiptProvider._(
      {required DownloadReceiptFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'downloadReceiptProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$downloadReceiptHash();

  @override
  String toString() {
    return r'downloadReceiptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return downloadReceipt(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DownloadReceiptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$downloadReceiptHash() => r'f019f42f979061bf72d54a5f7228506470c575e4';

/// Download receipt - returns file path

final class DownloadReceiptFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  const DownloadReceiptFamily._()
      : super(
          retry: null,
          name: r'downloadReceiptProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Download receipt - returns file path

  DownloadReceiptProvider call(
    String receiptUrl,
  ) =>
      DownloadReceiptProvider._(argument: receiptUrl, from: this);

  @override
  String toString() => r'downloadReceiptProvider';
}

/// Share receipt

@ProviderFor(shareReceipt)
const shareReceiptProvider = ShareReceiptFamily._();

/// Share receipt

final class ShareReceiptProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Share receipt
  const ShareReceiptProvider._(
      {required ShareReceiptFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'shareReceiptProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$shareReceiptHash();

  @override
  String toString() {
    return r'shareReceiptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return shareReceipt(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShareReceiptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shareReceiptHash() => r'1c7b2dfb62d7793e42dd900f71368525b847b024';

/// Share receipt

final class ShareReceiptFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const ShareReceiptFamily._()
      : super(
          retry: null,
          name: r'shareReceiptProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Share receipt

  ShareReceiptProvider call(
    String receiptUrl,
  ) =>
      ShareReceiptProvider._(argument: receiptUrl, from: this);

  @override
  String toString() => r'shareReceiptProvider';
}
