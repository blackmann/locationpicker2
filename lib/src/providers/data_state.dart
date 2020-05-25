/// Generic data state to be used with blocs
class DataState<T> {
  final T data;
  final DataError error;

  DataState({this.data, this.error});

  factory DataState.initial() {
    return Initial<T>();
  }

  factory DataState.loading() {
    return Loading<T>();
  }

  factory DataState.loaded(T data) {
    return Loaded(data);
  }

  factory DataState.error({String title, String message}) {
    return Error(DataError(title: title, message: message));
  }
}

/// Idle state. Both data and error are null
class Initial<T> extends DataState<T> {}

/// Loading state. Both data and error are null
class Loading<T> extends DataState<T> {}

/// Loaded state, only data exists
class Loaded<T> extends DataState<T> {
  Loaded(T data) : super(data: data);
}

/// Error state, only error exists
class Error<T> extends DataState<T> {
  Error(DataError error) : super(error: error);
}

class DataError {
  final String title;
  final String message;

  DataError({this.title, this.message});
}
