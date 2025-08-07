import 'package:flutter/material.dart';
import 'package:poc_map/data/constant.dart';

//Copiare l'intero file

class Credit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Card(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Creators:', style: kTextStyle.Creators),
                    SizedBox(height: 20),
                    Text('Di Benedetto Alessandro', style: kTextStyle.Authors),
                    SizedBox(height: 12),
                    Text('Billeci Antonino', style: kTextStyle.Authors),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
