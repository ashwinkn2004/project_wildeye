import 'package:flutter/material.dart';
import 'package:project_wildeye/utils/routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Wrap the entire body in SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 250,
                width: 300,
                child: Image.asset('assets/login.gif'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text("Log in",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900)),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Colors.grey[400]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Colors.grey[400]!, width: 1.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Colors.grey[400]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Colors.grey[400]!, width: 1.5),
                  ),
                  suffixIcon: Icon(Icons.visibility_off, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),

              //ONTAP CONTROLLED FOR THE FIREBASE


              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/client');
                },
                child: Container(
                  height: 50,
                  width: 400,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black),
                  child: Center(
                    child: Text(
                      'Log in',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Text("Don't have an account ? ",
                        style: TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.signUp);
                      },
                      child: Text("sign up",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              decoration: TextDecoration.underline)),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
