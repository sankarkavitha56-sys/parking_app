# Smart Parking Management System

A full-stack smart parking application built for real-time parking slot management. The project includes separate User and Admin dashboards, JWT-based authentication, MongoDB Atlas storage, and live occupancy updates using Socket.IO.

## Tech Stack

- Flutter Web
- Node.js
- Express.js
- MongoDB Atlas
- Mongoose
- JWT Authentication
- Socket.IO
- Razorpay package dependency for demo payment flow

## Project Overview

The Smart Parking Management System helps users find available parking lots, reserve a spot, release the spot after parking, and view parking history. Admins can manage parking lots, monitor occupied and available spots, and view revenue summaries.

This project is designed as a placement-ready full-stack demo. It focuses on clear architecture, role-based access, real-time updates, and a polished interview demo flow.

## Architecture

```text
Flutter Web App
  |-- Screens
  |-- Services
  |-- Models
  |
  | HTTP + JWT
  | Socket.IO
  v
Node.js + Express Backend
  |-- Auth Routes
  |-- User Routes
  |-- Admin Routes
  |-- Payment Routes
  |-- Socket.IO Events
  |
  v
MongoDB Atlas
  |-- Users
  |-- Parking Lots
  |-- Parking Spots
  |-- Reservations
  |-- Bookings
```

## Features

### User

- User registration and login
- View parking lots with availability
- Search parking lots
- Reserve a parking spot
- Release a parking spot
- Automatic parking fee calculation
- Parking history
- Live dashboard refresh using Socket.IO

### Admin

- Admin login
- Add, edit, and delete parking lots
- View all parking spots
- View occupied and available spot count
- Revenue summary by user and parking lot
- Realtime updates when parking status changes

### Security

- Password hashing with bcrypt
- JWT authentication
- Role-based access control
- Admin APIs protected with admin middleware
- Admin self-registration disabled

## API Endpoints

### Auth

```text
POST /api/auth/register
POST /api/auth/login
```

### User

```text
GET  /api/lots
GET  /api/spots/details
GET  /api/spots/:id/details
POST /api/reservations
GET  /api/reservations
PUT  /api/reservations/:id/release
GET  /api/summary
```

### Admin

```text
GET    /api/admin/summary
POST   /api/admin/lots
PUT    /api/admin/lots/:id
DELETE /api/admin/lots/:id
```

### Payment Demo

```text
POST /api/payment/initiate
POST /api/payment/confirm
```

## Installation

### Backend

```bash
cd backend
npm install
npm start
```

Required environment variables:

```text
PORT=3000
MONGODB_URI=your_mongodb_atlas_connection_string
JWT_SECRET=your_jwt_secret
```

### Flutter Web

```bash
flutter pub get
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:3000/api \
  --dart-define=SOCKET_URL=http://localhost:3000
```

For deployed builds:

```bash
flutter build web \
  --dart-define=API_BASE_URL=https://parking-api.onrender.com/api \
  --dart-define=SOCKET_URL=https://parking-api.onrender.com
```

## Deployment

Suggested deployment:

- Backend: Render or Railway
- Database: MongoDB Atlas
- Flutter Web: Firebase Hosting, Netlify, or Vercel

Example deployed URLs:

```text
Backend: https://parking-api.onrender.com
Frontend: https://smartparkingdemo.web.app
```

## Demo Flow

1. Login as user.
2. View parking lots.
3. Reserve a spot.
4. Confirm that the spot becomes occupied.
5. Open admin dashboard.
6. View updated occupancy and revenue summary.
7. Release the spot.
8. Confirm payment completed message.
9. Verify the spot becomes available again.

## Screenshots

Add screenshots after deployment:

```text
screenshots/login.png
screenshots/register.png
screenshots/user-dashboard.png
screenshots/reserve-spot.png
screenshots/release-spot.png
screenshots/admin-dashboard.png
screenshots/revenue-dashboard.png
screenshots/realtime-update.png
screenshots/parking-lot.png
```

## Resume Summary

Smart Parking Management System  
Flutter | Node.js | Express | MongoDB Atlas | JWT | Socket.IO

- Developed a real-time smart parking application with separate User and Admin dashboards.
- Implemented JWT Authentication and Role-Based Access Control.
- Built live parking occupancy updates using Socket.IO.
- Developed parking reservation and release workflow with automatic parking fee calculation.
- Created admin analytics dashboard displaying occupancy and revenue reports.
- Integrated MongoDB Atlas cloud database and prepared the application for online deployment.

## Future Scope

- Real payment gateway verification
- QR-based entry and exit
- Sensor-based spot detection
- Push notifications
- Mobile app release
- Advanced analytics

