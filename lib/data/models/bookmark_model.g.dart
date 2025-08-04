// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarkModelAdapter extends TypeAdapter<BookmarkModel> {
  @override
  final int typeId = 0;

  @override
  BookmarkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkModel(
      id: fields[0] as int,
      name: fields[1] as String,
      fullName: fields[2] as String,
      description: fields[3] as String?,
      htmlUrl: fields[4] as String,
      stargazersCount: fields[5] as int,
      forksCount: fields[6] as int,
      language: fields[7] as String?,
      avatarUrl: fields[8] as String?,
      ownerLogin: fields[9] as String,
      updatedAt: fields[10] as DateTime?,
      isPrivate: fields[11] as bool,
      defaultBranch: fields[12] as String?,
      bookmarkedAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.htmlUrl)
      ..writeByte(5)
      ..write(obj.stargazersCount)
      ..writeByte(6)
      ..write(obj.forksCount)
      ..writeByte(7)
      ..write(obj.language)
      ..writeByte(8)
      ..write(obj.avatarUrl)
      ..writeByte(9)
      ..write(obj.ownerLogin)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.isPrivate)
      ..writeByte(12)
      ..write(obj.defaultBranch)
      ..writeByte(13)
      ..write(obj.bookmarkedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
