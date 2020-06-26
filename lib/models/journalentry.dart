import 'package:flutter_graphql_hasura_talk/models/activity.dart';

import 'emotion.dart';

class JournalEntry {
  final int id;
  final String userName;
  final Emotion emotion;
  final Activity activity;
  final DateTime entryDate;

  JournalEntry(
      this.id, this.userName, this.emotion, this.activity, this.entryDate);

  JournalEntry.fromData(Map data)
      : id = data['id'] as int,
        userName = data['user']['name'] as String,
        emotion = Emotion.fromData(data['emotion'] as Map),
        activity = Activity.fromData(data['activity'] as Map),
        entryDate = DateTime.parse(data['created_at'] as String).toLocal();
}
