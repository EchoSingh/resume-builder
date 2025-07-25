FROM ghcr.io/xu-cheng/texlive-small:latest

# Install system dependencies (Alpine-based)
RUN apk add --no-cache \
    inkscape \
    fontconfig \
    bash

# Install missing LaTeX packages using tlmgr
RUN tlmgr install \
    fullpage \
    titlesec \
    enumitem \
    fontawesome5 \
    babel-english \
    tabularx \
    fancyhdr \
    multicol \
    xcolor \
    hyperref \
    geometry \
    scalerel \
    xstring \
    graphics \
    pgf \
    iftex

WORKDIR /app

COPY data/resume.tex .
COPY data/*.png .

ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -interaction=nonstopmode -output-directory=out data/resume.tex"]
