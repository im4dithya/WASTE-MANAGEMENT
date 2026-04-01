import 'package:flutter/material.dart';
void main(){
  runApp(removecart());
}
class removecart extends StatelessWidget {
  const removecart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: removecart_sub(),);
  }
}
class removecart_sub extends StatefulWidget {
  const removecart_sub({Key? key}) : super(key: key);

  @override
  State<removecart_sub> createState() => _removecart_subState();
}

class _removecart_subState extends State<removecart_sub> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
