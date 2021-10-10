import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  final String authToken;
  final userId;
  List<Product> _products = [];

  ProductsProvider(this.authToken, this._products, this.userId);

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteItems {
    return _products.where((prod) => prod.isFavorite).toList();
  }

  Future<void> addProduct(Product newProduct) async {
    final url = Uri.parse(
        'https://myshop-7c3e5-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      await http.post(url,
          body: json.encode({
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'isFavorite': newProduct.isFavorite,
          }));
    } catch (error) {
      print(error);
      throw error;
    } finally {
      _products.add(newProduct);
      notifyListeners();
    }
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    String filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://myshop-7c3e5-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final Map<String, dynamic> responseData = json.decode(response.body);
      url = Uri.parse(
          'https://myshop-7c3e5-default-rtdb.firebaseio.com/favorites/$userId.json?auth=$authToken');
      final favoritesResponse = await http.get(url);
      final favoritesMap = json.decode(favoritesResponse.body);
      final List<Product> newItems = [];
      if (responseData == null) {
      } else {
        responseData.forEach((prodId, prodData) {
          return newItems.add(
            Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              imageUrl: prodData['imageUrl'],
              price: prodData['price'],
              authToken: authToken,
              userId: userId,
              isFavorite:
                  favoritesMap == null ? false : favoritesMap[prodId] ?? false,
            ),
          );
        });
      }
      _products = newItems;
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(Product newProduct) async {
    final url = Uri.parse(
        'https://myshop-7c3e5-default-rtdb.firebaseio.com/products/${newProduct.id}.json?auth=$authToken');
    int index = _products.indexWhere((prod) => prod.id == newProduct.id);
    try {
      print(newProduct.id);
      await http.patch(
        url,
        body: json.encode(
          {
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            'title': newProduct.title,
          },
        ),
      );
      if (index >= 0) {
        _products[index] = newProduct;
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  void deleteProduct(String id) async {
    final url = Uri.parse(
        'https://myshop-7c3e5-default-rtdb.firebaseio.com/products/$id.json');
    int index = _products.indexWhere((prod) => prod.id == id);
    var product = _products[index];
    _products.removeAt(index);
    notifyListeners();
    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException('An error occured while deleting this product');
      }
    } catch (error) {
      _products.insert(index, product);
    } finally {
      notifyListeners();
    }
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }
}
