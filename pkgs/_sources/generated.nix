# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchgit,
  fetchurl,
}:
{
  manix = {
    pname = "manix";
    version = "d08e7ca185445b929f097f8bfb1243a8ef3e10e4";
    src =
      fetchgit
      {
        url = "https://github.com/mlvzk/manix";
        rev = "d08e7ca185445b929f097f8bfb1243a8ef3e10e4";
        fetchSubmodules = false;
        deepClone = false;
        leaveDotGit = false;
        sha256 = "1b7xi8c2drbwzfz70czddc4j33s7g1alirv12dwl91hbqxifx8qs";
      };
  };
}
