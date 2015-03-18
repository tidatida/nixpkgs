{ stdenv, fetchurl, kdelibs, pkgconfig, doxygen, popplerQt4, taglib, exiv2, ffmpeg }:

stdenv.mkDerivation  {

  name = "kfilemetadata-4.14.3";

  src = fetchurl {
    url = "mirror://kde/stable/4.14.3/src/kfilemetadata-4.14.3.tar.xz";
    sha256 = "0wak1nphnphcam8r6pba7m2gld4w04dkk8qn23myjammv3myc59i";
  };

  buildInputs = [
    kdelibs popplerQt4 taglib exiv2 ffmpeg
  ];

  nativeBuildInputs = [ pkgconfig doxygen ];

}
