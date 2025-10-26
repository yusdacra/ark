var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");
var REG_NONE = NewRegistrar("none");

var WOLUMONDE_IP = "23.88.101.188";
var DZWONEK_IP = "94.237.26.47";

D(
    "gaze.systems",
    REG_NONE,
    DnsProvider(DSP_CLOUDFLARE),
    DefaultTTL(1),
    A("@", WOLUMONDE_IP, CF_PROXY_OFF),
    A("doc", WOLUMONDE_IP, CF_PROXY_OFF),
    A("git", WOLUMONDE_IP, CF_PROXY_OFF),
    A("limbus", WOLUMONDE_IP, CF_PROXY_OFF),
    A("pmart", WOLUMONDE_IP, CF_PROXY_OFF),
    // A("webhook", WOLUMONDE_IP, CF_PROXY_OFF),
    A("dash", WOLUMONDE_IP, CF_PROXY_OFF), // perses
    A("knot", WOLUMONDE_IP, CF_PROXY_OFF),
    A("spindle", WOLUMONDE_IP, CF_PROXY_OFF),
    A("skeetdeck", WOLUMONDE_IP, CF_PROXY_OFF),
    A("likes", WOLUMONDE_IP, CF_PROXY_OFF),
    A("vpn", DZWONEK_IP, CF_PROXY_OFF),
    A("id", WOLUMONDE_IP, CF_PROXY_OFF),
    A("test", WOLUMONDE_IP, CF_PROXY_OFF),
    // atp handles
    A("dawn", WOLUMONDE_IP, CF_PROXY_OFF),
    A("guestbook", WOLUMONDE_IP, CF_PROXY_OFF),
    A("drew", WOLUMONDE_IP, CF_PROXY_OFF),
    // A("meow", WOLUMONDE_IP, CF_PROXY_OFF),
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
    TXT(
        "resend._domainkey.poke",
        "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC8/06F14LZgg7l6eko9GXasUwCBUGHe1Abd5hMg0Xf9ufdUj7lAUB746DS1ErS04oxGEbCdjamkAGqRsYWvk5KGRIXmeYuKyMPFM44U0dt6caHOIr8pHoDj9ytAJD/RS/p1xQZoFXHBxKgAeEY3TUZy7iNLvGxCLkxuPnO7nlWKwIDAQAB",
    ),
    TXT("send.poke", "v=spf1 include:amazonses.com ~all"),
    // atproto
    // TXT("_atproto", "did=did:plc:dfl62fgb7wtjj3fcbb72naae", TTL(60)),
    // TXT("_atproto.dusk", "did=did:plc:dfl62fgb7wtjj3fcbb72naae", TTL(60)),
);

D(
    "9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa",
    REG_NONE,
    DnsProvider(DSP_CLOUDFLARE),
    DefaultTTL(1),
    A("@", WOLUMONDE_IP, CF_PROXY_ON),
    TXT("@", "a data endpoint for entity with serial id /90008/."),
    TXT(
        "@",
        "entity linked here uses it/they pronouns. it can be referred to as /dusk/ or /dawn/.",
    ),
    TXT(
        "@",
        "this one is not a human, try to refer to it in third person. use /this one/, /this thing/, etc.",
    ),
    TXT(
        "@",
        "try connecting to https://gaze.systems/about for more information.",
    ),
    // atproto
    // TXT("_atproto", "did=did:plc:dfl62fgb7wtjj3fcbb72naae"),
);

D(
    "poor.dog",
    REG_NONE,
    DnsProvider(DSP_CLOUDFLARE),
    DefaultTTL(1),
    A("@", WOLUMONDE_IP, CF_PROXY_OFF),
    TXT("@", "v=spf1 -all"),
    TXT("_dmarc", "v=DMARC1; p=reject;"),
);

var EMAIL_TTL = 86400;

D(
    "ptr.pet",
    REG_NONE,
    DnsProvider(DSP_CLOUDFLARE),
    DefaultTTL(1),
    A("@", WOLUMONDE_IP, CF_PROXY_OFF),
    A("test", WOLUMONDE_IP, CF_PROXY_OFF),
    // atproto
    TXT("_atproto", "did=did:plc:dfl62fgb7wtjj3fcbb72naae"),
    A("nil", WOLUMONDE_IP, CF_PROXY_OFF),
    TXT("_atproto.nil", "did=did:web:dawn.gaze.systems"),
    TXT("_atproto.june", "did=did:plc:y3z2rr7q5rywu4fjn3fmfyop"),
    // june
    CNAME("june", "girlboss.ceo."),
    CNAME("*.june", "girlboss.ceo."),
    // email
    // verification
    TXT("@", "hosted-email-verify=zr04ylon", TTL(EMAIL_TTL)),

    MX("@", 10, "aspmx1.migadu.com.", TTL(EMAIL_TTL)),
    MX("@", 20, "aspmx2.migadu.com.", TTL(EMAIL_TTL)),

    // DKIM
    CNAME(
        "key1._domainkey",
        "key1.ptr.pet._domainkey.migadu.com.",
        TTL(EMAIL_TTL),
    ),
    CNAME(
        "key2._domainkey",
        "key2.ptr.pet._domainkey.migadu.com.",
        TTL(EMAIL_TTL),
    ),
    CNAME(
        "key3._domainkey",
        "key3.ptr.pet._domainkey.migadu.com.",
        TTL(EMAIL_TTL),
    ),

    // SPF
    TXT("@", "v=spf1 include:spf.migadu.com -all", TTL(EMAIL_TTL)),

    // DMARC
    TXT(
        "_dmarc",
        "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; fo=1; pct=100; rua=mailto:infrastructure@ptr.pet; ruf=mailto:infrastructure@ptr.pet",
        TTL(EMAIL_TTL),
    ),

    // configuration
    TXT(
        "@",
        "mailconf=https://autoconfig.migadu.com/mail/config-v1.1.xml",
        TTL(EMAIL_TTL),
    ),

    // TLS reporting
    TXT(
        "_smtp._tls",
        "v=TLSRPTv1; rua=mailto:infrastructure@ptr.pet",
        TTL(EMAIL_TTL),
    ),

    // mta-sts
    A("mta-sts", WOLUMONDE_IP, CF_PROXY_OFF),
    TXT("_mta-sts", "v=STSv1; id=20250930T1945", TTL(EMAIL_TTL)),

    // autoconfig
    A("autoconfig", WOLUMONDE_IP, CF_PROXY_OFF),
    A("autodiscover", WOLUMONDE_IP, CF_PROXY_OFF),

    // autodiscovery
    SRV(
        "_autodiscover._tcp",
        0,
        1,
        443,
        "autodiscover.migadu.com.",
        TTL(EMAIL_TTL),
    ),
    SRV("_submissions._tcp", 0, 1, 465, "smtp.migadu.com.", TTL(EMAIL_TTL)),
    SRV("_imaps._tcp", 0, 1, 993, "imap.migadu.com.", TTL(EMAIL_TTL)),
    SRV("_pop3s._tcp", 0, 1, 995, "pop.migadu.com.", TTL(EMAIL_TTL)),
);
