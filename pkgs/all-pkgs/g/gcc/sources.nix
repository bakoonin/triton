{ fetchTritonPatch }:
{
  "7" = {
    version = "7.3.0";
    sha256 = "832ca6ae04636adbb430e865a1451adf6979ab44ca1c8374f61fba65645ce15c";
    patches = [
      (fetchTritonPatch {
        rev = "8d29376d9dbe106435e0f58523fef8617da47972";
        file = "g/gcc/0001-libcpp-Remove-path-impurities.7.1.0.patch";
        sha256 = "10ed16616d7ed59d4c215367a63b6a1646b8be94be81737bd48403f6ff26d083";
      })
      (fetchTritonPatch {
        rev = "8d29376d9dbe106435e0f58523fef8617da47972";
        file = "g/gcc/0002-libcpp-Enforce-purity-for-time-functions.7.1.0.patch";
        sha256 = "616d16c4586a6ae4823a2e780a0655bf45f07caaacdc5886b73b41a3f5b9ab3d";
      })
    ];
  };
}
