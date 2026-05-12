This is my own version of the Samisk–Norsk transcription project. 

Original: https://github.com/tbitu/transkripsjon-samisk-norsk

Edited for public server.





# Real-time transcription and translation

This project is a real-time simultaneous translator that transcribes Northern Sámi speech into text and then translates the text into a selected target language. The solution is built with a Python backend for transcription and a web interface that handles translation, using the following services:
- **Transcription (backend):** `GetmanY1/wav2vec2-large-sami-cont-pt-22k-finetuned`
- **Translation (frontend):** TartuNLP Tahetorn_9B for translating Northern Sámi into various national and Sámi languages

## Supported translations

The application can translate from Northern Sámi into the following languages:
- Norwegian
- Finnish
- English
- **Sámi languages:** Northern Sámi (improved text), Southern Sámi, Lule Sámi, Inari Sámi, Skolt Sámi, Kildin Sámi, Pite Sámi, Ume Sámi

## Available ASR models 

| Model | Type | Typical Use |
| --- | --- | --- |
| `GetmanY1/wav2vec2-large-sami-cont-pt-22k-finetuned` | Wav2Vec2 CTC | Lightweight model trained on Sámi Parliament recordings, outputs Northern Sámi text (CTC). |

The Wav2Vec2 model requires mono PCM 16 kHz audio. The model always runs in float32; on GPU it uses less VRAM, but CPU loading times may be longer.

## Using Docker (recommended)

You can easily run the project using the prebuilt Docker image from GitHub Container Registry (GHCR). This provides the correct environment for PyTorch and GPU support without manually installing Python and dependencies.

> ⚠️ There is also a helper script for Windows/WSL ([wsl-run-transkripsjon.ps1](wsl-run-transkripsjon.ps1)), but it is untested/incomplete and should only be used as guidance.

### 1. Run with the prebuilt GHCR image

**Requirements:**
- Docker installed on the system
- NVIDIA GPU and [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) installed for GPU acceleration

**Command:**

```bash
docker run --gpus all -p 5000:5000 ghcr.io/maggamaa/transkripsjon-samisk-norsk:latest
```

- `--gpus all`: Gives the Docker container access to all NVIDIA GPUs
- `-p 5000:5000`: Exposes the web interface on port 5000

**Usage**:  
When the container is running, open [http://localhost:5000](http://localhost:5000) in your browser or use your local IP address from other devices on the network.

---

### 2. Build the Docker image yourself (for developers/advanced users)

#### a. Clone the repository

```bash
git clone https://github.com/maggamaa/transkripsjon-samisk-norsk.git
cd transkripsjon-samisk-norsk
```

#### b. Build the Docker image

The image is configured for NVIDIA GPUs and includes PyTorch with CUDA support.

```bash
docker build -t transkripsjon-samisk-norsk .
```

#### c. Run the image with GPU access

```bash
docker run --gpus all -p 5000:5000 transkripsjon-samisk-norsk
```

---

## 3. Running without Docker (manual setup)

**Requirements:**

1. **Python 3.8+**
2. **ffmpeg** installed and available in PATH:
    - Ubuntu/Debian: `sudo apt install ffmpeg`
    - macOS: `brew install ffmpeg`
    - Windows: Download from [ffmpeg.org](https://ffmpeg.org/download.html) and add it to PATH
3. **CUDA-compatible GPU (recommended):** CPU execution is supported but significantly slower.
4. **Internet connection:** Required for translation through the TartuNLP API

**Steps:**

1. **Create and activate a virtual environment:**

   ```bash
   python -m venv .venv
   source .venv/bin/activate  # Windows: .venv\Scripts\activate
   ```

2. **Install PyTorch for NVIDIA GPU:**

   ```bash
   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu129
   ```

3. **Install remaining dependencies:**

   ```bash
   pip install -r requirements.txt
   ```

4. **Start the server:**

   ```bash
   python main.py
   ```

   The server starts and loads the models. This may take some time. Once ready, it listens on `http://0.0.0.0:5000`.

---

## Web interface

- **Same machine:** Open a browser and go to [http://localhost:5000](http://localhost:5000)
- **Another device on the network:** Find the server IP address (for example `192.168.1.123`) and open `http://DIN_IP_ADRESSE:5000`

**Usage:**
- Click **«Start recording»** and allow microphone access in the browser.
- Speak Northern Sámi. The transcribed Northern Sami text appears in the left box, and the translation follows shortly after in the right box.
- Select **target language** from the dropdown menu (visible when “Translation” or “Both” is selected).
- Use the buttons **«Transcription»**, **«Translation»** og **«Both»** to choose which text boxes are displayed.
- Click **«Stop recording»** to finish.

---

## Architecture

- **Backend (Python):** Handles audio streaming, speech recognition via Wav2Vec2, and Voice Activity Detection (VAD)
- **Frontend (JavaScript):** Receives transcribed text and calls the TartuNLP Tahetorn_9B to translate into the selected language
- **API:** TartuNLP Tahetorn_9B provides free machine translation between Northern Sámi and other Sámi languages as well as some national languages

---

## Troubleshooting

- Missing GPU/driver errors: Verify that NVIDIA drivers and [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) are correctly installed.
- CPU fallback is supported, but performance is significantly lower with large models.
- **Translation not working:** Check your internet connection, since translation requires access to the TartuNLP API.

---

## Credits

- **Transcription:** [GetmanY1/wav2vec2-large-sami-cont-pt-22k-finetuned](https://huggingface.co/GetmanY1/wav2vec2-large-sami-cont-pt-22k-finetuned)
- **Translation:** [TartuNLP Tahetorn_9B](https://github.com/tbitu/sami-translation-backend)
- **Voice Activity Detection:** [Silero VAD](https://github.com/snakers4/silero-vad)
- **Punctuation Restoration:** [Stanza NLP](https://stanfordnlp.github.io/stanza/)