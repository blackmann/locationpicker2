import 'package:meta/meta.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// The result returned after completing location selection.
class LocationResult {
  /// The human readable name of the location. This is primarily the
  /// name of the road. But in cases where the place was selected from Nearby
  /// places list, we use the <b>name</b> provided on the list item.
  final String name; // or road

  /// The human readable locality of the location.
  final String locality;

  /// Latitude/Longitude of the selected location.
  final LatLng latLng;

  /// Formatted address suggested by Google
  final String formattedAddress;

  String placeId;

  Map<String, dynamic> data;

  LocationResult({
    @required this.latLng,
    this.name,
    this.locality,
    this.formattedAddress,
    this.data,
  });

  @override
  String toString() {
    return 'LocationResult: $name (${latLng.latitude}, ${latLng.longitude})';
  }
}
