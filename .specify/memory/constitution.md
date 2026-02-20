<!--
  SYNC IMPACT REPORT
  ==================
  Version Change: N/A → 1.0.0 (Initial adoption)
  
  Modified Principles: None (initial version)
  
  Added Sections:
  - Core Principles (5 principles)
  - Mandatory UI Features
  - Standard Chatbot Behaviors
  - Governance
  
  Removed Sections: None (initial version)
  
  Templates Status:
  - ✅ plan-template.md - Compatible (Constitution Check section exists)
  - ✅ spec-template.md - Compatible (Requirements structure aligns)
  - ✅ tasks-template.md - Compatible (Phase structure supports principles)
  
  Follow-up TODOs: None
-->

# AI Chatbot Mobile Frontend Constitution

**Scope**: Android and iOS Mobile Application  
**Authority**: This constitution is BINDING and MUST NOT omit, reinterpret, or weaken any requirement.

## Purpose

1. The system SHALL implement a mobile (Android/iOS) frontend for an AI Chatbot.
2. The backend APIs, behavior, and response formats already exist and MUST be used exactly as-is.
3. The mobile application SHALL act strictly as a client interface.
4. The goal SHALL be to replicate the current web chatbot behavior on mobile devices.

## Core Principles

### I. Backend API Compliance (NON-NEGOTIABLE)

All API integrations MUST follow the exact backend contract. The mobile app is a client—no backend modifications are permitted.

**Base URL**: MUST be configurable (e.g., `http://<host>:3978`)

**Send Message API**:
- Endpoint: `POST /api/chat`
- Request body MUST contain: `message`, `userId`, `conversationId`, `targetApp`
- MUST be called when user presses Send
- Response SHALL be streamed (Server-Sent Events style)
- App MUST continuously read stream until completion

**Load Chat History**:
- Endpoint: `GET /api/chat/history/{userId}`
- MUST be called when chat screen opens
- MUST display previous conversation messages

**Clear Chat / New Session**:
- MUST generate new UUID as `conversationId`
- MUST clear UI messages
- MUST start fresh conversation
- Changing `targetApp` MUST create new `conversationId`

### II. Session Isolation (NON-NEGOTIABLE)

Sessions MUST be completely isolated to prevent message mixing across conversations.

**conversationId Rules**:
- MUST be generated on first chat
- MUST be persisted locally
- MUST be recreated when: User taps "New Chat" OR User switches target application

**Isolation Requirements**:
- Messages from different sessions MUST NOT mix
- New `conversationId` MUST isolate future API calls
- Previous conversation MUST NOT affect new chat

**Refresh Behavior**:
- MUST delete all messages from UI
- MUST generate NEW `conversationId` (UUID)
- MUST discard previous session history locally
- MUST NOT resend the last message
- MUST NOT automatically call Send Message API
- Selected `targetApp` MUST remain unchanged unless user changes it

### III. Streaming-First UI (NON-NEGOTIABLE)

All response handling MUST implement proper streaming behavior with correct UI state management.

**Streaming Rules**:
- Response SHALL arrive in small chunks
- Each chunk SHALL contain partial answer text
- UI MUST progressively append text to the SAME bot message bubble
- App MUST NOT create multiple bot messages during streaming
- When stream ends, message MUST be marked as completed

**While Backend is Generating**:
- MUST show typing indicator ("Searching…" or "Thinking…")
- MUST disable send button
- MUST show Pause button

**When Completed**:
- MUST hide typing indicator
- MUST enable send button
- MUST display response time ("Answered in X seconds")
  - Timer starts when request is sent
  - Timer stops when streaming completes

**Pause/Stop Generation**:
- When user presses Pause: MUST immediately cancel network request
- MUST stop receiving stream
- MUST mark message as "stopped"
- User MUST be allowed to send new message afterward

### IV. Rich Content Rendering (CRITICAL)

Bot responses MAY contain Markdown. All rich content MUST render correctly.

**Required Markdown Support**:
- Headings
- Bold / Italic
- Bullet lists
- Numbered lists
- Links
- Code blocks (with styled container and COPY button)

**SQL Query Handling**:
- MUST detect code block with language "sql"
- MUST show copy button
- MUST preserve formatting exactly
- MUST NOT wrap lines incorrectly

**Table Handling**:
- MUST render Markdown tables as proper tables
- MUST maintain column alignment
- MUST allow horizontal scroll
- MUST provide "Download as Excel" button with same rows, columns, and headers

**Copy Response**:
- Each bot message MUST support copying entire response to clipboard

### V. Error Resilience (NON-NEGOTIABLE)

The app MUST handle all error conditions gracefully without crashing.

**Required Error Handling**:
- Network failure
- Timeout
- Empty response
- Server error

**User Message**: MUST display "Something went wrong. Please try again."

**Critical Rule**: The app MUST NOT crash under any circumstances.

## Mandatory UI Features

The chat screen MUST include ALL of the following:

| Feature | Requirement |
|---------|-------------|
| Message input box | Text entry for user messages |
| Send button | Triggers message submission |
| Typing indicator | Shows "Searching…" or "Thinking…" during processing |
| New session button | Creates fresh conversation |
| Pause generation button | Stops ongoing stream |
| Rephrase button | Allows message re-submission |
| Copy response button | Copies bot response to clipboard |
| Response time indicator | Shows "Answered in X seconds" |
| Target application selector | Dropdown/list (e.g., STS_LP, TMS, QMS) |

## Standard Chatbot Behaviors

The mobile app MUST implement these baseline behaviors:

- Maintain correct message order
- NOT duplicate bot messages
- NOT mix messages from different sessions
- Allow scrolling to previous messages
- Auto-scroll to newest message
- Preserve chat history on reopen

## Governance

This constitution supersedes all other development practices for the AI Chatbot Mobile Frontend project.

**Amendment Process**:
1. All changes MUST be documented with rationale
2. Version MUST be incremented according to semantic versioning:
   - MAJOR: Backward incompatible governance/principle changes
   - MINOR: New principle/section added or materially expanded
   - PATCH: Clarifications, wording, typo fixes
3. Migration plan MUST be provided for breaking changes

**Compliance**:
- All PRs/code reviews MUST verify compliance with this constitution
- Non-compliance MUST be flagged and resolved before merge
- Any deviation from principles MUST be explicitly justified and documented

**Version**: 1.0.0 | **Ratified**: 2026-02-13 | **Last Amended**: 2026-02-13
