import 'package:flutter/material.dart';
import 'package:password_manager/pages/signin.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 239, 239),
      body: Align(
        alignment: Alignment.center,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 100,),
              Text(
                'PassGuard',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 56, 0, 153),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Organized Password Storage",
                style: TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 56, 0, 153),
                  minimumSize: Size(100, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Signin()),
                  );
                },
                child: Text(
                  "Get Started",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 100,)
            ],
          ),
        ),
      ),
    );
  }
}
