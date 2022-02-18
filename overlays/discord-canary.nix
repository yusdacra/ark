final: prev: {
  discord-canary =
    prev.discord-canary.overrideAttrs
    (
      old: let
        binaryName = "DiscordCanary";
      in rec {
        version = "0.0.123";
        src =
          prev.fetchurl
          {
            url = "https://dl-canary.discordapp.net/apps/linux/${version}/discord-canary-${version}.tar.gz";
            sha256 = "0bijwfsd9s4awqkgxd9c2cxh7y5r06vix98qjp0dkv63r6jig8ch";
          };
        installPhase =
          ''
            mkdir -p $out/{bin,opt/${binaryName},share/pixmaps}
            mv * $out/opt/${binaryName}
            chmod +x $out/opt/${binaryName}/${binaryName}
            patchelf --set-interpreter ${prev.stdenv.cc.bintools.dynamicLinker} \
                $out/opt/${binaryName}/${binaryName}
            wrapProgram $out/opt/${binaryName}/${binaryName} \
                "''${gappsWrapperArgs[@]}" \
                --prefix XDG_DATA_DIRS : "${prev.gtk3}/share/gsettings-schemas/${prev.gtk3.name}/" \
                --prefix LD_LIBRARY_PATH : "${old.libPath}:${prev.electron_9}/lib/electron:${prev.libdrm}/lib:${prev.libGL_driver.out}/lib"
            ln -s $out/opt/${binaryName}/${binaryName} $out/bin/
            ln -s $out/opt/${binaryName}/discord.png $out/share/pixmaps/${old.pname}.png
            ln -s "${old.desktopItem}/share/applications" $out/share/
          '';
      }
    );
}
