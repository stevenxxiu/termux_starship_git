pkgname=starship-git
_pkgname=starship
pkgver=1.14.2.2747.g4b3bcaee4
pkgrel=1
pkgdesc="The cross-shell prompt for astronauts"
arch=('aarch64')
url='https://github.com/starship/starship'
license=('ISC')
makedepends=('cargo' 'git')
conflicts=('starship')
source=("$_pkgname::git+https://github.com/starship/starship.git")
sha256sums=('SKIP')

TERMUX_PREFIX='/data/data/com.termux/files/usr'

pkgver() {
  cd "$_pkgname"

  version_fmt=""
  version_fmt+="$(grep '^version =' Cargo.toml | head -n1 | cut -d\" -f2)"
  version_fmt+=".$(git rev-list --count HEAD)"
  version_fmt+=".g$(git rev-parse --short HEAD)"
  echo "${version_fmt}"
}

prepare() {
  cd "$_pkgname"

  rustup target add aarch64-linux-android
  cargo fetch --target aarch64-linux-android

  # Patches
  patch --forward --strip 1 --input "${startdir}/5071.patch"
  patch --forward --strip 1 --input "${startdir}/0001-fix-directory-ignore-Git-repos-that-are-parents-of-t.patch"
  patch --forward --strip 1 --input "${startdir}/cargo-chrono-978.diff"
}

build() {
  cd "$_pkgname"

  export PATH="/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
  export RUSTFLAGS="-C link-args=-Wl,-rpath=${TERMUX_PREFIX}/lib"

  cargo build \
    --target aarch64-linux-android \
    --release \
    --no-default-features \
    --features notify,gix-features/zlib-stock,gix-features/rustsha1
}

package() {
  cd "$_pkgname"
  install -Dm700 -t "${pkgdir}${TERMUX_PREFIX}/bin" target/aarch64-linux-android/release/starship
  install -Dm600 -t "${pkgdir}${TERMUX_PREFIX}/share/doc/${_pkgname}" LICENSE
}
