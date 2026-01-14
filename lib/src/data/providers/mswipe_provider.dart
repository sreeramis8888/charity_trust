import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/services/mswipe_service.dart';

part 'mswipe_provider.g.dart';

MswipeService? _mswipeServiceInstance;

@riverpod
MswipeService mswipeService(Ref ref) {
  if (_mswipeServiceInstance != null) {
    log('Reusing existing Mswipe service instance', name: 'mswipeProvider');
    return _mswipeServiceInstance!;
  }

  log('Creating new Mswipe service instance', name: 'mswipeProvider');
  final service = MswipeService();
  _mswipeServiceInstance = service;

  ref.onDispose(() {
    log('Mswipe provider disposed', name: 'mswipeProvider');
    service.dispose();
  });

  return service;
}
