// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'pvr_bit_utility.dart';
import 'pvr_color.dart';

// Ported from Jeffrey Lim's PVRTC encoder/decoder,
// https://bitbucket.org/jthlim/pvrtccompressor
class PvrPacket {
  PvrPacket(TypedData data) : rawData = Uint32List.view(data.buffer);
  Uint32List rawData;
  int index = 0;

  void setBlock(int x, int y) => setIndex(_getMortonNumber(x, y));

  void setIndex(int i) {
    // A PvrPacket uses 2 uint32 values, so get the physical index
    // from the logical index by multiplying by 2.
    index = i << 1;
    // Pull in the values from the raw data.
    _update();
  }

  int get modulationData => rawData[index];

  set modulationData(int x) => rawData[index] = x;

  int get colorData => rawData[index + 1];

  set colorData(int x) => rawData[index + 1] = x;

  bool get usePunchthroughAlpha => _usePunchthroughAlpha;

  set usePunchthroughAlpha(bool x) {
    _usePunchthroughAlpha = x;
    colorData = _getColorData();
  }

  int get colorA => _colorA;

  set colorA(int x) {
    _colorA = x;
    colorData = _getColorData();
  }

  bool get colorAIsOpaque => _colorAIsOpaque;

  set colorAIsOpaque(bool x) {
    _colorAIsOpaque = x;
    colorData = _getColorData();
  }

  int get colorB => _colorB;

  set colorB(int x) {
    _colorB = x;
    colorData = _getColorData();
  }

  bool get colorBIsOpaque => _colorBIsOpaque;

  set colorBIsOpaque(bool x) {
    _colorBIsOpaque = x;
    colorData = _getColorData();
  }

  void setColorRgbA(PvrColorRgb c) {
    final r = PvrBitUtility.bitScale8To5Floor[c.r];
    final g = PvrBitUtility.bitScale8To5Floor[c.g];
    final b = PvrBitUtility.bitScale8To4Floor[c.b];
    colorA = r << 9 | g << 4 | b;
    colorAIsOpaque = true;
  }

  void setColorRgbaA(PvrColorRgba c) {
    final a = PvrBitUtility.bitScale8To3Floor[c.a];
    if (a == 7) {
      final r = PvrBitUtility.bitScale8To5Floor[c.r];
      final g = PvrBitUtility.bitScale8To5Floor[c.g];
      final b = PvrBitUtility.bitScale8To4Floor[c.b];
      colorA = r << 9 | g << 4 | b;
      colorAIsOpaque = true;
    } else {
      final r = PvrBitUtility.bitScale8To4Floor[c.r];
      final g = PvrBitUtility.bitScale8To4Floor[c.g];
      final b = PvrBitUtility.bitScale8To3Floor[c.b];
      colorA = a << 11 | r << 7 | g << 3 | b;
      colorAIsOpaque = false;
    }
  }

  void setColorRgbB(PvrColorRgb c) {
    final r = PvrBitUtility.bitScale8To5Ceil[c.r];
    final g = PvrBitUtility.bitScale8To5Ceil[c.g];
    final b = PvrBitUtility.bitScale8To5Ceil[c.b];
    colorB = r << 10 | g << 5 | b;
    colorBIsOpaque = false;
  }

  void setColorRgbaB(PvrColorRgba c) {
    final a = PvrBitUtility.bitScale8To3Ceil[c.a];
    if (a == 7) {
      final r = PvrBitUtility.bitScale8To5Ceil[c.r];
      final g = PvrBitUtility.bitScale8To5Ceil[c.g];
      final b = PvrBitUtility.bitScale8To5Ceil[c.b];
      colorB = r << 10 | g << 5 | b;
      colorBIsOpaque = true;
    } else {
      final r = PvrBitUtility.bitScale8To4Ceil[c.r];
      final g = PvrBitUtility.bitScale8To4Ceil[c.g];
      final b = PvrBitUtility.bitScale8To4Ceil[c.b];
      colorB = a << 12 | r << 8 | g << 4 | b;
      colorBIsOpaque = false;
    }
  }

  PvrColorRgb getColorRgbA() {
    if (colorAIsOpaque) {
      final r = colorA >> 9;
      final g = colorA >> 4 & 0x1f;
      final b = colorA & 0xf;
      return PvrColorRgb(PvrBitUtility.bitScale5To8[r],
          PvrBitUtility.bitScale5To8[g], PvrBitUtility.bitScale4To8[b]);
    } else {
      final r = (colorA >> 7) & 0xf;
      final g = (colorA >> 3) & 0xf;
      final b = colorA & 7;
      return PvrColorRgb(PvrBitUtility.bitScale4To8[r],
          PvrBitUtility.bitScale4To8[g], PvrBitUtility.bitScale3To8[b]);
    }
  }

  PvrColorRgba getColorRgbaA() {
    if (colorAIsOpaque) {
      final r = colorA >> 9;
      final g = colorA >> 4 & 0x1f;
      final b = colorA & 0xf;
      return PvrColorRgba(PvrBitUtility.bitScale5To8[r],
          PvrBitUtility.bitScale5To8[g], PvrBitUtility.bitScale4To8[b], 255);
    } else {
      final a = colorA >> 11 & 7;
      final r = (colorA >> 7) & 0xf;
      final g = (colorA >> 3) & 0xf;
      final b = colorA & 7;
      return PvrColorRgba(
          PvrBitUtility.bitScale4To8[r],
          PvrBitUtility.bitScale4To8[g],
          PvrBitUtility.bitScale3To8[b],
          PvrBitUtility.bitScale3To8[a]);
    }
  }

  PvrColorRgb getColorRgbB() {
    if (colorBIsOpaque) {
      final r = colorB >> 10;
      final g = colorB >> 5 & 0x1f;
      final b = colorB & 0x1f;
      return PvrColorRgb(PvrBitUtility.bitScale5To8[r],
          PvrBitUtility.bitScale5To8[g], PvrBitUtility.bitScale5To8[b]);
    } else {
      final r = colorB >> 8 & 0xf;
      final g = colorB >> 4 & 0xf;
      final b = colorB & 0xf;
      return PvrColorRgb(PvrBitUtility.bitScale4To8[r],
          PvrBitUtility.bitScale4To8[g], PvrBitUtility.bitScale4To8[b]);
    }
  }

  PvrColorRgba getColorRgbaB() {
    if (colorBIsOpaque) {
      final r = colorB >> 10;
      final g = colorB >> 5 & 0x1f;
      final b = colorB & 0x1f;
      return PvrColorRgba(PvrBitUtility.bitScale5To8[r],
          PvrBitUtility.bitScale5To8[g], PvrBitUtility.bitScale5To8[b], 255);
    } else {
      final a = colorB >> 12 & 7;
      final r = colorB >> 8 & 0xf;
      final g = colorB >> 4 & 0xf;
      final b = colorB & 0xf;
      return PvrColorRgba(
          PvrBitUtility.bitScale4To8[r],
          PvrBitUtility.bitScale4To8[g],
          PvrBitUtility.bitScale4To8[b],
          PvrBitUtility.bitScale3To8[a]);
    }
  }

  int _getColorData() =>
      (usePunchthroughAlpha ? 1 : 0) |
      ((colorA & _bits14) << 1) |
      ((colorAIsOpaque ? 1 : 0) << 15) |
      ((colorB & _bits15) << 16) |
      ((colorBIsOpaque ? 1 : 0) << 31);

  void _update() {
    final x = colorData;
    usePunchthroughAlpha = x & 1 == 1;
    colorA = (x >> 1) & _bits14;
    colorAIsOpaque = ((x >> 15) & 1) == 1;
    colorB = (x >> 16) & _bits15;
    colorBIsOpaque = ((x >> 31) & 1) == 1;
  }

  static int _getMortonNumber(int x, int y) =>
      _mortonTable[x >> 8] << 17 |
      _mortonTable[y >> 8] << 16 |
      _mortonTable[x & 0xff] << 1 |
      _mortonTable[y & 0xff];

  bool _usePunchthroughAlpha = false;
  int _colorA = 0;
  bool _colorAIsOpaque = false;
  int _colorB = 0;
  bool _colorBIsOpaque = false;

  static const _bits14 = (1 << 14) - 1;
  static const _bits15 = (1 << 15) - 1;

  static const bilinearFactors = [
    [4, 4, 4, 4],
    [2, 6, 2, 6],
    [8, 0, 8, 0],
    [6, 2, 6, 2],
    [2, 2, 6, 6],
    [1, 3, 3, 9],
    [4, 0, 12, 0],
    [3, 1, 9, 3],
    [8, 8, 0, 0],
    [4, 12, 0, 0],
    [16, 0, 0, 0],
    [12, 4, 0, 0],
    [6, 6, 2, 2],
    [3, 9, 1, 3],
    [12, 0, 4, 0],
    [9, 3, 3, 1],
  ];

  // Weights are { colorA, colorB, alphaA, alphaB }
  static const weights = [
    // Weights for Mode=0
    [8, 0, 8, 0],
    [5, 3, 5, 3],
    [3, 5, 3, 5],
    [0, 8, 0, 8],

    // Weights for Mode=1
    [8, 0, 8, 0],
    [4, 4, 4, 4],
    [4, 4, 0, 0],
    [0, 8, 0, 8],
  ];

  static const _mortonTable = [
    0x0000,
    0x0001,
    0x0004,
    0x0005,
    0x0010,
    0x0011,
    0x0014,
    0x0015,
    0x0040,
    0x0041,
    0x0044,
    0x0045,
    0x0050,
    0x0051,
    0x0054,
    0x0055,
    0x0100,
    0x0101,
    0x0104,
    0x0105,
    0x0110,
    0x0111,
    0x0114,
    0x0115,
    0x0140,
    0x0141,
    0x0144,
    0x0145,
    0x0150,
    0x0151,
    0x0154,
    0x0155,
    0x0400,
    0x0401,
    0x0404,
    0x0405,
    0x0410,
    0x0411,
    0x0414,
    0x0415,
    0x0440,
    0x0441,
    0x0444,
    0x0445,
    0x0450,
    0x0451,
    0x0454,
    0x0455,
    0x0500,
    0x0501,
    0x0504,
    0x0505,
    0x0510,
    0x0511,
    0x0514,
    0x0515,
    0x0540,
    0x0541,
    0x0544,
    0x0545,
    0x0550,
    0x0551,
    0x0554,
    0x0555,
    0x1000,
    0x1001,
    0x1004,
    0x1005,
    0x1010,
    0x1011,
    0x1014,
    0x1015,
    0x1040,
    0x1041,
    0x1044,
    0x1045,
    0x1050,
    0x1051,
    0x1054,
    0x1055,
    0x1100,
    0x1101,
    0x1104,
    0x1105,
    0x1110,
    0x1111,
    0x1114,
    0x1115,
    0x1140,
    0x1141,
    0x1144,
    0x1145,
    0x1150,
    0x1151,
    0x1154,
    0x1155,
    0x1400,
    0x1401,
    0x1404,
    0x1405,
    0x1410,
    0x1411,
    0x1414,
    0x1415,
    0x1440,
    0x1441,
    0x1444,
    0x1445,
    0x1450,
    0x1451,
    0x1454,
    0x1455,
    0x1500,
    0x1501,
    0x1504,
    0x1505,
    0x1510,
    0x1511,
    0x1514,
    0x1515,
    0x1540,
    0x1541,
    0x1544,
    0x1545,
    0x1550,
    0x1551,
    0x1554,
    0x1555,
    0x4000,
    0x4001,
    0x4004,
    0x4005,
    0x4010,
    0x4011,
    0x4014,
    0x4015,
    0x4040,
    0x4041,
    0x4044,
    0x4045,
    0x4050,
    0x4051,
    0x4054,
    0x4055,
    0x4100,
    0x4101,
    0x4104,
    0x4105,
    0x4110,
    0x4111,
    0x4114,
    0x4115,
    0x4140,
    0x4141,
    0x4144,
    0x4145,
    0x4150,
    0x4151,
    0x4154,
    0x4155,
    0x4400,
    0x4401,
    0x4404,
    0x4405,
    0x4410,
    0x4411,
    0x4414,
    0x4415,
    0x4440,
    0x4441,
    0x4444,
    0x4445,
    0x4450,
    0x4451,
    0x4454,
    0x4455,
    0x4500,
    0x4501,
    0x4504,
    0x4505,
    0x4510,
    0x4511,
    0x4514,
    0x4515,
    0x4540,
    0x4541,
    0x4544,
    0x4545,
    0x4550,
    0x4551,
    0x4554,
    0x4555,
    0x5000,
    0x5001,
    0x5004,
    0x5005,
    0x5010,
    0x5011,
    0x5014,
    0x5015,
    0x5040,
    0x5041,
    0x5044,
    0x5045,
    0x5050,
    0x5051,
    0x5054,
    0x5055,
    0x5100,
    0x5101,
    0x5104,
    0x5105,
    0x5110,
    0x5111,
    0x5114,
    0x5115,
    0x5140,
    0x5141,
    0x5144,
    0x5145,
    0x5150,
    0x5151,
    0x5154,
    0x5155,
    0x5400,
    0x5401,
    0x5404,
    0x5405,
    0x5410,
    0x5411,
    0x5414,
    0x5415,
    0x5440,
    0x5441,
    0x5444,
    0x5445,
    0x5450,
    0x5451,
    0x5454,
    0x5455,
    0x5500,
    0x5501,
    0x5504,
    0x5505,
    0x5510,
    0x5511,
    0x5514,
    0x5515,
    0x5540,
    0x5541,
    0x5544,
    0x5545,
    0x5550,
    0x5551,
    0x5554,
    0x5555
  ];
}
