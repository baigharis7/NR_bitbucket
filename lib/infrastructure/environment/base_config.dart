abstract class BaseConfig {
  String get baseUrl;
  String get cognitoClientId;
  String get cognitoPoolId;
  String get cognitoAppClientSecret;
  String get prefsName;
  String get cognitoConfig;
}

class StagingConfig implements BaseConfig {
  @override String get baseUrl => '8bymr2h348.execute-api.eu-west-3.amazonaws.com';

  @override String get cognitoClientId => '729e89vrtssaguuv0hpdkhs1eg';

  @override String get cognitoPoolId => 'eu-west-3_ewIR3R9Sl';

  @override String get cognitoAppClientSecret => '';

  @override String get prefsName => 'nutrenaissance_dev_prefs';

  @override String cognitoConfig = ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "IdentityManager": {
                "Default": {}
            },
            "awsCognitoAuthPlugin": {
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
  @override String get baseUrl => '';

  @override String get cognitoPoolId => '';

  @override String get cognitoClientId => '';

  @override String get cognitoAppClientSecret => '';

  @override String get prefsName => '';

  @override String get cognitoConfig => '';
}