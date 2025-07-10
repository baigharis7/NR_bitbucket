import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhysicalActivityTab extends StatelessWidget {
  const PhysicalActivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Here will be the details of physical activities', style: TextStyle(color: Colors.white),),
      ],);
  }

}