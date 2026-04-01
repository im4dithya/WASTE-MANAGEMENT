import 'package:flutter/material.dart';
void main(){
  runApp(sendwasterequest());
}
class sendwasterequest extends StatelessWidget {
  const sendwasterequest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: sendwasterequest_sub(),);
  }
}
class sendwasterequest_sub extends StatefulWidget {
  const sendwasterequest_sub({Key? key}) : super(key: key);

  @override
  State<sendwasterequest_sub> createState() => _sendwasterequest_subState();
}

class _sendwasterequest_subState extends State<sendwasterequest_sub> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
