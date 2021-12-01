let
  sources = import ./nix/sources.nix;
  nixpkgs = import sources.nixpkgs {};
  stdenv  = nixpkgs.gcc-arm-embedded-10.stdenv;
  ats2    = nixpkgs.ats2;
in stdenv.mkDerivation rec {
  pname = "first-stm-proj";
  version = "0.0.1";
  src = ./.;
  stlink = nixpkgs.stlink;
  STM32_BASE_PATH = sources.STM32-base + "/";
  STM32_CUBE_PATH= sources.STM32-base-STM32Cube + "/";
  TOOLCHAIN_PATH = nixpkgs.gcc-arm-embedded-10 + "/bin";
  PATSHOME = ats2;
  buildInputs = [stlink nixpkgs.libusb1 ats2];
   
  buildPhase = ''
  make clean
  make 
  '';

  installPhase = ''
  cp -r bin $out

  '';

  }

  
