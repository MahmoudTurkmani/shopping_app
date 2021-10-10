import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/user_products_item.dart';
import '../providers/products.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatefulWidget {
  static const String routeName = '/user-products';

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _refreshPage();
    }
    super.didChangeDependencies();
  }

  Future<void> _refreshPage() async {
    try {
      setState(() {
        _isInit = false;
      });
      await Provider.of<ProductsProvider>(context, listen: false)
          .fetchProducts(true);
    } catch (error) {} finally {
      setState(() {
        _isInit = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPage,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your Products'),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                await Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName);
                _refreshPage();
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: !_isInit
            ? Center(child: CircularProgressIndicator())
            : Consumer<ProductsProvider>(
                builder: (ctx, productsData, _) => ListView.builder(
                  itemCount: productsData.products.length,
                  itemBuilder: (c, index) {
                    return UserProductsItem(
                      productsData.products[index].id,
                      productsData.products[index].title,
                      productsData.products[index].imageUrl,
                    );
                  },
                ),
              ),
      ),
    );
  }
}
