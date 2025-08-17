class MapUser {
  final int id;
  final String name;
  final String image;
  final int distance;

  MapUser({
    required this.id,
    required this.name,
    required this.image,
    required this.distance,
  });

  factory MapUser.fromJson(Map<String, dynamic> json) => MapUser(
        id: json['id'],
        name: json['name'],
        image: json['display_image'] ?? '',
        distance: json['distance'],
      );
}
