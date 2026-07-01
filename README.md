# 🚗 Smart Parking Management System

A full-stack Smart Parking Management System that allows users to book parking spots and enables administrators to manage parking lots, monitor occupancy, and track revenue in real time.

---

# 📌 Overview

This project digitizes parking management by replacing manual allocation with an online booking system.

The application consists of:

- Flutter Mobile Application
- Node.js + Express Backend
- MongoDB Atlas Cloud Database
- JWT Authentication
- REST APIs

---

# ✨ Features

## 👤 User

- Register
- Login
- JWT Authentication
- Persistent Login Session
- View Available Parking Lots
- View Parking Spots
- Book Parking Spot
- Release Parking Spot
- View Booking Details

---

## 👨‍💼 Admin

- Secure Admin Login
- Dashboard
- Create Parking Lot
- Delete Parking Lot
- Generate Parking Spots Automatically
- View All Spots
- View Spot Status
- Revenue Analytics
- Occupancy Analytics
- Total Revenue Summary

---

# 🏗️ Architecture

```
                 Flutter App
                      │
                      │ REST API
                      ▼
              Node.js + Express
                      │
          JWT Authentication
                      │
                      ▼
               MongoDB Atlas
```

---

# 🛠 Tech Stack

## Frontend

- Flutter
- Provider
- Shared Preferences
- HTTP Package

## Backend

- Node.js
- Express.js
- JWT
- Bcrypt
- Mongoose

## Database

- MongoDB Atlas

## Hosting

Backend
- Render

Database
- MongoDB Atlas

---

# 📂 Project Structure

```
smart-parking/

│
├── backend/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── app.js
│   └── package.json
│
└── frontend/
    ├── lib/
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   ├── widgets/
    │   └── main.dart
```

---

# 🔐 Authentication Flow

```
Register/Login

        │

        ▼

Backend validates credentials

        │

        ▼

JWT Token Generated

        │

        ▼

Flutter stores token using
SharedPreferences

        │

        ▼

Token attached to every API request

        │

        ▼

Backend validates JWT

        │

        ▼

Authorized Response
```

---

# 🚘 Parking Booking Flow

```
User Login

      │

      ▼

View Parking Lots

      │

      ▼

Choose Parking Spot

      │

      ▼

Book Spot

      │

      ▼

Spot Status

Available

↓

Occupied

↓

Vehicle Number Stored

↓

Revenue Starts Calculating

↓

User Releases Spot

↓

Available Again
```

---

# 👨‍💼 Admin Flow

```
Admin Login

      │

      ▼

Dashboard

      │

      ├── Add Parking Lot

      ├── Delete Parking Lot

      ├── Generate Spots

      ├── Monitor Occupancy

      ├── Revenue Analytics

      └── View All Parking Spots
```

---

# 📊 Revenue Calculation

Revenue is calculated based on the parking duration.

```
Revenue

=

Parking Price

×

Parking Duration
```

Example

```
Price

₹50/hour

Parking Time

2 Hours

Revenue

₹100
```

---

# 📦 REST APIs

## Authentication

| Method | Endpoint |
|---------|----------|
| POST | /api/auth/register |
| POST | /api/auth/login |

---

## Parking Lots

| Method | Endpoint |
|---------|----------|
| GET | /api/lots |
| POST | /api/lots |
| DELETE | /api/lots/:id |

---

## Parking Spots

| Method | Endpoint |
|---------|----------|
| GET | /api/spots/details |
| POST | /api/spots/book |
| POST | /api/spots/release |

---

## Admin

| Method | Endpoint |
|---------|----------|
| GET | /api/admin/summary |

---

# 🗄 Database Models

## User

```
id

username

password

role
```

---

## Parking Lot

```
id

primeLocationName

address

pinCode

price

maximumNumberOfSpots
```

---

## Parking Spot

```
id

label

status

vehicleNumber

lotId
```

---

## Reservation

```
id

userId

spotId

vehicleNumber

entryTime

exitTime

totalCost
```

---

# 🔄 Session Persistence

After successful login:

```
JWT Token

↓

Stored in SharedPreferences

↓

App Restart

↓

Session Restored Automatically

↓

User stays Logged In
```

---

# 🚀 Installation

## Clone

```bash
git clone <repository-url>
```

---

## Backend

```bash
cd backend

npm install

npm start
```

---

## Frontend

```bash
cd frontend

flutter pub get

flutter run
```

---

# ⚙ Environment Variables

Create a `.env`

```env
PORT=5000

MONGO_URI=your_mongodb_connection

JWT_SECRET=your_secret_key
```

---

# ☁ Deployment

Backend

- Render

Database

- MongoDB Atlas

---

# ⚠ Note

This project uses the **Render Free Tier**.

The backend automatically sleeps after a period of inactivity.

The first API request may take **20–60 seconds** while the server wakes up.

Subsequent requests are fast.

---

# 📸 Screenshots

Add screenshots here.

- Login
- Register
- User Dashboard
- Admin Dashboard
- Booking Screen
- Revenue Dashboard

---

# 🔮 Future Improvements

- QR Code Entry
- Online Payment Gateway
- Google Maps Integration
- Parking Reservation Timer
- Push Notifications
- License Plate Recognition
- IoT Sensor Integration
- Live Parking Availability
- Admin Analytics Dashboard

---

# 👨‍💻 Author

**Santhosh Kumar**

B.Tech Information Technology

Aspiring Software Engineer & Filmmaker

---

# 📄 License

This project is developed for educational and portfolio purposes.