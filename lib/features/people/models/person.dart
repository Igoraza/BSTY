class Person {
  Person({
    required this.id,
    required this.name,
    required this.displayImage,
    this.profession = '',
    this.location = '',
    required this.age,
  });

  final int id;
  final String name;
  final String displayImage;
  final dynamic profession;
  final dynamic location;
  final int age;

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json["id"],
        name: json["name"],
        displayImage: json["display_image"],
        profession: json["profession"],
        location: json["location"],
        age: json["age"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "display_image": displayImage,
        "profession": profession,
        "location": location,
        "age": age,
      };
}
