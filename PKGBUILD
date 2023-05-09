pkgname=starship-git
_pkgname=starship
pkgver=1.14.2.2726.g2641a3786
pkgrel=1
pkgdesc="The cross-shell prompt for astronauts"
arch=('any')
url='https://github.com/starship/starship'
license=('ISC')
depends=()
optdepends=()
makedepends=('docker-rootless-extras')
conflicts=('starship')
source=("$_pkgname::git+https://github.com/starship/starship.git")
sha256sums=('SKIP')

prefix='/data/data/com.termux/files/usr'

pkgver() {
  cd $_pkgname

  version_fmt=""
  version_fmt+="$(grep '^version =' Cargo.toml | head -n1 | cut -d\" -f2)"
  version_fmt+=".$(git rev-list --count HEAD)"
  version_fmt+=".g$(git rev-parse --short HEAD)"
  echo "${version_fmt}"
}

prepare() {
  cd $_pkgname

  # Fetch *Rust* packages on host, to avoid write permission issues with `~/.cargo/`
  cargo fetch \
    --locked \
    --target aarch64-unknown-linux-gnu \
    --manifest-path Cargo.toml

  chmod 644 "${HOME}/.cargo/registry/src/github.com-"*"/pin-utils-0.1.0/src/"*

  # Patches
  patch --forward --strip=1 --input="${startdir}/5071.patch"
}

build() {
  cd $_pkgname

  container_name=starship_termux_container
  image_name=termux_image

  export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/docker.sock"

  if [[ "$(docker images --quiet "${image_name}:latest" 2> /dev/null)" == "" ]]; then
    docker build --tag $image_name $startdir
  fi
  if docker container inspect $container_name > /dev/null 2>&1; then
    docker container stop $container_name
  fi

  docker container run \
    --detach \
    --rm \
    --interactive \
    --name $container_name \
    --mount type=bind,source=".",target=/tmp/starship/ \
    --volume "${HOME}/.cargo/registry:/home/build/.cargo/registry" \
    $image_name

  docker cp "${startdir}/config.toml" "${container_name}:/home/build/.cargo/"
  mkdir --parents --mode 777 target/
  docker container exec $container_name sh /tmp/starship/build.sh

  # `root` user in the *Docker* container maps to the user running *Docker*
  docker container exec $container_name sudo chown root:root /tmp/starship/target/aarch64-linux-android/release/starship

  docker container stop $container_name
}

package() {
  cd $_pkgname

  install -Dm700 target/aarch64-linux-android/release/starship "${pkgdir}/${prefix}/bin/${_pkgname}"
  install -Dm600 LICENSE "${pkgdir}/${prefix}/share/doc/starship/LICENSE"
}
