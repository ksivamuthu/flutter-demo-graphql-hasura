import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graphql_hasura_talk/graphql/api.dart';
import 'package:flutter_graphql_hasura_talk/models/journalentry.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return JournalPageState();
  }
}

class JournalPageState extends State<JournalPage> {
  StreamSubscription _subscription;
  @override
  Widget build(BuildContext context) {
    return GraphQLConsumer(builder: (GraphQLClient client) {
      subscribeNotifications(client);
      return Scaffold(
        appBar: AppBar(title: const Text('Dev Emotions')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildBodyWidget(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => navigateToAddEmotion(),
          child: const Icon(Icons.add),
        ),
      );
    });
  }

  Widget _buildBodyWidget() {
    return Query(
      options: QueryOptions(
        documentNode: gql(GqlQuery.getJournal),
        pollInterval: 10,
      ),
      builder: _buildQueryResultWidget,
    );
  }

  Widget _buildQueryResultWidget(QueryResult result,
      {VoidCallback refetch, FetchMore fetchMore}) {
    if (result.hasException) {
      return Text(result.exception.toString());
    }

    if (result.loading) {
      return const CircularProgressIndicator();
    }

    final List<JournalEntry> journalEntries = (result.data['journal'] as List)
        .map((e) => JournalEntry.fromData(e as Map))
        .toList();
    return _buildList(context, journalEntries);
  }

  // Build List
  Widget _buildList(BuildContext context, List<JournalEntry> journalEntries) {
    return ListView.builder(
      itemCount: journalEntries.length,
      itemBuilder: (context, i) {
        return _buildListItem(context, journalEntries[i]);
      },
    );
  }

  // Build List item
  Widget _buildListItem(BuildContext context, JournalEntry journalEntry) {
    final f = DateFormat('MMM-dd-yyy hh:mm aaa');
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Card(
        elevation: 5,
        child: ListTile(
          onLongPress: () async {},
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          leading: Container(
            padding: const EdgeInsets.only(right: 12.0),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.black26,
                ),
              ),
            ),
            child: Column(children: [
              Text(
                journalEntry.emotion.icon,
                style: const TextStyle(fontSize: 42),
              ),
            ]),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  journalEntry.emotion.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 22.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  journalEntry.activity.title,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              '${journalEntry.userName} - ${f.format(journalEntry.entryDate)}',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigateToAddEmotion() {
    Navigator.of(context).pushNamed('/emotions');
  }

  Future subscribeNotifications(GraphQLClient client) async {
    if (_subscription != null) return;
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('uid');
    _subscription = client
        .subscribe(Operation(
      documentNode: gql(GqlQuery.latestJournalEntry),
    ))
        .listen((event) {
      final journals = event.data;
      final journal = journals['journal'][0];
      if (journal != null) {
        if (journal['user']['id'] != uid) {
          BotToast.showNotification(
            leading: (cancel) => SizedBox.fromSize(
              size: const Size(50, 50),
              child: Text(
                '${journal["emotion"]["icon"]}',
                style: const TextStyle(fontSize: 35.0),
              ),
            ),
            title: (_) => Text(
              '${journal["user"]["name"]} is ${journal["emotion"]["icon"]}',
              style: const TextStyle(
                fontSize: 22.0,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      }
    });
  }
}
