{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, libxml2
}:

let
  version = "2.0.4";
in
buildPythonPackage rec {
  name = "itstool-${version}";

  src = fetchPyPi {
    package = "itstool";
    inherit version;
    sha256 = "e62b224d679aaa5f445255eee9893917f5f0ef1023010b8b57c3634fc588829d";
  };

  propagatedBuildInputs = [
    libxml2
  ];

  disabled = isPy3;

  meta = with lib; {
    homepage = http://itstool.org/;
    description = "XML to PO and back again";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
