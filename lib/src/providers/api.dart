import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:place_picker/src/entities/entities.dart';

import 'uuid.dart';

class ApiError implements Exception {
  final int statusCode;
  final String message;

  ApiError(http.Response response)
      : this.statusCode = response.statusCode,
        this.message = response.body;

  @override
  String toString() {
    return '[ApiError: $statusCode] : $message';
  }
}

class ApiProvider {
  final String apiKey;

  /// Session token required for autocomplete API call
  final String sessionToken = Uuid().generateV4();

  ApiProvider({@required this.apiKey});

  Future<Map<String, dynamic>> reverseGeoCode(LatLng latLng) async {
    final response = await http.get(
        "https://maps.googleapis.com/maps/api/geocode/json?" +
            "latlng=${latLng.latitude},${latLng.longitude}&" +
            "key=$apiKey");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw ApiError(response);
  }

  Future<List<NearbyPlace>> fetchNearbyPlaces(LatLng latLng) async {
    final response = await http.get(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?" +
            "key=$apiKey&" +
            "location=${latLng.latitude},${latLng.longitude}&radius=150");

    if (response.statusCode != 200) {
      throw ApiError(response);
    }

    final res = List<NearbyPlace>();

    final data = jsonDecode(response.body);

    for (Map<String, dynamic> item in data['results']) {
      final nearbyPlace = NearbyPlace()
        ..name = item['name']
        ..icon = item['icon']
        ..latLng = LatLng(item['geometry']['location']['lat'],
            item['geometry']['location']['lng']);

      res.add(nearbyPlace);
    }

    return res;
  }

  /// Returns the lat,lng of a place id (from search results)
  Future<LatLng> decodePlace(String placeId) async {
    final response = await http.get(
        "https://maps.googleapis.com/maps/api/place/details/json?key=$apiKey" +
            "&placeid=$placeId");

    if (response.statusCode != 200) {
      throw ApiError(response);
    }
    final data = jsonDecode(response.body);
    final location = data['result']['geometry']['location'];

    return LatLng(location['lat'] as double, location['lng'] as double);
  }

  /// Autocomplete suggestions
  Future<List<AutoCompleteItem>> getSearchPredictions(String keyword) async {
    keyword = keyword.replaceAll(" ", "+");

    var endpoint =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?" +
            "key=$apiKey&" +
            "input=$keyword&sessiontoken=$sessionToken";

    final response = await http.get(endpoint);

    if (response.statusCode != 200) {
      throw ApiError(response);
    }

    final data = jsonDecode(response.body);

    List<dynamic> predictions = data['predictions'];

    return predictions
        .map((e) => AutoCompleteItem(
            id: e['place_id'],
            text: e['description'],
            offset: e['matched_substrings'][0]['offset'],
            length: e['matched_substrings'][0]['length']))
        .toList();
  }
}
