import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatefulWidget {
  static const routeName = 'recipe_detail';
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold());
  }
}