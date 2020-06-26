mixin GqlQuery {
  static const String getAllEmotions = '''
  query allEmotions {
    emotions {
      id
      title
      icon
    }
  }
  ''';

  static const String getCategoriesAndActivities = '''
  query allCategories {
    categories {
      id
      title
      icon
      activities {
        id
        title
      }
    }
  }
  ''';

  static const String saveActivity = '''
    mutation save_activity(\$journal: journal_insert_input! ) {
      insert_journal_one(object: \$journal) {
        id
      }
    }
  ''';

  static const String getJournal = '''
  query journals {
    journal(order_by: {updated_at: desc}) {
      id
      user {
        name
      }
      activity {
        title
      }
      emotion {
        title
        icon
      }
      created_at
    }
  }
  ''';

  static const String signUp = '''
    mutation insert_user(\$user: user_insert_input! ) {
      insert_user_one(object: \$user, on_conflict: {
      constraint: user_uid_key,
      update_columns: [name]
    }) {
        id
        name
      }
    }
  ''';

  static const String latestJournalEntry = '''
  subscription {
    journal(order_by: {created_at: desc}, limit: 1) {
      id
      user {
        id
        name
      }
      emotion {
        icon
      }
    }
  }
  ''';
}
