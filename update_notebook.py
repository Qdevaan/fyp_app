import json

try:
    with open('server/bubbles_server.ipynb', 'r', encoding='utf-8') as f:
        nb = json.load(f)

    # Find the cell with settings
    for cell in nb['cells']:
        if 'DEEPGRAM_KEY: str =' in "".join(cell['source']):
            new_source = []
            for line in cell['source']:
                new_source.append(line)
                if 'DEEPGRAM_KEY: str =' in line:
                    new_source.append('    LIVEKIT_API_KEY: str = "devkey"\\n')
                    new_source.append('    LIVEKIT_API_SECRET: str = "secret"\\n')
                    new_source.append('    LIVEKIT_URL: str = "wss://localhost:7880"\\n')
            cell['source'] = new_source
            break

    # Find the cell with app definition
    for cell in nb['cells']:
        if 'current_session_logs = []' in "".join(cell['source']):
            new_source = []
            for line in cell['source']:
                new_source.append(line)
                if 'current_session_logs = []' in line:
                    new_source.append('\\n')
                    new_source.append('from livekit import api\\n')
                    new_source.append('\\n')
                    new_source.append('@app.get("/token")\\n')
                    new_source.append('def get_token(participant_name: str = "user"):\\n')
                    new_source.append('    token = api.AccessToken(settings.LIVEKIT_API_KEY, settings.LIVEKIT_API_SECRET) \\\n')
                    new_source.append('        .with_identity(participant_name) \\\n')
                    new_source.append('        .with_name(participant_name) \\\n')
                    new_source.append('        .with_grants(api.VideoGrants(room_join=True, room="my-room"))\\n')
                    new_source.append('    return {"token": token.to_jwt(), "url": settings.LIVEKIT_URL}\\n')
            cell['source'] = new_source
            break

    with open('server/bubbles_server.ipynb', 'w', encoding='utf-8') as f:
        json.dump(nb, f, indent=1)
    print("Notebook updated successfully")
except Exception as e:
    print(f"Error: {e}")
