import 'package:flutter/material.dart';

class AppColors {
  static const Color white = Colors.white;
  static const Color pureBlack = Color(0xff000000);
  static const Color black = Color(0xff363D4E);
  static const Color alertRed = Color(0xFFFF0000);
  static const Color titleBlue = Color(0xff0AD0DE);
  static const Color borderBlue = Color(0xff28BCF3);
  static const Color toggleBlue = Color(0xff5C97CB);
  static const Color inputBoxWhite = Color(0xffF9F9FF);

  static const Color pink = Color(0xffFF4E98);
  static const Color teal = Color(0xff23D2C3);
  static const Color purple = Color(0xff6C4DDA);
  static const Color orange = Color(0xffFBA709);
  static const Color deepOrange = Color(0xffF75400);
  static const Color blue = Color(0xff4F87BF);
  static const Color darkBlue = Color(0xff1A3764);
  static const Color medBlue = Color(0xff5E35B1);

  static const Color lighterGrey = Color(0xffF9F9FF);
  static const Color lightGrey = Color.fromRGBO(225, 225, 225, 1);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xffA6A3B8);
  static const Color lightBg = Color.fromARGB(255, 210, 162, 217);
  static const Color disabled = Color(0xFFACACAC);
  static const Color notifyYellow = Color(0xFFFFB100);
  static const Color chatPink = Color(0xFFFF4E98);

  static const Color reedemBlue = Color(0xFFEBFBFF);
  static const Color reedemStatusGreen = Color(0xFF13AA58);

  // [ Gradients ]
  static const LinearGradient buttonBlue = LinearGradient(colors: [
    Color(0xff9FDEFF),
    Color(0xff28BCF3),
    Color(0xff28BCF3),
  ]);

  static const LinearGradient redeemCoinsBlue = LinearGradient(colors: [
    Color(0xff2ACFF9),
    Color(0xff00A5D0),
    Color(0xff00A5D0),
    Color(0xff0082A3),
  ]);

  static const LinearGradient buttonBlueVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xff9FDEFF), Color(0xff28BCF3), Color(0xff28BCF3)],
  );

  static const LinearGradient orangeYelloH = LinearGradient(colors: [
    Color(0xffF75400),
    Color(0xffFEAB36),
  ]);

  static const pinkPurpleH = LinearGradient(
    colors: [
      Color(0xffEB579F),
      Color(0xff7A50A0),
    ],
  );

  static const yellowOrangeH = LinearGradient(
    colors: [
      Color(0xffFFCC00),
      Color(0xffFF8000),
    ],
  );

  static const redOrangeV = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xffF95E1B),
      Color(0xffFF8F00),
    ],
  );

  static const orangeRedH =
      LinearGradient(colors: [Color(0xFFFF8B8B), Color(0xffFF0505)]);

  static const pinkVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4E0E7), Color(0xffF32878)],
  );

  static const redVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFff8181), Color(0xffff0202)],
  );

  static const purpleV = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF907ae2), Color(0xff532fd2)],
  );

  static const purpleH =
      LinearGradient(colors: [Color(0xFF907ae2), Color(0xff532fd2)]);

  static const steelV = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFbee7f8), Color(0xff629bca)],
  );

  static const mepBlack = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomCenter,
      transform: GradientRotation(-0.5),
      colors: [
        Color(0xFF101928),
        Color(0xFF101928),
        Color(0xFF101928),
        Color(0xFF384A6E),
        Color(0xFF384A6E),
        Color(0xFF101928),
        Color(0xFF101928),
      ]);

  static const grayBlackH = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF676767),
      Color(0xFF0f0f10),
    ],
  );
  static const grayDisabled = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.fromARGB(255, 189, 189, 189),
      Color.fromARGB(255, 94, 94, 94),
    ],
  );

  // static const LinearGradient interestPinkRed = LinearGradient(colors: [
  //   Color(0xffFF9FC7),
  //   Color(0xffF32878),
  // ]);

  // static const LinearGradient interestOrange = LinearGradient(colors: [
  //   Color(0xffFFA16B),
  //   Color(0xffFC893D),
  // ]);

  static const Color interestPinkRed = Color(0xffF32878);

  static const Color interestOrange = Color(0xffFC893D);

  static const Color interestGreen = Color(0xff17CEA1);

  static const Color interestBlue = Color(0xff509FEE);
}
