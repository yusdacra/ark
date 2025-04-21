var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");
var REG_CHANGEME = NewRegistrar("none");

D("9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa", REG_CHANGEME,
	DnsProvider(DSP_CLOUDFLARE),
	DefaultTTL(1),
	A("@", "23.88.101.188", CF_PROXY_ON),
	TXT("@", "\"entity with serial id 90008 uses it/they pronouns, and prefers 3pp. please do not think of it as a human. connect to https://gaze.systems/about for more information.\""),
);

