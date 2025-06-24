class User {
  final String id;
   String? phoneNumber; 
   String name;
  final String email;


  User({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.email,

  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'phoneNumber': phoneNumber,
    'name': name,
    'email': email,
    
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'],
    phoneNumber: json['phoneNumber'] ?? '124',
    name: json['name'],
    email: json['email'],

  );
}