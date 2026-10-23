{ alsa-lib, autoPatchelfHook, fetchurl, lib, stdenv, stdenvNoCC }:

let
  manifest = builtins.fromJSON (builtins.readFile ./package-manifest.json);
  binary = manifest.binary.name;
  version = manifest.source.version;
in
stdenvNoCC.mkDerivation {
  pname = binary;
  inherit version;

  src = fetchurl {
    url = manifest.source.url;
    hash = manifest.source.hash;
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ alsa-lib stdenv.cc.cc.lib ];
  sourceRoot = "${binary}-${version}-linux-x86_64";
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -a ./. "$out/"
    runHook postInstall
  '';

  meta = with lib; {
    description = manifest.meta.description;
    homepage = manifest.meta.homepage;
    license = with licenses; [ mit asl20 ];
    mainProgram = binary;
    platforms = [ "x86_64-linux" ];
  };
}
