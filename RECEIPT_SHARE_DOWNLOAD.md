# Receipt Share & Download Implementation

## Overview

Complete implementation for sharing and downloading receipt PDFs from AWS S3 URLs in the payment success page.

## Files Created

### 1. **ReceiptService** (`lib/src/data/services/receipt_service.dart`)
Core service handling all receipt operations:
- `downloadReceipt(url)` - Downloads PDF to app documents directory
- `shareReceipt(url)` - Downloads and shares via native share sheet
- `openReceipt(url)` - Downloads and prepares for opening
- `receiptExists(url)` - Checks if receipt already downloaded
- `getLocalReceiptPath(url)` - Gets path if exists locally

### 2. **Receipt Provider** (`lib/src/data/providers/receipt_provider.dart`)
Riverpod providers for reactive state:
- `receiptServiceProvider` - Service instance
- `downloadReceiptProvider(url)` - Download future
- `shareReceiptProvider(url)` - Share future
- `openReceiptProvider(url)` - Open future
- `receiptExistsProvider(url)` - Existence check
- `getLocalReceiptPathProvider(url)` - Local path getter

### 3. **Updated PaymentSuccessPage** (`lib/src/interfaces/components/additional_pages/payment_success_page.dart`)
- Changed to `ConsumerStatefulWidget` for Riverpod integration
- Added `_ShareButton` widget with error handling
- Added `_DownloadButton` widget with error handling
- Both buttons show snackbar feedback on success/failure

## How It Works

### Download Flow
1. User taps "Download" button
2. Service downloads PDF from S3 URL to app documents directory
3. Filename extracted from URL or generated with timestamp
4. Success message shows file path

### Share Flow
1. User taps "Share" button
2. Service downloads PDF (if not already downloaded)
3. Native share sheet opens with PDF file
4. User can share via email, messaging, etc.

## Dependencies Required

Add to `pubspec.yaml`:
```yaml
dependencies:
  dio: ^5.0.0
  path_provider: ^2.0.0
  share_plus: ^7.0.0
  flutter_riverpod: ^2.0.0
  riverpod_annotation: ^2.0.0

dev_dependencies:
  build_runner: ^2.0.0
  riverpod_generator: ^2.0.0
```

## Usage

### In PaymentSuccessPage
The receipt URL is passed as a parameter:
```dart
PaymentSuccessPage(
  orderId: '12345',
  paymentId: 'pay_xyz',
  amount: 500.0,
  receipt: 'https://bucket-annujoom.s3.ap-south-1.amazonaws.com/donations/invoices/1764932103156_invoice_6932b9dd3ae7ca6f1128421d.pdf',
)
```

### In Other Widgets
```dart
// Download receipt
final filePath = await ref.read(downloadReceiptProvider(url).future);

// Share receipt
await ref.read(shareReceiptProvider(url).future);

// Check if exists
final exists = await ref.read(receiptExistsProvider(url).future);
```

## Error Handling

All operations include try-catch with user feedback:
- Download failures show error message
- Share failures show error message
- Network errors are caught and displayed
- Buttons are disabled if receipt URL is null

## File Storage

Downloaded receipts are stored in:
- **iOS**: `Documents` directory (app-specific)
- **Android**: `Documents` directory (app-specific)

Files are named based on S3 URL or timestamped if extraction fails.

## Next Steps

1. Run `flutter pub get` to install dependencies
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`
3. Pass receipt URL from your payment API response
4. Test share and download functionality

## Notes

- Downloads are cached locally - subsequent shares use cached file
- Share sheet is native to each platform (iOS/Android)
- File paths are app-specific and secure
- No external storage permissions needed on modern Android
