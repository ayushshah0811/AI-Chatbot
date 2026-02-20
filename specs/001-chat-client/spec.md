# Feature Specification: Mobile Chat Client

**Feature Branch**: `001-chat-client`  
**Created**: 2026-02-13  
**Status**: Draft  
**Input**: User description: "Mobile chat client interface for AI chatbot with streaming responses, markdown rendering, and multi-app support"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Send Message and Receive Streaming Response (Priority: P1)

As a user, I want to type a message and see the AI's response appear progressively in real-time, so I know the system is actively working and can start reading immediately.

**Why this priority**: This is the core functionality of a chatbot. Without message sending and streaming response display, the app has no value.

**Independent Test**: Can be fully tested by sending any message and verifying the response streams character-by-character into a single message bubble while showing a typing indicator.

**Acceptance Scenarios**:

1. **Given** the chat screen is open, **When** user types a message and taps Send, **Then** the message appears in the chat as a user bubble and a typing indicator ("Searching..." or "Thinking...") appears.
2. **Given** a message has been sent, **When** the backend starts streaming the response, **Then** text progressively appears in a SINGLE bot message bubble (not multiple bubbles).
3. **Given** streaming is in progress, **When** the stream completes, **Then** the typing indicator disappears, Send button is re-enabled, and "Answered in X seconds" is displayed.
4. **Given** streaming is in progress, **When** the user taps Pause, **Then** streaming stops immediately, partial response is preserved, and user can send a new message.

---

### User Story 2 - View and Continue Chat History (Priority: P2)

As a user, I want my previous conversations to be preserved and displayed when I reopen the app, so I can continue where I left off.

**Why this priority**: Session continuity is essential for practical use—users expect to reference prior conversations.

**Independent Test**: Can be tested by sending messages, closing the app, reopening it, and verifying all previous messages appear in correct order.

**Acceptance Scenarios**:

1. **Given** user has prior chat history, **When** the chat screen opens, **Then** previous messages load and display in chronological order.
2. **Given** chat history is loaded, **When** user scrolls up, **Then** older messages are visible and scrolling is smooth.
3. **Given** new messages arrive, **When** user is at the bottom of chat, **Then** the view auto-scrolls to show the newest message.

---

### User Story 3 - Switch Target Application (Priority: P2)

As a user, I want to select which backend application I'm chatting with (STS_LP, TMS, QMS, etc.), so I can get context-specific responses.

**Why this priority**: Multi-app support is a core differentiator; users need to chat within the correct application context.

**Independent Test**: Can be tested by switching the target app dropdown and verifying a new conversation starts with that app context.

**Acceptance Scenarios**:

1. **Given** the chat screen is open, **When** user taps the target application selector, **Then** a list of available applications appears (STS_LP, TMS, QMS, etc.).
2. **Given** user selects a different target application, **When** selection is confirmed, **Then** a NEW conversation starts (new conversationId), previous chat is cleared, and all future messages use the new targetApp.
3. **Given** user is in an active conversation, **When** user switches target app, **Then** the previous conversation is NOT mixed with the new one.

---

### User Story 4 - Start New Chat Session (Priority: P3)

As a user, I want to start a fresh conversation at any time, so I can ask unrelated questions without prior context affecting responses.

**Why this priority**: Important for user control, but less critical than core messaging and app switching.

**Independent Test**: Can be tested by tapping "New Chat" button and verifying chat clears and a new conversation begins.

**Acceptance Scenarios**:

1. **Given** an active conversation exists, **When** user taps the New Chat/Refresh button, **Then** all messages are cleared from the UI and a new conversationId is generated.
2. **Given** a new session is started, **When** user sends a message, **Then** the message uses the new conversationId and previous context is not sent.
3. **Given** session is refreshed, **When** looking at the UI, **Then** the selected targetApp remains unchanged unless user changes it.

---

### User Story 5 - View Rich Content (Markdown, Tables, Code) (Priority: P3)

As a user, I want bot responses with formatted text, code blocks, and tables to render properly, so I can read structured information clearly.

**Why this priority**: Essential for data-heavy responses but builds on core messaging functionality.

**Independent Test**: Can be tested by requesting responses that contain markdown formatting, SQL queries, and tables, then verifying proper rendering.

**Acceptance Scenarios**:

1. **Given** a bot response contains markdown (headings, bold, italic, lists, links), **When** displayed, **Then** formatting renders correctly.
2. **Given** a bot response contains a code block (especially SQL), **When** displayed, **Then** code appears in a styled block with a Copy button that preserves exact formatting.
3. **Given** a bot response contains a markdown table, **When** displayed, **Then** table renders with proper columns, horizontal scrolling is available, and a "Download as Excel" button appears.

---

### User Story 6 - Copy and Rephrase Responses (Priority: P4)

As a user, I want to copy bot responses to my clipboard and rephrase my questions, so I can share information and refine my queries.

**Why this priority**: Convenience features that enhance usability but are not blocking for MVP.

**Independent Test**: Can be tested by tapping Copy button on a bot response and verifying clipboard contains the text; tapping Rephrase and verifying message re-sends.

**Acceptance Scenarios**:

1. **Given** a bot response is displayed, **When** user taps Copy button, **Then** the entire response text is copied to clipboard.
2. **Given** a user message exists, **When** user taps Rephrase, **Then** a mechanism allows the user to re-submit or edit the message.

---

### Edge Cases

- What happens when the network disconnects mid-stream? → Stream stops, partial response is preserved with "stopped" indicator, user sees error message and can retry.
- What happens when backend returns an empty response? → Display user-friendly message "Something went wrong. Please try again."
- What happens when the backend is unreachable? → Display "Something went wrong. Please try again." without crashing.
- What happens when user rapidly sends multiple messages? → Send button is disabled during streaming; only one message processed at a time.
- What happens when response contains malformed markdown? → Gracefully degrade to plain text display rather than crash.

## Requirements *(mandatory)*

### Functional Requirements

**Chat Interface**
- **FR-001**: App MUST provide a message input box and Send button.
- **FR-002**: App MUST display messages in chronological order with clear user/bot distinction.
- **FR-003**: App MUST auto-scroll to the newest message when new content arrives.
- **FR-004**: App MUST allow scrolling to view previous messages.

**API Integration**
- **FR-005**: App MUST call `POST /api/chat` with body `{message, userId, conversationId, targetApp}` when user sends a message.
- **FR-006**: App MUST support Server-Sent Events (SSE) style streaming for responses.
- **FR-007**: App MUST call `GET /api/chat/history/{userId}` when chat screen opens to load history.
- **FR-008**: App MUST use a configurable base URL for all API calls.

**Session Management**
- **FR-009**: App MUST generate a UUID for conversationId on first chat.
- **FR-010**: App MUST persist conversationId locally across app restarts.
- **FR-011**: App MUST generate a NEW conversationId when user taps "New Chat".
- **FR-012**: App MUST generate a NEW conversationId when user switches target application.
- **FR-013**: App MUST NOT mix messages from different conversationIds.

**Streaming Behavior**
- **FR-014**: App MUST progressively display response text as stream chunks arrive.
- **FR-015**: App MUST update a SINGLE message bubble during streaming (NOT create multiple bubbles).
- **FR-016**: App MUST display a typing indicator ("Searching..." or "Thinking...") while waiting/streaming.
- **FR-017**: App MUST disable Send button during streaming.
- **FR-018**: App MUST show a Pause button during streaming that cancels the request.
- **FR-019**: App MUST track and display response time as "Answered in X seconds" upon completion.

**Markdown Rendering**
- **FR-020**: App MUST render markdown: headings, bold, italic, bullet lists, numbered lists, links.
- **FR-021**: App MUST render code blocks with copy functionality.
- **FR-022**: App MUST detect SQL code blocks and preserve exact formatting with copy button.
- **FR-023**: App MUST render markdown tables with proper column alignment and horizontal scroll.
- **FR-024**: App MUST provide "Download as Excel" button for tables.

**UI Controls**
- **FR-025**: App MUST provide a New Session/Refresh button that clears chat and generates new conversationId.
- **FR-026**: App MUST provide a target application selector (dropdown/list) with options like STS_LP, TMS, QMS.
- **FR-027**: App MUST provide a Copy button for each bot response.
- **FR-028**: App MUST provide a Rephrase button for user messages.

**Error Handling**
- **FR-029**: App MUST gracefully handle network failures, timeouts, and empty responses.
- **FR-030**: App MUST display user-friendly error message: "Something went wrong. Please try again."
- **FR-031**: App MUST NOT crash under any error condition.

**Data Persistence**
- **FR-032**: App MUST preserve chat history on app reopen.
- **FR-033**: App MUST NOT duplicate messages in history.
- **FR-034**: App MUST maintain correct message order across sessions.

### Key Entities

- **Message**: Represents a single chat message; key attributes: id, content, sender (user/bot), timestamp, conversationId, status (sending/complete/stopped)
- **Conversation**: Represents a chat session; key attributes: conversationId (UUID), userId, targetApp, createdAt, messages
- **TargetApplication**: Represents a backend application context; key attributes: name (STS_LP, TMS, QMS, etc.), displayLabel

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can send a message and see streaming response begin within 2 seconds of tapping Send.
- **SC-002**: Streamed responses display progressively with no visible lag or jitter during normal network conditions.
- **SC-003**: Chat history loads completely within 3 seconds of opening the chat screen.
- **SC-004**: 100% of markdown elements (headings, lists, code, tables) render correctly without raw syntax visible.
- **SC-005**: Users can successfully copy code blocks and bot responses to clipboard on first attempt.
- **SC-006**: Target application switching creates a new session within 1 second with no message carryover.
- **SC-007**: App recovers gracefully from network errors with no crashes and displays error message within 3 seconds.
- **SC-008**: Downloaded Excel files from tables contain identical data with matching rows, columns, and headers.

## Assumptions

- Backend API at configurable base URL (e.g., `http://<ip>:3978`) is always available and returns responses in documented format.
- userId is available/generated by the app (mechanism not specified—assumed to be device-based UUID).
- Target applications list (STS_LP, TMS, QMS, etc.) is static or provided by the app configuration.
- SSE streaming format follows standard conventions (text/event-stream with data: prefixed lines).
- Mobile device has standard clipboard access APIs available.
