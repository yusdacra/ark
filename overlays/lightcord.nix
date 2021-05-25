final: prev: {
  lightcord = prev.discord-canary.overrideAttrs (old:
    let binaryName = "lightcord"; in
    rec {
      pname = "lightcord";
      version = "0.1.5";
      src = prev.fetchzip {
        stripRoot = false;
        url = "https://github.com/Lightcord/Lightcord/releases/download/${version}/lightcord-linux-x64.zip";
        sha256 = "sha256-lorjKF7RQHLt3e57CrPa4QqpztHQqsF+ijiJD5hJYTY=";
      };
      autoPatchelfIgnoreMissingDeps = true;
      installPhase = ''
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
        ln -s $out/opt/${binaryName}/discord.png $out/share/pixmaps/${pname}.png
        ln -s "${old.desktopItem}/share/applications" $out/share/
      '';
      desktopItem = prev.makeDesktopItem {
        name = pname;
        exec = binaryName;
        desktopName = binaryName;
      };
      meta = { };
    });
}
