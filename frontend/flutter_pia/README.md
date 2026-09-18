# CreatingWings — Flutter

Flutter port of the HTML screen template. Same layout, colors (light blue + white,
wavy texture), copy, and flows.

## Screens
| File | Template screen |
|------|-----------------|
| `lib/screens/splash_screen.dart` | Screen 3 — 5-second black disclaimer, then routes to chat |
| `lib/screens/chat_screen.dart` | Screens 1 & 4 — chat, logo header, chatbar, exclamation button |
| `lib/screens/emergency_screen.dart` | Screen 2 — emergency alert dialog + Quick Exit |
| `lib/screens/menu_sheet.dart` | Screen 4 — overflow menu (Resources Options, Safety Plan, Progress Indicator, Account Information) |
| `lib/theme.dart` | Shared colors + text styles |
| `lib/widgets/wave_background.dart` | Reusable wavy texture (CustomPainter) |

## Run
```bash
flutter create .      # generate android/ ios/ platform folders in this dir
flutter pub get
flutter run
```

## Flow wiring
- App launches on the **splash**, which auto-advances to the **chat** after 5s.
- Tapping the **!** button opens the **emergency** dialog.
- Tapping the header **⋮** opens the **menu**.
- **Call 911 / Text a Trusted Person / Open Safety Plan** and the menu items have
  empty `onTap`/`onPressed` handlers — wire them to your real routes/services.

## Notes
- Fonts: install Manrope via `pubspec.yaml` (instructions inline) for an exact match;
  otherwise it falls back to the platform default.
- The wavy texture is drawn with a `CustomPainter` (no SVG dependency).
- All tokens live in `theme.dart` — change `AppColors.accent` to re-theme.
