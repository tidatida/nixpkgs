{ stdenv, fetchgit, cmake, gettext, pkgconfig, extra-cmake-modules, makeQtWrapper
, boost, subversion, apr, aprutil
, qtscript, qtwebkit, grantlee, karchive, kconfig, kcoreaddons, kguiaddons, kiconthemes, ki18n
, kitemmodels, kitemviews, kio, kparts, sonnet, kcmutils, knewstuff, knotifications
, knotifyconfig, ktexteditor, threadweaver, kdeclarative, libkomparediff2 }:

let
  pname = "kdevplatform";
  version = "4.90.91";

in
stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  
  src = fetchgit {
    url = git://anongit.kde.org/kdevplatform.git;
    rev = "93abae00efebb0a157753bf36be9e943b5d949e8";
    sha256 = "12x56xrgfw69wxvz6ma9cc716r47yi0k3myxmn0ln1b3naqbc99c";
  };

  nativeBuildInputs = [ cmake gettext pkgconfig extra-cmake-modules makeQtWrapper ];

  propagatedBuildInputs = [  ];
  buildInputs = [
    boost subversion apr aprutil
    qtscript qtwebkit grantlee karchive kconfig kcoreaddons kguiaddons kiconthemes
    ki18n kitemmodels kitemviews kio kparts sonnet kcmutils knewstuff
    knotifications knotifyconfig ktexteditor threadweaver kdeclarative
    libkomparediff2
  ];

  meta = with stdenv.lib; {
    maintainers = [ maintainers.ambrop72 ];
    platforms = platforms.linux;
    description = "KDE libraries for IDE-like programs";
    longDescription = ''
      A free, opensource set of libraries that can be used as a foundation for
      IDE-like programs. It is programing-language independent, and is planned
      to be used by programs like: KDevelop, Quanta, Kile, KTechLab ... etc."
    '';
    homepage = https://www.kdevelop.org;
  };
}
