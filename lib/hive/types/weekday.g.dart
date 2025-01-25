// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekday.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeekdayAdapter extends TypeAdapter<Weekday> {
  @override
  final int typeId = 2;

  @override
  Weekday read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Weekday.monday;
      case 1:
        return Weekday.tuesday;
      case 2:
        return Weekday.wednesday;
      case 3:
        return Weekday.thursday;
      case 4:
        return Weekday.friday;
      case 5:
        return Weekday.saturday;
      case 6:
        return Weekday.sunday;
      default:
        return Weekday.monday;
    }
  }

  @override
  void write(BinaryWriter writer, Weekday obj) {
    switch (obj) {
      case Weekday.monday:
        writer.writeByte(0);
        break;
      case Weekday.tuesday:
        writer.writeByte(1);
        break;
      case Weekday.wednesday:
        writer.writeByte(2);
        break;
      case Weekday.thursday:
        writer.writeByte(3);
        break;
      case Weekday.friday:
        writer.writeByte(4);
        break;
      case Weekday.saturday:
        writer.writeByte(5);
        break;
      case Weekday.sunday:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeekdayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
