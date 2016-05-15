{ stdenv, fetchurl, nspr, perl, zlib, sqlite, nssTools, mkCrossDerivation, isHost64bit, getHostDrv }:

let

  nssPEM = fetchurl {
    url = http://dev.gentoo.org/~polynomial-c/mozilla/nss-3.15.4-pem-support-20140109.patch.xz;
    sha256 = "10ibz6y0hknac15zr6dw4gv9nb5r5z9ym6gq18j3xqx7v7n3vpdw";
  };

in mkCrossDerivation rec {
  name = "nss-${version}";
  version = "3.27.2";

  src = fetchurl {
    url = "mirror://mozilla/security/nss/releases/NSS_3_27_2_RTM/src/${name}.tar.gz";
    sha256 = "dc8ac8524469d0230274fd13a53fdcd74efe4aa67205dde1a4a92be87dc28524";
  };

  nativeBuildInputs = [ perl ];
  buildInputs = [ nspr zlib sqlite ];

  patches =
    [ ./nss-3.21-gentoo-fixups.patch
      # Based on http://patch-tracker.debian.org/patch/series/dl/nss/2:3.15.4-1/85_security_load.patch
      ./85_security_load.patch
      ./cross-compile-windows.patch
    ];

  postPatch = ''
    # Fix up the patch from Gentoo.
    sed -i \
      -e "/^PREFIX =/s|= /usr|= $out|" \
      -e '/@libdir@/s|gentoo/nss|lib|' \
      -e '/ln -sf/d' \
      nss/config/Makefile

    # Note for spacing/tab nazis: The TAB characters are intentional!
    cat >> nss/config/Makefile <<INSTALL_TARGET
    install:
    	mkdir -p \$(DIST)/lib/pkgconfig
    	cp nss.pc \$(DIST)/lib/pkgconfig
    INSTALL_TARGET
  '';

  outputs = [ "out" "dev" "tools" ];

  NIX_CFLAGS_COMPILE = "-Wno-error";

  postInstall = ''
    rm -rf $out/private
    mv $out/public $out/include
    mv $out/*.OBJ/* $out/
    rmdir $out/*.OBJ

    cp -av config/nss-config $out/bin/nss-config

    ln -s lib $out/lib64
  '';

  meta = {
    homepage = https://developer.mozilla.org/en-US/docs/NSS;
    description = "A set of libraries for development of security-enabled client and server applications";
    platforms = stdenv.lib.platforms.all;
  };
}
(crossCompiling: let
  nssCpuArch = if stdenv.cross.arch == "x86" then "x386" else stdenv.cross.arch;
  nssOsArch = if stdenv.cross.libc == "msvcrt" then "WINNT" else "Linux";
  shlibsignCmd = if crossCompiling then "${nssTools}/bin/shlibsign" else "LD_LIBRARY_PATH=$out/lib $out/bin/shlibsign";
  shLibPattern = if crossCompiling && stdenv.cross.libc == "msvcrt" then (x: "${x}.dll") else (x: "lib${x}.so");
in {
  prePatch = stdenv.lib.optionalString (!crossCompiling || stdenv.cross.libc != "msvcrt") ''
    xz -d < ${nssPEM} | patch -p1
  '';

  preConfigure = ''
    cd nss
  '' + stdenv.lib.optionalString crossCompiling ''
    # Prevent the build system from trying to build nsinstall.
    sed -i 's|coreconf||' manifest.mn
    # Build nsinstall ourselves.
    (cd coreconf/nsinstall && cc nsinstall.c pathsub.c -o nsinstall)
    # Make the build system use this nsinstall.
    sed -i "s|^NSINSTALL *=.*$|NSINSTALL = $(pwd)/coreconf/nsinstall/nsinstall|" coreconf/*.mk
  '' + stdenv.lib.optionalString (crossCompiling && stdenv.cross.libc == "msvcrt") ''
    # Fix invalid -GT flag on Windows+GCC.
    sed -i "s|^OS_CFLAGS += -GT$||" coreconf/WINNT.mk
    # Make sure ar and windres are used right. Can't set this in makeFlags due to spaces.
    echo 'AR = ${stdenv.cross.config}-ar cr $@' >> coreconf/WINNT.mk
    echo 'RC = ${stdenv.cross.config}-windres -O coff --use-temp-file' >> coreconf/WINNT.mk
  '';

  makeFlags = [
    "NSPR_INCLUDE_DIR=${(getHostDrv crossCompiling nspr).dev}/include/nspr"
    "NSPR_LIB_DIR=${(getHostDrv crossCompiling nspr).out}/lib"
    "NSDISTMODE=copy"
    "BUILD_OPT=1"
    "SOURCE_PREFIX=\$(out)"
    "NSS_ENABLE_ECC=1"
    "USE_SYSTEM_ZLIB=1"
    "NSS_USE_SYSTEM_SQLITE=1"
  ] ++ stdenv.lib.optional (isHost64bit crossCompiling) "USE_64=1"
    ++ stdenv.lib.optional crossCompiling [
    "CROSS_COMPILE=1"
    "CC=${stdenv.cross.config}-gcc"
    "CCC=${stdenv.cross.config}-g++"
    "LINK=${stdenv.cross.config}-gcc"
    "AS=${stdenv.cross.config}-as"
    "RANLIB=${stdenv.cross.config}-ranlib"
    "OS_TEST=${nssCpuArch}"
    "CPU_ARCH=${nssCpuArch}"
    "OS_ARCH=${nssOsArch}"
    "OS_TARGET=${nssOsArch}"
    "NS_USE_GCC=1"
    "SQLITE_LIB_DIR=${(getHostDrv crossCompiling sqlite).out}/lib"
  ] ++ stdenv.lib.optional (crossCompiling && stdenv.cross.libc == "msvcrt") [
    "USE_MSYS=1"
    "ZLIB_LIBS=-lz"
    # With this it will link to libsqlite3.dll.a, not libsqlite3.a which
    # probably doesn't exit.
    "SQLITE_LIB_NAME=sqlite3.dll"
  ];
  
  postFixup = ''
    for libname in freebl3 nssdbm3 softokn3
    do
      libfile="$out/lib/${shLibPattern "$libname"}"
      ${shlibsignCmd} -v -i "$libfile"
    done

    moveToOutput bin "$tools"
    moveToOutput bin/nss-config "$dev"
    moveToOutput lib/libcrmf.a "$dev" # needed by firefox, for example
    rm "$out"/lib/*.a
  '';
})

