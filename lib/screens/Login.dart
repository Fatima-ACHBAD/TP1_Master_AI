import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tp1_master_ai/screens/ActivitiesPage.dart';
import 'package:tp1_master_ai/screens/Register.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = '';
  String password = '';
  bool rememberMe = false; // Nouvelle variable pour Remember me
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 68, 119),
      appBar: AppBar(
        backgroundColor: Colors.cyan[50],
        title: Text('Activity'),
        actions: [
          TextButton(
            onPressed: () {
              //Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
            },
            child: Text(
              'Register',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 30.0,
                          backgroundColor: Colors.cyan,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Form(
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                email = value;
                              },
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Login',
                                prefixIcon: Icon(Icons.person, color: Colors.black),
                                fillColor: Colors.white,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your login';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              onChanged: (value) {
                                password = value;
                              },
                              obscureText: true,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                prefixIcon: Icon(Icons.lock, color: Colors.black),
                                fillColor: Colors.white,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.0),
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMe = value!;
                                    });
                                  },
                                ),
                                Text('Remember me'),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    // Ajoutez ici la logique pour "Forget Password"
                                    // par exemple, vous pouvez ouvrir une boîte de dialogue pour réinitialiser le mot de passe
                                    // ou naviguer vers une page de réinitialisation du mot de passe.
                                    print('Forget Password tapped!');
                                  },
                                  child: Text(
                                    'Forget Password',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.cyan,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text('Se Connecter'),
                              onPressed: () {
                                if (email.isNotEmpty && password.length > 5) {
                                  login();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please enter your login and password.'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0), // Ajout d'un espace au bas de l'écran
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    try {
      email = email.toString().trim();
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ActivitiesPage()),
        );
      } else {
        print('Authentication failed. User is null.');
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed. Please check your credentials.'),
        ),
      );
    }
  }
}

