import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';

class SebhaTab extends StatefulWidget {
  @override
  State<SebhaTab> createState() => _SebhaTabState();
}

class _SebhaTabState extends State<SebhaTab> {
  int conter = 0;
  List<String> textsebha = ["الحمد لله", "الله اكبر", "سبحان الله"];
  int culindex = 0;
  double angle = 5;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      child: Theme(
        data: ThemeData(
            highlightColor: AppColors.transparent,
            splashColor: AppColors.transparent),
        child: InkWell(
          onTap: () {
            onClick();
          },
          child: Column(
            children: [
              SizedBox(height: 40),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 40),
                      child: Image.asset(
                        AppImage.headsebha,
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 75),
                    child: Transform.rotate(
                      angle: angle,
                      child: Theme(
                        data: ThemeData(
                            highlightColor: AppColors.transparent,
                            splashColor: AppColors.transparent),
                        child: InkWell(
                            onTap: () {
                              onClick();
                            },
                            child: Image.asset(AppImage.bodysebha)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "عدد التسبيحات",
                style: Theme.of(context).badgeTheme.textStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.all(20),
                child: Text(
                  "$conter",
                  style: Theme.of(context).badgeTheme.textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(50)),
                padding: EdgeInsets.all(10),
                child: Text(
                  textsebha[culindex],
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onClick() {
    angle += 3;

    if (conter == 30) {
      conter = 0;
      culindex++;

      if (culindex > 2) {
        culindex = 0;
      }
    }
    conter++;
    setState(() {});
  }
}
