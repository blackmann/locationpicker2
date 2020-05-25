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

    LocationResult lr =
        LocationResult(latLng: latLng, data: reverseData, name: name);

    result = DataState.loaded(lr);

    notifyListeners();
  }

  Future<void> _setWithLatLng(LatLng latLng) async {
    result = DataState.loading();

    notifyListeners();

    final reverseData = await api.reverseGeoCode(latLng);

    // TODO: change name
    LocationResult lr =
        LocationResult(latLng: latLng, data: reverseData, name: 'Unnamed road');

    result = DataState.loaded(lr);

    notifyListeners();
  }
}
