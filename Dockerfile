# Stage 1: Build the TeX Live distribution
FROM debian:bookworm-slim AS texlive-builder

# Set frontend to noninteractive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies needed for the TeX Live installer and for font configuration.
# Adding fontconfig and ghostscript is crucial for font-related packages and commands like updmap-sys.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    xzdec \
    perl \
    make \
    ca-certificates \
    fontconfig \
    ghostscript && \
    # Clean up apt cache
    rm -rf /var/lib/apt/lists/*

# Download and extract the TeX Live installer
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -O /tmp/install-tl-unx.tar.gz && \
    tar -xzf /tmp/install-tl-unx.tar.gz -C /tmp && \
    cd /tmp/install-tl-* && \
    # Create a profile for a non-interactive installation.
    printf '%s\n' \
        "selected_scheme scheme-basic" \
        "TEXDIR /usr/local/texlive" \
        "TEXMFLOCAL /usr/local/texlive/texmf-local" \
        "TEXMFSYSVAR /usr/local/texlive/texmf-var" \
        "TEXMFSYSCONFIG /usr/local/texlive/texmf-config" \
        "binary_x86_64-linux 1" > texlive.profile && \
    # Run the installer with the profile, forcing it to use a reliable repository
    # to prevent intermittent network errors from specific mirrors.
    ./install-tl --profile=texlive.profile --repository http://mirror.ctan.org/systems/texlive/tlnet/ && \
    # Clean up installer files
    cd / && \
    rm -rf /tmp/install-tl-unx.tar.gz /tmp/install-tl-*

# Add TeX Live binaries to the PATH
ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

# Update the TeX Live package manager and install required packages
RUN tlmgr update --self && \
    tlmgr install \
    latexmk \
    xelatex \
    fontawesome5 \
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
    scalerel && \
    # Explicitly rebuild the file database and format files to prevent errors.
    texhash && \
    fmtutil-sys --all && \
    # Clean up logs and temporary files to reduce image size.
    rm -rf /usr/local/texlive/install-tl.log /tmp/* /usr/local/texlive/texmf-var/web2c/tlmgr.log

# Stage 2: Create the final, smaller runtime image
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies. fontconfig is essential for xelatex.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fontconfig && \
    rm -rf /var/lib/apt/lists/*

# Copy the compiled TeX Live distribution from the builder stage
COPY --from=texlive-builder /usr/local/texlive /usr/local/texlive

# Add TeX Live binaries to the PATH
ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

# Set the working directory
WORKDIR /app

# Copy application data.
# IMPORTANT: Your resume.tex file uses an image 'lc2.png'.
# This file MUST be located in the 'data' directory to be found.
COPY data/ /app/data/

# Define the entrypoint to compile the resume.
# Using latexmk is more robust as it handles multiple compiler runs automatically.
ENTRYPOINT ["latexmk", "-xelatex", "-output-directory=out", "data/resume.tex"]
