import json

try:
    with open('server/bubbles_server.ipynb', 'r', encoding='utf-8') as f:
        nb = json.load(f)

    # 1. Update Dependencies (Find pip install)
    for cell in nb['cells']:
        source = "".join(cell['source'])
        if 'pip install' in source:
            new_source = []
            for line in cell['source']:
                if 'pip install' in line:
                    # Append new deps
                    line = line.strip() + " livekit livekit-agents livekit-plugins-deepgram livekit-api python-dotenv\n"
                new_source.append(line)
            cell['source'] = new_source
            break

    # 2. Add Imports (Find import section)
    for cell in nb['cells']:
        source = "".join(cell['source'])
        if 'import os' in source or 'import sys' in source:
            cell['source'].append("import logging\n")
            cell['source'].append("from livekit.agents import AutoSubscribe, JobContext, WorkerOptions, cli, llm, Worker\n")
            cell['source'].append("from livekit.agents.voice_assistant import VoiceAssistant\n")
            cell['source'].append("from livekit.plugins import deepgram, openai, silero\n")
            cell['source'].append("from livekit import api\n")
            break

    # 3. Add Agent Logic (Insert new cell before Execution)
    agent_code = [
        "# ==========================================\n",
        "# LIVEKIT AGENT\n",
        "# ==========================================\n",
        "async def entrypoint(ctx: JobContext):\n",
        "    print(f'Connecting to room {ctx.room.name}')\n",
        "    stt = deepgram.STT(api_key=settings.DEEPGRAM_KEY)\n",
        "    await ctx.connect(auto_subscribe=AutoSubscribe.AUDIO_ONLY)\n",
        "\n",
        "    @ctx.room.on('track_subscribed')\n",
        "    def on_track_subscribed(track, publication, participant):\n",
        "        if track.kind == 'audio':\n",
        "            print('Subscribed to audio track')\n",
        "            stream = stt.stream()\n",
        "            \n",
        "            async def read_stream():\n",
        "                async for event in stream:\n",
        "                    if event.type == deepgram.STTEventType.FINAL_TRANSCRIPT:\n",
        "                        if event.alternatives[0].text.strip():\n",
        "                            print(f'Final: {event.alternatives[0].text}')\n",
        "                            await ctx.room.local_participant.publish_data(\n",
        "                                json.dumps({'type': 'transcript', 'text': event.alternatives[0].text, 'is_final': True}),\n",
        "                                reliable=True\n",
        "                            )\n",
        "                    elif event.type == deepgram.STTEventType.INTERIM_TRANSCRIPT:\n",
        "                        if event.alternatives[0].text.strip():\n",
        "                            await ctx.room.local_participant.publish_data(\n",
        "                                json.dumps({'type': 'transcript', 'text': event.alternatives[0].text, 'is_final': False}),\n",
        "                                reliable=False\n",
        "                            )\n",
        "\n",
        "            async def pump_audio():\n",
        "                async for frame in track.stream():\n",
        "                    stream.push_frame(frame)\n",
        "                await stream.aclose()\n",
        "\n",
        "            import asyncio\n",
        "            asyncio.create_task(read_stream())\n",
        "            asyncio.create_task(pump_audio())\n"
    ]
    
    # Find execution cell index
    exec_idx = -1
    for i, cell in enumerate(nb['cells']):
        if 'if __name__ == "__main__":' in "".join(cell['source']):
            exec_idx = i
            break
    
    if exec_idx != -1:
        # Insert Agent cell before execution
        nb['cells'].insert(exec_idx, {
            "cell_type": "code",
            "execution_count": None,
            "metadata": {},
            "outputs": [],
            "source": agent_code
        })
        
        # 4. Update Execution Cell
        exec_cell = nb['cells'][exec_idx + 1] # +1 because we inserted one
        new_exec = [
            "if __name__ == \"__main__\":\n",
            "    # 1. Setup Ngrok\n",
            "    ngrok.set_auth_token(settings.NGROK_TOKEN)\n",
            "    for t in ngrok.get_tunnels():\n",
            "        try: ngrok.disconnect(t.public_url)\n",
            "        except: pass\n",
            "\n",
            "    try:\n",
            "        url = ngrok.connect(settings.PORT).public_url\n",
            "        print(f\"SERVER LIVE: {url}\")\n",
            "        # QR Code\n",
            "        qr = qrcode.QRCode(box_size=10, border=4)\n",
            "        qr.add_data(url)\n",
            "        qr.make(fit=True)\n",
            "        img = qr.make_image(fill_color=\"black\", back_color=\"white\")\n",
            "        try:\n",
            "            from IPython.display import display\n",
            "            display(img)\n",
            "        except: pass\n",
            "    except Exception as e:\n",
            "        print(f\"Ngrok Error: {e}\")\n",
            "\n",
            "    # 2. Start LiveKit Worker\n",
            "    print('Starting LiveKit Worker...')\n",
            "    async def run_worker():\n",
            "        # Ensure keys are present in env or passed explicitly\n",
            "        # We use settings values if env vars are not set, but Worker expects env vars usually\n",
            "        # So let's set them in os.environ just in case\n",
            "        os.environ['LIVEKIT_URL'] = settings.LIVEKIT_URL\n",
            "        os.environ['LIVEKIT_API_KEY'] = settings.LIVEKIT_API_KEY\n",
            "        os.environ['LIVEKIT_API_SECRET'] = settings.LIVEKIT_API_SECRET\n",
            "        \n",
            "        opts = WorkerOptions(entrypoint_fnc=entrypoint)\n",
            "        worker = Worker(opts)\n",
            "        await worker.run()\n",
            "\n",
            "    import asyncio\n",
            "    asyncio.create_task(run_worker())\n",
            "\n",
            "    # 3. Run Server\n",
            "    config = uvicorn.Config(app, host=settings.HOST, port=settings.PORT)\n",
            "    server = uvicorn.Server(config)\n",
            "    await server.serve()\n"
        ]
        exec_cell['source'] = new_exec

    with open('server/bubbles_server.ipynb', 'w', encoding='utf-8') as f:
        json.dump(nb, f, indent=1)
    print("Notebook updated for Colab successfully")
except Exception as e:
    print(f"Error: {e}")
