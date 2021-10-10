import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  final String authToken;
  final String userId;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.authToken,
    this.userId,
    this.isFavorite = false,
  });

  void toggleFavorite(String id) async {
    final url = Uri.parse(
        'https://myshop-7c3e5-default-rtdb.firebaseio.com/favorites/$userId/$id.json?auth=$authToken');
    isFavorite = !isFavorite;
    notifyListeners();
    await http
        .put(
      url,
      body: json.encode(
        isFavorite,
      ),
    )
        .catchError((error) {
      isFavorite = !isFavorite;
    });
    notifyListeners();
  }
}
