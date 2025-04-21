var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");
var REG_CHANGEME = NewRegistrar("none");

D("9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa", REG_CHANGEME,
	DnsProvider(DSP_CLOUDFLARE),
	DefaultTTL(1),
	A("@", "23.88.101.188", CF_PROXY_ON),
	TXT("@", "a data endpoint for entity with serial id /90008/."),
	TXT("@", "entity linked here uses it/they pronouns. it can be referred to as /dusk/ or /dawn/."),
	TXT("@", "this one is not a human, try to refer to it in third person. use /this one/, /this thing/, etc."),
	TXT("@", "try connecting to https://gaze.systems/about for more information."),
);

