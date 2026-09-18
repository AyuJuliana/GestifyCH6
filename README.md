# 🎵 Gestify

Gestify is an AI-powered iOS application that allows users to control music playback using hand gestures. Instead of interacting with buttons on the screen, users can perform simple hand gestures in front of the camera to play, pause, skip, or return to songs.

The application combines Computer Vision, Machine Learning, and Apple's native frameworks to create a more natural and hands-free music control experience.

---

# 💡 Background

Music has become part of my daily activities, whether I am studying, coding, working, or simply relaxing. However, there are many situations where interacting with the phone screen can be inconvenient, such as when cooking, exercising, or focusing on work.

This inspired me to explore how AI could create a more natural way to interact with music. At the same time, I wanted to learn how Machine Learning models can be integrated into a real iOS application using CoreML.

As a result, I built Gestify, an application that uses hand gesture recognition to control music playback through simple and intuitive gestures.

---

# ✨ Features

Control music playback using hand gestures without touching the screen.

| Gesture      | Action        |
| ------------ | ------------- |
| ✋ Open Palm  | Play Music    |
| ✊ Fist       | Pause Music   |
| ✌️ Peace     | Previous Song |
| 🤘 Rock Sign | Next Song     |

### 🤖 Real-Time Gesture Recognition

Recognizes hand gestures directly from the device camera in real time.

### 👋 Hand Detection

Uses Vision Framework to detect and isolate the hand before sending it to the Machine Learning model.

### 📖 Onboarding Experience

Introduces users to available gestures and how they interact with music controls.

### 💡 Contextual Tips with TipKit

Provides lightweight guidance and reminders while users interact with the application.

### ⚙️ Customizable Settings

Allows users to adjust application preferences through selection and input components.

### 🎶 Apple Music Integration

Integrates with Apple Music through MusicKit for seamless playback control.

---

# 🛠️ Technologies & Frameworks

### CoreML

Used to integrate the trained Machine Learning model into the iOS application and perform gesture classification on-device.

### Create ML

Used to train the image classification model with hand gesture datasets.

### Vision Framework

Used to detect and isolate hand regions from the camera feed before classification, improving prediction accuracy.

### AVFoundation

Used to access the device camera and capture real-time video frames.

### MusicKit

Used to connect with Apple Music and control playback actions such as play, pause, next, and previous.

### TipKit

Used to provide contextual guidance and improve user onboarding experience.

### SwiftUI

Used to build the user interface and create a modern, declarative iOS experience.

### Combine

Used to manage state updates and communication between different parts of the application.

The system first detects a hand using Vision Framework, then sends only the hand image to the CoreML model for classification. Once a gesture is recognized with sufficient confidence, the application executes the corresponding music control action.
