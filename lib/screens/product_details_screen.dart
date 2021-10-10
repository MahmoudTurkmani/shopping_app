import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final String prodId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<ProductsProvider>(context).findById(prodId);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: Hero(
              tag: '${loadedProduct.id}',
              child: Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            '\$${loadedProduct.price}',
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.blueGrey),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            '${loadedProduct.description}',
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
    );
  }
}
