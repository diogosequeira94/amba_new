import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    });
    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/amba.jpg',
              width: 275,
              height: 275,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 18.0, bottom: 8.0),
              child: Text(
                'AMBA',
                style: TextStyle(
                    fontSize: 42.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 80.0),
              child: Text('Hipólito Sequeira',
                  style: TextStyle(color: Colors.black, fontSize: 18.0)),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text('Secretário',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      ),
    );
  }
}
