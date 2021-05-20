import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget makeScrollable(Widget w) {
  return Scrollbar(
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
              width: 1000.0,
              height: 1000,
              child: ListView(
                children: [
                  SizedBox(
                    width: 1000,
                    height: 1000,
                    child: w,
                  )
                ],
              ))));
}
