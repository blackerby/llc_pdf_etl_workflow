import os
from pathlib import Path
import sys

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload


SCOPES = ["https://www.googleapis.com/auth/drive.file"]


def upload_basic(filename, folder):
    """Insert new file.
    Returns : Id's of the file uploaded

    Load pre-authorized user credentials from the environment.
    TODO(developer) - See https://developers.google.com/identity
    for guides on implementing OAuth2 for the application.
    """
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())


    try:
        # create drive api client
        service = build('drive', 'v3', credentials=creds)
        remote_name = str(filename).split("/")[1]
        file_metadata = {'name': remote_name, 'parents': [folder]}
        media = MediaFileUpload(filename, mimetype='text/plain')
        # pylint: disable=maybe-no-member
        file = service.files().create(body=file_metadata, media_body=media, fields='id').execute()
        print(f'{file.get("id")} created')

    except HttpError as error:
        print(f'An error occurred: {error}')
        file = None

    return file.get('id')


if __name__ == '__main__':
    dirname = sys.argv[1]
    with open("folder", "r") as f:
        folder = f.read()
        
    for filename in Path(dirname).glob("*.txt"):
        upload_basic(filename, folder)
