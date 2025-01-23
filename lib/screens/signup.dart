import 'package:dropdown_below/dropdown_below.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  List _selectRoleList = [
    {'no': 1, 'keyword': 'Admin'},
    {'no': 2, 'keyword': 'User'},
  ];
  List<DropdownMenuItem<Object?>> _dropdownRoleItems = [];
  var _selectedRole;

  @override
  void initState() {
    _dropdownRoleItems = buildDropdownTestItems(_selectRoleList);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DropdownMenuItem<Object?>> buildDropdownTestItems(List _selectRoleList) {
    List<DropdownMenuItem<Object?>> items = [];
    for (var i in _selectRoleList) {
      items.add(
        DropdownMenuItem(
          value: i,
          child: Text(i['keyword']),
        ),
      );
    }
    return items;
  }

  onChangeDropdownTests(selectedRole) {
    print(selectedRole);
    setState(() {
      _selectedRole = selectedRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Wrap the entire body in SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
      
              child: SizedBox(
                height: 250,
                width: 300,
                child: Image.asset('assets/signupmid.gif'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text("Sign Up",
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
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
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
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: DropdownBelow(
                itemWidth: 200,
                itemTextstyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                boxTextstyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
                boxPadding: EdgeInsets.fromLTRB(13, 12, 0, 12),
                boxWidth: 400,
                boxHeight: 45,
                boxDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    width: 1.5,
                    color: Color(0XFFbbbbbb),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Color(0XFFbbbbbb),
                ),
                hint: Text('Role'),
                value: _selectedRole,
                items: _dropdownRoleItems,
                onChanged: onChangeDropdownTests,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/success');
                },
                child: Container(
                  height: 50,
                  width: 400,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black),
                  child: Center(
                    child: Text(
                      'Create account',
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
                    child: Text("Already have an account? ",
                        style: TextStyle(fontSize: 15, color: Colors.grey)),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text("Login",
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
