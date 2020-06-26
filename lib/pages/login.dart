import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graphql_hasura_talk/graphql/api.dart';
import 'package:flutter_graphql_hasura_talk/graphql/config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildBodyWidget(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveUser();
        },
        child: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildBodyWidget() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '😊 🥳 😠',
            style: TextStyle(fontSize: 50),
          ),
          const SizedBox(height: 20),
          const Text(
            "Let's start",
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 40),
          TextFormField(
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24.0),
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Please enter your name',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelStyle: TextStyle(fontSize: 24.0),
            ),
            keyboardType: TextInputType.text,
          )
        ],
      ),
    );
  }

  Future saveUser() async {
    final AuthResult authResult = await _auth.signInAnonymously();
    final uid = authResult.user.uid;
    final client = Config.initializeClient();
    final QueryResult queryResult = await client.value.mutate(
      MutationOptions(
        documentNode: gql(GqlQuery.signUp),
        variables: {
          'user': {
            'name': nameController.text,
            'uid': uid,
          }
        },
      ),
    );
    saveUserId(queryResult.data['insert_user_one']['id'] as int);
    navigateToJournal();
  }

  Future saveUserId(int uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('uid', uid);
  }

  void navigateToJournal() {
    Navigator.of(context).pushNamed('/journal');
  }
}
