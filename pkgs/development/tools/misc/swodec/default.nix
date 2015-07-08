{ stdenv, fetchgit, glib, libswo, pkgconfig, automake, autoconf, libtool }:
stdenv.mkDerivation rec {
  name = "swodec";

  src = fetchgit {
    url = git://git.zapb.de/swodec.git;
    sha256 = "12p2yf6qmbdh9prvbywz4jy3cniqx2n51fg7yh2i0m52fq87jrxh";
  };

  buildInputs = [ glib libswo pkgconfig automake autoconf libtool ];

  preConfigure = "autoreconf -vfi";
  
  meta = with stdenv.lib; {
    description = "Command-line utility to decode SWO trace data";
    homepage = http://git.zapb.de/swodec.git/;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
