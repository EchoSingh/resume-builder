# Use a lean Ubuntu base image
FROM ubuntu:latest

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential system dependencies:
# wget: to download TeX Live installer
# xzdec: to decompress the TeX Live installer
# perl: required by TeX Live installer
# make: often needed for various compilation steps
# fontconfig: for font rendering
# g++: a C++ compiler, sometimes needed for certain LaTeX packages or tools
# inkscape: essential for processing SVG images if your LaTeX uses the 'svg' package
RUN apt-get update && apt-get install -y \
    wget \
    xzdec \
    perl \
    make \
    fontconfig \
    g++ \
    inkscape \
    && rm -rf /var/lib/apt/lists/*

# Download and install TeX Live
# We use 'scheme-small' which is a good balance between size and functionality,
# providing a more complete set of packages than 'scheme-basic'.
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

# Update PATH environment variable to include TeX Live binaries
ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

# Install necessary TeX Live collections and packages:
# tlmgr update --self: Updates the TeX Live Package Manager itself.
# collection-fontsrecommended: Provides recommended fonts, including those for fontawesome5.
# collection-latexextra: Contains many additional LaTeX packages, including marvosym, tabularx, multicol, titlesec, enumitem, supertabular, multirow, parskip, and geometry.
# collection-pictures: Includes packages for graphics and diagrams, notably TikZ.
# collection-langenglish: Provides language support for English, covering the babel package.
# Your resume uses: graphicx, fontawesome5, svg, xcolor, hyperref, latexsym, fullpage, titlesec, marvosym, color, enumitem, babel, tabularx, multicol, tikz.
# Most of these are covered by 'scheme-small' or the additional collections listed below.
RUN tlmgr update --self && \
    tlmgr install \
    collection-fontsrecommended \
    collection-latexextra \
    collection-pictures \
    collection-langenglish

# Manually run fmtutil-sys to generate formats for newly installed packages
# This ensures that all LaTeX formats are up-to-date and correctly configured.
RUN fmtutil-sys --all

# Set the working directory inside the container
WORKDIR /app

# Copy your LaTeX resume file and all associated image assets into the container.
# Ensure that 'resume.tex' and all '.png' files (gmail.png, ldn.png, etc.)
# are in the same directory as this Dockerfile when you build the image.
COPY resume.tex .
COPY gmail.png .
COPY ldn.png .
COPY github.png .
COPY lc.png .
COPY hf.png .
COPY kaggle.png .
COPY cf.png .

# Set the entrypoint for the container.
# This command will be executed when the container starts.
# xelatex: The compiler used for your resume (supports PNG and SVG via inkscape).
# -output-directory=out: Specifies that the output files (like the PDF) should be placed in an 'out' subdirectory.
# resume.tex: The main LaTeX file to compile.
# We first create the 'out' directory to avoid potential errors if it doesn't exist.
ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -output-directory=out resume.tex"]
