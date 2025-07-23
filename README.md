# Resume 📄

This repository contains a LaTeX-based resume with an automated PDF build process using GitHub Actions and Docker. It ensures consistent formatting, reproducible builds, and clean version control.



## Features

* Written in LaTeX for high-quality typesetting
* Automatically compiled via GitHub Actions
* Dockerized for consistent, dependency-free builds
* Organized project layout for easy maintenance and clarity



## Project Structure

```
resume/
├── .github/
│   └── workflows/
│       └── compile.yml
├── data/
│   └── resume.tex
├── assets/
│   └── image.png
├── out/
│   └── resume.aux
│   └── resume.log
│   └── resume.out
│   └── resume.pdf
├── Dockerfile
├── action.yml
└── README.md
```



## Usage

### Using Docker

Update the `Dockerfile` to reference the correct input files:

```dockerfile
COPY data/resume.tex .
COPY data/icon-image.png .
```

Then build and run the container:

```sh
docker build -t resume-builder .
docker run --rm -v $(pwd):/usr/src/app resume-builder
```

This process compiles the resume inside an isolated environment and outputs the PDF to the `out/` directory.



### Using GitHub Actions

1. Edit `data/resume.tex`

2. Commit and push your changes:

   ```sh
   git add data/resume.tex
   git commit -m "Update resume"
   git push origin main
   ```

3. GitHub Actions will:

   * Compile the LaTeX source
   * Place the updated PDF in the `out/` directory
   * Commit and push the updated PDF if necessary



### Local Compilation (Without Docker)

1. Ensure you have a LaTeX distribution installed (e.g., TeX Live, MiKTeX)
2. Compile manually:

   ```sh
   pdflatex -output-directory=out data/resume.tex
   ```



## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.



## Acknowledgements

* The LaTeX community for powerful and elegant typesetting tools
* GitHub Actions workflows and open-source LaTeX templates for automation inspiration


## Contact

For questions or suggestions, feel free to open an issue at [GitHub Issues](https://github.com/aditya26062003/resume/issues).

