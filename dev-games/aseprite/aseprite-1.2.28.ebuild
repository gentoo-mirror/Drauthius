# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7
inherit cmake-utils toolchain-funcs

DESCRIPTION="Animated sprite editor & pixel art tool"
HOMEPAGE="http://www.aseprite.org"
LICENSE="Proprietary"
SLOT="0"

PATCHES=(
	"${FILESDIR}/${P}-system_libarchive.patch"
	"${FILESDIR}/${P}-system_libwebp.patch"
)

SKIA_VERSION="m81-b607b32047"
SKIA_FILE="Skia-Linux-Release-${ARCH/amd64/x64}.zip"
SKIA_BASE_URL="https://github.com/${PN}/skia/releases/download"
SKIA_URI="${SKIA_BASE_URL}/${SKIA_VERSION}/${SKIA_FILE} -> ${P}-skia-${SKIA_VERSION}.zip"

ASEPRITE_FILE="${PN^}-v${PV//_/-}-Source.zip"
ASEPRITE_URI="https://github.com/${PN}/${PN}/releases/download/v${PV//_/-}/${ASEPRITE_FILE}"

SRC_URI="${ASEPRITE_URI} ${SKIA_URI}"
KEYWORDS="~amd64 ~x86"

IUSE="
	debug
	memleak
	webp"

RDEPEND="
	app-arch/libarchive
	app-text/cmark
	dev-libs/expat
	dev-libs/tinyxml
	media-libs/freetype:2
	>=media-libs/giflib-5.0
	media-libs/fontconfig
	media-libs/libpng:0
	webp? ( media-libs/libwebp )
	net-misc/curl
	sys-apps/util-linux
	sys-libs/zlib
	virtual/jpeg:=
	x11-libs/libX11
	x11-libs/pixman"

DOCS=( EULA.txt
	docs/ase-file-specs.md
	docs/LICENSES.md
	README.md )

src_unpack() {
	mkdir -p "${P}/skia"
	cd "${P}"
	unpack "${ASEPRITE_FILE}"
	( cd skia && unpack "${P}-skia-${SKIA_VERSION}.zip" )
}

src_prepare() {
	cmake-utils_src_prepare
}

src_configure() {
	use debug && CMAKE_BUILD_TYPE=Debug || CMAKE_BUILD_TYPE=Release

	local mycmakeargs=(
		-DENABLE_UPDATER=OFF
		-DFULLSCREEN_PLATFORM=ON
		-DUSE_SHARED_CMARK=ON
		-DUSE_SHARED_CURL=ON
		-DUSE_SHARED_GIFLIB=ON
		-DUSE_SHARED_JPEGLIB=ON
		-DUSE_SHARED_ZLIB=ON
		-DUSE_SHARED_LIBARCHIVE=ON
		-DUSE_SHARED_LIBPNG=ON
		-DUSE_SHARED_TINYXML=ON
		-DUSE_SHARED_PIXMAN=ON
		-DUSE_SHARED_FREETYPE=ON
		-DUSE_SHARED_HARFBUZZ=ON
		-DUSE_SHARED_WEBP=ON
		-DWITH_WEBP_SUPPORT="$(usex webp)"
		-DENABLE_MEMLEAK="$(usex memleak)"
		-DSKIA_DIR="${S}/skia"
	)

	cmake-utils_src_configure
}

pkg_postinst() {
	ewarn "Aseprite is for personal use only. You may not distribute it."
}
