# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )

inherit python-any-r1 git-r3

DESCRIPTION="Skia library for Aseprite"
HOMEPAGE="https://skia.org"

EGIT_REPO_URI="https://github.com/aseprite/skia"
EGIT_BRANCH="aseprite-m${PR/r/}"

DEPOT_TOOLS_URI="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
DEPOT_TOOLS_COMMIT="master"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="debug webp"

DEPEND="${PYTHON_DEPS}"
RDEPEND="
	dev-libs/expat
	dev-util/ninja
	media-libs/libjpeg-turbo
	media-libs/libpng
	webp? ( media-libs/libwebp )
	sys-libs/zlib"
BDEPEND=""

src_unpack() {
	git-r3_src_unpack

	cd "${S}"
	python2.7 tools/git-sync-deps || die "Failed to sync dependencies"

	EGIT_BRANCH="$DEPOT_TOOLS_COMMIT"
	git-r3_fetch "$DEPOT_TOOLS_URI"
	git-r3_checkout "$DEPOT_TOOLS_URI" depot_tools
}

src_configure() {
	local myskiaargs=(
		is_debug=$(usex debug true false)
		is_official_build=true
		skia_use_system_expat=true
		skia_use_system_icu=false # Samples won't build
		skia_use_system_libjpeg_turbo=true
		skia_use_system_libpng=true
		skia_use_system_libwebp=$(usex webp true false)
		skia_use_system_zlib=true
	)

	cd "${S}"
	export PATH="$PATH:${S}/depot_tools"
	gn gen out/Release --args="${myskiaargs[*]}" || die "Failed to configure skia"
}

src_compile() {
	ninja -C "out/$(usex debug Debug Release)" skia || die "Failed to compile skia"
}

src_install() {
	insinto /var/lib/aseprite-skia/
	doins -r include
	insinto /var/lib/aseprite-skia/src
	doins -r src/gpu
	insinto /var/lib/aseprite-skia/third_party
	doins -r third_party/skcms

	insinto /var/lib/aseprite-skia/out/$(usex debug Debug Release)
	dodir /var/lib/aseprite-skia/out/$(usex debug Debug Release)
	newins out/*/libskia.a libskia.a
}
