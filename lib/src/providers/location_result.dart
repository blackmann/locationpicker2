import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker/place_picker.dart';
import 'data_state.dart';
import 'api.dart';

class LocationResultProvider extends ChangeNotifier {
  final ApiProvider api;

  DataState<LocationResult> result = DataState.initial();

  LocationResultProvider({@required this.api});

  Timer deboucer;

  void setResult(LatLng coordinates) {
    result = DataState.loaded(LocationResult(latLng: coordinates));
  }

  String getResultTitle() {
    if (result is Loaded<LocationResult>) {
      return result.data.name;
    }

    return 'Loading location...';
  }

  /// Wait for debounce completion before executing
  void setWithLatLng(LatLng latLng) {
    deboucer?.cancel();

    deboucer = Timer(Duration(milliseconds: 500), () {
      _setWithLatLng(latLng);
    });
  }

  Future<void> setWithLatLngAndName(LatLng latLng, String name) async {
    result = DataState.loading();

    notifyListeners();

    final reverseData = await api.reverseGeoCode(latLng);

    // TODO use name arg
    final lr = _buildResult(latLng, reverseData);

    result = DataState.loaded(lr);

    notifyListeners();
  }

  Future<LocationResult> _setWithLatLng(LatLng latLng) async {
    result = DataState.loading();

    notifyListeners();

    final reverseData = await api.reverseGeoCode(latLng);

    final lr = _buildResult(latLng, reverseData);

    result = DataState.loaded(lr);

    notifyListeners();

    return lr;
  }

  Future<LocationResult> setWithPlaceId(String id) async {
    result = DataState.loading();

    notifyListeners();

    final decoded = await api.decodePlace(id);

    final res = await _setWithLatLng(decoded);

    return res;
  }

  LocationResult _buildResult(LatLng latLng, Map<String, dynamic> data) {
    final addressComp = data['results'][0];

    final name = addressComp['address_components'][0]['short_name'];
    final formattedAddress = addressComp['formatted_address'];

    LocationResult lr = LocationResult(
        latLng: latLng,
        data: data,
        name: name,
        formattedAddress: formattedAddress);

    return lr;
  }
}
