# go-claudio-go

<img src="bisio.png" alt="go-claudio-go" width="200">


The Official Slack App of the Simpatico Umorista.

Give your colleagues a boost when responding to channels with automated Claude workflows.

Reacts with `:claudio:` to every Slack message that mentions Claude (by name or `@Claude`).

Claudio! Bisio! Che simpatico umoristaaa!

## 1. Create the Slack app

1. Go to <https://api.slack.com/apps> → **Create New App** → **From a manifest**, pick the workspace and paste [manifest.yml](manifest.yml).
2. **Basic Information** → **App-Level Tokens** → **Generate Token and Scopes**, add the `connections:write` scope. Copy the `xapp-…` token.
3. **Install App** → **Install to Workspace**. Copy the **User OAuth Token** (`xoxp-…`).
4. Make sure the `:claudio:` custom emoji exists in the workspace (or set `GO_CLAUDIO_GO_EMOJI` to one that does), otherwise every reaction fails with `invalid_name`.

## 2. Set the environment variables

| Variable | Value |
|---|---|
| `GO_CLAUDIO_GO_XAPP_TOKEN` | `xapp-…` token from step 1.2 |
| `GO_CLAUDIO_GO_XOXP_TOKEN` | `xoxp-…` token from step 1.3 |
| `GO_CLAUDIO_GO_CLAUDE_USER_ID` | Claude's member ID, see below |
| `GO_CLAUDIO_GO_EXCLUDED_CHANNELS` | Optional, channel IDs to ignore, e.g. `"C0123 C0456"` |
| `GO_CLAUDIO_GO_EMOJI` | Optional, emoji name without the `:`, e.g. `bisio`. Defaults to `claudio` |

**Claude's member ID**, once `GO_CLAUDIO_GO_XOXP_TOKEN` is set:

```bash
curl -s -H "Authorization: Bearer $GO_CLAUDIO_GO_XOXP_TOKEN" \
  "https://slack.com/api/users.list?limit=1000" \
  | jq '.members[] | select(.is_bot and (.real_name // .name | test("claude"; "i"))) | {id, real_name}'
```

**Channel IDs**: open the channel → click its name → the ID is at the bottom of the **About** tab.

## 3. Install

```bash
./install.sh windows   # WSL: Windows scheduled task, starts at Windows logon
./install.sh systemd   # Linux: systemd user service, starts at login
```

This starts the app right away and copies the variables to `~/.config/go-claudio-go/env`, since background services can't see your shell's variables. Re-run it after changing any of them.

Logs: `~/.local/state/go-claudio-go/app.log` (windows) or `journalctl --user -u go-claudio-go -f` (systemd).

To remove everything (both setups, the saved variables and the logs): `./install.sh uninstall`
