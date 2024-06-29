import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:breezechartapp/src/screens/product/product_page.dart';

class CategoryPage extends StatefulWidget {
  final int categoryId;

  const CategoryPage({Key? key, required this.categoryId}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  Map<String, dynamic>? categoryDetails;
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    fetchCategoryDetails();
    fetchProducts();
  }

  Future<void> fetchCategoryDetails() async {
    try {
      Response response = await Dio().get('http://192.168.1.240:3020/categories/${widget.categoryId}');
      setState(() {
        categoryDetails = response.data;
      });
    } catch (error) {
      print('Error fetching category details: $error');
    }
  }

  Future<void> fetchProducts() async {
    try {
      Response response = await Dio().get('http://192.168.1.240:3020/products/c/${widget.categoryId}');
      setState(() {
        products = List<Map<String, dynamic>>.from(response.data);
      });
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryDetails != null ? categoryDetails!['category_name'] : 'Category'),
      ),
      body: categoryDetails == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryDetails!['category_name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  product['image'] ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['product_name'],
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '\$${product['items'][0]['price'].toString()}',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductPage(productId: product['product_id'],shopId:product['shop_id'] ,),
                                          ),
                                        );
                                      },
                                      child: Text('View Product'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}