{ stdenv, fetchurl, fetchpatch, autoreconfHook, pkgconfig, perl, docbook2x
, docbook_xml_dtd_45, python3Packages

# Optional Dependencies
, libapparmor ? null, gnutls ? null, libselinux ? null, libseccomp ? null
, cgmanager ? null, libnih ? null, dbus ? null, libcap ? null, systemd ? null
}:

let
  enableCgmanager = cgmanager != null && libnih != null && dbus != null;
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "lxc-${version}";
  version = "2.0.6";

  src = fetchurl {
    url = "https://linuxcontainers.org/downloads/lxc/lxc-${version}.tar.gz";
    sha256 = "0ynddnfirh9pmy7ijg300jrgzdhjzm07fsmvdw71mb2x0p82qabw";
  };

  nativeBuildInputs = [
    autoreconfHook pkgconfig perl docbook2x python3Packages.wrapPython
  ];
  buildInputs = [
    libapparmor gnutls libselinux libseccomp cgmanager libnih dbus libcap
    python3Packages.python systemd
  ];

  patches = [
    ./support-db2x.patch
    (fetchurl {
      name = "CVE-2017-5985.patch";
      url = "https://github.com/lxc/lxc/commit/d512bd5efb0e407eba350c4e649c464a65b712a3.patch";
      sha256 = "0v1rhlfviadsxj2wmbl7nqb64p6y2bxm9y43sc44jg3k6mkr0r5c";
    })
  ];

  XML_CATALOG_FILES = "${docbook_xml_dtd_45}/xml/dtd/docbook/catalog.xml";

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-api-docs"
    "--with-init-script=none"
    "--with-distro=nixos" # just to be sure it is "unknown"
  ] ++ optional (libapparmor != null) "--enable-apparmor"
    ++ optional (libselinux != null) "--enable-selinux"
    ++ optional (libseccomp != null) "--enable-seccomp"
    ++ optional (libcap != null) "--enable-capabilities"
    ++ [
    "--disable-examples"
    "--enable-python"
    "--disable-lua"
    "--enable-bash"
    (if doCheck then "--enable-tests" else "--disable-tests")
    "--with-rootfs-path=/var/lib/lxc/rootfs"
  ];

  doCheck = false;

  installFlags = [
    "localstatedir=\${TMPDIR}"
    "sysconfdir=\${out}/etc"
    "sysconfigdir=\${out}/etc/default"
    "bashcompdir=\${out}/share/bash-completion/completions"
    "READMEdir=\${TMPDIR}/var/lib/lxc/rootfs"
    "LXCPATH=\${TMPDIR}/var/lib/lxc"
  ];

  postInstall = ''
    wrapPythonPrograms
  '';

  meta = {
    homepage = "http://lxc.sourceforge.net";
    description = "Userspace tools for Linux Containers, a lightweight virtualization system";
    license = licenses.lgpl21Plus;

    longDescription = ''
      LXC is the userspace control package for Linux Containers, a
      lightweight virtual system mechanism sometimes described as
      "chroot on steroids". LXC builds up from chroot to implement
      complete virtual systems, adding resource management and isolation
      mechanisms to Linux’s existing process management infrastructure.
    '';

    platforms = platforms.linux;
    maintainers = with maintainers; [ wkennington globin fpletz ];
  };
}
