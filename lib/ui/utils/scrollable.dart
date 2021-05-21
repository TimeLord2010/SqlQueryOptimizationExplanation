import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget makeScrollable(Widget w, {double width = 2000.0, double height = 2000.0}) {
  return Scrollbar(
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
              width: width,
              height: height,
              child: ListView(
                children: [
                  SizedBox(
                    width: width,
                    height: height,
                    child: w,
                  )
                ],
              ))));
}
