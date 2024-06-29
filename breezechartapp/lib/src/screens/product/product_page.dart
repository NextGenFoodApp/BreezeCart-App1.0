import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductPage extends StatefulWidget {
  final int productId;
  final int shopId;

  const ProductPage({Key? key, required this.productId, required this.shopId}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Map<String, dynamic>? product;
  Map<String, dynamic>? category;
  Map<String, dynamic>? shop;
  int quantity = 1;
  Map<String, dynamic>? selectedItem;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Assume user data is stored in local storage or secure storage
      final storedUser = '{"user_id": 1}'; // Dummy user data
      if (storedUser.isNotEmpty) {
        setState(() {
          user = jsonDecode(storedUser);
        });
      } else {
        print('No user found in local storage');
      }
    } catch (error) {
      print('Error parsing user data: $error');
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      final productResponse = await http.get(Uri.parse('http://192.168.1.240:3020/products/${widget.productId}'));
      final productData = jsonDecode(productResponse.body);

      final categoryResponse = await http.get(Uri.parse('http://192.168.1.240:3020/categories/${productData['category_id']}'));
      final categoryData = jsonDecode(categoryResponse.body);

      final shopResponse = await http.get(Uri.parse('http://192.168.1.240:3020/shops/${widget.shopId}'));
      final shopData = jsonDecode(shopResponse.body);

      setState(() {
        product = productData;
        category = categoryData;
        shop = shopData;
        selectedItem = productData['items'].length == 1 ? productData['items'][0] : null;
      });
    } catch (error) {
      print('Error fetching product details: $error');
    }
  }

  void handleQuantityChange(String value) {
    setState(() {
      quantity = int.tryParse(value) ?? 1;
    });
  }

  Future<void> handleAddToCart(int itemId) async {
    if (user == null) return;
    try {
      await http.post(
        Uri.parse('http://192.168.1.240:3020/users/add-to-cart'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user!['user_id'],
          'addItem': {
            'item_id': itemId,
            'product_id': product!['product_id'],
            'quantity': quantity
          }
        }),
      );
      print('Product added to cart');
    } catch (error) {
      print('Error adding to cart: $error');
    }
  }

  void handleAddToBulk(int itemId) {
    print('Added product to bulk: ${product!['product_id']}');
    print('Added item: $itemId');
    print('Added quantity: $quantity');
  }

  void handleItemClick(Map<String, dynamic> item) {
    setState(() {
      selectedItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: product == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product!['product_name'],
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text('From: ${shop?['shop_name'] ?? ''}'),
                  if (product!['items'].length > 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${product!['attribute']}:'),
                        Wrap(
                          children: product!['items'].map<Widget>((item) {
                            return GestureDetector(
                              onTap: () => handleItemClick(item),
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedItem == item ? Colors.blue : Colors.grey,
                                  ),
                                ),
                                child: Image.network(
                                  item['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  if (selectedItem != null)
                    Text(
                      '${selectedItem!['unit']}, Price: \$${selectedItem!['price']}',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  if (product!['items'].length == 1)
                    Text(
                      '${product!['items'][0]['unit']}, Price: \$${product!['items'][0]['price']}',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    onChanged: handleQuantityChange,
                    controller: TextEditingController(text: quantity.toString()),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedItem != null || product!['items'].length == 1
                              ? () => handleAddToCart(selectedItem != null ? selectedItem!['item_id'] : product!['items'][0]['item_id'])
                              : null,
                          child: const Text('Add to my cart'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedItem != null || product!['items'].length == 1
                              ? () => handleAddToBulk(selectedItem != null ? selectedItem!['item_id'] : product!['items'][0]['item_id'])
                              : null,
                          child: const Text('Add to my bulk'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

