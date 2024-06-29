import 'package:breezechartapp/src/screens/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String loginType = 'customer';
  String email = '';
  String password = '';
  String shopId = '';
  String shopPassword = '';

  void handleLoginTypeChange(String type) {
    setState(() {
      loginType = type;
    });
  }

  void handleLogin() async {
    try {
      if (loginType == 'customer') {
        var response = await http.post(
          Uri.parse('http://192.168.1.240:3020/users/login'),
          body: jsonEncode({'email': email, 'password': password}),
          headers: {'Content-Type': 'application/json'},
        );
        // print('Customer Login: $response.body');
        var data = response.body;
        print(data);
        // Store session data using shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', data);

        // Navigate to user dashboard
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserDashboard()),
        );
      } else {
        var response = await http.post(
          Uri.parse('http://192.168.1.240:3020/shops/login'),
          body: jsonEncode({'shop_id': shopId, 'password': shopPassword}),
          headers: {'Content-Type': 'application/json'},
        );
        var data = jsonDecode(response.body);
        print('Shop Owner Login: $data');

        // Store session data using shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('shopId', shopId);
        prefs.setString('shopPassword', shopPassword);

        // Navigate to user dashboard
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserDashboard()),
        );
      }
    } catch (error) {
      print('Error logging in: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWelcomeMessage(),
                  const SizedBox(height: 20),
                  _buildLoginTypeDropdown(),
                  const SizedBox(height: 20),
                  if (loginType == 'customer') ...[
                    _buildEmailTextField(),
                    const SizedBox(height: 20),
                    _buildPasswordTextField(),
                  ] else ...[
                    _buildShopIdTextField(),
                    const SizedBox(height: 20),
                    _buildShopPasswordTextField(),
                  ],
                  const SizedBox(height: 20),
                  _buildForgotPasswordOption(),
                  const SizedBox(height: 20),
                  _buildLoginButton(),
                  const SizedBox(height: 30),
                  _buildDividerWithText(),
                  const SizedBox(height: 20),
                  _buildGoogleSignInButton(),
                  const SizedBox(height: 10),
                  _buildRegisterNowOption(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Welcome Back!',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLoginTypeDropdown() {
    return DropdownButton<String>(
      value: loginType,
      onChanged: (String? value) => handleLoginTypeChange(value!),
      items: [
        DropdownMenuItem(
          value: 'customer',
          child: Text('Customer'),
        ),
        DropdownMenuItem(
          value: 'shopOwner',
          child: Text('Shop Owner'),
        ),
      ],
    );
  }

  Widget _buildEmailTextField() {
    return TextField(
      controller: emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => email = value,
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
      onChanged: (value) => password = value,
    );
  }

  Widget _buildShopIdTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Shop ID',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => shopId = value,
    );
  }

  Widget _buildShopPasswordTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Shop Password',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
      onChanged: (value) => shopPassword = value,
    );
  }

  Widget _buildForgotPasswordOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: handleLogin,
      child: const Text('Login'),
    );
  }

  Widget _buildDividerWithText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 0.5,
              color: Colors.grey[400],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Or continue with',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 0.5,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/google.png', width: 50, height: 50),
      ],
    );
  }

  Widget _buildRegisterNowOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => SignupPage()),
        // );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Not a member?',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(width: 4),
          const Text(
            'Register now',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
