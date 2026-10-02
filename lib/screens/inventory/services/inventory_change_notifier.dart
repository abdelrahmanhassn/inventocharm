import 'dart:async';

class InventoryChangeNotifier {
  InventoryChangeNotifier._();

  static final _changes = StreamController<void>.broadcast();

  static Stream<void> get changes => _changes.stream;

  static void notifyChanged() {
    _changes.add(null);
  }
}
