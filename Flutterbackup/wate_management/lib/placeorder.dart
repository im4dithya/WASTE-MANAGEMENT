import 'package:flutter/material.dart';
void main(){
  runApp(placeorder());
}
class placeorder extends StatelessWidget {
  const placeorder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: placeorder_sub(),);
  }
}
class placeorder_sub extends StatefulWidget {
  const placeorder_sub({Key? key}) : super(key: key);

  @override
  State<placeorder_sub> createState() => _placeorder_subState();
}

class _placeorder_subState extends State<placeorder_sub> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
