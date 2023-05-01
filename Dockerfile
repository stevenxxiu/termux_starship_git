# syntax = docker/dockerfile:1.2
FROM archlinux

RUN echo 'Server = https://sydney.mirror.pkgbuild.com/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# `makepkg` cannot (and should not) be run as root:
RUN useradd --create-home build && \
    mkdir /etc/sudoers.d/ && \
    echo "build ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/build

# Install packages
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman --sync --refresh --sysupgrade --noconfirm --needed \
        base-devel \
        cmake \
        git \
        rustup

# Continue execution (and `CMD`) as build:
USER build
WORKDIR /home/build/

COPY config.toml /home/build/.cargo/

RUN git clone https://aur.archlinux.org/android-ndk.git && cd android-ndk \
    && makepkg --syncdeps --install --noconfirm \
    && cd .. \
    && rm -rf android-ndk

RUN rustup default stable \
    && rustup target add aarch64-linux-android
