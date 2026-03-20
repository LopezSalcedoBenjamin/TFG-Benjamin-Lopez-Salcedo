import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nodos_inteligencia_artificial_tfg_benjamin/consts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogoPicker extends StatefulWidget{
  final Function(File image) onImageSelected;

  const LogoPicker({super.key, required this.onImageSelected});

  @override
  State<LogoPicker> createState() => _LogoPickerState();
}

class _LogoPickerState extends State<LogoPicker>{

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage() async{
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);

    if(img!=null){
      final file = File(img.path);
      setState(() =>_image = file);
      widget.onImageSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectImage,
      child: Container(
        width: 130.w,
        height: 130.h,
        decoration: BoxDecoration(
          color: button1,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white24, width: 2.w),
        ),
        child: _image!=null
          ? ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.file(_image!, fit: BoxFit.cover, width: 130.w, height: 130.h,),
          )
          : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 40.r, color: Colors.white54,),
              SizedBox(height: 8.h,),
              Text("Añadir logo", style: TextStyle(color: Colors.white54, fontSize: 13.sp),)
            ],
          ),
      ),
    );
  }
}