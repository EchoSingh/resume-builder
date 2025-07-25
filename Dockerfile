# Base image: XeLaTeX-ready but minimal
FROM jpbernius/xelatex

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required tools + missing LaTeX packages via texlive collections
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    unzip \
    fontconfig \
    inkscape \
    texlive-fonts-recommended \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-font-utils \
    texlive-fonts-extra \
    texlive-pictures \
    texlive-science \
    texlive-lang-english \
    texlive-xetex \
    && rm -rf /var/lib/apt/lists/*

# (Optional) Manually install other packages like qrcode.sty
RUN cd /tmp && \
    wget http://mirrors.ctan.org/macros/latex/contrib/qrcode.zip && \
    unzip qrcode.zip && \
    cd qrcode && \
    latex qrcode.ins && \
    mkdir -p /usr/local/share/texmf/tex/latex/qrcode && \
    cp qrcode.sty /usr/local/share/texmf/tex/latex/qrcode && \
    texhash && \
    rm -rf /tmp/qrcode /tmp/qrcode.zip

# Working directory for resume build
WORKDIR /app

# Copy LaTeX source and assets
COPY data/resume.tex .
COPY data/*.png .

# Default command: compile resume using xelatex
ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -interaction=nonstopmode -output-directory=out data/resume.tex"]
