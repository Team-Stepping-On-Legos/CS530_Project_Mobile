import 'package:json_annotation/json_annotation.dart';

part 'end.g.dart';

@JsonSerializable()
class End {
	DateTime? dateTime;
	String? timeZone;

	End({this.dateTime, this.timeZone});

	factory End.fromJson(Map<String, dynamic> json) => _$EndFromJson(json);

	Map<String, dynamic> toJson() => _$EndToJson(this);
}
