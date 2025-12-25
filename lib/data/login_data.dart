class LoginData {
  final String apiKey;
  final String apiSecret;

  LoginData({required this.apiKey, required this.apiSecret});

  Map<String, String> toJson() => {'ec2256a4aa13f09': apiKey, 'da3f897e2c6a81d': apiSecret};

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    apiKey: json['ec2256a4aa13f09'] as String? ?? '',
    apiSecret: json['da3f897e2c6a81d'] as String? ?? '',
  );
}
