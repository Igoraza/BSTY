import 'package:flutter/material.dart';

class InnerPageText extends StatelessWidget {
  const InnerPageText({
    Key? key,
    required this.title,
    required this.style,
  }) : super(key: key);

  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Padding(

        /// [ TODO : add margin and remove \n ]
        padding: EdgeInsets.symmetric(
            horizontal: appWidth * 0.03, vertical: appHeight * 0.01),
        child: Text(title, style: style));
  }
}
