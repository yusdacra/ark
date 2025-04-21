{
  dnscontrol,
  writers,
  ...
}:
writers.writeBashBin "dns" ''
  cd dns
  ${dnscontrol}/bin/dnscontrol $1 --notify
''
