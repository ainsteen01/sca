# 💬 SCA — Simple Chat App

**An open-source project for simple, private chatting.**
*Data lives on your device. The server is just a real-time switchboard.*

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.95+-green?logo=fastapi)](https://fastapi.tiangolo.com)

---

## 📋 Introduction

SCA is a real-time chat application built with simplicity, accessibility, and privacy in mind. It's particularly suitable for beginners or anyone who wants a lightweight messaging system without centralized data collection.

### How it works

* Log in using your mobile number
* See who's currently online
* Send instant text messages to online users
* All chat history is stored **only on your device** (no server-side logs)

The project demonstrates how to build a privacy-focused communication tool using modern frameworks: **Flutter** for the frontend, **Hive** for local storage, and **FastAPI WebSockets** for real-time backend communication.

---

## 🧩 Tech Stack

| Area         | Technology         | Purpose                                  |
| ------------ | ------------------ | ---------------------------------------- |
| **Frontend** | Flutter            | Cross-platform mobile UI (iOS/Android)   |
| **Local DB** | Hive               | Lightweight NoSQL storage for messages   |
| **Backend**  | Python + FastAPI   | WebSocket server & connection management |
| **Hosting**  | Render (Free Tier) | Cloud deployment                         |

---

## ✨ Features

* **📲 Mobile Login** – Simple authentication using 10+ digit mobile numbers
* **🟢 Live Presence** – See which users are online in real time
* **💬 Instant Messaging** – Send/receive text messages instantly (online users only)
* **🔒 Privacy First** – Messages stored **only on your device** using Hive
* **💓 Heartbeat System** – Keeps connections alive and detects inactive users
* **🧹 Auto Cleanup** – Stale connections removed automatically
* **📡 Presence Broadcasts** – Online list updates automatically when users join/leave
* **🩺 Health Check** – Monitoring endpoint for deployment

---

## 🧠 System Architecture

The application follows a **minimal server dependency model**.

```
Mobile App  ←→  WebSocket Server  ←→  Mobile App
     |                                   |
     └──────── Local Chat Storage ───────┘
```

### 🔄 Communication Flow

1. Mobile app connects to the backend via WebSockets
2. Server stores active user connections in memory
3. Users can view who is currently online
4. Messages are delivered instantly if recipient is connected
5. Messages are saved locally using Hive
6. Inactive users are automatically removed

---

### 🚫 What the Server Does NOT Store

* Chat history
* User profiles
* Message logs
* Databases

The server acts only as a **live message router**.

---

## 🔌 WebSocket Endpoint

```
/ws/{mobile}
```

Each user connects using their mobile number.

---

### 📱 Mobile Validation Rules

| Rule           | Requirement         |
| -------------- | ------------------- |
| Format         | Digits only         |
| Minimum length | 10                  |
| Invalid input  | Connection rejected |

---

## 📡 WebSocket Message Types

### 💓 Heartbeat (Keep Connection Alive)

**Client → Server**

```json
{ "type": "ping" }
```

**Server → Client**

```json
{ "type": "pong" }
```

---

### 🟢 Request Online Users

**Client → Server**

```json
{ "type": "get_online_users" }
```

**Server → Client**

```json
{
  "type": "online_users",
  "users": ["mobile1", "mobile2"]
}
```

---

### 💬 Send Message

**Client → Server**

```json
{
  "type": "message",
  "to": "recipient_mobile",
  "text": "Hello!"
}
```

**Server → Recipient**

```json
{
  "type": "message",
  "from": "sender_mobile",
  "text": "Hello!"
}
```

---

### 🔄 Automatic Presence Broadcast

Sent to all users whenever someone connects or disconnects.

```json
{
  "type": "online_users",
  "users": [...]
}
```

---

## ⏱ Connection Management

The server monitors user activity using timestamps.

| Parameter        | Value      | Purpose                   |
| ---------------- | ---------- | ------------------------- |
| Ping Timeout     | 60 seconds | Disconnect inactive users |
| Cleanup Interval | 30 seconds | Background cleanup cycle  |

Inactive users are removed automatically and presence is updated.

---

## 🧹 Background Cleanup Task

Runs continuously to:

* Detect users who stopped sending heartbeats
* Remove stale connections
* Broadcast updated online users

Designed for safe operation in cloud hosting environments.

---

## 🩺 Health Check Endpoint

```
GET /health
```

### Example Response

```json
{
  "status": "ok",
  "connections": 3
}
```

### Useful For

* Deployment monitoring
* Uptime checks
* Debugging active connections

---

## 🚀 Deployment

Typical deployment flow:

1. Create cloud web service
2. Install dependencies
3. Start FastAPI server
4. Expose WebSocket endpoint
5. Monitor health endpoint

---

## 🔐 Privacy Model

> 🛡 Built with privacy by design

✔ No server-side message storage
✔ No database required
✔ No message retention
✔ Device-only chat storage
✔ Minimal metadata usage

---

## 📈 Limitations

* Messages delivered only when both users are online
* No offline message queue
* In-memory connections reset on server restart
* Single server instance recommended

---

## 🎯 Learning Value

This project demonstrates:

* WebSocket real-time communication
* Presence tracking systems
* Local storage architecture
* Stateless backend design
* Connection lifecycle management
* Cloud deployment fundamentals

---

## 📜 License

MIT License — open for learning, experimentation, and educational use.
