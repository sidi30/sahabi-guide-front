#!/usr/bin/env python3
"""Upload an .aab to Google Play via the Developer API.

Usage:
  python scripts/play_upload.py <aab_path> [track] [package_name]

Defaults: track=internal, package=com.sahabi_guide.sahabi_guide
Requires play-service-account.json at the app root (gitignored).
"""
import sys
import os
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SA_FILE = os.path.join(ROOT, "play-service-account.json")
SCOPES = ["https://www.googleapis.com/auth/androidpublisher"]


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: play_upload.py <aab_path> [track] [package_name]")
    aab = sys.argv[1]
    track = sys.argv[2] if len(sys.argv) > 2 else "internal"
    package = sys.argv[3] if len(sys.argv) > 3 else "com.sahabi_guide.sahabi_guide"

    if not os.path.isfile(aab):
        sys.exit(f"aab not found: {aab}")
    if not os.path.isfile(SA_FILE):
        sys.exit(f"service account key not found: {SA_FILE}")

    creds = service_account.Credentials.from_service_account_file(SA_FILE, scopes=SCOPES)
    svc = build("androidpublisher", "v3", credentials=creds, cache_discovery=False)

    print(f"package={package} track={track} aab={os.path.basename(aab)}")
    edit = svc.edits().insert(body={}, packageName=package).execute()
    edit_id = edit["id"]
    print(f"edit created: {edit_id}")

    media = MediaFileUpload(aab, mimetype="application/octet-stream", resumable=True)
    up = svc.edits().bundles().upload(
        packageName=package, editId=edit_id, media_body=media
    ).execute()
    version_code = up["versionCode"]
    print(f"uploaded bundle versionCode={version_code}")

    svc.edits().tracks().update(
        packageName=package,
        editId=edit_id,
        track=track,
        body={"releases": [{"versionCodes": [str(version_code)], "status": "completed"}]},
    ).execute()
    print(f"assigned versionCode {version_code} to track '{track}'")

    svc.edits().commit(packageName=package, editId=edit_id).execute()
    print(f"committed. v{version_code} live on '{track}'.")


if __name__ == "__main__":
    main()
