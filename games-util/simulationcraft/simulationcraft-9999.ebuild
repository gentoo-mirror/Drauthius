# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="SimulationCraft is a tool to explore combat mechanics in the popular MMO RPG World of Warcraft. It is a multi-player event-driven simulator written in C++ that models raid damage."
HOMEPAGE="http://simulationcraft.org/"
LICENSE="GPL-3.0"
SLOT="0"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/simulationcraft/simc.git"
	EGIT_BRANCH="legion-dev"
fi

IUSE="
	+gui"

RDEPEND="gui? ( dev-qt/qtchooser )"
DEPEND="
	${RDEPEND}
	dev-libs/openssl
	gui? ( dev-qt/qtwebkit:5 )
"

src_configure() {
	use gui && qtchooser -run-tool=qmake -qt=5 simcqt.pro PREFIX="${D}/usr" CONFIG+=openssl LIBS+="-lssl -lcrypto"
}

src_compile() {
	emake -C engine OPENSSL=1 optimized
	use gui && emake
}

src_install() {
	install -D -m755 engine/simc "${D}"/usr/bin/simc
	use gui && emake install
}
