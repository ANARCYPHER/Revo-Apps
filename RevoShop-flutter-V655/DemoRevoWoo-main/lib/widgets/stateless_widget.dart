import 'package:flutter/material.dart';

class RevoStateless extends StatelessWidget {
  final Widget? child;
  const RevoStateless({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child!;
  }
}
