import 'package:note/FirebaseServices/repository.dart';
import 'package:note/View/home.dart';
import 'package:note/View/login.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final repo = Repository();

  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                TextField(
                  controller: fullName,
                  decoration: InputDecoration(hintText: "Full name"),
                ),

                TextField(
                  controller: email,
                  decoration: InputDecoration(hintText: "Email"),
                ),

                TextField(
                  controller: password,
                  decoration: InputDecoration(hintText: "Password"),
                ),

                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () async {
                      if (fullName.text.isNotEmpty ||
                          email.text.isNotEmpty ||
                          password.text.isNotEmpty) {
                        final res = await repo.signUp(
                          fullName: fullName.text,
                          email: email.text,
                          password: password.text,
                        );
                        if (res.success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res.message ?? "")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Fields are required")),
                        );
                      }
                    },
                    child: Text("Register"),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Text("Login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
