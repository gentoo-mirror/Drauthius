# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit git-r3

EGIT_REPO_URI="https://github.com/HaxeFoundation/${PN}"
EGIT_COMMIT=${PV}
SRC_URI=""
KEYWORDS="~amd64 ~x86"

DESCRIPTION="Haxe cross-platform toolkit"
HOMEPAGE="http://haxe.org/"

LICENSE="GPL-2 LGPL-2.1 BSD"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-lang/neko
	>=dev-lang/ocaml-4.02[ocamlopt]
	dev-libs/libpcre
	dev-ml/camlp4[ocamlopt]
	sys-libs/zlib"

MAKEOPTS+=" -j1"

src_install() {
	mkdir -p "${D}/usr/bin" # Missing from install target
	emake INSTALL_DIR="${D}/usr" install
	# Strip destination from haxelib.
	sed -i "s|${D}||" "${D}/usr/bin/haxelib"
}
