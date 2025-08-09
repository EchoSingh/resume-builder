# Use a pre-built TeX Live image to speed up the build process
FROM texlive/texlive:latest

# Set the working directory to match the GitHub Actions runner
WORKDIR /github/workspace

# No need to COPY the file, as the entire workspace is mounted by the action
# The ENTRYPOINT will compile the resume from the mounted volume
ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -output-directory=out data/resume.tex"]
