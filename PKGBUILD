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
makedepends=('git' 'crystal' 'shards')
source=('crcophony::git+https://github.com/freyamade/crcophony.git')
provides=('crcophony')

package() {
    cd "$srcdir/crcophony"
    shards install
    mkdir -p "$pkgdir/usr/bin/"
    mkdir -p "$pkgdir/opt"
    crystal build src/crcophony.cr --release -o "$pkgdir/opt/crcophony" --progress
    printf "#!/bin/bash\n/opt/crcophony" > "$pkgdir/usr/bin/crcophony"
}
