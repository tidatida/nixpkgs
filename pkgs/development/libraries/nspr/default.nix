{ stdenv, fetchurl, mkCrossDerivation, isHost64bit, autoconf
, CoreServices ? null }:

let version = "4.13.1"; in

mkCrossDerivation {
  name = "nspr-${version}";

  src = fetchurl {
    url = "mirror://mozilla/nspr/releases/v${version}/src/nspr-${version}.tar.gz";
    sha256 = "5e4c1751339a76e7c772c0c04747488d7f8c98980b434dc846977e43117833ab";
  };

  outputs = [ "out" "dev" ];
  outputBin = "dev";

  nativeBuildInputs = stdenv.lib.optional (stdenv ? cross) [ autoconf ];

  buildInputs = [] ++ stdenv.lib.optionals stdenv.isDarwin [ CoreServices ];

  enableParallelBuilding = true;

  meta = {
    homepage = http://www.mozilla.org/projects/nspr/;
    description = "Netscape Portable Runtime, a platform-neutral API for system-level and libc-like functions";
    platforms = stdenv.lib.platforms.all;
  };
}
(crossCompiling: {
  patches =
    # For cross-compile, fix broken understanding for host/build/target by
    # the configure script. Build system is where code is built, host is where
    # it will run. See https://bugzilla.mozilla.org/show_bug.cgi?id=742033
    stdenv.lib.optional crossCompiling [ ./cross-compile.patch ] ++
    # Fix for GCC/Windows build. See https://bugzilla.mozilla.org/show_bug.cgi?id=1317176
    stdenv.lib.optional (crossCompiling && stdenv.cross.libc == "msvcrt") [ ./static-tls.patch ];

  preConfigure = ''
      cd nspr
  '' + stdenv.lib.optionalString crossCompiling ''
      # Regenerate configure script after patching.
      autoconf
      
  '';

  configureFlags = [
    "--enable-optimize"
    "--disable-debug"
  ] ++ stdenv.lib.optional (isHost64bit crossCompiling) "--enable-64bit";

  # Delete static libraries. But for Windows, delete just the real static
  # libraries and leave the DLL import libraries.
  postInstall = (if crossCompiling && stdenv.cross.libc == "msvcrt" then ''
    find $out -name "*_s.a" -delete
  '' else ''
    find $out -name "*.a" -delete
  '') + ''
    moveToOutput share "$dev" # just aclocal
  '';
})
