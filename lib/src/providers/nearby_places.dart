import 'package:flutter/foundation.dart';
import 'package:place_picker/src/entities/entities.dart';
import 'api.dart';

class NearbyPlacesProvider extends ChangeNotifier {
  final ApiProvider api;

  final List<NearbyPlace> nearbyPlaces = [];

  NearbyPlacesProvider({@required this.api});

  Future<void> fetchNearbyPlaces(latLng) async {
    final nbp = await api.fetchNearbyPlaces(latLng);

    nearbyPlaces.clear();

    nearbyPlaces.addAll(nbp);

    notifyListeners();
  }
}
