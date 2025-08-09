# Use a pre-built TeX Live image to speed up the build process
FROM texlive/texlive:latest

# Set the working directory
WORKDIR /app

# Copy the resume source file into the container
COPY data/resume.tex .

# Compile the resume using xelatex
# The output will be placed in the 'out' directory
ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -output-directory=out resume.tex"]
