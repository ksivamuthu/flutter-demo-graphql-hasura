class Activity {
  final int id;
  final String title;

  Activity(this.id, this.title);
  Activity.fromData(Map data)
      : id = data['id'] as int,
        title = data['title'] as String;
}

class Category {
  final int id;
  final String title;
  final String icon;
  final List<Activity> activities;

  Category(this.id, this.title, this.icon, this.activities);
  Category.fromData(Map data)
      : id = data['id'] as int,
        title = data['title'] as String,
        icon = data['icon'] as String,
        activities = (data['activities'] as List)
            .map((activity) => Activity.fromData(activity as Map))
            .toList();
}
