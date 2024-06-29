import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:breezechartapp/src/screens/shop/shop_page.dart';
import 'package:breezechartapp/src/screens/shop/shops_page.dart'; // Import the shops_page.dart file
import 'package:breezechartapp/src/screens/my_cart.dart';
import 'package:breezechartapp/src/screens/catergory/catergory_page.dart';
import 'package:breezechartapp/src/screens/auth/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> shops = [];
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    fetchShopsAndCategories();
  }

  Future<void> fetchShopsAndCategories() async {
    try {
      // Fetch shops
      final shopsResponse =
          await http.get(Uri.parse('http://192.168.1.240:3020/shops'));
      if (shopsResponse.statusCode == 200) {
        setState(() {
          shops =
              List<Map<String, dynamic>>.from(jsonDecode(shopsResponse.body));
        });
        print('Shops: $shops');
      } else {
        print('Failed to load shops');
      }

      // Fetch categories
      final categoriesResponse =
          await http.get(Uri.parse('http://192.168.1.240:3020/categories'));
      if (categoriesResponse.statusCode == 200) {
        setState(() {
          categories = List<Map<String, dynamic>>.from(
              jsonDecode(categoriesResponse.body));
        });
      } else {
        print('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BreezeCart'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Define what happens when the cart icon is pressed
              // For example, navigate to the cart screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CartPage()), // Replace with your cart screen widget
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                children: [
                  const Text(
                    'Welcome to BreezeCart',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Follow Your Doorstep',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Handle Shop Now button press
                        },
                        child: const Text('Shop Now'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          // Handle Learn More button press
                        },
                        child: const Text('Learn More'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Shops
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shops',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: shops.map<Widget>((shop) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ShopPage(shopId: shop['shop_id']),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    shop['logo'],
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  shop['shop_name'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  shop['shop_owner'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map<Widget>((category) {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryPage(
                                  categoryId: category['category_id']),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          category['category_name'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Shops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'My Account',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to Home page (current page)
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));

              break;
            case 1:
              // Navigate to Shops page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopsPage(), // Use ShopsPage here
                ),
              );
              break;
            case 2:
              // Navigate to My Account page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
