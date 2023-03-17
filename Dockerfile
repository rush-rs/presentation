FROM debian:buster-slim

# install basic software
RUN apt update\
    && apt upgrade -y \
# DO I NEED `llvm-dev`?
    && apt install llvm-dev build-essential\
    zip jq wget curl git fontconfig software-properties-common\
    libimage-exiftool-perl bsdmainutils\
    texlive-luatex texlive-base texlive-latex-recommended\
    texlive-pictures texlive-latex-extra texlive-lang-german texlive-science\
    biber latexmk rsync -y

# add the LLVM apt repository
RUN apt-add-repository 'deb http://apt.llvm.org/buster/ llvm-toolchain-buster-14 main'\
    && curl https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add - && apt update

# install LLVM 14 and other packages using the older repos
RUN apt install llvm-14-dev libpolly-14-dev zlib1g-dev -y

# install the RISCV toolchain since a newer version of it is required
RUN apt-add-repository 'deb http://deb.debian.org/debian bullseye main'\
    && apt update\
    && apt install binutils-riscv64-linux-gnu gcc-10-riscv64-linux-gnu qemu-user -y \
    && ln -s $(which riscv64-linux-gnu-gcc-10) /usr/bin/riscv64-linux-gnu-gcc

# configure Rust
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:/root/.wasmer/bin:$PATH

# install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > install.sh\
    && chmod +x install.sh \
    && ./install.sh -y \
    && rm install.sh

# update the `crates.io` index since it takes a lot of time
WORKDIR /root
RUN git clone https://github.com/rush-rs/rush
WORKDIR /root/rush
RUN cargo update\
    && cargo install tokei

# install Fira Sans
WORKDIR /usr/local/share/fonts
RUN curl --proto '=https' -sSf "https://fonts.google.com/download?family=Fira%20Sans" > fira.zip\
    && unzip fira.zip\
    && rm fira.zip OFL.txt\
    && fc-cache -f -v\
# JetBrains Mono
    && curl --proto '=https' -sSfL "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" -o jetbrains.zip\
    && unzip jetbrains.zip\
    && mv fonts/ttf/* .\
    && rm jetbrains.zip OFL.txt\
    && fc-cache -f -v

# clone the presentation an run initializations
WORKDIR /root
RUN git clone https://github.com/rush-rs/presentation
WORKDIR /root/presentation
RUN make init

# download `mtheme`
WORKDIR /root/
RUN wget "https://github.com/matze/mtheme/archive/master.zip"\
    && unzip master.zip\
    && cd mtheme-master\
    && make sty\
    && mv *.sty /usr/share/texmf/tex/latex\
    && texhash\
    && cd ../\
    && rm -rf mtheme-master master.zip

# install NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -\
    && apt install nodejs -y\
    && node -v

# uninstall all unneeded software
RUN apt remove wget curl zip -y\
    && apt-get clean -y\
    && apt autoclean -y\
    && apt autoremove -y\
    && rm -rf /var/cache/apt
