class Emotion {
  final int id;
  final String title;
  final String icon;

  Emotion(this.id, this.title, this.icon);
  Emotion.fromData(Map data)
      : id = data['id'] as int,
        title = data['title'] as String,
        icon = data['icon'] as String;
}
