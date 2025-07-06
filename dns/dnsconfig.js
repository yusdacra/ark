var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");
var REG_NONE = NewRegistrar("none");

var WOLUMONDE_IP = "23.88.101.188"

D("gaze.systems", REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),
	DefaultTTL(1),
	A("@", WOLUMONDE_IP, CF_PROXY_OFF),
	A("dawn", WOLUMONDE_IP, CF_PROXY_OFF),
	A("doc", WOLUMONDE_IP, CF_PROXY_OFF),
	A("git", WOLUMONDE_IP, CF_PROXY_OFF),
	A("guestbook", WOLUMONDE_IP, CF_PROXY_OFF),
	A("limbus", WOLUMONDE_IP, CF_PROXY_OFF),
	A("pmart", WOLUMONDE_IP, CF_PROXY_OFF),
	A("webhook", WOLUMONDE_IP, CF_PROXY_OFF),
	A("dash", WOLUMONDE_IP, CF_PROXY_OFF), // perses
	A("knot", WOLUMONDE_IP, CF_PROXY_OFF),
	A("skeetdeck", WOLUMONDE_IP, CF_PROXY_OFF),
	A("likes", WOLUMONDE_IP, CF_PROXY_OFF),
	A("bird", WOLUMONDE_IP, CF_PROXY_OFF),
	A("id", WOLUMONDE_IP, CF_PROXY_OFF),
	// thing
	// TXT("id", "a data endpoint for entity with serial id /90008/."),
	// TXT("id", "entity linked here uses it/they pronouns. it can be referred to as /dusk/ or /dawn/."),
	// TXT("id", "this one is not a human, try to refer to it in third person. use /this one/, /this thing/, etc."),
	// TXT("id", "try connecting to https://gaze.systems/about for more information."),
	// github pages
	CNAME("dev", "90-008.github.io."),
	// fastmail
	CNAME("fm1._domainkey", "fm1.gaze.systems.dkim.fmhosted.com."),
	CNAME("fm2._domainkey", "fm2.gaze.systems.dkim.fmhosted.com."),
	CNAME("fm3._domainkey", "fm3.gaze.systems.dkim.fmhosted.com."),
	MX("@", 10, "in1-smtp.messagingengine.com."),
	MX("@", 20, "in2-smtp.messagingengine.com."),
	TXT("@", "v=spf1 include:spf.messagingengine.com ?all"),
	TXT("_dmarc", "v=DMARC1; p=none;"),
	// resend
	MX("send.poke", 10, "feedback-smtp.us-east-1.amazonses.com."),
	TXT("resend._domainkey.poke", "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC8/06F14LZgg7l6eko9GXasUwCBUGHe1Abd5hMg0Xf9ufdUj7lAUB746DS1ErS04oxGEbCdjamkAGqRsYWvk5KGRIXmeYuKyMPFM44U0dt6caHOIr8pHoDj9ytAJD/RS/p1xQZoFXHBxKgAeEY3TUZy7iNLvGxCLkxuPnO7nlWKwIDAQAB"),
	TXT("send.poke", "v=spf1 include:amazonses.com ~all"),
	// atproto
	// TXT("_atproto", "did=did:plc:dfl62fgb7wtjj3fcbb72naae", TTL(60)),
);

D("9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa", REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),
	DefaultTTL(1),
	A("@", WOLUMONDE_IP, CF_PROXY_ON),
	TXT("@", "a data endpoint for entity with serial id /90008/."),
	TXT("@", "entity linked here uses it/they pronouns. it can be referred to as /dusk/ or /dawn/."),
	TXT("@", "this one is not a human, try to refer to it in third person. use /this one/, /this thing/, etc."),
	TXT("@", "try connecting to https://gaze.systems/about for more information."),
	// atproto
	// TXT("_atproto", "did=did:plc:dfl62fgb7wtjj3fcbb72naae"),
);

D("poor.dog", REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),
	DefaultTTL(1),
	A("@", WOLUMONDE_IP, CF_PROXY_OFF),
);
