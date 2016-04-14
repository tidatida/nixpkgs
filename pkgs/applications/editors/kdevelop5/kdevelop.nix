{ stdenv, fetchgit, cmake, gettext, pkgconfig, extra-cmake-modules, makeQtWrapper
, qtquick1, qtquickcontrols
, kconfig, kdeclarative, kdoctools, kiconthemes, ki18n, kitemmodels, kitemviews
, kjobwidgets, kcmutils, kio, knewstuff, knotifyconfig, kparts, ktexteditor
, threadweaver, kxmlgui, kwindowsystem, kcrash
, plasma-framework, krunner, kdevplatform, kdevelop-pg-qt, shared_mime_info
, libksysguard, okteta, llvmPackages
}:

let
  pname = "kdevelop";
  version = "4.90.91";

in
stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchgit {
    url = git://anongit.kde.org/kdevelop.git;
    rev = "5a40943ce31486fe53a3eb137873b8e5692dce7a";
    sha256 = "1hwck694aqx7496yn5h9q85gzd61rjklfdrx8qic08hzjb60ppbk";
  };

  nativeBuildInputs = [ cmake gettext pkgconfig extra-cmake-modules makeQtWrapper ];

  buildInputs = [
    qtquick1 qtquickcontrols
    kconfig kdeclarative kdoctools kiconthemes ki18n kitemmodels kitemviews
    kjobwidgets kcmutils kio knewstuff knotifyconfig kparts ktexteditor
    threadweaver kxmlgui kwindowsystem kcrash plasma-framework krunner
    kdevplatform kdevelop-pg-qt shared_mime_info libksysguard okteta
    llvmPackages.llvm llvmPackages.clang-unwrapped
  ];

  postInstall = ''
    wrapQtProgram "$out/bin/kdevelop"
  '';

  meta = with stdenv.lib; {
    maintainers = [ maintainers.ambrop72 ];
    platforms = platforms.linux;
    description = "KDE official IDE";
    longDescription =
      ''
        A free, opensource IDE (Integrated Development Environment)
        for MS Windows, Mac OsX, Linux, Solaris and FreeBSD. It is a
        feature-full, plugin extendable IDE for C/C++ and other
        programing languages. It is based on KDevPlatform, KDE and Qt
        libraries and is under development since 1998.
      '';
    homepage = https://www.kdevelop.org;
  };
}
