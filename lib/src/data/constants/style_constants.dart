import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:flutter/material.dart';

const kExtraLight = FontWeight.w300;
const kUltraLight = FontWeight.w200;
const kLight = FontWeight.w400;
const kRegular = FontWeight.w500;
const kMedium = FontWeight.w600;
const kSemiBold = FontWeight.w700;
const kBold = FontWeight.w800;
const kExtraBold = FontWeight.w900;
const kBlackFont = FontWeight.w900;

// LETTER SPACING
const double kShortClose = -2;
const double kShort = -0.5;

// FONT SIZES
const double kDisplay = 28;
const double kLarge = 22;
const double kHeading = 20;
const double kSubHeading = 18;
const double kBody = 16;
const double kSize14 = 14;
const double kSize12 = 12;

// Helper
TextStyle kStyle(FontWeight weight, double size) => TextStyle(
      fontFamily: 'Manrope',
      fontWeight: weight,
      color: kTextColor,
      fontSize: size,
    );

//* DISPLAY

final kDisplayTitleR = kStyle(kRegular, kDisplay);
final kDisplayTitleM = kStyle(kMedium, kDisplay);
final kDisplayTitleSB = kStyle(kSemiBold, kDisplay);
final kDisplayTitleB = kStyle(kBold, kDisplay);
final kDisplayTitleEB = kStyle(kExtraBold, kDisplay);

//* LARGE

final kLargeTitleR = kStyle(kRegular, kLarge);
final kLargeTitleM = kStyle(kMedium, kLarge);
final kLargeTitleSB = kStyle(kSemiBold, kLarge);
final kLargeTitleB = kStyle(kBold, kLarge);
final kLargeTitleEB = kStyle(kExtraBold, kLarge);

//* HEADING

final kHeadTitleR = kStyle(kRegular, kHeading);
final kHeadTitleM = kStyle(kMedium, kHeading);
final kHeadTitleSB = kStyle(kSemiBold, kHeading);
final kHeadTitleB = kStyle(kBold, kHeading);
final kHeadTitleEB = kStyle(kExtraBold, kHeading);

//* SUBHEADING

final kSubHeadingL = kStyle(kLight, kSubHeading);
final kSubHeadingR = kStyle(kRegular, kSubHeading);
final kSubHeadingM = kStyle(kMedium, kSubHeading);
final kSubHeadingSB = kStyle(kSemiBold, kSubHeading);
final kSubHeadingB = kStyle(kBold, kSubHeading);
final kSubHeadingEB = kStyle(kExtraBold, kSubHeading);

//* BODY

final kBodyTitleL = kStyle(kLight, kBody);
final kBodyTitleR = kStyle(kRegular, kBody);
final kBodyTitleM = kStyle(kMedium, kBody);
final kBodyTitleSB = kStyle(kSemiBold, kBody);
final kBodyTitleB = kStyle(kBold, kBody);
final kBodyTitleEB = kStyle(kExtraBold, kBody);

//* SMALL

final kSmallTitleUL = kStyle(kUltraLight, kSize14);
final kSmallTitleL = kStyle(kLight, kSize14);
final kSmallTitleR = kStyle(kRegular, kSize14);
final kSmallTitleM = kStyle(kMedium, kSize14);
final kSmallTitleSB = kStyle(kSemiBold, kSize14);
final kSmallTitleB = kStyle(kBold, kSize14);
final kSmallTitleEB = kStyle(kExtraBold, kSize14);

//* SMALLER

final kSmallerTitleL = kStyle(kLight, kSize12);
final kSmallerTitleEL = kStyle(kExtraLight, kSize12);
final kSmallerTitleUL = kStyle(kUltraLight, kSize12);
final kSmallerTitleR = kStyle(kRegular, kSize12);
final kSmallerTitleRWithGradient = kStyle(kRegular, kSize12);
final kSmallerTitleM = kStyle(kMedium, kSize12);
final kSmallerTitleSB = kStyle(kSemiBold, kSize12);
final kSmallerTitleB = kStyle(kBold, kSize12);
final kSmallerTitleEB = kStyle(kExtraBold, kSize12);
