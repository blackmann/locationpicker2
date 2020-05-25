import 'package:meta/meta.dart';

/// Autocomplete results item returned from Google will be deserialized
/// into this model.
class AutoCompleteItem {
  /// The id of the place. This helps to fetch the lat,lng of the place.
  final String id;

  /// The text (name of place) displayed in the autocomplete suggestions list.
  final String text;

  /// Assistive index to begin highlight of matched part of the [text] with
  /// the original query
  final int offset;

  /// Length of matched part of the [text]
  final int length;

  AutoCompleteItem(
      {@required this.id,
      @required this.text,
      @required this.offset,
      @required this.length});
}
