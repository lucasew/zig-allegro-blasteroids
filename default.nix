{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "zig-allegro-blasteroids";
  src = ./.;
  nativeBuildInputs = with pkgs; [ zig ];
  buildInputs = with pkgs; [ allegro5 ];

  dontPatch = true;
  dontConfigure = true;

  unpackPhase = ''
    runHook preUnpack

    cp -r -p -T "$src" .
    chmod -R u+w .

    runHook postUnpack
  '';
  
  buildPhase = ''
    runHook preBuild

    export XDG_CACHE_HOME=$(mktemp -d)
    zig build --verbose
    rm -rf $XDG_CACHE_HOME

    runHook postbuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -m755 zblasteroids $out/bin
    makeWrapper $out/bin/zblasteroids \
      --set ZAB_FONT ${./blasteroids_font.ttf}

    find $out

    runHook postInstall
  '';

  fixupPhase = ''
    runHook preFixup

    patchelf $out/bin/*
    strip $out/bin/*

    runHook postFixup
  '';
}
