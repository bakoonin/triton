{ stdenv
, buildLinux
, fetchFromGitHub
, fetchurl
, git
, perl

, # Overrides to the kernel config.
  extraConfig ? ""

, # A list of patches to apply to the kernel.  Each element of this list
  # should be an attribute set {name, patch} where `name' is a
  # symbolic name and `patch' is the actual patch.  The patch may
  # optionally be compressed with gzip or bzip2.
  kernelPatches ? []

, ignoreConfigErrors ? false
, extraMeta ? {}
, channel
, ...
}:

let

  sources = {
    "4.9" = {
      version = "4.9.29";
      baseSha256 = "029098dcffab74875e086ae970e3828456838da6e0ba22ce3f64ef764f3d7f1a";
      patchSha256 = "a3e4f2000ba4968a2ca141b444c3e7b7b1c25b4c3a8fc8100ab76cea2d1988b2";
    };
    "4.10" = {
      version = "4.10.16";
      baseSha256 = "3c95d9f049bd085e5c346d2c77f063b8425f191460fcd3ae9fe7e94e0477dc4b";
      patchSha256 = "3bbd1da3133e544983caa269887c3515e19229b2ea4990d75695b5ca16d46c59";
    };
    "4.11" = {
      version = "4.11.1";
      baseSha256 = "b67ecafd0a42b3383bf4d82f0850cbff92a7e72a215a6d02f42ddbafcf42a7d6";
      patchSha256 = "0d96845b0f1bbe47a62659f48367948c4e747f995694927aa309e0e5e1556949";
    };
    "testing" = {
      version = "4.12-rc1";
      baseSha256 = "b67ecafd0a42b3383bf4d82f0850cbff92a7e72a215a6d02f42ddbafcf42a7d6";
      patchUrls = [
        "https://github.com/wkennington/linux/releases/download/v${version}/patch-${version}.xz"
      ];
      patchSha256 = "3af47d04c5706274650cefbbd17deae1566ce427ee8f06e0f0b150bef1d63e03";
    };
    "bcachefs" =
      let
        date = "2017-05-14";
      in {
        version = "4.11.1";
        patchUrls = [
          "https://github.com/wkennington/linux/releases/download/bcachefs-${version}-${date}/patch-bcachefs-${version}-${date}.xz"
        ];
        baseSha256 = "b67ecafd0a42b3383bf4d82f0850cbff92a7e72a215a6d02f42ddbafcf42a7d6";
        patchSha256 = "63bc0c608e82199f42942c78a2b00cb8e6ebd45d2b0155afc9b1d499b4bfeea0";
        features.bcachefs = true;
      };
  };

  source = sources."${channel}";

  inherit (source)
    version;

  inherit (stdenv.lib)
    elemAt
    head
    optionals
    splitString
    tail
    toInt;

  needsGitPatch = source.needsGitPatch or false;

  unpatchedVersion =
    let
      rclist = splitString "-" version;
      isRC = [ ] != tail rclist;
      vlist = splitString "." (head rclist);
      minorInt = toInt (elemAt vlist 1);
      correctMinor = if isRC then minorInt - 1 else minorInt;
    in "${elemAt vlist 0}.${toString correctMinor}";

  directoryUrls = [
    "mirror://kernel/linux/kernel/v4.x"
    "mirror://kernel/linux/kernel/v4.x/testing"
  ];

  src = if source ? rev then
    fetchFromGitHub {
      inherit (source)
        owner
        repo
        rev
        sha256;
    }
  else
    fetchurl {
      urls =
        let
          version' = if source ? baseSha256 then unpatchedVersion else version;
        in source.baseUrls or (source.urls or (map (n: "${n}/linux-${version'}.tar.xz") directoryUrls));
      hashOutput = false;
      sha256 = source.baseSha256 or source.sha256;
    };

  patch = if source ? patchSha256 && source.patchSha256 != null then
    fetchurl {
      urls = source.patchUrls or (map (n: "${n}/patch-${version}.xz") directoryUrls);
      hashOutput = false;
      sha256 = source.patchSha256;
    }
  else
    null;

  srcsVerification = [
    (fetchurl {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}/linux-${if source ? baseSha256 then unpatchedVersion else version}.tar.sign") directoryUrls;
      pgpKeyFingerprints = [
        "647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E"
        "ABAF 11C6 5A29 70B1 30AB  E3C4 79BE 3E43 0041 1886"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    })
  ] ++ optionals (patch != null) [
    (fetchurl {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}/patch-${version}.sign") directoryUrls;
      pgpKeyFingerprints = [
        "647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E"
        "ABAF 11C6 5A29 70B1 30AB  E3C4 79BE 3E43 0041 1886"
      ];
      inherit (patch) urls outputHash outputHashAlgo;
    })
  ];

  lib = stdenv.lib;

  modDirVersion = let
    rcSplit = lib.splitString "-" version;
    vSplit = lib.splitString "." (lib.head rcSplit);
    vSplit' = if lib.length vSplit == 2 then vSplit ++ [ "0" ] else vSplit;
    rcSplit' = [ (lib.concatStringsSep "." vSplit') ] ++ tail rcSplit;
  in lib.concatStringsSep "-" rcSplit';

  common = import ./common.nix { inherit stdenv; };

  kernelConfigFun = baseConfig:
    let
      configFromPatches =
        map ({extraConfig ? "", ...}: extraConfig) kernelPatches;
    in lib.concatStringsSep "\n" ([baseConfig] ++ configFromPatches);

  configfile = stdenv.mkDerivation {
    inherit ignoreConfigErrors;
    name = "linux-config-${version}";

    generateConfig = ./generate-config.pl;

    kernelConfig = kernelConfigFun config;

    nativeBuildInputs = [ perl ]
      ++ optionals needsGitPatch [ git ];

    platformName = "pc";
    kernelBaseConfig = "defconfig";
    kernelTarget = "bzImage";
    autoModules = true;
    arch = common.kernelArch;

    postPatch = kernel.postPatch + ''
      # Patch kconfig to print "###" after every question so that
      # generate-config.pl from the generic builder can answer them.
      sed -e '/fflush(stdout);/i\printf("###");' -i scripts/kconfig/conf.c
    '';

    inherit (kernel) src patches preUnpack prePatch;

    buildPhase = ''
      cd $buildRoot

      # Get a basic config file for later refinement with $generateConfig.
      make -C ../$sourceRoot O=$PWD $kernelBaseConfig ARCH=$arch

      # Create the config file.
      echo "generating kernel configuration..."
      echo "$kernelConfig" > kernel-config
      DEBUG=1 ARCH=$arch KERNEL_CONFIG=kernel-config AUTO_MODULES=$autoModules \
           SRC=../$sourceRoot perl -w $generateConfig
    '';

    installPhase = "mv .config $out";
  };

  kernel = buildLinux {
    inherit version modDirVersion src needsGitPatch patch kernelPatches;

    configfile = configfile.nativeDrv or configfile;

    crossConfigfile = configfile.crossDrv or configfile;

    config = { CONFIG_MODULES = "y"; CONFIG_FW_LOADER = "m"; };

    crossConfig = { CONFIG_MODULES = "y"; CONFIG_FW_LOADER = "m"; };
  };

  passthru = {
    meta = kernel.meta // extraMeta;

    inherit channel srcsVerification;

    features = source.features or { };

    passthru = kernel.passthru // (removeAttrs passthru [ "passthru" "meta" ]);
  };

  config = import ./common-config.nix
    { inherit stdenv version extraConfig; };

  nativeDrv = lib.addPassthru kernel.nativeDrv passthru;

  crossDrv = lib.addPassthru kernel.crossDrv passthru;
in if kernel ? crossDrv then nativeDrv // { inherit nativeDrv crossDrv; } else lib.addPassthru kernel passthru
