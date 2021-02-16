{ lib, buildDunePackage
, checkseum, cmdliner, git-unix, git-cohttp-unix, yaml, fpath
, irmin, irmin-fs, irmin-git, irmin-graphql, irmin-http
, irmin-pack, irmin-watcher, irmin-test
}:

buildDunePackage rec {

  pname = "irmin-unix";

  inherit (irmin) version src;

  useDune2 = true;

  propagatedBuildInputs = [
    checkseum cmdliner git-unix yaml fpath
    irmin irmin-fs irmin-git irmin-graphql irmin-http
    irmin-pack irmin-watcher git-cohttp-unix
  ];

  checkInputs = lib.optional doCheck irmin-test;

  doCheck = true;

  meta = irmin.meta // {
    description = "Unix backends for Irmin";
  };

}

