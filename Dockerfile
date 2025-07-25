# Stage 1: Build the TeX Live distribution
FROM debian:bookworm-slim AS texlive-builder

# Set frontend to noninteractive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies needed for the TeX Live installer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    xzdec \
    perl \
    make \
    ca-certificates && \
    # Clean up apt cache
    rm -rf /var/lib/apt/lists/*

# Download and extract the TeX Live installer
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -O /tmp/install-tl-unx.tar.gz && \
    tar -xzf /tmp/install-tl-unx.tar.gz -C /tmp && \
    cd /tmp/install-tl-* && \
    printf '%s\n' \
        "selected_scheme scheme-basic" \
        "TEXDIR /usr/local/texlive" \
        "TEXMFLOCAL /usr/local/texlive/texmf-local" \
        "TEXMFSYSVAR /usr/local/texlive/texmf-var" \
        "TEXMFSYSCONFIG /usr/local/texlive/texmf-config" \
        "binary_x86_64-linux 1" > texlive.profile && \
    # Run the installer with the profile
    ./install-tl --profile=texlive.profile && \
    # Clean up installer files
    cd / && \
    rm -rf /tmp/install-tl-unx.tar.gz /tmp/install-tl-*

# Add TeX Live binaries to the PATH
ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

# Update the TeX Live package manager and install required packages
RUN tlmgr update --self && \
    tlmgr install \
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
    rm -rf /usr/local/texlive/install-tl.log /tmp/* /usr/local/texlive/texmf-var/web2c/tlmgr.log

# Stage 2: Create the final, smaller runtime image
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fontconfig \
    # inkscape and g++ were in the original file, kept here
    inkscape \
    g++ && \
    rm -rf /var/lib/apt/lists/*

# Copy the compiled TeX Live distribution from the builder stage
COPY --from=texlive-builder /usr/local/texlive /usr/local/texlive

# Add TeX Live binaries to the PATH
ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

# Set the working directory
WORKDIR /app

# Copy application data
# This assumes you have a 'data' directory in your build context
COPY data/ /app/data/

# Define the entrypoint to compile the resume
ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -output-directory=out data/resume.tex"]
