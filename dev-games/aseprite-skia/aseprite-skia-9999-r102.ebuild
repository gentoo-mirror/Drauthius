# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9,10} )

inherit python-any-r1 git-r3 ninja-utils

DESCRIPTION="Skia library for Aseprite"
HOMEPAGE="https://skia.org"

EGIT_REPO_URI="https://github.com/aseprite/skia"
EGIT_BRANCH="aseprite-m${PR/r/}"

DEPOT_TOOLS_URI="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
DEPOT_TOOLS_COMMIT="main"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="debug"

RDEPEND="
	dev-libs/expat
	media-libs/harfbuzz
	media-libs/libjpeg-turbo
	media-libs/libpng
	media-libs/libwebp
	media-libs/freetype:2
	sys-libs/zlib"
BDEPEND="
	${PYTHON_DEPS}
	dev-util/ninja"

src_unpack() {
	git-r3_src_unpack

	sed -ri '/third_party\/externals\/(expat|icu|libjpeg|libpng|libwebp|zlib|harfbuzz|freetype)/d' "${S}/DEPS"

	cd "${S}"
	./tools/git-sync-deps || die "Failed to sync dependencies"

	EGIT_BRANCH="$DEPOT_TOOLS_COMMIT"
	git-r3_fetch "$DEPOT_TOOLS_URI"
	git-r3_checkout "$DEPOT_TOOLS_URI" depot_tools
}

src_configure() {
	local myskiaargs=(
		is_debug=$(usex debug true false)
		is_official_build=true
		skia_use_system_expat=true
		skia_use_system_icu=true
		skia_use_system_libjpeg_turbo=true
		skia_use_system_libpng=true
		skia_use_system_libwebp=true
		skia_use_system_zlib=true
		skia_use_sfntly=false
		skia_use_freetype=true
		skia_use_harfbuzz=true
		skia_pdf_subset_harfbuzz=true
		skia_use_system_freetype2=true
		skia_use_system_harfbuzz=true
	)

	cd "${S}"
	export PATH="$PATH:${S}/depot_tools"
	gn gen out/$(usex debug Debug Release) --args="${myskiaargs[*]}" || die "Failed to configure skia"
}

src_compile() {
	eninja -C "out/$(usex debug Debug Release)" skia modules || die "Failed to compile skia"
}

src_install() {
	insinto /var/lib/aseprite-skia/
	doins -r include
	doins -r modules
	insinto /var/lib/aseprite-skia/src
	doins -r src/gpu
	doins -r src/core
	insinto /var/lib/aseprite-skia/third_party
	doins -r third_party/skcms

	insinto /var/lib/aseprite-skia/out/$(usex debug Debug Release)
	dodir /var/lib/aseprite-skia/out/$(usex debug Debug Release)
	doins out/$(usex debug Debug Release)/lib*.a
}
