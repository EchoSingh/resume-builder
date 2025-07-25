# Stage 1: Build TeX Live environment with necessary packages
FROM debian:bookworm-slim AS texlive-builder

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for the TeX Live installer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    xzdec \
    perl \
    make && \
    rm -rf /var/lib/apt/lists/*

# Download, extract, and install a minimal TeX Live scheme
# This installs the base TeX Live structure and tlmgr.
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

# Updated tlmgr and install only the specific LaTeX packages required for my resume
RUN /usr/local/texlive/bin/x86_64-linux/tlmgr update --self && \
    /usr/local/texlive/bin/x86_64-linux/tlmgr install \
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
    babel-english \
    && /usr/local/texlive/bin/x86_64-linux/fmtutil-sys --all

---

# Stage 2: Final runtime image for compilation

FROM debian:bookworm-slim

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential runtime dependencies for LaTeX compilation
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fontconfig \
    inkscape \
    g++ && \
    rm -rf /var/lib/apt/lists/*

# Copy the minimal TeX Live installation from the builder stage
COPY --from=texlive-builder /usr/local/texlive /usr/local/texlive

# Add TeX Live binaries to the PATH
ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

# Set the working directory within the container
WORKDIR /app

# Copy resume source files into the container
COPY data/ /app/data/

# compile the resume
ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -output-directory=out data/resume.tex"]
