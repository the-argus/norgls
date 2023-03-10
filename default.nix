{
  nimRelease ? true,
  nimPackages,
  ...
}:
nimPackages.buildNimPackage {
  pname = "norgls";
  version = "0.0.1";
  src = ./.;

  nimBinOnly = false;
  nimbleFile = ./norgls.nimble;
  inherit nimRelease;
  nimFlags = ["--threads:on"];

  buildInputs = with nimPackages; [
    jsonschema
    (nimPackages.fetchNimble {
      pname = "asynctools";
      version = "0.1.1";
      hash = "sha256-mrO+WeSzCBclqC2UNCY+IIv7Gs8EdTDaTeSgXy3TgNM=";
    })
  ];
}
