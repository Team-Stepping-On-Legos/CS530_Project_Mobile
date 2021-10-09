class NotificationHistoryData{
  String? eventID;
  String time;
  String title;
  String message;

  NotificationHistoryData(this.eventID, this.time, this.title, this.message,);

  NotificationHistoryData.fromJson(Map json)
      : eventID = json['eventID'],
        time = json['time'],
        title = json['title'],
        message = json['message'];

  Map toJson() {
    return {'eventID': eventID, 'time': time, 'title': title, 'message': message};
  }

  Object? toList() {}

}