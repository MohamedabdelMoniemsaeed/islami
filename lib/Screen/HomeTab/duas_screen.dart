import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/Screen/HomeTab/duas.dart';
import 'package:provider/provider.dart';

class DuasScreen extends StatelessWidget {
  static const String routeName = "DuasScreen";
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            provider.isDarkMode() ? AppImage.backgroundDark : AppImage.backgroundHome
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("الأدعية", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: IconThemeData(color: provider.isDarkMode() ? AppColors.blackDark : Colors.black),
        ),
        body: const DuasTab(),
      ),
    );
  }
}
