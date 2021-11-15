import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';

// import 'package:easy_mask.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: TextField(
                decoration: InputDecoration(hintText: 'Cellphone'),
                inputFormatters: [
                  TextInputMask(mask: '\\+ 9 (999) 9999 99 99', reverse: false)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: TextField(
                decoration: InputDecoration(hintText: 'Brazilian CPF'),
                inputFormatters: [
                  TextInputMask(
                    mask: '999.999.999-99',
                    placeholder: '_',
                    maxPlaceHolders: 11,
                    reverse: false,
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: TextField(
                decoration: InputDecoration(hintText: 'Multi Mask CPF/CNPJ'),
                inputFormatters: [
                  TextInputMask(
                      mask: ['999.999.999-99', '99.999.999/9999-99'],
                      reverse: false)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: TextField(
                decoration: InputDecoration(hintText: 'Multi Mask Phone'),
                inputFormatters: [
                  TextInputMask(
                    mask: ['(99) 9999 9999', '(99) 99999 9999'],
                    reverse: false,
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: TextField(
                decoration: InputDecoration(hintText: 'Date'),
                inputFormatters: [
                  TextInputMask(mask: '99/99/9999', reverse: false)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: TextField(
                decoration: InputDecoration(hintText: 'Brazilian Phone'),
                inputFormatters: [
                  TextInputMask(mask: '\\+5!5! (!99) 99999-9999')
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 120),
              child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(hintText: 'Money'),
                inputFormatters: [
                  TextInputMask(
                    mask: '\$! !9+,99',
                    placeholder: '0',
                    maxPlaceHolders: 3,
                    reverse: true,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
