# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7
inherit cmake-utils toolchain-funcs xdg-utils

DESCRIPTION="Animated sprite editor & pixel art tool"
HOMEPAGE="http://www.aseprite.org"
LICENSE="Proprietary"
SLOT="0"

PATCHES=(
	"${FILESDIR}/${P}-system_harfbuzz.patch"
	"${FILESDIR}/${P}-system_libarchive.patch"
	"${FILESDIR}/${P}-system_libwebp.patch"
)

ASEPRITE_FILE="${PN^}-v${PV//_/-}-Source.zip"
ASEPRITE_URI="https://github.com/${PN}/${PN}/releases/download/v${PV//_/-}/${ASEPRITE_FILE}"

SRC_URI="${ASEPRITE_URI}"
KEYWORDS="~amd64 ~x86"
S="${WORKDIR}"

IUSE="
	debug
	memleak
	webp
	kde
"

RDEPEND="
	app-arch/libarchive
	app-text/cmark
	dev-libs/expat
	dev-libs/tinyxml
	=dev-games/aseprite-skia-9999-r102
	media-libs/freetype:2
	>=media-libs/giflib-5.0
	media-libs/fontconfig
	media-libs/libpng:0
	webp? ( media-libs/libwebp )
	net-misc/curl
	sys-apps/util-linux
	sys-libs/zlib
	virtual/jpeg:=
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/pixman
	kde? (
		 kde-apps/thumbnailers
	)"

DOCS=(
	EULA.txt
	docs/ase-file-specs.md
	docs/LICENSES.md
	README.md)

src_prepare() {
	cmake-utils_src_prepare

	sed -i "s:Icon=aseprite:Icon=${EPREFIX}/usr/share/aseprite/data/icons/ase256.png:" "${S}/src/desktop/linux/aseprite.desktop" || die
	sed -i "s:#!/usr/bin/sh:#!/bin/env sh:" "${S}/src/desktop/linux/aseprite-thumbnailer" || die
}

src_configure() {
	use debug && CMAKE_BUILD_TYPE=Debug || CMAKE_BUILD_TYPE=Release

	local mycmakeargs=(
		-DENABLE_UPDATER=OFF
		-DENABLE_CCACHE="$(has ccache "${FEATURES}" && echo 'ON' || echo 'OFF')"
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
		-DENABLE_DESKTOP_INTEGRATION=ON
		-DENABLE_QT_THUMBNAILER="$(usex kde)"
		-DENABLE_WEBP="$(usex webp)"
		-DENABLE_MEMLEAK="$(usex memleak)"
		-DLAF_BACKEND=skia
		-DLAF_WITH_EXAMPLES=OFF
		-DLAF_WITH_TESTS=OFF
		-DSKIA_DIR="/var/lib/aseprite-skia"
		-DSKIA_LIBRARY_DIR="/var/lib/aseprite-skia/out/Release"
	)

	cmake-utils_src_configure
}

pkg_postinst() {
	ewarn "Aseprite is for personal use only. You may not distribute it."

	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
