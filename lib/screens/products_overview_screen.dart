import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';

enum ItemFilter {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products-overview';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavoritesOnly = false;
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
          .fetchProducts();
    } catch (error) {
      print(error);
    } finally {
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
          title: Text('MyShop'),
          actions: [
            PopupMenuButton(
              onSelected: (selectedValue) {
                setState(() {
                  if (selectedValue == ItemFilter.Favorites) {
                    _showFavoritesOnly = true;
                  } else if (selectedValue == ItemFilter.All) {
                    _showFavoritesOnly = false;
                  }
                });
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  child: Text('Show Favorites'),
                  value: ItemFilter.Favorites,
                ),
                PopupMenuItem(
                  child: Text('Show All'),
                  value: ItemFilter.All,
                )
              ],
            ),
            Consumer<Cart>(
              builder: (ctx, cart, ch) {
                return Badge(
                  child: ch,
                  value: cart.itemCount.toString(),
                );
              },
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () =>
                    Navigator.of(context).pushNamed(CartScreen.routeName),
              ),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: !_isInit
            ? Center(child: CircularProgressIndicator())
            : ProductsGrid(_showFavoritesOnly),
      ),
    );
  }
}
