{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, zope-event
}:

let
  version = "4.4.3";
in
buildPythonPackage rec {
  name = "zope.interface-${version}";

  src = fetchPyPi {
    package = "zope.interface";
    inherit version;
    sha256 = "d6d26d5dfbfd60c65152938fcb82f949e8dada37c041f72916fef6621ba5c5ce";
  };

  buildInputs = [
    zope-event
  ];

  meta = with lib; {
    description = "Interfaces for Python";
    homepage = http://zope.org/Products/ZopeInterface;
    license = licenses.zpt20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
