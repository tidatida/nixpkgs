{ stdenv, fetchurl, pkgconfig, kdelibs, akonadi, kdepimlibs, qjson, xapian, kfilemetadata, boost }:

stdenv.mkDerivation {

  name = "baloo-4.14.3";

  src = fetchurl {
    url = "mirror://kde/stable/4.14.3/src/baloo-4.14.3.tar.xz";
    sha256 = "0p3awsrc20q79kq04x0vjz84acxz6gjm9jc7j2al4kybkyzx5p4y";
  };

  propagatedBuildInputs = [ kdelibs akonadi kdepimlibs qjson xapian kfilemetadata boost ];

  nativeBuildInputs = [ pkgconfig ];

}

