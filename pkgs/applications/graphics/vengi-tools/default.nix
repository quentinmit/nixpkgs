{ lib
, stdenv
, fetchFromGitHub
, fetchurl

, cmake
, pkg-config
, ninja
, python3
, makeWrapper

, glm
, lua5_4
, SDL2
, SDL2_mixer
, enet
, libuv
, libuuid
, wayland-protocols
, Carbon
# optionals
, opencl-headers
, OpenCL

, callPackage
, nixosTests
}:

# cmake 3.21 inserts invalid `ldd` and `-Wl,--no-as-needed` calls, apparently
# related to
# https://cmake.org/cmake/help/v3.21/prop_tgt/LINK_WHAT_YOU_USE.html
let cmake3_22 = cmake.overrideAttrs (old: {
  version = "3.22.0";
  src = fetchurl {
    url = "https://cmake.org/files/v3.22/cmake-3.22.0.tar.gz";
    sha256 = "sha256-mYx7o0d40t/bPfimlUaeJLEeK/oh++QbNho/ReHJNF4=";
  };
});

in stdenv.mkDerivation rec {
  pname = "vengi-tools";
  version = "0.0.14";

  src = fetchFromGitHub {
    owner = "mgerhardy";
    repo = "engine";
    rev = "v${version}";
    sha256 = "sha256-v82hKskTSwM0NDgLVHpHZNRQW6tWug4pPIt91MrUwUo=";
  };

  nativeBuildInputs = [
    cmake3_22
    pkg-config
    ninja
    python3
    makeWrapper
  ];

  buildInputs = [
    glm
    lua5_4
    SDL2
    SDL2_mixer
    enet
    libuv
    libuuid
    # Only needed for the game
    #postgresql
    #libpqxx
    #mosquitto
  ] ++ lib.optional stdenv.isLinux wayland-protocols
    ++ lib.optionals stdenv.isDarwin [ Carbon OpenCL ]
    ++ lib.optional (!stdenv.isDarwin) opencl-headers;

  cmakeFlags = [
    # Disable tests due to a problem in linking gtest:
    # ld: /build/vengi-tests-core.LDHlV1.ltrans0.ltrans.o: in function `main':
    # <artificial>:(.text.startup+0x3f): undefined reference to `testing::InitGoogleMock(int*, char**)'
    "-DUNITTESTS=OFF"
    "-DVISUALTESTS=OFF"
    # We're only interested in the generic tools
    "-DGAMES=OFF"
    "-DMAPVIEW=OFF"
    "-DAIDEBUG=OFF"
  ];

  # Set the data directory for each executable. We cannot set it at build time
  # with the PKGDATADIR cmake variable because each executable needs a specific
  # one.
  # This is not needed on darwin, since on that platform data files are saved
  # in *.app/Contents/Resources/ too, and are picked up automatically.
  postInstall = lib.optionalString (!stdenv.isDarwin) ''
    for prog in $out/bin/*; do
      wrapProgram "$prog" \
        --set CORE_PATH $out/share/$(basename "$prog")/
    done
  '';

  passthru.tests = {
    voxconvert-roundtrip = callPackage ./test-voxconvert-roundtrip.nix {};
    run-voxedit = nixosTests.vengi-tools;
  };

  meta = with lib; {
    description = "Tools from the vengi voxel engine, including a thumbnailer, a converter, and the VoxEdit voxel editor";
    longDescription = ''
      Tools from the vengi C++ voxel game engine. It includes a voxel editor
      with character animation support and loading/saving into a lot of voxel
      volume formats. There are other tools like e.g. a thumbnailer for your
      filemanager and a command line tool to convert between several voxel
      formats.
    '';
    homepage = "https://mgerhardy.github.io/engine/";
    downloadPage = "https://github.com/mgerhardy/engine/releases";
    license = [ licenses.mit licenses.cc-by-sa-30 ];
    maintainers = with maintainers; [ fgaz ];
    platforms = platforms.all;
  };
}
