TERMUX_PKG_HOMEPAGE=https://luajit.org/
TERMUX_PKG_DESCRIPTION="Just-In-Time Compiler for Lua"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="Leonid Plyushch <leonid.plyushch@gmail.com"
TERMUX_PKG_VERSION=2.1.0~beta3
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://github.com/LuaJIT/LuaJIT/archive/v2.1.0-beta3.tar.gz
TERMUX_PKG_SHA256=409f7fe570d3c16558e594421c47bdd130238323c9d6fd6c83dedd2aaeb082a8
TERMUX_PKG_BREAKS="libluajit-dev"
TERMUX_PKG_REPLACES="libluajit-dev"
TERMUX_PKG_EXTRA_MAKE_ARGS="amalg PREFIX=$TERMUX_PREFIX"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	# luajit wants same pointer size for host and target build
	export HOST_CC="gcc"
	if [ $TERMUX_ARCH_BITS = "32" ]; then
		if [ $(uname) = "Linux" ]; then
			# NOTE: "apt install libc6-dev-i386" for 32-bit headers
			export HOST_CFLAGS="-m32"
			export HOST_LDFLAGS="-m32"
		elif [ $(uname) = "Darwin" ]; then
			export HOST_CFLAGS="-m32 -arch i386"
			export HOST_LDFLAGS="-arch i386"
		fi
	fi
	export TARGET_FLAGS="$CFLAGS $CPPFLAGS $LDFLAGS"
	export TARGET_SYS=Linux
	unset CFLAGS LDFLAGS
}

termux_step_make_install () {
	mkdir -p $TERMUX_PREFIX/include/luajit-2.0/
	cp -f $TERMUX_PKG_SRCDIR/src/{lauxlib.h,lua.h,lua.hpp,luaconf.h,luajit.h,lualib.h} $TERMUX_PREFIX/include/luajit-2.0/
	rm -f $TERMUX_PREFIX/lib/libluajit*

	install -Dm600 $TERMUX_PKG_SRCDIR/src/libluajit.so $TERMUX_PREFIX/lib/libluajit-5.1.so
	(cd $TERMUX_PREFIX/lib; ln -s -f libluajit-5.1.so libluajit.so)

	install -Dm600 $TERMUX_PKG_SRCDIR/etc/luajit.1 $TERMUX_PREFIX/share/man/man1/luajit.1
	install -Dm600 $TERMUX_PKG_SRCDIR/etc/luajit.pc $TERMUX_PREFIX/lib/pkgconfig/luajit.pc
	install -Dm700 $TERMUX_PKG_SRCDIR/src/luajit $TERMUX_PREFIX/bin/luajit

	# Files needed for the -b option (http://luajit.org/running.html) to work.
	# Note that they end up in the 'luajit' subpackage, not the 'libluajit' one.
	TERMUX_LUAJIT_JIT_FOLDER_RELATIVE=share/luajit-$TERMUX_PKG_VERSION/jit
	local TERMUX_LUAJIT_JIT_FOLDER=$TERMUX_PREFIX/$TERMUX_LUAJIT_JIT_FOLDER_RELATIVE
	rm -Rf $TERMUX_LUAJIT_JIT_FOLDER
	mkdir -p $TERMUX_LUAJIT_JIT_FOLDER
	cp $TERMUX_PKG_SRCDIR/src/jit/*lua $TERMUX_LUAJIT_JIT_FOLDER
}
