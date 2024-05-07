{ pkgs ? import <nixpkgs> {} }:
    pkgs.mkShell {
        buildInputs = with pkgs.buildPackages;
        [
            pkg-config
            go
            xorg.libXxf86vm
            xorg.xinput
            xorg.libXi.dev
            xorg.libXinerama
            xorg.libXrandr
            xorg.libXcursor
            xorg.libX11
            xorg.libX11.dev
            glfw
            glfw2
            glew
        ];
}

