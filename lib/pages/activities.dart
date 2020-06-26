import 'package:flutter/material.dart';
import 'package:flutter_graphql_hasura_talk/graphql/api.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../models/emotion.dart';

class DevActivities extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DevActivitiesState();
}

class DevActivitiesState extends State<DevActivities> {
  int uid;
  Emotion selectedEmotion;
  int selectedActivity;

  @override
  void initState() {
    super.initState();
    retrieveUserId();
  }

  Future retrieveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getInt('uid');
  }

  @override
  Widget build(BuildContext context) {
    selectedEmotion = ModalRoute.of(context).settings.arguments as Emotion;
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Activities')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _buildCategoriesList(context),
      ),
      floatingActionButton: _saveActivityMutationWidget(),
    );
  }

  Widget _saveActivityMutationWidget() {
    return Mutation(
      options: MutationOptions(
        documentNode: gql(GqlQuery.saveActivity),
        onCompleted: (dynamic resultData) => navigateBackToHome(),
      ),
      builder: (
        RunMutation runMutation,
        QueryResult result,
      ) {
        return FloatingActionButton(
          onPressed: () => {
            runMutation({
              'journal': {
                'user_id': uid,
                'emotion_id': selectedEmotion.id,
                'activity_id': selectedActivity
              }
            }),
          },
          child: const Icon(Icons.chevron_right),
        );
      },
    );
  }

  Widget _buildCategoriesList(BuildContext context) {
    return Query(
      options: QueryOptions(
        documentNode: gql(GqlQuery.getCategoriesAndActivities),
      ),
      builder: (QueryResult result,
          {VoidCallback refetch, FetchMore fetchMore}) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.loading) {
          return const Text('Loading');
        }

        final List<Category> categories = (result.data['categories'] as List)
            .map((c) => Category.fromData(c as Map))
            .toList();

        return ListView.builder(
          itemCount: categories.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      selectedEmotion.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                    Text(
                      selectedEmotion.title,
                      style: const TextStyle(fontSize: 32),
                    )
                  ],
                ),
              );
            }
            final Category category = categories[i - 1];
            return ListTile(
              title: Padding(
                padding: const EdgeInsets.only(
                    left: 5, top: 10, bottom: 10, right: 5),
                child: Row(children: [
                  Text(
                    category.icon,
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    category.title,
                    style: const TextStyle(fontSize: 22, color: Colors.purple),
                  ),
                ]),
              ),
              subtitle: _buildWrap(category),
            );
          },
        );
      },
    );
  }

  Widget _buildWrap(Category category) {
    return Wrap(
      runSpacing: 20.0,
      spacing: 10.0,
      children: _buildActivitiesList(category.activities),
    );
  }

  List<Widget> _buildActivitiesList(List<Activity> devActivities) {
    final List<Widget> chips = [];
    for (final Activity devActivity in devActivities) {
      chips.add(ChoiceChip(
        label: Text(devActivity.title),
        labelPadding: const EdgeInsets.only(left: 10, right: 10),
        labelStyle: const TextStyle(fontSize: 20, color: Colors.black),
        selectedColor: Colors.lightGreen,
        selected: selectedActivity == devActivity.id,
        onSelected: (bool value) {
          setState(() {
            if (value) {
              selectedActivity = devActivity.id;
            }
          });
        },
      ));
    }

    return chips;
  }

  void navigateBackToHome() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/journal', ModalRoute.withName('/'));
  }
}
