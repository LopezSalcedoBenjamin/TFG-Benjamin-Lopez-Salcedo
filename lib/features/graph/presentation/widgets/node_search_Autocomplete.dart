
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../domain/entities/node_entity.dart';

class NodeSearchStyle{
  final Color fillColor;
  final Color borderColor;
  final Color hintColor;
  final Color textColor;
  final Color listColor;
  final Color listTextColor;

  const NodeSearchStyle({
    this.fillColor = Colors.white38,
    this.borderColor = Colors.black12,
    this.hintColor = Colors.black38,
    this.textColor = Colors.black87,
    this.listColor = Colors.white70,
    this.listTextColor = Colors.black87,
  });
}

class NodeSearchAutocomplete extends StatelessWidget {
  final List<NodeEntity> nodeList;
  final TextEditingController nodeController;
  final String hintText;
  final NodeSearchStyle style;
  final VoidCallback? onTap;


  const NodeSearchAutocomplete({
    super.key,
    required this.nodeList,
    required this.nodeController,
    this.hintText = "Buscar nodo...",
    this.style = const NodeSearchStyle(),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete(
      optionsBuilder: (TextEditingValue textValue){
        if(textValue.text.isEmpty) return nodeList;
        return nodeList.where(
                (n) => n.title.toLowerCase().contains(textValue.text.toLowerCase())
        );
      },
      displayStringForOption: (node) => node.title,
      onSelected: (node){
        nodeController.text = node.title;
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmited){
        return Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
              color: style.fillColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: style.borderColor, width: 2.w)
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 20.r, color: style.hintColor,),
              SizedBox(width: 5.w,),
              Expanded(
                  child: TextField(
                    onTap: () {
                      if (!focusNode.hasFocus) {
                        onTap?.call();
                      }
                    },
                    controller: controller,
                    focusNode: focusNode,
                    style: TextStyle(color: style.textColor),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: TextStyle(color: style.hintColor, fontSize: 16.sp),
                    ),
                  )
              ),
            ],
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12.r),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 180.h),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final node = options.elementAt(index);
                  return ListTile(
                    title: Text(node.title, style: TextStyle(color: style.listTextColor, fontSize: 13.sp)),
                    tileColor: style.listColor,
                    onTap: () => onSelected(node),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
