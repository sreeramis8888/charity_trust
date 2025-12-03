import 'package:flutter_countries/flutter_countries.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_provider.g.dart';

@riverpod
Future<List<Country>> getAllCountries(Ref ref) async {
  return await Countries.all;
}

@riverpod
Future<List<State>> getStatesByCountry(Ref ref, String countryCode) async {
  try {
    return await States.byCountryCode(countryCode);
  } catch (e) {
    return [];
  }
}

@riverpod
Future<List<City>> getDistrictsByState(
  Ref ref,
  String countryCode,
  String stateCode,
) async {
  try {
    return await Cities.byStateCode(stateCode);
  } catch (e) {
    return [];
  }
}

@riverpod
Future<String?> getCountryName(Ref ref, String countryCode) async {
  try {
    final countries = await Countries.byIso2(countryCode);
    return countries.isNotEmpty ? countries.first.name : null;
  } catch (e) {
    return null;
  }
}

@riverpod
Future<String?> getStateName(Ref ref, String stateCode) async {
  try {
    final states = await States.byStateCode(stateCode);
    return states.isNotEmpty ? states.first.name : null;
  } catch (e) {
    return null;
  }
}

@riverpod
Future<String?> getCityName(Ref ref, String cityId) async {
  try {
    final cities = await Cities.byId(cityId);
    return cities.isNotEmpty ? cities.first.name : null;
  } catch (e) {
    return null;
  }
}
