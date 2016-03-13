# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-engines/love/love-0.8.0.ebuild,v 1.10 2014/07/06 13:20:24 mgorny Exp $

EAPI=3

inherit base git-r3

EGIT_REPO_URI="https://github.com/HaxeFoundation/${PN}"
EGIT_COMMIT=${PV}
SRC_URI=""
KEYWORDS="amd64 ~arm ~ppc x86"

DESCRIPTION="Haxe cross-platform toolkit"
HOMEPAGE="http://haxe.org/"

LICENSE="GPL-2 LGPL-2.1 BSD"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-lang/ocaml[ocamlopt]"

MAKEOPTS+=" -j1"

src_install() {
	mkdir -p "${D}/usr/bin" # Missing from install target
	emake INSTALL_DIR="${D}/usr" install
	# Strip destination from haxelib.
	sed -i "s|${D}||" "${D}/usr/bin/haxelib"
}
