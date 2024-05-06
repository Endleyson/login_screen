class Authentication {
  bool? status;
  String? message;
  int? userId;
  String? fullName;
  String? email;
  String? password;
  String? userImage;

  Authentication(
      {this.status = false,
      this.message,
      this.userId,
      this.fullName,
      this.email,
      this.password,
      this.userImage});

  factory Authentication.fromJson(Map<String, dynamic> json) {
    return Authentication(
      status: json.containsKey('status') ? json['status'] : false,
      message: json.containsKey('message') ? json['message'] : '',
      userId: json.containsKey('user_id') ? json['user_id'] : 0,
      email: json.containsKey('email') ? json['email'] : '',
      password: json.containsKey('password') ? json['password'] : '',
      fullName: json.containsKey('full_name') ? json['full_name'] : '',
      userImage: json.containsKey('user_image') ? json['user_image'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'user_id': userId,
        'email': email,
        'full_name': fullName,
        'user_image': userImage,
      };
}
