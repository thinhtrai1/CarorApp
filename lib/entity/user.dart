class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String token;

  User(this.id, this.username, this.email, this.firstName, this.lastName, this.token);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['username'],
      json['email'],
      json['firstName'],
      json['lastName'],
      json['token'],
    );
  }

  Map toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
