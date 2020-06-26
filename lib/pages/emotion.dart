import 'package:flutter/material.dart';
import 'package:flutter_graphql_hasura_talk/graphql/api.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/emotion.dart';

class AddEmotionDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddEmotionDialogState();
  }
}

class AddEmotionDialogState extends State<AddEmotionDialog> {
  Emotion _selectedEmotion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Emotion')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildBodyWidget(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _onNextPressed,
        child: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildBodyWidget() {
    return Query(
      options: QueryOptions(documentNode: gql(GqlQuery.getAllEmotions)),
      builder: _buildQueryResultWidget,
    );
  }

  Widget _buildQueryResultWidget(QueryResult result,
      {VoidCallback refetch, FetchMore fetchMore}) {
    if (result.hasException) {
      return Text(result.exception.toString());
    }

    if (result.loading) {
      return const Text('Loading');
    }

    final List<Emotion> emotions = (result.data['emotions'] as List)
        .map((e) => Emotion.fromData(e as Map))
        .toList();

    return GridView.count(
      crossAxisCount: 3,
      children: _buildEmotionImages(emotions),
    );
  }

  List<Widget> _buildEmotionImages(List<Emotion> emotions) {
    final List<Widget> widgets = [];

    for (final Emotion emotion in emotions) {
      widgets.add(
        FlatButton(
          onPressed: () => _onEmotionSelected(emotion),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Text(
                  emotion.icon,
                  style: const TextStyle(fontSize: 50),
                ),
              ),
              Expanded(
                child: Chip(
                  label: Text(emotion.title),
                  labelStyle: const TextStyle(color: Colors.white),
                  avatar: _selectedEmotion != null &&
                          _selectedEmotion.id == emotion.id
                      ? const Icon(Icons.check)
                      : null,
                  backgroundColor: _selectedEmotion != null &&
                          _selectedEmotion.id == emotion.id
                      ? Colors.green
                      : Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  void _onEmotionSelected(Emotion emotion) {
    setState(() => _selectedEmotion = emotion);
  }

  void _onNextPressed() {
    if (_selectedEmotion != null) {
      Navigator.of(context)
          .pushNamed('/devActivities', arguments: _selectedEmotion);
    }
  }
}
