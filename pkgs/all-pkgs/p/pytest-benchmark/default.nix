{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, unzip

, pytest
, statistics
}:

let
  version = "3.0.0";
in
buildPythonPackage rec {
  name = "pytest-benchmark-${version}";

  src = fetchPyPi {
    package = "pytest-benchmark";
    inherit version;
    type = ".zip";
    sha256 = "cec1d1d259b9869ac306f91936f9607508a119c34f21cca79d50521bc29bf980";
  };

  nativeBuildInputs = [
    unzip
  ];

  propagatedBuildInputs = [
    pytest
    statistics
  ];

  doCheck = true;

  meta = with lib; {
    description = "py.test fixture for benchmarking code";
    homepage = https://github.com/ionelmc/pytest-benchmark;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
