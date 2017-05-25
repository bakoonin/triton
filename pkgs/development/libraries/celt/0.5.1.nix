{ callPackage, fetchurl, ... } @ args:

callPackage ./generic.nix (args // rec{
  version = "0.5.1.3";

  src = fetchurl {
    url = "mirror://xiph/celt/celt-${version}.tar.gz";
    sha256 = "0bkam9z5vnrxpbxkkh9kw6yzjka9di56h11iijikdd1f71l5nbpw";
  };
})
