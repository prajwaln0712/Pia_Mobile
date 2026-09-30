# Wire ChatScreen to the real backend (pia1.0)

**Status:** Implemented (code changes landed, `flutter analyze` clean). On-device verification (steps 2–7 below) not yet run.

## Context

The Flutter app was shipping with `AboutScreen` as a temporary placeholder `home:` (the real Splash → Chat flow was fully built but disconnected via a commented-out import in `main.dart`). Separately, `ChatScreen` — the actual product screen — was a static mockup: a hardcoded 5-message thread, a composer with no controller, and a send button with no tap handler. The only backend call anywhere in the app was `getUser()`, and it pointed at an unconfirmed ALB hostname.

The real backend (`https://github.com/Creating-Wings-Co/pia1.0`) is a working FastAPI + MongoDB + Auth0 + Gemini RAG chatbot with a confirmed API contract (verified against its `main.py` / `database.py` / `auth0_utils.py` and cross-checked against its own React client's `.env.example`). This work makes the chat screen real: reachable, backed by live send/receive, and correctly identifying the user (anonymous guest or real Auth0 login).

**Explicitly out of scope for this pass** (moving to other screens later): `menu_sheet.dart`'s 4 items and `emergency_screen.dart`'s 3 action buttons are untouched.

## Findings that shaped the plan

- `auth_service.dart` was **not** commented out — Auth0 code was fully live. The thing disabling it was `main.dart`: the `splash_screen.dart` import and `home: SplashScreen()` were commented out, with `AboutScreen` as `home`. "Uncommenting Auth0" therefore meant restoring navigation, not editing `auth_service.dart`.
- `backend/main.py` inside this repo is a 2-line unparseable stub. The real backend lives in the separate `pia1.0` repository; that is the source of truth for endpoints.
- The base URL hardcoded in `api_service.dart` (`http://chatbot-backend-alb-1820253308.us-east-1.elb.amazonaws.com/`) is not recorded anywhere in the backend repo. The one confirmed production origin is `https://chat.creatingwings.org` (from the backend's React client `.env.example`).
- The backend has **no** endpoints for Resources, Safety Plan, Progress Indicator, trusted contacts, or profile update. Only chat, user, and auth endpoints exist. Those menu/emergency buttons therefore cannot be API-wired yet.
- `/api/chat` requires an existing DB user (404 otherwise), so identity resolution (anonymous or logged-in + registered) is a prerequisite for chat.

## Backend contract being integrated against

Base URL: `https://chat.creatingwings.org` (Auth0 audience `https://chat.creatingwings.org/api` already matches `auth_service.dart`).

| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST | `/api/auth/callback` | none | `{sub, name, email, income_range?, employment_status?, marital_status?, education?, location?, acceptedTerms=true, is18OrOlder=true}` | `200 {user_id, name, email}` — **upserts** the user by Auth0 `sub` |
| POST | `/api/user/anonymous` | none | — | `200 {user_id, name: "Guest User", email}` — creates a guest (`auth0_sub = "anonymous_<hex12>"`) |
| GET | `/api/user/me` | Bearer JWT | — | `200` full profile; `404` if the sub has no DB row |
| POST | `/api/chat` | optional | `{user_id, conversation_id?, message}` | `200 {response, conversation_id, escalate, escalation_type}`; `400` no usable user_id, `404` user not found |
| POST | `/api/chat/stream` | optional | same as `/api/chat` | SSE stream (not used in this pass) |
| GET / DELETE | `/api/conversation/{user_id}/{conversation_id}` | Bearer JWT | — | conversation history / delete (not used in this pass) |
| GET | `/health`, `/api/health` | none | — | health status |

Behavior that matters for the client:

- **One rolling conversation per user.** `database.py` keys chats by `auth0_sub` only (capped at 15 messages). `conversation_id` is accepted and echoed but does not separate threads.
- **No history-fetch endpoint** usable for the chat UI — conversation content only reaches the client as the `response` echo, so identity switches cannot restore old threads.
- **Bearer fallback is safe.** If a Bearer token is present but its `sub` has no DB record, the server ignores it and uses the body `user_id`. This is the safety net for "logged in but callback sync failed".
- **Auth:** RS256 JWT via Auth0 JWKS, issuer `https://{AUTH0_DOMAIN}/`; audience is checked only when `AUTH0_AUDIENCE` is set server-side.
- `Auth0UserInfo` requires non-null `name` and `email`; sending null returns 422.
- `escalate` / `escalation_type` (`DANGER` / `ABUSE` / `SENSITIVE`) come back in the chat response as canned advisory text, not structured data. Not given special UI in this pass.

## Design decisions

1. **`login()` returns the full `Credentials`** (auth0_flutter's own type) instead of just the token string, so the caller can build the registration body from `credentials.user`. No mapping layer is warranted — the codebase already instantiates both services directly in `ChatScreen`.
2. **Orchestration lives in `ChatScreenState`**, not `AuthService` or a new controller. `ApiService` already depends on `AuthService` for its token interceptor, so making `AuthService` depend on `ApiService` would be circular. A new controller would need both injected anyway and remove no complexity for a single-screen app. The logic is split into small private methods (`_login`, `_ensureUserId`, `_resolveUserId`, `_onSend`) so extraction later is easy.
3. **Anonymous user id is persisted** in secure storage under `anonymous_user_id`, mirroring `access_token` / `user_id`, so a guest keeps the same backend identity across restarts. It is **not** cleared on `logout()` — logging out returns the user to their prior guest identity.
4. **Identity resolution is memoized** (`_userIdFuture ??= _resolveUserId()`) so rapid double-taps on send cannot each call `POST /api/user/anonymous` and mint orphaned guest accounts.
5. **Identity is resolved before the optimistic user bubble is added**, so a failed resolution never leaves a "sent" message that never reached the server.
6. **On login, the session resets** (`_conversationId = null`, messages back to the greeting) — there is no endpoint to fetch or merge the old anonymous thread, so leaving old bubbles would misrepresent server state.
7. **Non-streaming `/api/chat`** for this pass. Dio has no first-class SSE support; `/api/chat/stream` would need manual chunk parsing. Streaming is a valid future enhancement.
8. **Error handling keeps the existing style**: `print()` + return `null` in `ApiService`, `_show()` SnackBar in the screen. No Result/Either type, no retry affordance this pass.
9. **Mock thread trimmed to the single real greeting.** The other four `kSampleThread` lines were fake demo Q&A and would look like real prior conversation once live.

## Changes

### `lib/main.dart`
- Deleted `lib/screens/about_screen.dart` (referenced nowhere else in `lib/`).
- Removed the `about_screen.dart` import; uncommented the `splash_screen.dart` import.
- `home:` is now `const SplashScreen()`; removed the stale "TEMPORARY" header comment.

### `lib/services/auth_service.dart`
- `login()`: `Future<String?>` → `Future<Credentials?>`; still writes `access_token` / `user_id` to secure storage, now returns `credentials`.
- Added `_anonymousUserIdKey = 'anonymous_user_id'`, `getAnonymousUserId()`, `setAnonymousUserId(String id)`.
- `logout()` unchanged — it only deletes `access_token` / `user_id`, so the anonymous id survives.

### `lib/services/api_service.dart`
- `baseUrl` → `'https://chat.creatingwings.org/'` (also resolves the earlier iOS App Transport Security concern about plaintext HTTP).
- Added, all following the existing `getUser()` try / `on DioException` / `print` / return-`null` pattern:
  - `registerUser({sub, name, email})` → `POST /api/auth/callback`
  - `createAnonymousUser()` → `POST /api/user/anonymous`
  - `sendMessage({userId, conversationId?, message})` → `POST /api/chat`, body `{'user_id', if (conversationId != null) 'conversation_id', 'message'}`
- `getUser()` left in place (unused this pass; useful for a future profile screen).

### `lib/screens/chat_screen.dart`
- Removed `kSampleThread`; added `_kGreeting` and a mutable `_messages` list seeded with it.
- New state: `_userId`, `_conversationId`, `_userIdFuture`, `_sending`, `_composerController` (disposed in a new `dispose()`); existing `_busy` now means "login in flight".
- `_ensureUserId()` / `_resolveUserId()`: logged in → stored real `sub`; else cached anonymous id; else `createAnonymousUser()` and persist it.
- `_loginAndFetchUser` → `_login()`:
  1. If already logged in → `Already signed in`, return.
  2. `credentials = await login()`; `null` → `Login failed`.
  3. Guard null/empty `credentials.user.email` (nullable in the SDK type, required by the backend) → message, return.
  4. `registerUser(sub, name ?? '', email)`; failure → `Signed in, but couldn't sync your profile…`, return (chat keeps working on the anonymous id).
  5. Success → `_userId = sub`, `_conversationId = null`, `_userIdFuture = null`, messages reset to the greeting, `Signed in as <email>`.
- `_onSend()`:
  1. Guard empty text / already sending; `_sending = true`.
  2. `userId = await _ensureUserId()`; `null` → `Could not start a session. Check your connection.`
  3. Append the user bubble, clear the controller.
  4. `sendMessage(...)`; `null` → `Message failed to send. Please try again.` (bubble stays).
  5. Success → store `conversation_id`, append the bot bubble from `response`.
  6. `finally` → `_sending = false`.
- `build()` iterates `_messages`; `_Composer` and `_SendButton` now take `controller` / `sending` / `onSend` using the same callback-down + busy-bool pattern as `_Header` / `_LoginButton`. `TextField` gets `controller`, `enabled: !sending`, `textInputAction: TextInputAction.send`, `onSubmitted`. `_SendButton` is tappable, disables and shows a spinner while sending.

## Call sequences

**First message, not logged in**

1. Splash (5s) → `pushReplacement` → `ChatScreen`.
2. User taps send / keyboard "send" → `_onSend()`.
3. `_ensureUserId()`: not logged in → no cached anonymous id → `POST /api/user/anonymous` → persist returned `user_id`.
4. User bubble appears; `POST /api/chat {user_id, message}`.
5. Bot bubble appears from `response`; `_conversationId` stored and reused on later sends.

**User taps login mid-conversation**

1. `_login()` → Auth0 web flow → `Credentials`.
2. `POST /api/auth/callback {sub, name, email}` upserts the backend user.
3. Session resets to the greeting under the real `sub`.
4. Next send goes through `_onSend()`; `_ensureUserId()` short-circuits on the stored `sub`.

## Verification checklist

Static check — done:

1. `flutter analyze` — zero errors; remaining infos are pre-existing style lints (`avoid_print`, `prefer_const_constructors`, deprecated `encryptedSharedPreferences`), plus three new `avoid_print` hits on the new API methods, consistent with the existing pattern. No references to `AboutScreen` / `about_screen` / `kSampleThread` remain.

On-device — **still to do**:

2. Launch on emulator/simulator: Splash → Chat (not About); thread starts with only the one greeting bubble.
3. Send a message without logging in: user bubble appears immediately, then a real Gemini-generated reply (anonymous path: `POST /api/user/anonymous` → `POST /api/chat`).
4. Send a second message: reuses the same anonymous identity and `_conversationId` (backend should show one `chats` document, not several).
5. Tap login and complete Auth0: confirm `POST /api/auth/callback` fires (backend logs, or `GET /api/user/me` with the stored token now returns 200 instead of 404); message list resets to the greeting; the next message goes out under the real `sub`.
6. Force a failure (airplane mode / bad URL) mid-send: SnackBar error appears, no crash, no silently vanishing message.
7. Restart the app without logging in: the previously created anonymous `user_id` is reused, not re-minted.

## Deferred / open items

- **`menu_sheet.dart`** — all four items still just close the menu. Only "Account Information" has a backend endpoint (`GET /api/user/me`, read-only; no update endpoint exists). Resources, Safety Plan, and Progress Indicator have no backend support at all.
- **`emergency_screen.dart`** — "Call 911" can be a `tel:` intent via the already-installed `url_launcher`. "Text a Trusted Person" and "Open Safety Plan" have no data source (no trusted-contact field, no safety-plan document anywhere in the backend).
- **Escalation UI** — `escalate` / `escalation_type` are returned but ignored; visual treatment is a follow-up.
- **Streaming** via `/api/chat/stream` (SSE) as a possible upgrade.
- **Auto-scroll** to the newest message (needs a `ScrollController`) — polish, skipped.
- **Retry affordance** for failed sends — skipped.
- **Replace `print()`** with a real logger before release (pre-existing pattern, `avoid_print`).
- **iOS**: bundle-id-based Auth0 callback registration (`CFBundleURLTypes` + dashboard entry) is still required before the login button works on iOS — see the App Store deployment notes.
