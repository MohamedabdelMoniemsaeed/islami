import 'package:flutter/material.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class SebhaTab extends StatefulWidget {
  const SebhaTab({super.key});

  @override
  State<SebhaTab> createState() => _SebhaTabState();
}

class _SebhaTabState extends State<SebhaTab> {
  int counter = 0;
  List<String> textSebha = ["الحمد لله", "الله اكبر", "سبحان الله"];
  int currentIndex = 0;
  double angle = 0;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 40),
                child: Image.asset(
                  AppImage.headsebha,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 75),
                child: Transform.rotate(
                  angle: angle,
                  child: InkWell(
                    onTap: onClick,
                    child: Image.asset(
                      AppImage.bodysebha,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "عدد التسبيحات",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Text(
              "$counter",
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              textSebha[currentIndex],
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: provider.isDarkMode() ? Colors.black : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void onClick() {
    setState(() {
      angle += 0.2;
      counter++;
      if (counter % 33 == 0) {
        currentIndex = (currentIndex + 1) % textSebha.length;
      }
    });
  }
}
