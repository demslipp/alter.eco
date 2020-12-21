import 'package:enum_to_string/enum_to_string.dart';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable(includeIfNull: false)
class Task {
  final int id;

  //null
  String title;

  //null
  String description;
  TaskStatus status;
  Coordinate coordinate;
  TaskType type;
  int reward;

  //null
  int assignee;

  //null
  int updated;

  //null
  String dueDate;
  int createdBy;
  int created;

  Task(
      {this.id,
      this.title,
      this.description,
      this.status,
      this.coordinate,
      this.type,
      this.reward,
      this.assignee,
      this.updated,
      this.dueDate,
      this.createdBy,
      this.created});

  @override
  String toString() => '$title task id=$id)';

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
//  factory Task.fromJson(Map<String, dynamic> json) => Task(
//        id: json['id'],
//        title: json['title'],
//        description: json['description'],
//        status: EnumToString.fromString(TaskStatus.values, json['status']),
//        coordinate: Coordinate.fromJson(json['coordinate']),
//        type: EnumToString.fromString(TaskType.values, json['type']),
//        reward: json['reward'],
//        assignee: json['assignee'],
//        updated: json['updated'],
//        dueDate: json['dueDate'],
//        createdBy: json['createdBy'],
//        created: json['created'],
//      );

  Map<String, dynamic> toJson() => _$TaskToJson(this);
//  Map<String, dynamic> toJson() => {
//        'id': id,
//        'title': title,
//        'description': description,
//        'status': EnumToString.parse(status),
//        'coordinate': coordinate.toJson(),
//        'type': EnumToString.parse(type),
//        'reward': reward,
//        'assignee': assignee,
//        'updated': updated,
//        'dueDate': dueDate,
//        'createdBy': createdBy,
//        'created': created
//      };
}

enum TaskStatus {
  TRASHED,
  CREATED,
  WAITING_FOR_APPROVE,
  APPROVED,
  TO_DO,
  IN_PROGRESS,
  RESOLVED,
  COMPLETED
}

enum TaskLoadStatus { LOADING, STABLE }

enum TaskType { ANIMAL, PEOPLE, ENVIRONMENT, PLANT, URBAN, OTHER }

@JsonSerializable(explicitToJson: true)
class Coordinate {
  double longitude;
  double latitude;

  Coordinate({this.longitude, this.latitude});

//  factory Coordinate.fromJson(Map<String, dynamic> json) {
//    return Coordinate(
//      longitude: json['longitude'],
//      latitude: json['latitude'],
//    );
//  }

  factory Coordinate.fromJson(Map<String, dynamic> json) =>
      _$CoordinateFromJson(json);
  Map<String, dynamic> toJson() => _$CoordinateToJson(this);

//  Map<String, dynamic> toJson() => {
//        'longitude': longitude,
//        'latitude': latitude,
//      };

  @override
  String toString() => 'Longitude: $longitude, latitude = $latitude)';
}
