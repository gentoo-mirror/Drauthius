# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils toolchain-funcs

DESCRIPTION="Animated sprite editor & pixel art tool"
HOMEPAGE="http://www.aseprite.org"
LICENSE="Proprietary"
SLOT="0"

PATCHES=( "${FILESDIR}/${PN}-system_libarchive.patch" )

if [[ ${PV} = 9999* || ${PV} = *beta* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/aseprite/aseprite"
	EGIT_BRANCH="master"
	if [[ ${PV} != 9999* ]]; then
		EGIT_COMMIT="v${PV/_/-}"
	fi
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
	+system-giflib
	+system-jpeg
	+system-libpng
	+system-libwebp
	+system-pixman
	+system-tinyxml
	+system-zlib"

RDEPEND="
	app-arch/libarchive
	app-text/cmark
	system-tinyxml? ( dev-libs/tinyxml )
	system-allegro? ( media-libs/allegro:0[X,png] )
	system-giflib? ( >=media-libs/giflib-5.0 )
	system-libpng? ( media-libs/libpng:0 )
	webp? ( system-libwebp? ( media-libs/libwebp ) )
	system-curl? ( net-misc/curl )
	system-zlib? ( sys-libs/zlib )
	system-jpeg? ( virtual/jpeg:= )
	x11-libs/libX11
	x11-libs/libXxf86dga
	system-pixman? ( x11-libs/pixman )"
DEPEND="$RDEPEND
	app-arch/unzip"
	#dev-cpp/gtest

DOCS=( EULA.txt
	docs/ase-file-specs.md
	docs/LICENSES.md
	README.md )

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
	use debug && CMAKE_BUILD_TYPE=Debug || CMAKE_BUILD_TYPE=Release

	local mycmakeargs=(
		-DCURL_STATICLIB=OFF
		-DENABLE_UPDATER=OFF
		-DFULLSCREEN_PLATFORM=ON
		-DENABLE_TESTS=OFF
		-DBUILD_GMOCK=OFF
		$(use system-pixman && echo \
			-DPIXMAN_DIR="$($(tc-getPKG_CONFIG) --variable=includedir pixman-1)/pixman-1" \
			-DPIXMAN_LIBRARY="$($(tc-getPKG_CONFIG) --variable=libdir pixman-1)/libpixman-1.so")
		-DUSE_SHARED_CMARK=ON
		-DUSE_SHARED_CURL="$(usex system-curl)"
		-DUSE_SHARED_GIFLIB="$(usex system-giflib)"
		-DUSE_SHARED_JPEGLIB="$(usex system-jpeg)"
		-DUSE_SHARED_LIBARCHIVE=ON
		-DUSE_SHARED_LIBPNG="$(usex system-libpng)"
		-DUSE_SHARED_LIBLOADPNG="$(usex system-allegro)"
		-DUSE_SHARED_LIBWEBP="$(usex system-libwebp)"
		-DUSE_SHARED_TINYXML="$(usex system-tinyxml)"
		-DUSE_SHARED_PIXMAN="$(usex system-pixman)"
		-DUSE_SHARED_FREETYPE=OFF # Currently requires non-distributed internal files."
		-DUSE_SHARED_ALLEGRO4="$(usex system-allegro)"
		-DWITH_WEBP_SUPPORT="$(usex webp)"
		-DENABLE_MEMLEAK="$(usex memleak)"
	)

	cmake-utils_src_configure
}

pkg_postinst() {
	elog "Aseprite is for personal use only. You may not distribute it."
}
