{stdenv, fetchurl, fetchgit, cmake, openssl, nss, pkgconfig, nspr, bash, debug ? false}:
let
  s = # Generated upstream information
  rec {
    baseName="badvpn";
    version="1.999.129";
    name="${baseName}-${version}";
    hash="078gax6yifkf9y9g01wn1p0dypvgiwcsdmzp1bhwwfi0fbpnzzgl";
    url="https://github.com/ambrop72/badvpn/archive/1.999.129.tar.gz";
    sha256="078gax6yifkf9y9g01wn1p0dypvgiwcsdmzp1bhwwfi0fbpnzzgl";
  };
  buildInputs = [
    cmake openssl nss pkgconfig nspr
  ];
  compileFlags = "-O3 ${stdenv.lib.optionalString (!debug) "-DNDEBUG"}";
in
stdenv.mkDerivation {
  inherit (s) name version;
  inherit buildInputs;

  src = fetchgit {
    url = https://github.com/ambrop72/badvpn;
    rev = "1cdcaf8c3cfe1c8cf5cffaed8a2e906a4222ad03";
    sha256 = "0kwk26qmbmfz3qyviy603bzch7nh7zp2mhnrkvfn7fjh624bgjfy";
  };

  preConfigure = ''
    find . -name '*.sh' -exec sed -e 's@#!/bin/sh@${stdenv.shell}@' -i '{}' ';'
    find . -name '*.sh' -exec sed -e 's@#!/bin/bash@${bash}/bin/bash@' -i '{}' ';'
    cmakeFlagsArray=("-DCMAKE_BUILD_TYPE=" "-DCMAKE_C_FLAGS=${compileFlags}");
  '';

  meta = {
    inherit (s) version;
    description = ''A set of network-related (mostly VPN-related) tools'';
    license = stdenv.lib.licenses.bsd3 ;
    maintainers = [stdenv.lib.maintainers.raskin];
    platforms = stdenv.lib.platforms.linux;
  };
}
