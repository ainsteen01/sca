import 'package:flutter/material.dart';
import 'package:sca/shared_data.dart';

import 'chat_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var data = SharedData();
  TextEditingController numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 70,),
            CircleAvatar(
                radius: 100,
                child: Icon(Icons.person,size: 100,)),
            SizedBox(height: 20,),
            const Text("Login", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 25),),
            SizedBox(height: 20,),
            const Text("Please enter your mobile number to use our app"),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12, blurRadius: 9, spreadRadius: 4
                    )
                  ]
                ),
                child: TextField(
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  controller: numberController,
                  decoration: InputDecoration(
                    counterText: "",
                    enabled: true,
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    prefixIcon: Icon(Icons.phone_android),
                    hintText: "mobile number",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))
                    ),
                    onPressed: () async {
                      if(numberController.text.isNotEmpty && numberController.text.length == 10){
                        await SharedData().shareNumber(numberController.text);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen()));
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Center(child: const Text("Invalid mobile number",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),),backgroundColor: Colors.red,));
                      }
        
                }, child: const Text("Continue")),
              ),
            ),
        
          ],
        ),
      ),
    );
  }
}
