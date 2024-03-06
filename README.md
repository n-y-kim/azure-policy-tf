# azure-policy-tf

## 폴더 구조
```bash
.
├── README.md
├── builtin-policies
│   ├── compute
│   │   └── ClassicCompute_Audit.json
│   │   └── Builtin_Policy_Sample.json
│   │   └── ....
│   │    
│   ├── general
│   │   └── NotAllowM365_Deny.json
│   │   └── ....
│   │
│   └── 카테고리 별 폴더 이름 ...
│   
├── custom-policies
│   ├── network
│   │   └── subnet-need-nsg-assigned-to-be-created.json
│   │   └── ....
│   │
│   └── 카테고리 별 폴더 이름 ....
│   
├── main.tf
├── modules
│   └── policy
│       └── policy_apply.tf
├── providers.tf
```

- `builtin-policies`: Azure에서 제공하는 기본 정책들을 카테고리별로 복사해서 정리한 폴더. `Allowed values`, `Default Value`, `Name` 등을 수정한 것들도 여기에 포함. 
- `custom-policies`: Built-in base가 아닌 완전히 새로운 정책들을 정리한 폴더. 
    > 해당 폴더에 있는 json은 예시입니다
- `policy` 모듈: `policy_directory` 변수에 따라 `builtin-policies` 또는 `custom-policies` 폴더를 참조하여 정책을 적용하는 모듈.
- `main.tf`: 정책을 적용하는 메인 파일. 

## built-in policy json 파일 작성 시 유의사항

### 1. `name` 값은 수정하지 않아도 됨.

[Azure policy github](https://github.com/Azure/azure-policy/tree/master/built-in-policies/policyDefinitions)에서 json 파일을 다운 받아보면 `name` 값이 정해져있습니다.

예시)

```json

{
  "properties": {
    "displayName": "Container registries should have local admin account disabled.",
    "description": "Disable admin account for your registry so that it is not accessible by local admin. Disabling local authentication methods like admin user, repository scoped access tokens and anonymous pull improves security by ensuring that container registries exclusively require Azure Active Directory identities for authentication. Learn more at: https://aka.ms/acr/authentication.",
    "policyType": "BuiltIn",
    "mode": "Indexed",
    "metadata": {
      "version": "1.0.1",
      "category": "Container Registry"
    },
    "version": "1.0.1",
    "parameters": {
      "effect": {
        "type": "String",
        "defaultValue": "Audit",
        "allowedValues": [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        }
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.ContainerRegistry/registries"
          },
          {
            "field": "Microsoft.ContainerRegistry/registries/adminUserEnabled",
            "equals": true
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
  },
  "id": "/providers/Microsoft.Authorization/policyDefinitions/dc921057-6b28-4fbe-9b83-f7bec05db6c2", 
  "name": "dc921057-6b28-4fbe-9b83-f7bec05db6c2" # 이 부분
}

```

이 Built in policy를 식별하게 하는 문자열이므로, 이미 기본 Built in으로 배포되어 있기 때문에 같은 name으로 정책을 만들 수 없습니다.

따라서 `modules/policy/policy_apply.tf` 에서 모든 정책의 `name`을 `DisplayName`으로 변경하여 배포합니다. (해당 파일 L14) 사용자가 따로 해당 파일의 name을 변경할 필요가 없습니다.

### 2. `displayName` 값이나 `description` 값은 수정 권고.

이미 존재하는 Built-in policy와 이름이 겹치지 않게 하기 위해 `displayName` 값을 수정하는 것을 권고합니다. 가독성을 위해 한글로 작성하는 것도 좋습니다.