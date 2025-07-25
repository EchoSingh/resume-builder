FROM ghcr.io/xu-cheng/texlive-small:latest


RUN apk add --no-cache \
    inkscape \
    fontconfig

WORKDIR /app

COPY data/resume.tex .
COPY data/*.png .

ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -interaction=nonstopmode -output-directory=out data/resume.tex"]
