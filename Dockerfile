
FROM ghcr.io/xu-cheng/texlive-small:latest


RUN apt-get update && apt-get install -y \
    inkscape \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app


COPY data/resume.tex .
COPY data/*.png .

# Compile using xelatex
ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -interaction=nonstopmode -output-directory=out data/resume.tex"]
