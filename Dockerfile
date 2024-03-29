FROM rust:alpine

# to remove the cache at the end, all apk installs must happen in one step,
# see https://github.com/gliderlabs/docker-alpine/issues/45
RUN apk add --update \
        texlive \
        texlive-luatex \
        xdvik texlive-dvi \
        texmf-dist \
        texmf-dist-bibtexextra \
        texmf-dist-formatsextra \
        texmf-dist-latexextra \
        texmf-dist-science \
        texmf-dist-pictures \
        texmf-dist-fontsextra \
 \
        libc-dev libxml2-dev libffi-dev g++ \
        make git jq rsync nodejs \
        python3 zip curl \
        tokei \
        exiftool \
        font-jetbrains-mono-nl && \
    rm -rf /var/cache/apk/*

# the `biber` package in the repos is too new, so we manually download version 2.17 from sourceforge
# RUN wget -O- https://master.dl.sourceforge.net/project/biblatex-biber/biblatex-biber/2.17/binaries/Linux-musl/biber-linux_x86_64-musl.tar.gz?viasf=1 | tar xzv -C /bin
RUN wget -O- https://downloads.rubixdev.de/biber-linux_x86_64-musl.tar.gz | tar xzv -C /bin

# install Fira Sans
WORKDIR /usr/local/share/fonts
RUN curl --proto '=https' -sSf "https://fonts.google.com/download?family=Fira%20Sans" > fira.zip\
    && unzip fira.zip\
    && rm fira.zip OFL.txt\
    && fc-cache -f -v

WORKDIR /presentation
ENV RUSTFLAGS="-C target-feature=-crt-static"
ENV CARGO_TARGET_DIR=/root/.cache/cargo
ENV CARGO_HOME=/root/cargo
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
ENV PATH=${PATH}:${CARGO_HOME}/bin

RUN cargo install --git https://github.com/rush-rs/lirstings --force\
    && apk del curl zip\
    && git clone https://github.com/rush-rs/presentation \
    && git config --global --add safe.directory /presentation/presentation/deps/rush

