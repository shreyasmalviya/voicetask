<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Gemini-8E75B2?style=for-the-badge&logo=googlebard&logoColor=white" />
  <img src="https://img.shields.io/badge/Offline-First-4CAF50?style=for-the-badge&logo=databricks&logoColor=white" />
</div>

<h1 align="center">VoiceTask AI 🎙️</h1>

<p align="center">
  <b>An offline-first, intelligent Kanban task manager that turns your natural speech into perfectly structured tasks.</b><br>
  Built with Flutter and powered natively by the Gemini 2.5 Flash Multi-modal API.
</p>

---

## 🚀 Overview

VoiceTask bypasses traditional, imprecise Speech-to-Text (STT) models by capturing your voice directly as raw uncompressed audio (.wav/pcm) and feeding it natively into Gemini's multi-modal inference engine. This enables the AI to perfectly understand accents, slang, implied priority, and complicated dates with zero intermediate transcription failures.

Once parsed, your tasks are securely saved offline utilizing local Hive storage.

## ✨ Features

- **Direct Audio-to-Task Engine**: Records uncompressed `pcm16bits` audio to eliminate hallucinatory transcripts, pushing direct binary to `gemini-2.5-flash`.
- **Offline-First Architecture**: Completely independent of cloud calendars or user-accounts. Your tasks, habits, and dates live securely on your device via Hive DB.
- **Dynamic Kanban & Dashboards**:
  - **Board View**: A fluid, swipeable `Todo / Active / Done` Kanban layout.
  - **List View**: A vertical scroll clustering tasks dynamically by 'Overdue', 'Today', 'Upcoming', and 'No Date'.
  - **Dashboard View**: Built with `fl_chart`, visualizes a rolling 7-day performance curve and breaks down critical pending vs. completed metrics.
- **Implicit Auto-Saving**: Rapid zero-friction UI that saves details, dates, and priorities instantaneously without "Save" buttons.

## 🛠️ Tech Stack

*   **Framework**: Flutter (Dart)
*   **AI Backend**: Gemini 2.5 Flash via standard `http` requests
*   **Audio Pipeline**: `record` package (`AudioEncoder.wav` @ 16kHz)
*   **State Management**: Riverpod (`flutter_riverpod`)
*   **Local Storage**: `hive` and `hive_flutter`
*   **Analytics**: `fl_chart`

## ⚙️ How to Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/shreyasmalviya/voicetask.git
   cd voicetask
   ```
2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
3. **Add your Gemini API Key:**
   - Head over to `lib/services/gemini_service.dart`.
   - Replace the `YOUR_GEMINI_API_KEY_HERE` string at line 8 with a real key from Google AI Studio.
4. **Build and Run:**
   ```bash
   flutter run
   ```

*(Note: The Android application requires a minimum SDK of 23 to support native audio recording features).*

## 🔒 Security

This application does not collect analytics or pipe your tasks to a backend server. Voice segments are transmitted directly (via HTTPS) strictly to Google's Gemini endpoint and are instantly destroyed locally upon completion. No API keys are visible to the end-user.

---
*Created by [Shreyas Malviya](https://github.com/shreyasmalviya) ✨*
