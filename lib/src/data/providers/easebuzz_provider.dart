import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/services/easebuzz_service.dart';

part 'easebuzz_provider.g.dart';

@riverpod
EasebuzzService easebuzzService(Ref ref) {
  log('Creating new easebuzz service instance', name: 'easeProvider');
  final service = EasebuzzService();

  ref.onDispose(() {
    log('easebuzz provider disposed', name: 'easeProvider');
    service.dispose();
  });

  return service;
}
