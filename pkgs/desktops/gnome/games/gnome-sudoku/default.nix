{ stdenv
, lib
, fetchurl
, meson
, ninja
, vala
, pkg-config
, gobject-introspection
, gettext
, gtk3
, gnome
, wrapGAppsHook
, libgee
, json-glib
, qqwing
, itstool
, libxml2
, desktop-file-utils
}:

stdenv.mkDerivation rec {
  pname = "gnome-sudoku";
  version = "44.beta";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-sudoku/${lib.versions.major version}/${pname}-${version}.tar.xz";
    sha256 = "0peQtr/tH8GQvSBfTRGN8hWeGs2Uz0l8lvv0Yd2XEZQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    gobject-introspection
    gettext
    itstool
    libxml2
    desktop-file-utils
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    libgee
    json-glib
    qqwing
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-sudoku";
      attrPath = "gnome.gnome-sudoku";
    };
  };

  meta = with lib; {
    homepage = "https://wiki.gnome.org/Apps/Sudoku";
    description = "Test your logic skills in this number grid puzzle";
    maintainers = teams.gnome.members;
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
