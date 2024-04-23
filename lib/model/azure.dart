class Azure {
  String? odataContext;
  String? userPrincipalName;
  String? id;
  String? displayName;
  String? surname;
  String? givenName;
  String? preferredLanguage;
  String? mail;
  String? mobilePhone;
  String? jobTitle;
  String? officeLocation;
  List<String>? businessPhones;

  Azure(
      {this.odataContext,
      this.userPrincipalName,
      this.id,
      this.displayName,
      this.surname,
      this.givenName,
      this.preferredLanguage,
      this.mail,
      this.mobilePhone,
      this.jobTitle,
      this.officeLocation,
      this.businessPhones});

  Azure.fromJson(Map<String, dynamic> json) {
    odataContext = json['@odata.context'];
    userPrincipalName = json['userPrincipalName'];
    id = json['id'];
    displayName = json['displayName'];
    surname = json['surname'];
    givenName = json['givenName'];
    preferredLanguage = json['preferredLanguage'];
    mail = json['mail'];
    mobilePhone = json['mobilePhone'];
    jobTitle = json['jobTitle'];
    officeLocation = json['officeLocation'];
    businessPhones = json['businessPhones'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['@odata.context'] = odataContext;
    data['userPrincipalName'] = userPrincipalName;
    data['id'] = id;
    data['displayName'] = displayName;
    data['surname'] = surname;
    data['givenName'] = givenName;
    data['preferredLanguage'] = preferredLanguage;
    data['mail'] = mail;
    data['mobilePhone'] = mobilePhone;
    data['jobTitle'] = jobTitle;
    data['officeLocation'] = officeLocation;
    data['businessPhones'] = businessPhones;
    return data;
  }
}
