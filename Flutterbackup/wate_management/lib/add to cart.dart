import 'package:flutter/material.dart';
void main(){
  runApp(addtocart());
}
class addtocart extends StatelessWidget {
  const addtocart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:addtocart_sub(),);
  }
}
class addtocart_sub extends StatefulWidget {
  const addtocart_sub({Key? key}) : super(key: key);

  @override
  State<addtocart_sub> createState() => _addtocart_subState();
}

class _addtocart_subState extends State<addtocart_sub> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
