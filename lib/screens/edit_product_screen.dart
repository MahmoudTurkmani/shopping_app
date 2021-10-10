import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';
import '../providers/auth.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _imageUrlNode = FocusNode();
  bool _isInit = false;
  bool _editMode = false;
  bool _isLoading = false;
  String authToken;
  Product _newProduct = Product(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0.0,
    isFavorite: false,
  );
  var values = {
    'id': null,
    'title': '',
    'description': '',
    'price': null,
    'isFavorite': false,
  };

  @override
  void initState() {
    super.initState();
    _imageUrlNode.addListener(_updateImage);
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlNode.removeListener(_updateImage);
    _imageUrlNode.dispose();
    _imageUrlController.dispose();
  }

  void _updateImage() {
    if (!_imageUrlNode.hasFocus) {
      if ((_imageUrlController.text.endsWith('.png') ||
              _imageUrlController.text.endsWith('.jpg') ||
              _imageUrlController.text.endsWith('.jpeg')) &&
          (_imageUrlController.text.startsWith('http') ||
              _imageUrlController.text.startsWith('https'))) {
        setState(() {});
      }
    }
  }

  Future<void> _saveForm() async {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        if (_editMode == true) {
          await Provider.of<ProductsProvider>(context, listen: false)
              .updateProduct(_newProduct);
        } else {
          await Provider.of<ProductsProvider>(context, listen: false)
              .addProduct(_newProduct);
        }
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Could\'nt add/update product'),
                content: Text(
                    'An error occured while trying to add/update your product.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Okay'),
                  ),
                ],
              );
            });
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final _oldId = ModalRoute.of(context).settings.arguments as String;
      if (_oldId != null) {
        _newProduct = Provider.of<ProductsProvider>(context).findById(_oldId);
        values = {
          'id': _newProduct.id,
          'title': _newProduct.title,
          'description': _newProduct.description,
          'price': _newProduct.price.toString(),
          'isFavorite': _newProduct.isFavorite.toString(),
        };
        _imageUrlController.text = _newProduct.imageUrl;
        _isInit = true;
        _editMode = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      // Title input
                      TextFormField(
                        initialValue: values['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a title';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _newProduct = Product(
                            id: values['id'],
                            title: value,
                            description: _newProduct.description,
                            imageUrl: _newProduct.imageUrl,
                            price: _newProduct.price,
                            isFavorite: _newProduct.isFavorite,
                          );
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      // Amount input
                      TextFormField(
                        initialValue: values['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a number';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalide number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a number that is greater than 0';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _newProduct = Product(
                            id: values['id'],
                            title: _newProduct.title,
                            description: _newProduct.description,
                            imageUrl: _newProduct.imageUrl,
                            price: double.parse(value),
                            isFavorite: _newProduct.isFavorite,
                          );
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      // Description input
                      TextFormField(
                        initialValue: values['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a title';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _newProduct = Product(
                            id: values['id'],
                            title: _newProduct.title,
                            description: value,
                            imageUrl: _newProduct.imageUrl,
                            price: _newProduct.price,
                            isFavorite: _newProduct.isFavorite,
                          );
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(50)),
                            child: _imageUrlController.text.isEmpty
                                ? null
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            // Image URL input
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              focusNode: _imageUrlNode,
                              onFieldSubmitted: (val) =>
                                  FocusScope.of(context).unfocus(),
                              onEditingComplete: _updateImage,
                              controller: _imageUrlController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a title';
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (value) {
                                _newProduct = Product(
                                  id: values['id'],
                                  title: _newProduct.title,
                                  description: _newProduct.description,
                                  imageUrl: value,
                                  price: _newProduct.price,
                                  isFavorite: _newProduct.isFavorite,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _saveForm,
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
