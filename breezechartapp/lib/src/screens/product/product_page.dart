
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductPage extends StatefulWidget {
  final int productId;

  const ProductPage({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Map<String, dynamic>? productDetails;

  Future<void> fetchProductDetails() async {
    try {
      final productResponse = await http.get(Uri.parse('http://192.168.1.240:3020/products/1'));
    }catch(e){
      print('Error fetching product details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Center(
        child: Text('Product ID: ${widget.productId}'),
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// class ProductPage extends StatelessWidget {
//   final int productId;

//   const ProductPage({Key? key, required this.productId}) : super(key: key);

  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Product Details'),
//       ),
//       body: Center(
//         child: Text('Product ID: $productId'),
//       ),
//     );
//   }
// }
