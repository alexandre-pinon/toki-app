// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitTypeAdapter extends TypeAdapter<UnitType> {
  @override
  final int typeId = 1;

  @override
  UnitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UnitType.ml;
      case 1:
        return UnitType.cl;
      case 2:
        return UnitType.dl;
      case 3:
        return UnitType.l;
      case 4:
        return UnitType.g;
      case 5:
        return UnitType.kg;
      case 6:
        return UnitType.tsp;
      case 7:
        return UnitType.tbsp;
      case 8:
        return UnitType.cup;
      case 9:
        return UnitType.piece;
      case 10:
        return UnitType.pinch;
      case 11:
        return UnitType.bunch;
      case 12:
        return UnitType.clove;
      case 13:
        return UnitType.can;
      case 14:
        return UnitType.package;
      case 15:
        return UnitType.slice;
      case 16:
        return UnitType.totaste;
      case 17:
        return UnitType.unit;
      default:
        return UnitType.ml;
    }
  }

  @override
  void write(BinaryWriter writer, UnitType obj) {
    switch (obj) {
      case UnitType.ml:
        writer.writeByte(0);
        break;
      case UnitType.cl:
        writer.writeByte(1);
        break;
      case UnitType.dl:
        writer.writeByte(2);
        break;
      case UnitType.l:
        writer.writeByte(3);
        break;
      case UnitType.g:
        writer.writeByte(4);
        break;
      case UnitType.kg:
        writer.writeByte(5);
        break;
      case UnitType.tsp:
        writer.writeByte(6);
        break;
      case UnitType.tbsp:
        writer.writeByte(7);
        break;
      case UnitType.cup:
        writer.writeByte(8);
        break;
      case UnitType.piece:
        writer.writeByte(9);
        break;
      case UnitType.pinch:
        writer.writeByte(10);
        break;
      case UnitType.bunch:
        writer.writeByte(11);
        break;
      case UnitType.clove:
        writer.writeByte(12);
        break;
      case UnitType.can:
        writer.writeByte(13);
        break;
      case UnitType.package:
        writer.writeByte(14);
        break;
      case UnitType.slice:
        writer.writeByte(15);
        break;
      case UnitType.totaste:
        writer.writeByte(16);
        break;
      case UnitType.unit:
        writer.writeByte(17);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
