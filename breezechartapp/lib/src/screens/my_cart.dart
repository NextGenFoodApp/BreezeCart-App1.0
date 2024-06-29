import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, dynamic>? user;
  List cart = [];
  List<Map<String, dynamic>> cartDetails = [];
  Map<int, int> quantityChanges = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUser = prefs.getString('user');

    if (storedUser != null) {
      try {
        var decodedData = jsonDecode(storedUser);
        if (decodedData is Map<String, dynamic>) {
          user = decodedData;

          if (user != null && user!['user_id'] != null) {
            Response response = await Dio()
                .get('http://192.168.1.240:3020/users/${user!['user_id']}');
            setState(() {
              cart = response.data['cart'];
            });
            fetchCartDetails();
          } else {
            print('No user ID found in the parsed user object');
          }
        } else {
          print('Decoded user data is not a Map');
        }
      } catch (error) {
        print('Error decoding user data: $error');
      }
    } else {
      print('No user found in localStorage');
    }
  }

  Future<void> fetchCartDetails() async {
    List<Future<Map<String, dynamic>?>> futures = cart.map((cartItem) async {
      try {
        Response productResponse = await Dio().get(
            'http://192.168.1.240:3020/products/${cartItem['product_id']}');
        Map<String, dynamic> product = productResponse.data;
        Map<String, dynamic> item = product['items']
            .firstWhere((item) => item['item_id'] == cartItem['item_id']);
        return {
          'product_name': product['product_name'],
          'unit': item['unit'],
          'unit_price': item['price'],
          'quantity': cartItem['quantity'],
          'total_price': item['price'] * cartItem['quantity']
        };
      } catch (error) {
        print('Error fetching product data: $error');
        return null;
      }
    }).toList();

    List<Map<String, dynamic>> fetchedCartDetails = (await Future.wait(futures))
        .where((detail) => detail != null)
        .cast<Map<String, dynamic>>()
        .toList();

    setState(() {
      cartDetails = fetchedCartDetails;
    });
  }

  void handleQuantityChange(int index, int value) {
    setState(() {
      quantityChanges[index] = value;
    });
  }

  Future<void> handleConfirmChange(int index) async {
    setState(() {
      cartDetails[index]['quantity'] =
          quantityChanges[index] ?? cartDetails[index]['quantity'];
      cartDetails[index]['total_price'] =
          cartDetails[index]['unit_price'] * cartDetails[index]['quantity'];
    });

    try {
      await Dio().post(
          'http://192.168.1.240:3020/users/update-cart-item-quantity',
          data: {
            'userId': user!['user_id'],
            'updateItemIndex': index,
            'newQuantity': quantityChanges[index]
          });
      setState(() {
        quantityChanges[index] = 0;
      });
    } catch (error) {
      print('Error updating cart item quantity: $error');
    }
  }

  Future<void> handleDelete(int index) async {
    setState(() {
      cartDetails.removeAt(index);
    });

    try {
      await Dio().post('http://192.168.1.240:3020/users/delete-item-from-cart',
          data: {'userId': user!['user_id'], 'deleteItemIndex': index});
      fetchUserData();
      fetchCartDetails();
    } catch (error) {
      print('Error deleting item from cart: $error');
    }
  }

  void handleCheckout() {
    Navigator.pushNamed(context, '/checkout');
  }

  void handleAddToBulk() {
    print('Cart added to bulk');
  }

  double calculateTotal() {
    return cartDetails.fold(0.0, (total, item) => total + item['total_price']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Shopping Cart',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: cartDetails.length,
                  itemBuilder: (context, index) {
                    final item = cartDetails[index];
                    return Card(
                      child: ListTile(
                        title: Text(item['product_name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Variation: ${item['unit']}'),
                            Text(
                                'Unit Price: \$${item['unit_price'].toStringAsFixed(2)}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Quantity:'),
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: TextEditingController(
                                        text: (quantityChanges[index] ??
                                                item['quantity'])
                                            .toString()),
                                    onChanged: (value) {
                                      handleQuantityChange(
                                          index, int.parse(value));
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () => handleConfirmChange(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => handleDelete(index),
                                ),
                              ],
                            ),
                            Text(
                                'Total Price: \$${item['total_price'].toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text('Total Cart Value: \$${calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: handleCheckout,
                child: const Text('Checkout'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: handleAddToBulk,
                child: const Text('Add Cart to My Bulk'),
                style: ElevatedButton.styleFrom(primary: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
