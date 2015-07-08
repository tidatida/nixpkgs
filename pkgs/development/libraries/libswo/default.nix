{ stdenv, fetchgit, pkgconfig, automake, autoconf, libtool }:

stdenv.mkDerivation rec {
  name = "libswo";

  src = fetchgit {
    url = git://git.zapb.de/libswo.git;
    sha256 = "08lqkd17041c3lw1iagqbqx8j4r7lq22b8kkhwjnhbd9f39hg23v";
  };

  buildInputs = [ pkgconfig automake autoconf libtool ];

  preConfigure = "autoreconf -vfi";
  
  meta = with stdenv.lib; {
    description = "Library to decode SWO trace data";
    homepage = http://git.zapb.de/libswo.git/;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
