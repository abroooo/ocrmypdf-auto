FROM balenalib/armv7hf-ubuntu-python:latest

#FROM balenalib/raspberry-pi2-ubuntu:latest
#FROM resin/rpi-raspbian:latest
#FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ghostscript \
        gosu \
#        python3-venv \
 #       python3-pip \
        qpdf \
        tesseract-ocr \
        tesseract-ocr-eng \
        tesseract-ocr-osd \
        unpaper \
        build-essential \
#       python-dev python-setuptools \
#        libffi-dev \
#        python3-dev python3-setuptools \
        libjpeg8-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends python3-venv \
       python3-pip 
RUN apt-get update && apt-get install -y --no-install-recommends \
python3-dev mupdf libffi-dev

RUN apt-get update && apt-get install -y --no-install-recommends \
libmupdf-dev mupdf mupdf-tools
RUN apt-get update && apt-get install -y --no-install-recommends \
swig ocrmypdf
ENV LANG=C.UTF-8

RUN python3 -m venv --system-site-packages /appenv

RUN . /appenv/bin/activate; \
    pip3 install --upgrade pip

# Pull in ocrmypdf via requirements.txt and install pinned version
COPY src/requirements.txt /app/

RUN . /appenv/bin/activate; \
    pip install -r /app/requirements.txt

COPY src/ /app/

# Create restricted privilege user docker:docker to drop privileges
# to later. We retain root for the entrypoint in order to install
# additional tesseract OCR language packages.
RUN groupadd -g 1000 docker && \
    useradd -u 1000 -g docker -N --home-dir /app docker && \
    mkdir /config /input /output /ocrtemp /archive && \
    chown -Rh docker:docker /app /config /input /output /ocrtemp /archive && \
    chmod 755 /app/docker-entrypoint.sh

VOLUME ["/config", "/input", "/output", "/ocrtemp", "/archive"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]

