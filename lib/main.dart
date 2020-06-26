import 'package:flutter/material.dart';
import 'package:flutter_graphql_hasura_talk/graphql/config.dart';
import 'package:flutter_graphql_hasura_talk/pages/activities.dart';
import 'package:flutter_graphql_hasura_talk/pages/emotion.dart';
import 'package:flutter_graphql_hasura_talk/pages/journal.dart';
import 'package:flutter_graphql_hasura_talk/pages/login.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:bot_toast/bot_toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // GraphQL Provider widget with configured GraphQL client
    return GraphQLProvider(
      client: Config.initializeClient(),
      child: CacheProvider(child: materialApp()), //Cache Provider
    );
  }

  Widget materialApp() {
    return MaterialApp(
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/journal': (context) => JournalPage(),
        '/emotions': (context) => AddEmotionDialog(),
        '/devActivities': (context) => DevActivities()
      },
      title: 'Dev Emotion Tracker',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
    );
  }
}
