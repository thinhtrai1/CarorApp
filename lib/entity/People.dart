class People {
  final int id;
  final String username;
  final String email;
  final String firstname;
  final String lastname;
  final String avatar;
  final String country;
  final String phone;
  final String? facebook;

  People(
    this.id,
    this.username,
    this.email,
    this.firstname,
    this.lastname,
    this.avatar,
    this.country,
    this.phone,
    this.facebook,
  );

  factory People.fromJson(Map<String, dynamic> json) {
    return People(
      json['id'],
      json['username'],
      json['email'],
      json['firstname'],
      json['lastname'],
      json['avatar'],
      json['country'],
      json['phone'],
      json['facebook'],
    );
  }
}
