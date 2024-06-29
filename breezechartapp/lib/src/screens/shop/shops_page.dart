import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:breezechartapp/src/screens/shop/shop_page.dart';

class ShopsPage extends StatefulWidget {
  @override
  _ShopsPageState createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  List<Map<String, dynamic>> shops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShops();
  }

  Future<void> fetchShops() async {
    try {
      Response response = await Dio().get('http://192.168.1.240:3020/shops');
      setState(() {
        shops = List<Map<String, dynamic>>.from(response.data);
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching shops data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shops'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(
                      shop['logo'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(shop['shop_name']),
                    subtitle: Text(shop['address']),
                    onTap: () {
                      // Handle shop tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopPage(shopId: shop['shop_id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
