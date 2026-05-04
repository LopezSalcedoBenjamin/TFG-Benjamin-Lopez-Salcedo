import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../consts.dart';

class NiaScreen extends StatefulWidget {
  const NiaScreen({super.key});

  @override
  State<NiaScreen> createState() => _NiaScreenState();
}

class _NiaScreenState extends State<NiaScreen> {

  bool _hasText = true;

  final TextEditingController _textInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(

        appBar: AppBar(
          iconTheme: IconThemeData(
             color: Colors.white
          ),
          backgroundColor: colorAppBar,
          toolbarHeight: 80.h,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Generador NIA", style: TextStyle(color: Colors.white)),
              Text(
                "Añade nodos y relaciones con tu historia",
                style: TextStyle(color: Colors.white24, fontSize: 14.sp),)
            ],
          ),
        ),

        backgroundColor: blackGraph1,

        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 15.h),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: Colors.white24, width: 2.w),
                        color: blackGraph2
                    ),
                    child: TextField(
                      onTap: (){
                        setState(() {
                          _hasText = true;
                        });
                      },
                      controller: _textInputController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        filled: false,
                        hintText: _hasText?
                        "Escribe un texto para generar un grafo..."
                        : "El texto se encuentra vacío.\nPor favor escriba una historia antes de generar...",
                        hintStyle: TextStyle(
                            color: _hasText? Colors.white24 : redAlert.withAlpha(200),
                            fontSize: 16.sp),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 15.h),

                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if(_textInputController.text.isEmpty){
                        setState(() {
                          _hasText = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/NIA_button.png",
                          height: 40.h,
                          width: 40.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Generar grafo",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }
}
