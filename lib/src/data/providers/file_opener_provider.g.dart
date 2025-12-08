// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_opener_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// File opener service provider

@ProviderFor(fileOpenerService)
const fileOpenerServiceProvider = FileOpenerServiceProvider._();

/// File opener service provider

final class FileOpenerServiceProvider extends $FunctionalProvider<
    FileOpenerService,
    FileOpenerService,
    FileOpenerService> with $Provider<FileOpenerService> {
  /// File opener service provider
  const FileOpenerServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fileOpenerServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fileOpenerServiceHash();

  @$internal
  @override
  $ProviderElement<FileOpenerService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FileOpenerService create(Ref ref) {
    return fileOpenerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileOpenerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileOpenerService>(value),
    );
  }
}

String _$fileOpenerServiceHash() => r'1cbd49affd705551fb2bfe8754c6f0f254d09734';

/// Open file - returns OpenResult

@ProviderFor(openFile)
const openFileProvider = OpenFileFamily._();

/// Open file - returns OpenResult

final class OpenFileProvider extends $FunctionalProvider<AsyncValue<OpenResult>,
        OpenResult, FutureOr<OpenResult>>
    with $FutureModifier<OpenResult>, $FutureProvider<OpenResult> {
  /// Open file - returns OpenResult
  const OpenFileProvider._(
      {required OpenFileFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'openFileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$openFileHash();

  @override
  String toString() {
    return r'openFileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OpenResult> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OpenResult> create(Ref ref) {
    final argument = this.argument as String;
    return openFile(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OpenFileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$openFileHash() => r'b372e7c6dcd49f854a603cd4eae9f55b0061d7cf';

/// Open file - returns OpenResult

final class OpenFileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OpenResult>, String> {
  const OpenFileFamily._()
      : super(
          retry: null,
          name: r'openFileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Open file - returns OpenResult

  OpenFileProvider call(
    String filePath,
  ) =>
      OpenFileProvider._(argument: filePath, from: this);

  @override
  String toString() => r'openFileProvider';
}

/// Open PDF file

@ProviderFor(openPdf)
const openPdfProvider = OpenPdfFamily._();

/// Open PDF file

final class OpenPdfProvider extends $FunctionalProvider<AsyncValue<OpenResult>,
        OpenResult, FutureOr<OpenResult>>
    with $FutureModifier<OpenResult>, $FutureProvider<OpenResult> {
  /// Open PDF file
  const OpenPdfProvider._(
      {required OpenPdfFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'openPdfProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$openPdfHash();

  @override
  String toString() {
    return r'openPdfProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OpenResult> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OpenResult> create(Ref ref) {
    final argument = this.argument as String;
    return openPdf(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OpenPdfProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$openPdfHash() => r'8934737c3fbca9123028e9262efed970b8f9d933';

/// Open PDF file

final class OpenPdfFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OpenResult>, String> {
  const OpenPdfFamily._()
      : super(
          retry: null,
          name: r'openPdfProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Open PDF file

  OpenPdfProvider call(
    String filePath,
  ) =>
      OpenPdfProvider._(argument: filePath, from: this);

  @override
  String toString() => r'openPdfProvider';
}

/// Check if file exists

@ProviderFor(fileExists)
const fileExistsProvider = FileExistsFamily._();

/// Check if file exists

final class FileExistsProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Check if file exists
  const FileExistsProvider._(
      {required FileExistsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'fileExistsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fileExistsHash();

  @override
  String toString() {
    return r'fileExistsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return fileExists(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FileExistsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fileExistsHash() => r'f63ba665ef0ad57b94bb2e72e25ee750c61aeb9e';

/// Check if file exists

final class FileExistsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const FileExistsFamily._()
      : super(
          retry: null,
          name: r'fileExistsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Check if file exists

  FileExistsProvider call(
    String filePath,
  ) =>
      FileExistsProvider._(argument: filePath, from: this);

  @override
  String toString() => r'fileExistsProvider';
}

/// Get file size

@ProviderFor(getFileSize)
const getFileSizeProvider = GetFileSizeFamily._();

/// Get file size

final class GetFileSizeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Get file size
  const GetFileSizeProvider._(
      {required GetFileSizeFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'getFileSizeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getFileSizeHash();

  @override
  String toString() {
    return r'getFileSizeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return getFileSize(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetFileSizeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getFileSizeHash() => r'5f3c901cd49f091a672197ab6c2d79736b859036';

/// Get file size

final class GetFileSizeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  const GetFileSizeFamily._()
      : super(
          retry: null,
          name: r'getFileSizeProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Get file size

  GetFileSizeProvider call(
    String filePath,
  ) =>
      GetFileSizeProvider._(argument: filePath, from: this);

  @override
  String toString() => r'getFileSizeProvider';
}

/// Delete file

@ProviderFor(deleteFile)
const deleteFileProvider = DeleteFileFamily._();

/// Delete file

final class DeleteFileProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Delete file
  const DeleteFileProvider._(
      {required DeleteFileFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'deleteFileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deleteFileHash();

  @override
  String toString() {
    return r'deleteFileProvider'
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
    return deleteFile(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteFileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteFileHash() => r'ee0879432daff497e6b67b8238f9755c71c5f41e';

/// Delete file

final class DeleteFileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const DeleteFileFamily._()
      : super(
          retry: null,
          name: r'deleteFileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Delete file

  DeleteFileProvider call(
    String filePath,
  ) =>
      DeleteFileProvider._(argument: filePath, from: this);

  @override
  String toString() => r'deleteFileProvider';
}
