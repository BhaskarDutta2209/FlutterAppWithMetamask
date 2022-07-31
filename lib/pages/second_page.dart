import 'package:flutter/material.dart';
import 'package:my_app/widgets/cards_widget.dart';
import 'package:my_app/widgets/home_widget.dart';
import 'package:my_app/widgets/pay_widget.dart';
import 'package:my_app/widgets/receive_widget.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int _currentIndex = 0;

  final appBarTitles = ['Home', 'Cards', 'Pay', 'Receive'];

  final List<Widget> _widgetOptions = [
    HomeWidget(),
    CardsWidget(),
    PayWidget(),
    ReceiveWidget()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_currentIndex]),
        automaticallyImplyLeading: false,
      ),
      body: Center(child: _widgetOptions.elementAt(_currentIndex)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_rounded), label: 'cards'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded), label: 'pay'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_rounded), label: 'receive')
        ],
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
      ),
    );
  }
}
