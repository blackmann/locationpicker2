import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker/src/entities/autocomplete_item.dart';
import 'package:place_picker/src/entities/entities.dart';
import 'package:place_picker/src/providers/autocomplete.dart';
import 'package:provider/provider.dart';

import 'providers/providers.dart';
import 'widgets/widgets.dart';

const kDefaultLocation = LatLng(5.6364025, -0.1670703);

/// Place picker widget made with map widget from
/// [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter)
/// and other API calls to [Google Places API](https://developers.google.com/places/web-service/intro)
///
/// API key provided should have `Maps SDK for Android`, `Maps SDK for iOS`
/// and `Places API`  enabled for it
class PlacePicker extends StatelessWidget {
  /// API key generated from Google Cloud Console. You can get an API key
  /// [here](https://cloud.google.com/maps-platform/)
  final String apiKey;

  /// Location to be displayed when screen is showed. If this is set or not null, the
  /// map does not pan to the user's current location.
  final LatLng displayLocation;

  PlacePicker(this.apiKey, {this.displayLocation});

  @override
  Widget build(BuildContext context) {
    final api = ApiProvider(
      apiKey: apiKey,
    );

    return MultiProvider(providers: [
      // auto complete
      ChangeNotifierProvider(
          create: (context) => AutoCompleteProvider(api: api)),

      // location
      ChangeNotifierProvider(
          create: (context) => LocationResultProvider(api: api)),

      // nearby places
      ChangeNotifierProxyProvider<LocationResultProvider, NearbyPlacesProvider>(
          create: (context) => NearbyPlacesProvider(api: api),
          update: (context, lp, previous) {
            if (lp.result is Loaded<LocationResult>) {
              final latLng = lp.result.data.latLng;

              previous.fetchNearbyPlaces(latLng);
            }

            return previous;
          }),
    ], child: PlacePickerView(displayLocation));
  }
}

/// Place picker state
class PlacePickerView extends StatefulWidget {
  final LatLng displayLocation;

  PlacePickerView(this.displayLocation);

  @override
  _PlacePickerViewState createState() => _PlacePickerViewState();
}

class _PlacePickerViewState extends State<PlacePickerView> {
  final Completer<GoogleMapController> mapController = Completer();

  final GlobalKey appBarKey = GlobalKey();

  OverlayEntry overlayEntry;

  void onMapCreated(GoogleMapController controller) {
    this.mapController.complete(controller);

    Provider.of<LocationResultProvider>(context, listen: false)
        .setWithLatLng(widget.displayLocation ?? kDefaultLocation);
  }

  @override
  Widget build(BuildContext context) {
    final autoCompleteProvider = Provider.of<AutoCompleteProvider>(context);

    final nearbyPlacesProvider = Provider.of<NearbyPlacesProvider>(context);

    final locationResultProvider = Provider.of<LocationResultProvider>(context);

    return Scaffold(
      appBar: AppBar(
        key: this.appBarKey,
        title: SearchInput((s) {
          autoCompleteProvider.search(s);
        }),
        centerTitle: true,
        leading: null,
        automaticallyImplyLeading: false,
      ),

      //
      body: Column(
        children: <Widget>[
          // map
          Expanded(
              child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: widget.displayLocation ?? kDefaultLocation,
                    zoom: 15),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                onMapCreated: onMapCreated,
                onTap: (latLng) {
                  mapController.future.then((controller) {
                    controller.animateCamera(CameraUpdate.newLatLng(latLng));
                  });
                },
                onCameraMove: (position) {
                  locationResultProvider.setWithLatLng(position.target);
                },
              ),
              Center(
                child: Icon(
                  Icons.location_on,
                  color: Colors.black,
                  size: 32,
                ),
              )
            ],
          )),

          //  nearby places
          if (autoCompleteProvider.autocompletions
                  is Initial<List<AutoCompleteItem>> ||
              !isKeyboardShowing())
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SelectPlaceAction(
                      locationResultProvider.getResultTitle(),
                      () => Navigator.of(context)
                          .pop(locationResultProvider.result.data)),
                  Divider(height: 8),
                  Padding(
                    child:
                        Text("Nearby Places", style: TextStyle(fontSize: 16)),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  Expanded(
                    child: ListView(
                      children: nearbyPlacesProvider.nearbyPlaces
                          .map((it) => NearbyPlaceItem(it, () {
                                mapController.future.then((controller) {
                                  controller.animateCamera(
                                      CameraUpdate.newLatLng(it.latLng));
                                });
                              }))
                          .toList(),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  bool isKeyboardShowing() {
    return MediaQuery.of(context).viewInsets.bottom > 100;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // build overlay on autocomplete results
    final autoCompleteProvider = Provider.of<AutoCompleteProvider>(context);

    final locationResultProvider = Provider.of<LocationResultProvider>(context);

    autoCompleteProvider.addListener(() {
      final results = autoCompleteProvider.autocompletions;

      clearOverlay();

      if (results is Loaded<List<AutoCompleteItem>>) {
        final suggestions = results.data
            .map((e) => RichSuggestion(e, () {
                  autoCompleteProvider.clear();

                  // move camera
                  locationResultProvider.setWithPlaceId(e.id).then((lr) {
                    mapController.future.then((controller) {
                      controller.moveCamera(CameraUpdate.newLatLng(lr.latLng));
                    });
                  });
                }))
            .toList();

        displayAutoCompleteSuggestions(suggestions);
      } else if (results is Loading<List<AutoCompleteItem>>) {
        // show loading overlay
      } else if (results is Initial<List<AutoCompleteItem>>) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final RenderBox renderBox = context.findRenderObject();
    Size size = renderBox.size;

    final RenderBox appBarBox =
        this.appBarKey.currentContext.findRenderObject();

    this.overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        top: appBarBox.size.height,
        child: Material(elevation: 1, child: Column(children: suggestions)),
      ),
    );

    Overlay.of(context).insert(this.overlayEntry);
  }

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    clearOverlay();
  }
}
