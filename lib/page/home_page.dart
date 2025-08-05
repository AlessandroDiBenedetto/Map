import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'map.dart';

class home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/lotties/loc.json'),
              Text(
                'Welcome',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'sans-serif',
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 200,
                height: 50,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black12,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => maps()),
                      );
                    },
                    child: Text(
                      ('Cliccami per iniziare'),
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontFamily: 'sans-serif',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
