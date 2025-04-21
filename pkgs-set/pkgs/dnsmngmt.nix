{
  gnused,
  dnscontrol,
  writers,
  ...
}:
writers.writeBashBin "dns" ''
  cd dns
  dnsDir="$PWD"
  for dir in */; do
    msg="=== $1 dns changes for $(basename $dir) ==="
    echo "$msg"
    cd $dnsDir/$dir; ${dnscontrol}/bin/dnscontrol $1; cd $dnsDir
    echo "$msg" | ${gnused}/bin/sed 's/./=/g'
  done
''
