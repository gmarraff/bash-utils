#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "slack-bolt",
#     "slack-sdk",
# ]
# ///
import json
import os
import re
import threading
from datetime import datetime
from pathlib import Path
from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler
from slack_sdk.errors import SlackApiError

ENV_PREFIX = "GO_CLAUDIO_GO_"

def get_env():
    names = [f"{ENV_PREFIX}{n}" for n in (
        "XAPP_TOKEN",
        "XOXP_TOKEN",
        "CLAUDE_USER_ID",
    )]
    missing = [n for n in names if not os.getenv(n)]
    if missing:
        raise RuntimeError(f"Missing required environment variable(s): {', '.join(missing)}")
    return tuple(os.environ[n] for n in names)

XAPP_TOKEN, XOXP_TOKEN, CLAUDE_USER_ID = get_env()
EXCLUDED_CHANNELS = os.getenv(f"{ENV_PREFIX}EXCLUDED_CHANNELS", "").split()
EXCLUDED_CHANNEL_PREFIXES = tuple(os.getenv(f"{ENV_PREFIX}EXCLUDED_CHANNEL_PREFIXES", "").split())

app = App(token=XOXP_TOKEN)
EMOJI = os.getenv(f"{ENV_PREFIX}EMOJI", "claudio")

# Claud, Claude, Claudio and Claudione, with any letter stretched out
# (clauddddd, claudeeee, claudioneeee)
CLAUDE_RE = re.compile(r"\bc+l+a+u+d+(?:e+|i+o+(?:n+e+)?)?\b", re.IGNORECASE)

def message_mention_claude(event):
    text = event.get("text", "")
    # Blocks may carry content missing from text, so search them too
    blocks = str(event.get("blocks", ""))
    # @Claude mentions only carry the app's bot user ID, never its name
    if CLAUDE_USER_ID in text or CLAUDE_USER_ID in blocks:
        return True
    return bool(CLAUDE_RE.search(text) or CLAUDE_RE.search(blocks))

CHANNEL_CACHE = Path.home() / ".cache" / "go-claudio-go" / "channels.json"
try:
    channel_names = json.loads(CHANNEL_CACHE.read_text())
except (FileNotFoundError, json.JSONDecodeError):
    channel_names = {}
channel_names_lock = threading.Lock()

# Events only carry the channel ID, so look each name up once and keep it on
# disk across restarts
def channel_name(channel):
    with channel_names_lock:
        if channel not in channel_names:
            info = app.client.conversations_info(channel=channel)
            channel_names[channel] = info["channel"]["name"]
            CHANNEL_CACHE.parent.mkdir(parents=True, exist_ok=True)
            tmp = CHANNEL_CACHE.with_suffix(".tmp")
            tmp.write_text(json.dumps(channel_names))
            tmp.replace(CHANNEL_CACHE)
        return channel_names[channel]

@app.event("message")
def tag_claude_posts(event, client):
    if event.get("channel") in EXCLUDED_CHANNELS:
        return
    if message_mention_claude(event):
        if EXCLUDED_CHANNEL_PREFIXES and channel_name(event["channel"]).startswith(EXCLUDED_CHANNEL_PREFIXES):
            return
        try:
            client.reactions_add(
                channel=event["channel"],
                timestamp=event["ts"],
                name=EMOJI,
            )
            link = client.chat_getPermalink(
                channel=event["channel"],
                message_ts=event["ts"],
            )["permalink"]
            print(f"{datetime.now().isoformat(timespec='seconds')} Bisio has been sent to {link}")
        except SlackApiError as e:
            if e.response["error"] != "already_reacted":
                raise

if __name__ == "__main__":
    SocketModeHandler(app, XAPP_TOKEN).start()