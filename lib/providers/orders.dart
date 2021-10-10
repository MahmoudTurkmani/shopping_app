import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  OrderItem({
    @required this.id,
    @required this.products,
    @required this.total,
    @required this.date,
  });
}

class Orders with ChangeNotifier {
  final String authToken;
  final String userId;
  List<OrderItem> _orders = [];

  Orders(this.authToken, this.userId, this._orders);

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'https://myshop-7c3e5-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final Map<String, dynamic> extractedData = json.decode(response.body);
      List<OrderItem> loadedOrders = [];
      extractedData.forEach((key, value) {
        loadedOrders.add(
          OrderItem(
            id: key,
            total: double.parse(value['total']),
            date: DateTime.parse(value['date']),
            products: (value['products'] as List<dynamic>).map((item) {
              return CartItem(
                id: item['id'],
                price: double.parse(item['price']),
                quantity: item['quantity'],
                title: item['title'],
              );
            }).toList(),
          ),
        );
      });
      _orders = loadedOrders;
    } catch (error) {
      return;
    }
  }

  List<OrderItem> get orders {
    fetchOrders();
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    final url = Uri.parse(
        'https://myshop-7c3e5-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        products: products,
        total: total,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
    List<Map<String, dynamic>> productsList = products.map((prod) {
      return {
        'id': prod.id,
        'title': prod.title,
        'quantity': prod.quantity,
        'price': prod.price.toStringAsFixed(2),
      };
    }).toList();
    await http
        .post(url,
            body: json.encode({
              'products': productsList,
              'total': total,
              'date': DateTime.now().toString(),
            }))
        .catchError((_) {
      _orders.removeAt(0);
      notifyListeners();
    });
  }
}
