// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getAllCountries)
const getAllCountriesProvider = GetAllCountriesProvider._();

final class GetAllCountriesProvider extends $FunctionalProvider<
        AsyncValue<List<Country>>, List<Country>, FutureOr<List<Country>>>
    with $FutureModifier<List<Country>>, $FutureProvider<List<Country>> {
  const GetAllCountriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getAllCountriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getAllCountriesHash();

  @$internal
  @override
  $FutureProviderElement<List<Country>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Country>> create(Ref ref) {
    return getAllCountries(ref);
  }
}

String _$getAllCountriesHash() => r'e638eb04415bf1c604b8d2ed62c8a7b985c33d83';

@ProviderFor(getStatesByCountry)
const getStatesByCountryProvider = GetStatesByCountryFamily._();

final class GetStatesByCountryProvider extends $FunctionalProvider<
        AsyncValue<List<State>>, List<State>, FutureOr<List<State>>>
    with $FutureModifier<List<State>>, $FutureProvider<List<State>> {
  const GetStatesByCountryProvider._(
      {required GetStatesByCountryFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'getStatesByCountryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getStatesByCountryHash();

  @override
  String toString() {
    return r'getStatesByCountryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<State>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<State>> create(Ref ref) {
    final argument = this.argument as String;
    return getStatesByCountry(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetStatesByCountryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getStatesByCountryHash() =>
    r'ab24440500b44620298ce3a183f2d5aef5f94bb5';

final class GetStatesByCountryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<State>>, String> {
  const GetStatesByCountryFamily._()
      : super(
          retry: null,
          name: r'getStatesByCountryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GetStatesByCountryProvider call(
    String countryCode,
  ) =>
      GetStatesByCountryProvider._(argument: countryCode, from: this);

  @override
  String toString() => r'getStatesByCountryProvider';
}

@ProviderFor(getDistrictsByState)
const getDistrictsByStateProvider = GetDistrictsByStateFamily._();

final class GetDistrictsByStateProvider extends $FunctionalProvider<
        AsyncValue<List<City>>, List<City>, FutureOr<List<City>>>
    with $FutureModifier<List<City>>, $FutureProvider<List<City>> {
  const GetDistrictsByStateProvider._(
      {required GetDistrictsByStateFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'getDistrictsByStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getDistrictsByStateHash();

  @override
  String toString() {
    return r'getDistrictsByStateProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<City>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<City>> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return getDistrictsByState(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetDistrictsByStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getDistrictsByStateHash() =>
    r'c314a37527d3d9759769749687bd3f0b6cea9643';

final class GetDistrictsByStateFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<List<City>>,
            (
              String,
              String,
            )> {
  const GetDistrictsByStateFamily._()
      : super(
          retry: null,
          name: r'getDistrictsByStateProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GetDistrictsByStateProvider call(
    String countryCode,
    String stateCode,
  ) =>
      GetDistrictsByStateProvider._(argument: (
        countryCode,
        stateCode,
      ), from: this);

  @override
  String toString() => r'getDistrictsByStateProvider';
}

@ProviderFor(getCountryName)
const getCountryNameProvider = GetCountryNameFamily._();

final class GetCountryNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const GetCountryNameProvider._(
      {required GetCountryNameFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'getCountryNameProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getCountryNameHash();

  @override
  String toString() {
    return r'getCountryNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return getCountryName(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetCountryNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getCountryNameHash() => r'098e51e00a58699782766e7fccf90da4c8f19b79';

final class GetCountryNameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  const GetCountryNameFamily._()
      : super(
          retry: null,
          name: r'getCountryNameProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GetCountryNameProvider call(
    String countryCode,
  ) =>
      GetCountryNameProvider._(argument: countryCode, from: this);

  @override
  String toString() => r'getCountryNameProvider';
}

@ProviderFor(getStateName)
const getStateNameProvider = GetStateNameFamily._();

final class GetStateNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const GetStateNameProvider._(
      {required GetStateNameFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'getStateNameProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getStateNameHash();

  @override
  String toString() {
    return r'getStateNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return getStateName(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetStateNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getStateNameHash() => r'69795301e6ea6264ed7a19aa2442ad727d9091b0';

final class GetStateNameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  const GetStateNameFamily._()
      : super(
          retry: null,
          name: r'getStateNameProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GetStateNameProvider call(
    String stateCode,
  ) =>
      GetStateNameProvider._(argument: stateCode, from: this);

  @override
  String toString() => r'getStateNameProvider';
}

@ProviderFor(getCityName)
const getCityNameProvider = GetCityNameFamily._();

final class GetCityNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const GetCityNameProvider._(
      {required GetCityNameFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'getCityNameProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getCityNameHash();

  @override
  String toString() {
    return r'getCityNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return getCityName(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetCityNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getCityNameHash() => r'3db6651cfa71916f0464091a0e194d8f5b45e490';

final class GetCityNameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  const GetCityNameFamily._()
      : super(
          retry: null,
          name: r'getCityNameProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GetCityNameProvider call(
    String cityId,
  ) =>
      GetCityNameProvider._(argument: cityId, from: this);

  @override
  String toString() => r'getCityNameProvider';
}
