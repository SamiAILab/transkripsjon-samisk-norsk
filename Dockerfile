# Use an official NVIDIA CUDA base image.
FROM nvidia/cuda:12.9.1-cudnn-devel-ubuntu24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Oslo
# Tells the transformers library where the cache should be located
ENV TRANSFORMERS_CACHE=/root/.cache/huggingface

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set the working folder
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
# Adding --break-system-packages to allow pip installation on Ubuntu 24.04
RUN pip3 install --no-cache-dir --break-system-packages torch torchaudio --index-url https://download.pytorch.org/whl/cu129
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Download and cache the models during building
# Copy only the download script and model registry first
COPY download_model.py model_registry.py ./
# Run the script to download the model. This step will take some time.
RUN python3 download_model.py
# Delete the script afterwards to keep the image clean.
RUN rm download_model.py

# Copy the rest of the application files
COPY . .

# Inform Docker that the container will listen on port 5000
EXPOSE 5000

# The command that runs when the container starts
CMD ["python3", "main.py"]