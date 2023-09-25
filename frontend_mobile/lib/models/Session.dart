class Session {
  String name;
  String description;
  String guided_text;
  String audio;
  int stage;
  String completed_message;
  bool completed;
  int feedback = 0;

  Session(
      {this.name,
      this.description,
      this.guided_text,
      this.audio,
      this.stage,
      this.completed_message,
      this.completed,
      this.feedback});

  factory Session.fromJson(Map<String, dynamic> json) {
    Session session = Session(
        name: json["name"],
        description: json["description"],
        guided_text: json["guided_text"],
        audio: json["audio"],
        stage: json["stage"],
        completed_message: json["completed_message"],
        completed: json["completed"],
        feedback: json["feedback"]);
    return session;
  }

//when the user finish listen to session
  void doneSession(int feedback) {
    this.completed = true;
    this.feedback = feedback;
  }
}
