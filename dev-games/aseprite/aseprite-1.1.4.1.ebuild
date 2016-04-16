# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils toolchain-funcs

DESCRIPTION="Animated sprite editor & pixel art tool"
HOMEPAGE="http://www.aseprite.org"
LICENSE="GPL-2"
SLOT="0"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/aseprite/aseprite"
	EGIT_COMMIT="master"
else
	SRC_URI="https://github.com/${PN}/${PN}/releases/download/v${PV}/${PN^}-v${PV}-Source.zip"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}"
fi

IUSE="
	debug
	memleak
	webp
	system-allegro
	+system-curl
	+system-freetype
	+system-giflib
	+system-jpeg
	+system-libpng
	+system-libwebp
	+system-pixman
	+system-tinyxml
	+system-zlib"

RDEPEND="
	system-tinyxml? ( dev-libs/tinyxml )
	system-allegro? ( media-libs/allegro:0[X,png] )
	system-freetype? ( media-libs/freetype:2 )
	system-giflib? ( >=media-libs/giflib-5.0 )
	system-libpng? ( media-libs/libpng:0 )
	webp? ( system-libwebp? ( media-libs/libwebp ) )
	system-curl? ( net-misc/curl )
	system-zlib? ( sys-libs/zlib )
	system-jpeg? ( virtual/jpeg:= )
	x11-libs/libX11
	system-pixman? ( x11-libs/pixman )"
DEPEND="$RDEPEND
	app-arch/unzip
	dev-cpp/gtest"

DOCS=( docs/files/ase.txt
	docs/files/fli.txt
	docs/files/msk.txt
	docs/files/pic.txt
	docs/files/picpro.txt
	README.md )
# EULA.txt not applicable to source code distribution.

src_prepare() {
	cmake-utils_src_prepare

	if use system-allegro; then
		ewarn "system-allegro is enabled. It has know issues which are solved"
		ewarn "in the bundled version:"
		ewarn " * You will not be able to resize the window."
		ewarn " * You will have problems adding HSV colours on non-English systems."
	fi
}

src_configure() {
	use debug && CMAKE_BUILD_TYPE=Debug

	local mycmakeargs=(
		-DCURL_STATICLIB=OFF
		-DENABLE_UPDATER=OFF
		-DFULLSCREEN_PLATFORM=ON
		-DENABLE_TESTS=ON
		$(use system-pixman && echo \
			-DLIBPIXMAN_INCLUDE_DIR="$($(tc-getPKG_CONFIG) --variable=includedir pixman-1)/pixman-1" \
			-DLIBPIXMAN_LIBRARY="$($(tc-getPKG_CONFIG) --variable=libdir pixman-1)/libpixman-1.so")
		$(use system-freetype && echo \
			-DFREETYPE_INCLUDE_DIR="$($(tc-getPKG_CONFIG) --variable=includedir freetype2)" \
			-DFREETYPE_LIBRARY="$($(tc-getPKG_CONFIG) --variable=libdir freetype2)/libfreetype.so")
		-DUSE_SHARED_ALLEGRO4="$(usex system-allegro)"
		-DUSE_SHARED_CURL="$(usex system-curl)"
		-DUSE_SHARED_FREETYPE="$(usex system-freetype)"
		-DUSE_SHARED_GIFLIB="$(usex system-giflib)"
		-DUSE_SHARED_JPEGLIB="$(usex system-jpeg)"
		-DUSE_SHARED_LIBLOADPNG="$(usex system-allegro)"
		-DUSE_SHARED_LIBPNG="$(usex system-libpng)"
		-DUSE_SHARED_PIXMAN="$(usex system-pixman)"
		-DUSE_SHARED_TINYXML="$(usex system-tinyxml)"
		-DUSE_SHARED_ZLIB="$(usex system-zlib)"
		-DWITH_WEBP_SUPPORT="$(usex webp)"
		-DUSE_SHARED_LIBWEBP="$(usex system-libwebp)"
		-DENABLE_memleak="$(usex memleak)"
	)

	cmake-utils_src_configure
}
