{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    allegro5
    zig
    zls
    gdb
  ];
}
