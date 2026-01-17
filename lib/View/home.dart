import 'package:note/FirebaseServices/repository.dart';
import 'package:note/View/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final User? usr = FirebaseAuth.instance.currentUser;
  final repo = Repository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              usr?.displayName ?? "",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(usr?.email ?? ""),
            TextButton(
              onPressed: () async {
                await repo.signOut().then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                });
              },
              child: Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
