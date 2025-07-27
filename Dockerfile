FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    xzdec \
    perl \
    make \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

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

ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

RUN tlmgr update --self && \
    tlmgr install \
    collection-fontsrecommended \
    collection-latexextra \
    collection-pictures \
    collection-langenglish \
    academicons \
    fontawesome5

RUN fmtutil-sys --all

WORKDIR /app

ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -output-directory=out data/resume.tex"]
