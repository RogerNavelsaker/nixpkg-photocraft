{ alsa-lib, autoPatchelfHook, fetchurl, lib, libGL, libx11, libxcb, libxkbcommon, libxcursor, libxext, libxfixes, libxi, libxrandr, libxrender, stdenv, stdenvNoCC, vulkan-loader, wayland }:

let
  manifest = builtins.fromJSON (builtins.readFile ./package-manifest.json);
  binary = manifest.binary.name;
  version = manifest.source.version;
  runtimeLibs = [
    alsa-lib
    libGL
    libxkbcommon
    libx11
    libxcursor
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxcb
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
  ];
in
stdenvNoCC.mkDerivation {
  pname = binary;
  inherit version;

  src = fetchurl {
    url = manifest.source.url;
    hash = manifest.source.hash;
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = runtimeLibs;
  runtimeDependencies = runtimeLibs;
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
