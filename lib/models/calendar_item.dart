import 'package:json_annotation/json_annotation.dart';

import 'event.dart';

part 'calendar_item.g.dart';

@JsonSerializable()
class CalendarItem {
	String? id;
	String? summary;
	String? description;
	DateTime? startTime;
	DateTime? endTime;
	String? htmlLink;
	Event? event;
	List<dynamic>? notifications;

	CalendarItem({
		this.id, 
		this.summary, 
		this.description, 
		this.startTime, 
		this.endTime, 
		this.htmlLink, 
		this.event, 
		this.notifications, 
	});

	factory CalendarItem.fromJson(Map<String, dynamic> json) {
		return _$CalendarItemFromJson(json);
	}

	Map<String, dynamic> toJson() => _$CalendarItemToJson(this);
  
  Object? toList() {}
}
