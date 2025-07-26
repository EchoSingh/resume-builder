# Use a lean Ubuntu base image
FROM ubuntu:latest

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y \
    wget \
    xzdec \
    perl \
    make \
    fontconfig \
    g++ \
    inkscape \
    && rm -rf /var/lib/apt/lists/*

# Download and install TeX Live
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
    && tar -xzf install-tl-unx.tar.gz \
    && cd install-tl-* \
    && printf '%s\n' \
        "selected_scheme scheme-small" \
        "TEXDIR /usr/local/texlive" \
        "TEXMFLOCAL /usr/local/texlive/texmf-local" \
        "TEXMFSYSVAR /usr/local/texlive/texmf-var" \
        "TEXMFSYSCONFIG /usr/local/texlive/texmf-config" \
        "TEXMFVAR ~/.texlive/texmf-var" \
        "TEXMFCONFIG ~/.texlive/texmf-config" \
        "binary_x86_64-linux 1" > texlive.profile \
    && ./install-tl --profile=texlive.profile \
    && cd .. \
    && rm -rf install-tl-unx.tar.gz install-tl-*

# Update PATH environment variable to include TeX Live binaries
ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

# Install necessary TeX Live collections and packages:
RUN tlmgr update --self && \
    tlmgr install \
    collection-fontsrecommended \
    collection-latexextra \
    collection-pictures \
    collection-langenglish

# Manually run fmtutil-sys to generate formats for newly installed packages
RUN fmtutil-sys --all

# Set the working directory inside the container
WORKDIR /app

# Copy your LaTeX resume file and all associated image assets into the container.
# Ensure that 'resume.tex' is in the same directory as this Dockerfile,
# and all '.png' files are in a 'data' subdirectory relative to the Dockerfile.
COPY data/resume.tex .
COPY data/gmail.png .
COPY data/ldn.png .
COPY data/github.png .
COPY data/lc2.png .
COPY data/hf.png .
COPY data/kaggle.png .
COPY data/cf.png .

# Set the entrypoint for the container.
ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -output-directory=out data/resume.tex"]
