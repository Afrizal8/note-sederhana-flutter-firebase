// To parse this JSON data, do
//
//     final notesModel = notesModelFromMap(jsonString);

import 'dart:convert';

NotesModel notesModelFromMap(String str) => NotesModel.fromMap(json.decode(str));

String notesModelToMap(NotesModel data) => json.encode(data.toMap());

class NotesModel {
  final String? id;
  final String? title;
  final String? content;
  final String? createdAt;

  NotesModel({
    this.id,
    this.title,
    this.content,
    this.createdAt,
  });

  NotesModel copyWith({
    String? id,
    String? title,
    String? content,
    String? createdAt,
  }) =>
      NotesModel(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );

  factory NotesModel.fromMap(Map<String, dynamic> json) => NotesModel(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "content": content,
    "createdAt": createdAt,
  };
}
