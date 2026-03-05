import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color primaryColor = const Color(0xFFDA291C);
Color secondaryColor = const Color(0xFF0055A4);

Color whiteColor = const Color(0xFFFFFFFF);
Color blackColor = const Color(0xFF000000);

Color background = const Color(0xFFF5F5F5);

TextStyle blackTextStyle = GoogleFonts.poppins().copyWith(color: blackColor);
TextStyle whiteTextStyle = GoogleFonts.poppins().copyWith(color: whiteColor);

TextStyle primaryTextStyle = GoogleFonts.poppins().copyWith(
  color: primaryColor,
);
TextStyle secondaryTextStyle = GoogleFonts.poppins().copyWith(
  color: secondaryColor,
);

FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semiBold = FontWeight.w600;
FontWeight bold = FontWeight.w700;

Color successColor = const Color(0xFF4CAF50);
Color pendingColor = const Color(0xFFFB8C00);
Color errorColor = const Color(0xFFD32F2F);
