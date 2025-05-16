# Reward Hub

Reward Hub is a loyalty program Rails application that allows users to accumulate points through transactions and claim rewards.

## Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/username/reward_hub.git
   cd reward_hub

2. **Install Ruby Dependencies:**
   ```bash
   bundle install

3. **Run Database Migrations and Seed Data:**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed

4. **Run rails s:**
   ```bash
   rails s

---
## Postman API Collection
[Reward Hub API.postman_collection.json](https://github.com/user-attachments/files/20227335/Reward.Hub.API.postman_collection.json)

---
## Documentation
https://www.notion.so/Reward-Hub-1f2ed51d5d1e80d2b122f3fb3a8c265a?pvs=4


## API Documentation
This document provides an overview of the API endpoints available for the application. The API is organized into three main sections:
1. User Endpoints
2. Transaction Endpoints
3. Reward Endpoints

All API endpoints use `http://localhost:3000` as the base URL.

**NOTE:**
- Wherever authorization is required, make sure to include the user's api_token.
  
---

### User Endpoints

#### Create User
- **Method:** POST
- **URL:** `/api/v1/user`
- **Headers:**
  - Content-Type: application/json
  - Accept: application/json
- **Payload:**
```json
{
    "user": {
        "name": "John Doe",
        "email": "john@example.com",
        "birthdate": "1990-01-01",
        "country": "USA"
    }
}
```
- **Response:**
```json
{
    "message": "User created successfully",
    "user": {
        "id": 33,
        "name": "John Doe",
        "email": "john@example.com",
        "birthdate": "1990-01-01",
        "api_token": "10fa5ac3be5a746f6911b372695a4bd3fd075910",
        "country": "USA",
        "total_points": 0,
        "created_at": "2025-05-14T16:22:59.032Z",
        "updated_at": "2025-05-14T16:22:59.032Z"
    }
}
```

#### Get Current User
- **Method:** GET
- **URL:** `/api/v1/me`
- **Headers:**
  - Content-Type: application/json
  - Accept: application/json
  - Authorization: Bearer
- **Response:**
```json
{
    "id": 33,
    "name": "John Doe",
    "email": "john@example.com",
    "birthdate": "1990-01-01",
    "api_token": "10fa5ac3be5a746f6911b372695a4bd3fd075910",
    "country": "USA",
    "total_points": 220,
    "created_at": "2025-05-14T16:22:59.032Z",
    "updated_at": "2025-05-14T16:22:59.032Z"
}
```

### Transaction Endpoints

#### Create Transaction
- **Method:** POST
- **URL:** URL: /api/v1/transactions
- **Headers:**
  - Content-Type: application/json
  - Accept: application/json
  - Authorization: Bearer
- **Payload:**
```json
{
    "transaction": {
        "amount": 200.5,
        "country": "USA",
        "external_id": "txn_12345"
    }
}
```
- **Response:**
```json
{
    "transaction": {
        "id": 4,
        "user_id": 11,
        "amount": 200.5,
        "country": "USA",
        "external_id": "txn_123456",
        "created_at": "2025-05-14 16:23:19 UTC"
    }
}
```

#### List Transaction
- **Method:** GET
- **URL:** URL: /api/v1/transactions
- **Headers:**
  - Content-Type: application/json
  - Accept: application/json
  - Authorization: Bearer
- **Response:**
```json
[
    {
        "id": 4,
        "user_id": 11,
        "amount": 200.5,
        "country": "USA",
        "external_id": "txn_123456",
        "created_at": "2025-05-14 16:23:19 UTC"
    },
    {
        "id": 3,
        "user_id": 11,
        "amount": 2000.5,
        "country": "USA",
        "external_id": "txn_1234534",
        "created_at": "2025-05-14 16:14:40 UTC"
    }
]
```

### Reward Endpoints

#### List Available Rewards
- **Method:** GET
- **URL:** URL: /api/v1/reward/available
- **Headers:**
  - Content-Type: application/json
  - Accept: application/json
  - Authorization: Bearer
- **Response:**
```json
{
    "available_rewards": [
        {
            "id": 1,
            "name": "Free Coffee",
            "points_req": 100,
            "valid_from": "2025-05-14 00:00:00 UTC",
            "valid_until": "2026-05-14 15:30:34 UTC"
        }
    ]
}
```

#### Claim Reward
- **Method:** POST
- **URL:** URL: /api/v1/reward/reward_id/claim
- **Headers:**
  - Content-Type: application/json
  - Accept: application/json
  - Authorization: Bearer
- **Response:**
```json
{
    "message": "Reward claimed successfully"
}
```

#### Claimed Reward
- **Method:** GET
- **URL:** URL: /api/v1/reward/claimed
- **Headers:**
  - Content-Type: application/json
  - Accept: application/json
  - Authorization: Bearer
- **Response:**
```json
{
    "claimed_rewards": [
        {
            "id": 1,
            "name": "Free Coffee",
            "valid_from": "2025-05-14 00:00:00 UTC",
            "valid_until": "2026-05-14 15:30:34 UTC"
        }
      {
            "id": 1,
            "name": "Free Coffee",
            "valid_from": "2025-05-14 00:00:00 UTC",
            "valid_until": "2026-05-14 15:30:34 UTC"
        }
    ]
}
```
