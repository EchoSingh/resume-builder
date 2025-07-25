FROM danteev/texlive:small

RUN apt-get update && apt-get install -y \
    inkscape \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY data/resume.tex .
COPY data/*.png .

ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -interaction=nonstopmode -output-directory=out data/resume.tex"]
