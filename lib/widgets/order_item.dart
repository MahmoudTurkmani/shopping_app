import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/cart.dart';

class OrderItem extends StatefulWidget {
  final List<CartItem> products;
  final double total;
  final DateTime dateTime;

  OrderItem({
    @required this.dateTime,
    @required this.products,
    @required this.total,
  });

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        elevation: 3,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${widget.total}'),
              subtitle: Text(
                  '${DateFormat('dd/MM/yyyy hh:mm').format(widget.dateTime)}'),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(
                    _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              constraints: BoxConstraints(
                minHeight: _isExpanded
                    ? min(widget.products.length * 15.0 + 30, 200)
                    : 0,
                maxHeight: _isExpanded
                    ? min(widget.products.length * 15.0 + 30, 200)
                    : 0,
              ),
              child: Container(
                color: Color.fromRGBO(237, 237, 237, 1),
                child: ListView.builder(
                  itemCount: widget.products.length,
                  itemBuilder: (ctx, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '${widget.products[index].title}',
                            style: TextStyle(fontSize: 18),
                          ),
                          Spacer(),
                          Text(
                            '${widget.products[index].quantity}x  ${widget.products[index].price}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
