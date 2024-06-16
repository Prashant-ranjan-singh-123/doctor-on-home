class User {
  String name;
  int age;

  User(this.name, this.age);

  Map toJson() => {
    'name': name,
    'age': age,
  };
}