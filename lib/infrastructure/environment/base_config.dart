abstract class BaseConfig {
  String get baseUrl;
  String get distributionPath;
  String get cognitoClientId;
  String get cognitoPoolId;
  String get prefsName;
  String get cognitoConfig;
}

class DevConfig implements BaseConfig {
  @override String get baseUrl => '8bymr2h348.execute-api.eu-west-3.amazonaws.com';

  @override String get distributionPath => '/dev';

  @override String get cognitoClientId => '729e89vrtssaguuv0hpdkhs1eg';

  @override String get cognitoPoolId => 'eu-west-3_ewIR3R9Sl';

  @override String get prefsName => 'nutrenaissance_dev_prefs';

  @override String cognitoConfig = ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                          "PoolId": "eu-west-3:a91c68fa-b36b-4d3e-b52d-8f751b5c1f47",
                          "Region": "eu-west-3"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "eu-west-3_ewIR3R9Sl",
                        "AppClientId": "729e89vrtssaguuv0hpdkhs1eg",
                        "Region": "eu-west-3"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH"
                    }
                }
            }
        }
    }
  }''';
}

class ProductionConfig implements BaseConfig {
  @override String get baseUrl => '05kpv2341k.execute-api.eu-west-3.amazonaws.com';

  @override String get distributionPath => '/prod';

  @override String get cognitoClientId => 'd1lt020mqpfmkq1vkkm0dsgpd';

  @override String get cognitoPoolId => 'eu-west-3_sZA2GWT5W';

  @override String get prefsName => 'nutrenaissance_prod_prefs';

  @override String get cognitoConfig => ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                          "PoolId": "eu-west-3:59d68e1a-2ddc-46d5-8691-5a118d4747f2",
                          "Region": "eu-west-3"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "eu-west-3_sZA2GWT5W",
                        "AppClientId": "d1lt020mqpfmkq1vkkm0dsgpd",
                        "Region": "eu-west-3"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH"
                    }
                }
            }
        }
    }
  }''';
}