class Validators {
static String? validateAadharNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Aadhar number is required';
  }

  final aadhar = value.trim();

  if (!RegExp(r'^\d{12}$').hasMatch(aadhar)) {
    return 'Aadhar number must be exactly 12 digits';
  }

  if (!_verifyAadharChecksum(aadhar)) {
    return 'Invalid Aadhar number';
  }

  return null;
}

static bool _verifyAadharChecksum(String aadhar) {
  const List<List<int>> d = [
    [0,1,2,3,4,5,6,7,8,9],
    [1,2,3,4,0,6,7,8,9,5],
    [2,3,4,0,1,7,8,9,5,6],
    [3,4,0,1,2,8,9,5,6,7],
    [4,0,1,2,3,9,5,6,7,8],
    [5,9,8,7,6,0,4,3,2,1],
    [6,5,9,8,7,1,0,4,3,2],
    [7,6,5,9,8,2,1,0,4,3],
    [8,7,6,5,9,3,2,1,0,4],
    [9,8,7,6,5,4,3,2,1,0],
  ];

  const List<List<int>> p = [
    [0,1,2,3,4,5,6,7,8,9],
    [1,5,7,6,2,8,3,0,9,4],
    [5,8,0,3,7,9,6,1,4,2],
    [8,9,1,6,0,4,3,5,2,7],
    [9,4,5,3,1,2,6,8,7,0],
    [4,2,8,6,5,7,3,9,0,1],
    [2,7,9,3,8,0,6,4,1,5],
    [7,0,4,6,9,1,3,2,5,8],
  ];

  int c = 0;

  for (int i = 0; i < aadhar.length; i++) {
    int digit = int.parse(aadhar[aadhar.length - i - 1]);
    c = d[c][p[i % 8][digit]];
  }

  return c == 0;
}

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    if (email.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    if (!email.contains('@')) {
      return 'Email must contain @';
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Email must have exactly one @';
    }

    final localPart = parts[0];
    final domainPart = parts[1];

    if (localPart.isEmpty) {
      return 'Email local part cannot be empty';
    }

    if (localPart.length > 64) {
      return 'Email local part is too long (max 64 characters)';
    }

    if (!RegExp(r'^[a-zA-Z0-9._%-]+$').hasMatch(localPart)) {
      return 'Email contains invalid characters';
    }

    if (localPart.startsWith('.') || localPart.endsWith('.')) {
      return 'Email cannot start or end with a dot';
    }

    if (localPart.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    if (domainPart.isEmpty) {
      return 'Email domain cannot be empty';
    }

    if (!domainPart.contains('.')) {
      return 'Email domain must contain a dot';
    }

    final domainParts = domainPart.split('.');
    if (domainParts.length < 2) {
      return 'Email domain must have at least one dot';
    }

    for (final part in domainParts) {
      if (part.isEmpty) {
        return 'Email domain parts cannot be empty';
      }

      if (part.length > 63) {
        return 'Email domain part is too long';
      }

      if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(part)) {
        return 'Email domain contains invalid characters';
      }

      if (part.startsWith('-') || part.endsWith('-')) {
        return 'Email domain parts cannot start or end with hyphen';
      }
    }

    final tld = domainParts.last;
    if (tld.length < 2) {
      return 'Email TLD must be at least 2 characters';
    }

    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(tld)) {
      return 'Email TLD must contain only letters';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}
