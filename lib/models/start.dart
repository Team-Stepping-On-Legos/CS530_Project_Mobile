import 'package:json_annotation/json_annotation.dart';

part 'start.g.dart';

@JsonSerializable()
class Start {
	DateTime? dateTime;
	String? timeZone;

	Start({this.dateTime, this.timeZone});

	factory Start.fromJson(Map<String, dynamic> json) => _$StartFromJson(json);

	Map<String, dynamic> toJson() => _$StartToJson(this);
}
