---
name: gog
description: Google Calendar (and Gmail/Drive/Contacts/Sheets/Docs) via the gog CLI (gogcli). Use for agenda, event search, create/update/delete, and calendar colors. Always confirm before any write.
metadata: {"openclaw":{"emoji":"📅","requires":{"bins":["gog"]}}}
---

# gog

Use the `gog` binary (gogcli) for Google Calendar and other Google Workspace services. Config: `~/.config/gogcli/config.json`. OAuth is required; use `gog auth add <email>` and `gog auth list` to manage accounts.

## Global flags (apply to most commands)

- `-a, --account=STRING` — Account email for API commands
- `-j, --json` — Output JSON (best for scripting)
- `-p, --plain` — Stable parseable text (TSV; no colors)
- `--no-input` — Never prompt; fail instead (for automation)
- `-n, --dry-run` — Do not make changes; print intended actions
- `-y, --force` — Skip confirmations for destructive commands

Prefer `--plain` for read-only listing; use `--json` when aggregating or when exact fields matter.

## Auth (one-time setup)

- List accounts: `gog auth list`
- Add account: `gog auth add <email>`
- Auth status: `gog auth status`
- Credentials: `gog auth credentials` (manage OAuth client credentials)

## Calendar — list calendars and events

- List calendars: `gog calendar calendars [flags]` — use `--json` or `--plain`, `--max=100`, `--all`
- List events: `gog calendar events [<calendarId>] [flags]`
  - Default calendarId is primary. Omit for primary, or use `--all` for all calendars.
  - Time range: `--from=STRING` and `--to=STRING` (RFC3339, or relative: today, tomorrow, monday)
  - Shortcuts: `--today`, `--tomorrow`, `--week`, `--days=N`
  - `--max=10`, `--query=STRING` (free text), `--all` (all calendars)
  - Example: `gog calendar events --all --from today --to tomorrow --plain`
- Get one event: `gog calendar event <calendarId> <eventId>`
- Calendar colors: `gog calendar colors` — event color IDs 1–11 for `--event-color`

## Calendar — search

- Search events: `gog calendar search <query> [flags]`
  - `--calendar=primary` (or calendar ID), `--from`, `--to`, `--today`, `--tomorrow`, `--week`, `--days=N`, `--max=25`

## Calendar — create event

- Create: `gog calendar create <calendarId> [flags]`
  - Required: `--summary=STRING`, `--from=STRING`, `--to=STRING` (RFC3339 or date-only for all-day)
  - Optional: `--description=STRING`, `--location=STRING`, `--attendees=STRING` (comma-separated emails)
  - `--all-day` — all-day event (use date-only in --from/--to)
  - `--event-color=STRING` — color ID 1–11 (see `gog calendar colors`)
  - `--rrule=RRULE,...` — recurrence (e.g. RRULE:FREQ=WEEKLY;BYDAY=MO,WE)
  - `--reminder=REMINDER,...` — e.g. popup:30m, email:1d (max 5)
  - `--with-meet` — add Google Meet link
  - Example: `gog calendar create primary --summary "Team standup" --from 2026-02-25T09:00:00Z --to 2026-02-25T09:30:00Z`

## Calendar — update event

- Update: `gog calendar update <calendarId> <eventId> [flags]`
  - Same flags as create: `--summary`, `--from`, `--to`, `--description`, `--location`, `--attendees`, `--event-color`, etc.
  - For recurring: `--scope=all|single|future`, `--original-start=STRING` (for single/future)

## Calendar — delete and RSVP

- Delete: `gog calendar delete <calendarId> <eventId> [flags]` — `--scope=all|single|future`, `--send-updates=all|externalOnly|none`
- Respond to invitation: `gog calendar respond <calendarId> <eventId> [flags]` (rsvp/reply)

## Other calendar commands

- Free/busy: `gog calendar freebusy <calendarIds> [flags]`
- Conflicts: `gog calendar conflicts [flags]`
- Focus time: `gog calendar focus-time --from=STRING --to=STRING [<calendarId>]`
- Out of office: `gog calendar out-of-office --from=STRING --to=STRING [<calendarId>]`
- Working location: `gog calendar working-location --from=STRING --to=STRING --type=STRING [<calendarId>]` (type: home/office/custom)

## Behaviour

- For any calendar write (create/update/delete/RSVP): summarise the exact action first, get explicit "yes", then execute.
- Filter holiday/noise calendars from results by default unless the user asks for them (e.g. exclude calendars whose name contains "holiday", "holidays").
- Set `GOG_ACCOUNT=you@gmail.com` in the environment to avoid repeating `--account`.
