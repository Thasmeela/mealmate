import 'package:flutter/material.dart';
import 'package:mealmate/login.dart';
import 'package:mealmate/signup.dart';


class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/signup_bg.avif"),
        fit: BoxFit.fill)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(alignment: Alignment.topCenter,
            child: Image.asset(
                "assets/logo.png",scale: 1,
                height: 150,
                width: 150,
              ),),
              Text(
              "Welcome Back!",
              style:TextStyle(
                color: const Color.fromARGB(255, 2, 177, 11),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                
              ),
            ),
            Container(
                height: 500,
                width: 300,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 218, 213, 213),
                          filled: true,
                          prefixIcon: Icon(Icons.mail),
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 218, 213, 213),
                          filled: true,
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 60,
                      width: 300,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 53, 193, 2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 252, 251, 250),
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(" Already have an account? "), GestureDetector(
                    
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup()));
                    },
                    child: Text("Sign Up",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.orange))),
                ],
              ),
                  ],
                ),
              ),
          ]
      
      
    )));
  }
}