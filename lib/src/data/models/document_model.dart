enum DocumentKind {
  pdf,
  image,
  text,
  office,
  unknown,
}

class DocumentModel {
  final String? id;
  final String title;
  final String description;
  final String fileUrl;
  final int fileSize;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DocumentModel({
    this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.fileSize,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  String get _pathLower {
    final uri = Uri.tryParse(fileUrl);
    final path = uri?.path.isNotEmpty == true ? uri!.path : fileUrl;
    return path.toLowerCase();
  }

  DocumentKind get kind {
    final path = _pathLower;
    if (path.endsWith('.pdf')) return DocumentKind.pdf;
    if (path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp')) {
      return DocumentKind.image;
    }
    if (path.endsWith('.txt') || path.endsWith('.csv')) {
      return DocumentKind.text;
    }
    if (path.endsWith('.doc') ||
        path.endsWith('.docx') ||
        path.endsWith('.xls') ||
        path.endsWith('.xlsx')) {
      return DocumentKind.office;
    }
    return DocumentKind.unknown;
  }

  bool get isPdf => kind == DocumentKind.pdf;
  bool get isImage => kind == DocumentKind.image;
  bool get isText => kind == DocumentKind.text;
  bool get isOffice => kind == DocumentKind.office;

  String get formattedFileSize {
    if (fileSize <= 0) return '';
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['_id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      fileSize: json['file_size'] is int
          ? json['file_size'] as int
          : int.tryParse(json['file_size']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
