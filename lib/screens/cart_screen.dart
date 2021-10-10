import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/orders.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Spacer(),
                    Consumer<Cart>(
                      builder: (ctx, cart, _) {
                        return Chip(
                          label: Text(
                            '\$${cart.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        );
                      },
                    ),
                    Consumer<Cart>(
                      builder: (ctx, cart, _) {
                        return TextButton(
                          onPressed: cart.items.isEmpty || _isLoading
                              ? null
                              : () async {
                                  try {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await Provider.of<Orders>(context,
                                            listen: false)
                                        .addOrder(
                                      cart.items.values.toList(),
                                      cart.totalPrice,
                                    );
                                  } catch (_) {
                                    print(_);
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    cart.clearCart();
                                  }
                                },
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text('ORDER NOW'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<Cart>(
              builder: (_, cart, ch) {
                return ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, index) {
                    return CartItem(
                      productKey: cart.items.keys.toList()[index],
                      id: cart.items.values.toList()[index].id,
                      price: cart.items.values.toList()[index].price,
                      quantity: cart.items.values.toList()[index].quantity,
                      title: cart.items.values.toList()[index].title,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
