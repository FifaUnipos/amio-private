class NotificationModel {
  final int id;
  final String title;
  final String description;
  final String type;
  final String priority;
  final Meta meta;
  final String date;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.meta,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      priority: json['priority'],
      meta: Meta.fromJson(json['meta']),
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'priority': priority,
      'meta': meta.toJson(),
      'date': date,
    };
  }
}

class Meta {
  final String resourceId;
  final String resourceType;

  Meta({
    required this.resourceId,
    required this.resourceType,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      resourceId: json['resource_id'],
      resourceType: json['resource_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resource_id': resourceId,
      'resource_type': resourceType,
    };
  }
}
