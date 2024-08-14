import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  Map<String, int> _itemCounts = {};

  Map<String, int> get itemCounts => _itemCounts;

  void addItem(String itemId, int count) {
    if (_itemCounts.containsKey(itemId)) {
      _itemCounts[itemId] = (_itemCounts[itemId]! + count);
    } else {
      _itemCounts[itemId] = count;
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    _itemCounts.remove(itemId);
    notifyListeners();
  }

  void clearCart() {
    _itemCounts.clear();
    notifyListeners();
  }
}
