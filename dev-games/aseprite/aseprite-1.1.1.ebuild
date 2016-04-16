# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils toolchain-funcs git-r3

DESCRIPTION="Animated sprite editor & pixel art tool"
HOMEPAGE="http://www.aseprite.org"
EGIT_REPO_URI="https://github.com/aseprite/aseprite"
EGIT_COMMIT="v${PV}"
KEYWORDS="~amd64 ~x86"

LICENSE="GPL-2"
SLOT="0"

IUSE="debug memleak +system-curl +system-tinyxml +system-giflib +system-libpng +system-zlib +system-jpeg +system-pixman +system-freetype system-allegro"

RDEPEND="
	system-tinyxml? ( dev-libs/tinyxml )
	system-allegro? ( media-libs/allegro:0[X,png] )
	system-freetype? ( media-libs/freetype:2 )
	system-giflib? ( >=media-libs/giflib-5.0 )
	system-libpng? ( media-libs/libpng:0 )
	system-curl? ( net-misc/curl )
	system-zlib? ( sys-libs/zlib )
	system-jpeg? ( virtual/jpeg:= )
	x11-libs/libX11
	system-pixman? ( x11-libs/pixman )"
DEPEND="$RDEPEND
	dev-cpp/gtest"

DOCS=( docs/files/ase.txt
	docs/files/fli.txt
	docs/files/msk.txt
	docs/files/pic.txt
	docs/files/picpro.txt
	README.md )

src_prepare() {
	use system-freetype && epatch "${FILESDIR}/aseprite-freetype-include-${PV}.patch"

	cmake-utils_src_prepare

	if use system-allegro; then
		ewarn "system-allegro is enabled. It has a bug which prevents"
		ewarn "resizing of the Aseprite window."
	fi
}

src_configure() {
	use debug && CMAKE_BUILD_TYPE=Debug

	local mycmakeargs=(
		-DCURL_STATICLIB=OFF
		-DENABLE_UPDATER=OFF
		-DFULLSCREEN_PLATFORM=ON
		$(use system-pixman && echo \
			-DLIBPIXMAN_INCLUDE_DIR="$($(tc-getPKG_CONFIG) --variable=includedir pixman-1)/pixman-1" \
			-DLIBPIXMAN_LIBRARY="$($(tc-getPKG_CONFIG) --variable=libdir pixman-1)/libpixman-1.so")
		$(use system-freetype && echo \
			-DFREETYPE_INCLUDE_DIR="$($(tc-getPKG_CONFIG) --variable=includedir freetype2)" \
			-DFREETYPE_LIBRARY="$($(tc-getPKG_CONFIG) --variable=libdir freetype2)/libfreetype.so")
		-DUSE_SHARED_CURL="$(usex system-curl)"
		-DUSE_SHARED_GIFLIB="$(usex system-giflib)"
		-DUSE_SHARED_JPEGLIB="$(usex system-jpeg)"
		-DUSE_SHARED_ZLIB="$(usex system-zlib)"
		-DUSE_SHARED_LIBPNG="$(usex system-libpng)"
		-DUSE_SHARED_TINYXML="$(usex system-tinyxml)"
		-DUSE_SHARED_PIXMAN="$(usex system-pixman)"
		-DUSE_SHARED_FREETYPE="$(usex system-freetype)"
		-DUSE_SHARED_ALLEGRO4="$(usex system-allegro)"
		-DUSE_SHARED_LIBLOADPNG="$(usex system-allegro)"
		-DENABLE_memleak="$(usex memleak)"
	)

	cmake-utils_src_configure
}
