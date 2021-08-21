{ lib, stdenv, fetchFromGitHub, pkg-config, gtk3, wrapGAppsHook }:

stdenv.mkDerivation rec {
  pname = "zenmonitor";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "Ta180m";
    repo = "zenmonitor3";
    rev = "v${version}";
    sha256 = "sha256-dbjLpfflIsEU+wTApghJYBPxBXqS/7MJqcMBcj50o6I=";
  };

  buildInputs = [ gtk3 ];
  nativeBuildInputs = [ pkg-config wrapGAppsHook ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "Monitoring software for AMD Zen-based CPUs";
    homepage = "https://github.com/Ta180m/zenmonitor3";
    license = licenses.mit;
    platforms = [ "i686-linux" "x86_64-linux" ];
    maintainers = with maintainers; [ alexbakker artturin ];
  };
}
