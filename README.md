# SCA — Simple - Chat - App 

An opensource project for simple chatting

## Introduction

This project is a real-time chat application designed with simplicity, accessibility, and privacy in mind, making it especially suitable for beginner-level users. The app allows users to log in using their mobile numbers and view a list of currently available users. When two users are online simultaneously, they can communicate instantly through text messages. To maintain privacy and reduce server dependency, all chat data is stored locally on the users’ devices rather than on a central server.
The application is built using Flutter for the frontend, providing a responsive and cross-platform user interface, while Hive is used as the local storage solution for efficiently managing chat data on the device. The backend is developed with Python using FastAPI, which handles user connectivity and real-time communication logic.
For deployment and online accessibility, the backend is hosted on the free hosting tier of Render.com. This setup enables the system to run without infrastructure costs during development while still supporting live user interaction.
Overall, the project demonstrates how a lightweight, privacy-focused chat system can be built using modern development tools, combining real-time communication with local data storage and minimal server reliance.

## 🧩 Tech Stack
Frontend

* Flutter (cross-platform mobile UI framework)

* Hive (local database for chat storage)

## Backend

* Python WebSocket server built with FastAPI

* Real-time connection and presence tracking

* Hosted on free tier of Render.com

## ✨ Features

* 📲 Login using mobile number

* 🟢 Real-time online user presence

* 💬 Instant text messaging (online users only)

* 🔒 Messages stored only on user devices

* 💓 Heartbeat system to detect inactive users

* 🧹 Automatic cleanup of disconnected users

* 📡 Manual and automatic online user updates

* 🩺 Health check endpoint for deployment monitoring

## 🧠 System Architecture

The application follows a minimal server dependency model:

* 1. The mobile app connects to the backend using WebSockets.

* 2. The server maintains active connections in memory.

* 3. Users can see who is currently online.

* 4. Messages are delivered directly if the recipient is connected.

* 5. Messages are stored locally using Hive.

* 6. If a user disconnects or stops sending heartbeats, they are removed automatically.

The server does NOT store:

* Chat history

* User profiles

* Message logs

## 🔌 WebSocket Endpoint
> /ws/{mobile}
Each user connects using their mobile number.

# Mobile Validation

* Must contain only digits

* Minimum length: 10

Invalid numbers are rejected.

## 📡 WebSocket Message Types
# 1️⃣ Heartbeat
Keeps the connection alive.
# Client → Server
> { "type": "ping" }
# Server → Client
> { "type": "pong" }

# 2️⃣ Request Online Users
Client can request the current online list.
# Client → Server
> { "type": "get_online_users" }
# Server → Client
> {
  "type": "online_users",
  "users": ["mobile1", "mobile2"]
}

# 3️⃣ Send Message
Send a text message to another online user.
# Client → Server
> { "type": "message","to": "recipient_mobile","text": "Hello!"}
# Server → Recipient
> {"type": "message","from": "sender_mobile","text": "Hello!"}

# 4️⃣ Automatic Presence Broadcast
Whenever a user connects or disconnects, all users receive:
> {
 "type": "online_users",
  "users": [...]
}

# ⏱ Connection Management
The server tracks activity timestamps for each connection.
| Parameter        | Value      | Purpose                   |
| ---------------- | ---------- | ------------------------- |
| Ping Timeout     | 60 seconds | Disconnect inactive users |
| Cleanup Interval | 30 seconds | Background cleanup check  |
Inactive users are automatically removed and presence is updated.

# 🧹 Background Cleanup Task
Runs continuously to:
* Detect users who stopped sending heartbeats

* Remove stale connections

* Broadcast updated online list
Designed to work safely on cloud hosting environments.

# 🩺 Health Check Endpoint
> GET /health
# Response
> {
  "status": "ok",
  "connections": 3
}

Useful for:

* Deployment monitoring

* Uptime checks

* Debugging connection count

# 🚀 Deployment
The backend is deployed using a cloud hosting platform free tier.
Typical deployment steps:
* Create web service
* Install dependencies
* Run FastAPI server
* Expose WebSocket endpoint
* Monitor health endpoint

# 🔐 Privacy Model
This project is designed with privacy-first principles:
✔ No server-side message storage
✔ No database required
✔ No chat history retention
✔ Device-only storage
✔ Minimal metadata handling

# 📈 Limitations
* Messages delivered only when both users are online
* No offline message queue
* In-memory connection storage (not persistent across restarts)
* Single server instance recommended for current design

# 📜 License
Open for learning and educational use.
