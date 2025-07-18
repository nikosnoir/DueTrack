import '../main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import '../models/user.dart';
import '../providers/courses_provider.dart';
import 'package:provider/provider.dart';


class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  bool isLogin = true;

  String username = '';
  String name = '';
  String password = '';
  String errorText = '';

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
      errorText = '';
    });
  }

  Future<void> _handleSubmit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    if (isLogin) {
      final user = await _dbHelper.loginUser(username, password);
      if (user != null) {
        await _saveLogin(user);
        _navigateToHome();
      } else {
        setState(() {
          errorText = "Invalid username or password";
        });
      }
    } else {
      final result = await _dbHelper.registerUser(User(
        username: username,
        name: name,
        password: password,
      ));

      if (result > 0) {
        final user = await _dbHelper.loginUser(username, password);
        if (user != null) {
          await _saveLogin(user);
          _navigateToHome();
        }
      } else {
        setState(() {
          errorText = "Username already exists";
        });
      }
    }
  }

  Future<void> _saveLogin(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);
    await prefs.setString('username', user.username);
    await prefs.setString('name', user.name);
  }

  void _navigateToHome() async {
  // Load assignments and courses from SQLite before navigating
  await Provider.of<CoursesProvider>(context, listen: false).loadData();

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MainNavigationPage()),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isLogin)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (val) => val!.isEmpty ? 'Enter name' : null,
                  onSaved: (val) => name = val!,
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (val) => val!.isEmpty ? 'Enter username' : null,
                onSaved: (val) => username = val!,
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (val) => val!.isEmpty ? 'Enter password' : null,
                onSaved: (val) => password = val!,
              ),
              const SizedBox(height: 16),
              if (errorText.isNotEmpty)
                Text(
                  errorText,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(isLogin ? 'Login' : 'Sign Up'),
              ),
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
