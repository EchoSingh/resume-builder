# Base image
FROM debian:stable-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Add Debian repositories
RUN echo "deb http://deb.debian.org/debian stable main" > /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian stable-updates main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian-security stable-security main" >> /etc/apt/sources.list

# Install LaTeX and required system packages
RUN apt-get update && apt-get install -qyf \
    curl \
    jq \
    make \
    git \
    inkscape \
    python3-pygments \
    gnuplot \
    fontconfig \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-pictures \
    texlive-science \
    texlive-lang-english \
    && rm -rf /var/lib/apt/lists/*

# Working directory
WORKDIR /app

# Copy LaTeX source and assets
COPY data/resume.tex .
COPY data/*.png .

# Default compile command: build PDF using xelatex
ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -interaction=nonstopmode -output-directory=out data/resume.tex"]
