FROM texlive/texlive:latest
WORKDIR /github/workspace
ENTRYPOINT ["sh", "-c", "mkdir -p out && xelatex -output-directory=docs data/resume.tex"]
