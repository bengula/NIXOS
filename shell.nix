# save as shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    openvino
    (python3.withPackages (ps: [ ps.openvino ps.onnxruntime ]))
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.openvino}/lib:${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
    echo "OpenVINO development environment loaded!"
  '';
}
