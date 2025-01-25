// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingTaskAdapter extends TypeAdapter<PendingTask> {
  @override
  final int typeId = 4;

  @override
  PendingTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingTask(
      type: fields[0] as TaskType,
      item: fields[1] as ShoppingListItem,
    );
  }

  @override
  void write(BinaryWriter writer, PendingTask obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.item);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskTypeAdapter extends TypeAdapter<TaskType> {
  @override
  final int typeId = 3;

  @override
  TaskType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskType.check;
      case 1:
        return TaskType.uncheck;
      default:
        return TaskType.check;
    }
  }

  @override
  void write(BinaryWriter writer, TaskType obj) {
    switch (obj) {
      case TaskType.check:
        writer.writeByte(0);
        break;
      case TaskType.uncheck:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
