# Maintainer: freyamade <contact@freyama.de>

pkgname=crcophony-git
pkgver=0.6.0
pkgrel=1
pkgdesc='Fast, neat discord TUI written in Crystal'
arch=('x86_64')
url='https://github.com/freyamade/crcophony'
license=('MIT')
md5sums=('SKIP')
depends=('dbus' 'termbox-git')
makedepends=('git' 'crystal>=0.31.0' 'shards')
source=("$pkgname::git+https://github.com/freyamade/crcophony.git")
provides=('crcophony')

pkgver() {
    cd "$pkgname"
    printf "%s" "$(git rev-parse --short HEAD)"
}

build() {
    cd "$srcdir/$pkgname"
    shards build crcophony --release --progress -Dpreview_mt
}

package() {
    mkdir -p "$pkgdir/usr/bin/"
    mkdir -p "$pkgdir/opt"
    printf "#!/bin/bash\n/opt/crcophony" > "$pkgdir/usr/bin/crcophony"
    chmod +x "$pkgdir/usr/bin/crcophony"
    mv "$srcdir/$pkgname/bin/crcophony" "$pkgdir/opt/crcophony"
}
