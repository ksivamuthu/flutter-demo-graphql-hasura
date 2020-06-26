import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

mixin Config {
  static String _token;

  static final HttpLink httpLink = HttpLink(
    uri: 'https://flutter-dev-emotion-tracker.herokuapp.com/v1/graphql',
  );

  static final AuthLink authLink = AuthLink(getToken: () => _token);

  static final WebSocketLink websocketLink = WebSocketLink(
    url: 'wss://flutter-dev-emotion-tracker.herokuapp.com/v1/graphql',
    config: const SocketClientConfig(
      initPayload: {},
    ),
  );

  static final Link link = authLink.concat(httpLink).concat(websocketLink);

  static ValueNotifier<GraphQLClient> initializeClient() {
    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
        link: link,
      ),
    );
    return client;
  }
}
