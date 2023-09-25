import 'Session.dart';

class Sessions {
  List<Session> morning = [];
  List<Session> night = [];
  List<Session> short = [];
  List<Session> long = [];

  void addMorning(Session session) {
    this.morning.add(session);
  }

  void addNight(Session session) {
    this.night.add(session);
  }

  void addShort(Session session) {
    this.short.add(session);
  }

  void addLong(Session session) {
    this.long.add(session);
  }

  List<Session> getMorning() {
    return this.morning;
  }

  List<Session> getNight() {
    return this.night;
  }

  List<Session> getShort() {
    return this.short;
  }

  List<Session> getLong() {
    return this.long;
  }

//get the list of type by his name
  List<Session> getByType(String type) {
    var lst;
    switch (type) {
      case "morning":
        lst = morning;
        break;
      case "night":
        lst = night;
        break;
      case "short":
        lst = short;
        break;
      case "long":
        lst = long;
    }
    return lst;
  }

//when the user finish listen to session, search the session that was listened
  void doneSession(String name, int stage, int feedback) {
    switch (stage) {
      case 1:
        for (Session s in morning) {
          if (s.name.compareTo(name) == 0) s.doneSession(feedback);
        }
        break;
      case 2:
        for (Session s in night) {
          if (s.name.compareTo(name) == 0) s.doneSession(feedback);
        }
        break;
      case 3:
        for (Session s in long) {
          if (s.name.compareTo(name) == 0) s.doneSession(feedback);
        }
        break;
      case 4:
        for (Session s in short) {
          if (s.name.compareTo(name) == 0) s.doneSession(feedback);
        }
        break;
    }
  }

//restart the sessions
  void resertSession() {
    for (Session s in morning) {
      s.completed = false;
      s.feedback = 0;
    }
    for (Session s in night) {
      s.completed = false;
      s.feedback = 0;
    }
    for (Session s in long) {
      s.completed = false;
      s.feedback = 0;
    }
    for (Session s in short) {
      s.completed = false;
      s.feedback = 0;
    }
  }
}
