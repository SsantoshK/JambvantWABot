# UI Prototype

This folder contains a minimal client-side prototype for recording Hindi audio that can be sent to the Jambvant bot.

How to use:
- Open `index.html` in a browser that supports `MediaRecorder`.
- Click `Start Recording`, speak in Hindi, then `Stop` and play the recorded audio.

Next steps:
- Wire the recording upload to your backend which will forward media to WhatsApp or store it for processing by the n8n workflow.
- Add user authentication and better UX for mobile.
