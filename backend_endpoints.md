# Backend Reference Data Endpoints

All 5 endpoints serve S3 files from the `nutrients-pro` bucket. Each returns:
```json
{ "v": <int>, "data": <json_content> }
```

The version (`v`) is derived from the S3 object's `LastModified` timestamp (epoch seconds), so it auto-increments whenever the file is re-uploaded.

## Reusable Lambda (Option A — recommended)

Deploy one Lambda 5 times with different env vars (`S3_KEY`):

```javascript
// index.mjs — Node.js 20, ESM
import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({ region: "eu-west-3" });
const BUCKET = process.env.BUCKET || "nutrients-pro";
const S3_KEY = process.env.S3_KEY;

export const handler = async () => {
  try {
    const response = await s3.send(new GetObjectCommand({
      Bucket: BUCKET,
      Key: S3_KEY,
    }));

    const body = await response.Body.transformToString();
    const data = JSON.parse(body);
    const version = Math.floor(response.LastModified.getTime() / 1000);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ v: version, data }),
    };
  } catch (err) {
    console.error(`Failed to fetch ${S3_KEY} from ${BUCKET}:`, err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to fetch reference data" }),
    };
  }
};
```

## Deployment Table

| Lambda Name | API Gateway Path | `S3_KEY` env var | Used By |
|-------------|-----------------|------------------|---------|
| `reference-data-nutrients-prod` | `/reference-data/nutrients` | `nutrients.json` | NutrientCalculationService (food + liquid) |
| `reference-data-nutrient-loss-prod` | `/reference-data/nutrient-loss` | `nutrients_loss_table.json` | NutrientCalculationService (cooking loss) |
| `reference-data-sport-mets-prod` | `/reference-data/sport-mets` | `sports.json` | SportKcalCalculationService |
| `reference-data-objective-nutrients-prod` | `/reference-data/objective-nutrients` | `objective_nutrients.json` | ProfileComputationService (micronutrient prioritization) |
| `reference-data-nutrient-objective-prod` | `/reference-data/nutrient-objective` | `nutrient_objective.json` | ProfileComputationService (RDA computation) |

**NOTE:** Verify S3 key names for endpoints 4 and 5 — check what `upload-profile-data-prod` Lambda uses when reading these from S3.

## Individual Lambdas (Option B)

### 1. `/reference-data/nutrients`

```javascript
import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({ region: "eu-west-3" });

export const handler = async () => {
  try {
    const response = await s3.send(new GetObjectCommand({
      Bucket: "nutrients-pro",
      Key: "nutrients.json",
    }));

    const body = await response.Body.transformToString();
    const data = JSON.parse(body);
    const version = Math.floor(response.LastModified.getTime() / 1000);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ v: version, data }),
    };
  } catch (err) {
    console.error("Failed to fetch nutrients:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to fetch nutrients" }),
    };
  }
};
```

### 2. `/reference-data/nutrient-loss`

```javascript
import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({ region: "eu-west-3" });

export const handler = async () => {
  try {
    const response = await s3.send(new GetObjectCommand({
      Bucket: "nutrients-pro",
      Key: "nutrients_loss_table.json",
    }));

    const body = await response.Body.transformToString();
    const data = JSON.parse(body);
    const version = Math.floor(response.LastModified.getTime() / 1000);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ v: version, data }),
    };
  } catch (err) {
    console.error("Failed to fetch nutrient loss table:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to fetch nutrient loss table" }),
    };
  }
};
```

### 3. `/reference-data/sport-mets`

```javascript
import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({ region: "eu-west-3" });

export const handler = async () => {
  try {
    const response = await s3.send(new GetObjectCommand({
      Bucket: "nutrients-pro",
      Key: "sports.json",
    }));

    const body = await response.Body.transformToString();
    const data = JSON.parse(body);
    const version = Math.floor(response.LastModified.getTime() / 1000);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ v: version, data }),
    };
  } catch (err) {
    console.error("Failed to fetch sport METs:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to fetch sport METs" }),
    };
  }
};
```

### 4. `/reference-data/objective-nutrients`

```javascript
import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({ region: "eu-west-3" });

export const handler = async () => {
  try {
    const response = await s3.send(new GetObjectCommand({
      Bucket: "nutrients-pro",
      Key: "objective_nutrients.json", // verify this key name
    }));

    const body = await response.Body.transformToString();
    const data = JSON.parse(body);
    const version = Math.floor(response.LastModified.getTime() / 1000);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ v: version, data }),
    };
  } catch (err) {
    console.error("Failed to fetch objective nutrients:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to fetch objective nutrients" }),
    };
  }
};
```

### 5. `/reference-data/nutrient-objective`

```javascript
import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({ region: "eu-west-3" });

export const handler = async () => {
  try {
    const response = await s3.send(new GetObjectCommand({
      Bucket: "nutrients-pro",
      Key: "nutrient_objective.json", // verify this key name
    }));

    const body = await response.Body.transformToString();
    const data = JSON.parse(body);
    const version = Math.floor(response.LastModified.getTime() / 1000);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ v: version, data }),
    };
  } catch (err) {
    console.error("Failed to fetch nutrient objective:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to fetch nutrient objective" }),
    };
  }
};
```

---

# FCM Push Notification Endpoints

## 6. `register-fcm-token` Lambda

**API Gateway Path**: POST `/fcm-token`
**Auth**: Same Cognito authorizer as other endpoints

**DynamoDB Table**: `fcm-tokens`
- Partition key: `userId` (String)
- Sort key: `token` (String)
- Attributes: `platform` (String), `updatedAt` (Number)

```javascript
// index.mjs — Node.js 20, ESM
import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const dynamodb = new DynamoDBClient({ region: "eu-west-3" });

export const handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const { userId, token, platform } = body;

    await dynamodb.send(new PutItemCommand({
      TableName: "fcm-tokens",
      Item: {
        userId: { S: userId },
        token: { S: token },
        platform: { S: platform },
        updatedAt: { N: Date.now().toString() },
      },
    }));

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ success: true }),
    };
  } catch (err) {
    console.error("Failed to register FCM token:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to register token" }),
    };
  }
};
```

## 7. `delete-fcm-token` Lambda

**API Gateway Path**: DELETE `/fcm-token`
**Auth**: Same Cognito authorizer

```javascript
import { DynamoDBClient, DeleteItemCommand } from "@aws-sdk/client-dynamodb";

const dynamodb = new DynamoDBClient({ region: "eu-west-3" });

export const handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const { token } = body;

    // Token alone isn't enough for DynamoDB delete (need userId too),
    // so use a GSI on token or scan. For simplicity, require userId in body.
    const userId = body.userId;

    await dynamodb.send(new DeleteItemCommand({
      TableName: "fcm-tokens",
      Key: {
        userId: { S: userId },
        token: { S: token },
      },
    }));

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ success: true }),
    };
  } catch (err) {
    console.error("Failed to delete FCM token:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to delete token" }),
    };
  }
};
```

## 8. FCM Send Helper (for Routine Lambdas)

Add this to existing EventBridge routine Lambdas (food-routine, sport-routine, supplement-routine). After creating the event in DynamoDB, call `notifyUser()` to send a silent FCM push:

```javascript
// fcm_helper.mjs
import admin from "firebase-admin";
import { DynamoDBClient, QueryCommand } from "@aws-sdk/client-dynamodb";

// Initialize Firebase Admin SDK (once per Lambda cold start)
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

const dynamodb = new DynamoDBClient({ region: "eu-west-3" });

export async function notifyUser(userId) {
  try {
    const result = await dynamodb.send(new QueryCommand({
      TableName: "fcm-tokens",
      KeyConditionExpression: "userId = :uid",
      ExpressionAttributeValues: { ":uid": { S: userId } },
    }));

    const tokens = (result.Items || []).map((item) => item.token.S);
    if (tokens.length === 0) return;

    await admin.messaging().sendEachForMulticast({
      tokens,
      data: { type: "routine_event_created", timestamp: Date.now().toString() },
      // Uncomment for visible notifications:
      // notification: { title: "Routine completed", body: "Your scheduled routine has been logged." },
      android: { priority: "high" },
      apns: { payload: { aps: { "content-available": 1 } } },
    });
  } catch (err) {
    console.error("Failed to send FCM notification:", err);
    // Non-fatal: don't let notification failure break the routine Lambda
  }
}
```

### Usage in routine Lambdas:

```javascript
import { notifyUser } from "./fcm_helper.mjs";

// ... after creating event in DynamoDB ...
await notifyUser(userId);
```

### FCM Setup Checklist

- [ ] Create DynamoDB table `fcm-tokens` (partition key: `userId`, sort key: `token`)
- [ ] Deploy `register-fcm-token` Lambda with POST `/fcm-token` route
- [ ] Deploy `delete-fcm-token` Lambda with DELETE `/fcm-token` route
- [ ] Add `firebase-admin` npm package to routine Lambdas
- [ ] Download Firebase service account key JSON and set `GOOGLE_APPLICATION_CREDENTIALS` env var, OR use Application Default Credentials via IAM
- [ ] Add `fcm_helper.mjs` to routine Lambda deployments
- [ ] Call `notifyUser(userId)` at the end of each routine Lambda
- [ ] iOS: Configure APNs key in Firebase Console (Settings > Cloud Messaging > APNs)

---

## Setup Checklist

- [ ] Create 5 Lambda functions (Node.js 20, ESM) or 1 reusable function with env vars
- [ ] IAM role: `s3:GetObject` on `arn:aws:s3:::nutrients-pro/*`
- [ ] API Gateway: 5 GET routes matching paths in `lib/data/api/referencedata/reference_data_api.dart`
- [ ] Auth: same Cognito authorizer as other endpoints
- [ ] Verify S3 key names for objective_nutrients.json and nutrient_objective.json
- [ ] Test: first login should download all 5 files; subsequent logins skip if unchanged

## Expected Data Formats

### nutrients.json
```json
[
  {
    "id": 1, "isFood": 0, "g": "cereals", "en": "Wheat flour", "es": "Harina de trigo",
    "recommendable": 1, "freeSugar": "0",
    "params": { "energyKcal": 364, "protein": 10.3, ... }
  },
  ...
]
```

### nutrients_loss_table.json
```json
[
  { "cookingMethodId": 1, "nutrients": { "vitC": 0.25, "vitB1": 0.15, ... } },
  ...
]
```

### sports.json
```json
[
  { "id": 1, "en": "Running", "es": "Correr", "mets": ["3,5", "7,0", "10,5"] },
  ...
]
```

### objective_nutrients.json
```json
{
  "1": ["calcium", "vitD", ...],
  "2": ["iron", ...],
  "100": ["iron", "vitC", ...],
  ...
}
```

### nutrient_objective.json
```json
{
  "calcium": {
    "male": { "19-30": { "rda": 1000, "ul": 2500 }, "30-50": {...}, "50-70": {...}, "70+": {...} },
    "female": { "19-30": {...}, ... }
  },
  ...
}
```
