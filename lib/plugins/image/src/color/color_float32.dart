// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import '../image/palette.dart';
import '../util/color_util.dart';
import 'channel.dart';
import 'channel_iterator.dart';
import 'color.dart';
import 'format.dart';

/// A 32-bit floating point color.
class ColorFloat32 extends Iterable<num> implements Color {
  ColorFloat32(int numChannels) : data = Float32List(numChannels);

  ColorFloat32.from(ColorFloat32 other)
      : data = Float32List.fromList(other.data);

  ColorFloat32.fromList(List<double> color)
      : data = Float32List.fromList(color);

  ColorFloat32.rgb(num r, num g, num b) : data = Float32List(3) {
    data[0] = r.toDouble();
    data[1] = g.toDouble();
    data[2] = b.toDouble();
  }

  ColorFloat32.rgba(num r, num g, num b, num a) : data = Float32List(4) {
    data[0] = r.toDouble();
    data[1] = g.toDouble();
    data[2] = b.toDouble();
    data[3] = a.toDouble();
  }
  final Float32List data;

  @override
  ColorFloat32 clone() => ColorFloat32.from(this);

  @override
  Format get format => Format.float32;

  @override
  int get length => data.length;

  @override
  num get maxChannelValue => 1.0;

  @override
  num get maxIndexValue => 1.0;

  @override
  bool get isLdrFormat => false;

  @override
  bool get isHdrFormat => true;

  @override
  bool get hasPalette => false;

  @override
  Palette? get palette => null;

  @override
  num operator [](int index) => index < data.length ? data[index] : 0;

  @override
  void operator []=(int index, num value) {
    if (index < data.length) {
      data[index] = value.toDouble();
    }
  }

  @override
  num get index => r;
  @override
  set index(num i) => r = i;

  @override
  num get r => data.isNotEmpty ? data[0] : 0;
  @override
  set r(num r) => data.isNotEmpty ? data[0] = r.toDouble() : 0;

  @override
  num get g => data.length > 1 ? data[1] : 0;
  @override
  set g(num g) {
    if (data.length > 1) {
      data[1] = g.toDouble();
    }
  }

  @override
  num get b => data.length > 2 ? data[2] : 0;
  @override
  set b(num b) {
    if (data.length > 2) {
      data[2] = b.toDouble();
    }
  }

  @override
  num get a => data.length > 3 ? data[3] : 1;
  @override
  set a(num a) {
    if (data.length > 3) {
      data[3] = a.toDouble();
    }
  }

  @override
  num get rNormalized => r / maxChannelValue;
  @override
  set rNormalized(num v) => r = v * maxChannelValue;

  @override
  num get gNormalized => g / maxChannelValue;
  @override
  set gNormalized(num v) => g = v * maxChannelValue;

  @override
  num get bNormalized => b / maxChannelValue;
  @override
  set bNormalized(num v) => b = v * maxChannelValue;

  @override
  num get aNormalized => a / maxChannelValue;
  @override
  set aNormalized(num v) => a = v * maxChannelValue;

  @override
  num get luminance => getLuminance(this);
  @override
  num get luminanceNormalized => getLuminanceNormalized(this);

  @override
  num getChannel(Channel channel) => channel == Channel.luminance
      ? luminance
      : channel.index < data.length
          ? data[channel.index]
          : 0;

  @override
  num getChannelNormalized(Channel channel) =>
      getChannel(channel) / maxChannelValue;

  @override
  void set(Color c) {
    r = c.r;
    g = c.g;
    b = c.b;
    a = c.a;
  }

  @override
  void setRgb(num r, num g, num b) {
    data[0] = r.toDouble();
    final nc = data.length;
    if (nc > 1) {
      data[1] = g.toDouble();
      if (nc > 2) {
        data[2] = b.toDouble();
      }
    }
  }

  @override
  void setRgba(num r, num g, num b, num a) {
    data[0] = r.toDouble();
    final nc = data.length;
    if (nc > 1) {
      data[1] = g.toDouble();
      if (nc > 2) {
        data[2] = b.toDouble();
        if (nc > 3) {
          data[3] = a.toDouble();
        }
      }
    }
  }

  @override
  ChannelIterator get iterator => ChannelIterator(this);

  @override
  bool operator ==(Object other) =>
      other is Color && other.length == length && other.hashCode == hashCode;

  @override
  int get hashCode => Object.hashAll(toList());

  @override
  Color convert({Format? format, int? numChannels, num? alpha}) =>
      convertColor(this,
          format: format, numChannels: numChannels, alpha: alpha);
}
