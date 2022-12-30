{ pkgs }:
pkgs.mkShell {
  ZAB_FONT = "./blasteroids_font.ttf";
  buildInputs = with pkgs; [
    allegro5
    zig
    zls
    gdb
  ];
}
