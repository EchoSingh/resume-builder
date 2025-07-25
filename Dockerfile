FROM debian:bookworm-slim AS texlive-builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    xzdec \
    perl \
    make \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -O /tmp/install-tl-unx.tar.gz && \
    tar -xzf /tmp/install-tl-unx.tar.gz -C /tmp && \
    cd /tmp/install-tl-* && \
    printf '%s\n' \
        "selected_scheme scheme-minimal" \
        "TEXDIR /usr/local/texlive" \
        "TEXMFLOCAL /usr/local/texlive/texmf-local" \
        "TEXMFSYSVAR /usr/local/texlive/texmf-var" \
        "TEXMFSYSCONFIG /usr/local/texlive/texmf-config" \
        "binary_x86_64-linux 1" > texlive.profile && \
    ./install-tl --profile=texlive.profile && \
    cd / && \
    rm -rf /tmp/install-tl-unx.tar.gz /tmp/install-tl-*

ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

RUN tlmgr update --self && \
    tlmgr install \
    collection-basic \
    xelatex \
    fontawesome5 \
    xcolor \
    tikz \
    hyperref \
    latexsym \
    fullpage \
    titlesec \
    marvosym \
    enumitem \
    tabularx \
    multicol \
    babel-english && \
    fmtutil-sys --all && \
    rm -rf /usr/local/texlive/install-tl.log /tmp/*

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fontconfig \
    inkscape \
    g++ && \
    rm -rf /var/lib/apt/lists/*

COPY --from=texlive-builder /usr/local/texlive /usr/local/texlive

ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

WORKDIR /app

COPY data/ /app/data/

ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -output-directory=out data/resume.tex"]
