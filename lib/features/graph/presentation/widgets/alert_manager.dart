import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class alertHelper{
  static void showSnakbar(BuildContext context, String message, Color backColor, Color textColor){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15.sp),),
          backgroundColor: backColor,
          elevation: 0,
          duration: Duration(seconds: 5),
          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10.r)),
          margin: EdgeInsets.all(20.r),
          behavior: SnackBarBehavior.floating,
          animation: CurvedAnimation(parent: kAlwaysCompleteAnimation, curve: Curves.easeInOut),
        )
    );
  }
}