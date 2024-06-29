import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../product/product_page.dart';

class ShopPage extends StatefulWidget {
  final int shopId;

  const ShopPage({Key? key, required this.shopId}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Map<String, dynamic>? shopDetails;
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    fetchShopDetailsAndProducts();
  }

  Future<void> fetchShopDetailsAndProducts() async {
    try {
      // print('fetchShopDetailsAndProducts....');
      // print('ShopID : ${widget.shopId}');

      // Fetch shop details
      final shopResponse = await http
          .get(Uri.parse('http://192.168.1.240:3020/shops/${widget.shopId}'));
      // print('Shop details response status: ${shopResponse.statusCode}');
      // print('Shop details response body: ${shopResponse.body}');
      if (shopResponse.statusCode == 200) {
        if (shopResponse.body.isNotEmpty) {
          setState(() {
            shopDetails = jsonDecode(shopResponse.body);
          });
        } else {
          print('Shop details response is empty');
        }
      } else {
        print(
            'Failed to load shop details. Status code: ${shopResponse.statusCode}');
      }

      // Fetch products based on the shop's product IDs
      if (shopDetails != null && shopDetails!['products'] != null) {
        List<int> productIds = List<int>.from(shopDetails!['products']);
        for (int productId in productIds) {
          final productResponse = await http
              .get(Uri.parse('http://192.168.1.240:3020/products/$productId'));
          // print('Product $productId response status: ${productResponse.statusCode}');
          // print('Product $productId response body: ${productResponse.body}');
          if (productResponse.statusCode == 200) {
            if (productResponse.body.isNotEmpty) {
              setState(() {
                products.add(jsonDecode(productResponse.body));
              });
            } else {
              print('Product $productId response is empty');
            }
          } else {
            print(
                'Failed to load product $productId. Status code: ${productResponse.statusCode}');
          }
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shopDetails?['shop_name'] ?? 'Shop Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (shopDetails != null) ...[
                Text(
                  shopDetails!['shop_name'],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    shopDetails!['logo'],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Owner: ${shopDetails!['shop_owner']}'),
                const SizedBox(height: 8),
                Text('Address: ${shopDetails!['address']}'),
                const SizedBox(height: 8),
                Text('Phone: ${shopDetails!['phone_no']}'),
                const SizedBox(height: 8),
                Text('Email: ${shopDetails!['email']}'),
                const SizedBox(height: 16),
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: products.map<Widget>((product) {
                    return ListTile(
                      leading: product['image'] != null
                          ? SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.network(
                                product['image'],
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                      title: Text(product['product_name']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductPage(productId: product['product_id'], shopId: product['shop_id'],),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ] else ...[
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
