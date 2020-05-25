import 'package:flutter/foundation.dart';
import 'package:place_picker/src/entities/entities.dart';
import 'package:place_picker/src/providers/data_state.dart';
import 'api.dart';

class AutoCompleteProvider extends ChangeNotifier {
  final ApiProvider api;

  DataState<List<AutoCompleteItem>> autocompletions = DataState.initial();

  AutoCompleteProvider({@required this.api});

  Future<void> search(String keyword) async {
    // hides the nearby places too when keyword is empty
    autocompletions = DataState.loading();

    notifyListeners();

    if (keyword.isEmpty) {
      return;
    }

    final predictions = await api.getSearchPredictions(keyword);

    autocompletions = DataState.loaded(predictions);

    notifyListeners();
  }

  Future<void> clear() async {
    autocompletions = DataState.initial();

    notifyListeners();
  }
}
