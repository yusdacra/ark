var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");
var DSP_PRIMARY = NewDnsProvider("hedns");
var REG_NONE = NewRegistrar("none");

var DZWONEK_IP4 = "94.237.26.47";
var DZWONEK_IP6 = "2a04:3542:1000:910:6898:1dff:fea1:4b4b";
var DZWONEK_IPS = [DZWONEK_IP4, DZWONEK_IP6];
var TRIMOUNTS_IP4 = "159.195.58.28";
var TRIMOUNTS_IP6 = "2a0a:4cc0:c1:e83d::b00b";
var TRIMOUNTS_IPS = [TRIMOUNTS_IP4, TRIMOUNTS_IP6];
var VOLSINII_IP4 = "199.71.188.53";
var VOLSINII_IP6 = ""; // no ipv6 for now
var VOLSINII_IPS = [VOLSINII_IP4];

function host(name, ips, opts) {
    var records = [];
    if (opts) {
        records.push(A(name, ips[0], opts));
        if (ips[1]) records.push(AAAA(name, ips[1], opts));
    } else {
        records.push(A(name, ips[0]));
        if (ips[1]) records.push(AAAA(name, ips[1]));
    }
    return records;
}

function hosts(_names, ips, opts) {
    var names = [];
    if (typeof _names === "string")
        names.push(_names);
    else
        names = _names;

    var records = [];
    _.each(names, function (name) {
        _.each(host(name, ips, opts), function (r) {
            records.push(r);
        });
    });
    return records;
}

function TRIMOUNTS(names, opts) {
    return hosts(names, TRIMOUNTS_IPS, opts);
}
function DZWONEK(names, opts) {
    return hosts(names, DZWONEK_IPS, opts);
}
function VOLSINII(names, opts) {
    return hosts(names, VOLSINII_IPS, opts);
}

function IGNORE_ACME() {
    return IGNORE_NAME("_acme-challenge");
}

D(
    "gaze.systems",
    REG_NONE,
    DnsProvider(DSP_PRIMARY),
    TRIMOUNTS(
        [
            "@", "pmart", "dash",
            "knot", "spindle",
            "guestbook",
        ],
        CF_PROXY_OFF,
    ),
    DZWONEK("vpn", CF_PROXY_OFF),
    VOLSINII("tap", CF_PROXY_OFF),
    // github pages
    CNAME("dev", "90-008.github.io."),
    // fastmail
    CNAME("fm1._domainkey", "fm1.gaze.systems.dkim.fmhosted.com."),
    CNAME("fm2._domainkey", "fm2.gaze.systems.dkim.fmhosted.com."),
    CNAME("fm3._domainkey", "fm3.gaze.systems.dkim.fmhosted.com."),
    MX("@", 10, "in1-smtp.messagingengine.com."),
    MX("@", 20, "in2-smtp.messagingengine.com."),
    TXT("@", "v=spf1 include:spf.messagingengine.com ?all"),
    TXT("_dmarc", "v=DMARC1; p=reject;"),
    // resend
    MX("send.poke", 10, "feedback-smtp.us-east-1.amazonses.com."),
    TXT(
        "resend._domainkey.poke",
        "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC8/06F14LZgg7l6eko9GXasUwCBUGHe1Abd5hMg0Xf9ufdUj7lAUB746DS1ErS04oxGEbCdjamkAGqRsYWvk5KGRIXmeYuKyMPFM44U0dt6caHOIr8pHoDj9ytAJD/RS/p1xQZoFXHBxKgAeEY3TUZy7iNLvGxCLkxuPnO7nlWKwIDAQAB",
    ),
    TXT("send.poke", "v=spf1 include:amazonses.com ~all"),
    // atproto
    TXT("_atproto.eris", "did=did:plc:bxjnsrfzozl365rsdo5yvuz5", TTL(60)),
    TXT("_atproto.drew", "did=did:plc:vo6ie3kd6xvpjlof4pnb2zzp", TTL(60)),
    TXT("_atproto.devacc", "did=did:plc:jemcdqsv2m3mpxhqckql3xxo", TTL(60)),
    TXT("_kicya", "3853739a3802a077d62e83494b4603bbdb36332662c5cb58865084bcf0dc87a8"),
    IGNORE_ACME(),
);

D(
    "9.0.0.0.8.e.f.1.5.0.7.4.0.1.0.0.2.ip6.arpa",
    REG_NONE,
    DnsProvider(DSP_CLOUDFLARE),
    TRIMOUNTS("@", CF_PROXY_ON),
    TXT("@", "a data endpoint for entity with serial id /90008/."),
    TXT(
        "@",
        "entity linked here uses it/that pronouns. it can also be referred to as /dawn/.",
    ),
    TXT(
        "@",
        "this one is not a human, try to refer to it in third person. use /this one/, /this thing/, etc.",
    ),
    TXT(
        "@",
        "try connecting to https://gaze.systems/about for more information.",
    ),
    IGNORE_ACME(),
);

D(
    "poor.dog",
    REG_NONE,
    DnsProvider(DSP_PRIMARY),
    TRIMOUNTS("@", CF_PROXY_OFF),
    TXT("@", "v=spf1 -all"),
    TXT("_dmarc", "v=DMARC1; p=reject;"),
    TXT("_atproto", "did=did:plc:dfl62fgb7wtjj3fcbb72naae", TTL(60)),
    IGNORE_ACME(),
);

var EMAIL_TTL = function () { return TTL(86400); };

D(
    "ptr.pet",
    REG_NONE,
    DnsProvider(DSP_PRIMARY),
    TRIMOUNTS(["@", "tunes", "corpus", "x", "id"], CF_PROXY_OFF),
    DZWONEK(["nucleus", "trill", "dysnomia"], CF_PROXY_OFF),
    TXT("_kicya", "3b11cb74243eea1fc84e62ffefd7e246279c2f203e1cae42e19d0454dc8d2172"),
    // atproto
    TXT("_atproto", "did=did:plc:dfl62fgb7wtjj3fcbb72naae"),
    TXT("_atproto.nil", "did=did:plc:dumbmutt4po52ept2tczimje"),
    TXT("_atproto.june", "did=did:plc:y3z2rr7q5rywu4fjn3fmfyop"),
    // june
    CNAME("june", "girlboss.ceo."),
    CNAME("*.june", "girlboss.ceo."),
    // email
    // verification
    TXT("@", "hosted-email-verify=zr04ylon", EMAIL_TTL()),

    MX("@", 10, "aspmx1.migadu.com.", EMAIL_TTL()),
    MX("@", 20, "aspmx2.migadu.com.", EMAIL_TTL()),

    // DKIM
    CNAME(
        "key1._domainkey",
        "key1.ptr.pet._domainkey.migadu.com.",
        EMAIL_TTL(),
    ),
    CNAME(
        "key2._domainkey",
        "key2.ptr.pet._domainkey.migadu.com.",
        EMAIL_TTL(),
    ),
    CNAME(
        "key3._domainkey",
        "key3.ptr.pet._domainkey.migadu.com.",
        EMAIL_TTL(),
    ),

    // SPF
    TXT("@", "v=spf1 include:spf.migadu.com -all", EMAIL_TTL()),

    // DMARC
    TXT(
        "_dmarc",
        "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; fo=1; pct=100; rua=mailto:infrastructure@ptr.pet; ruf=mailto:infrastructure@ptr.pet",
        EMAIL_TTL(),
    ),

    // configuration
    TXT(
        "@",
        "mailconf=https://autoconfig.migadu.com/mail/config-v1.1.xml",
        EMAIL_TTL(),
    ),

    // TLS reporting
    TXT(
        "_smtp._tls",
        "v=TLSRPTv1; rua=mailto:infrastructure@ptr.pet",
        EMAIL_TTL(),
    ),

    // mta-sts
    TRIMOUNTS("mta-sts", CF_PROXY_OFF),
    TXT("_mta-sts", "v=STSv1; id=20250930T1945", EMAIL_TTL()),

    // autoconfig
    TRIMOUNTS(["autoconfig", "autodiscover"], CF_PROXY_OFF),

    // autodiscovery
    SRV(
        "_autodiscover._tcp",
        0,
        1,
        443,
        "autodiscover.migadu.com.",
        EMAIL_TTL(),
    ),
    SRV("_submissions._tcp", 0, 1, 465, "smtp.migadu.com.", EMAIL_TTL()),
    SRV("_imaps._tcp", 0, 1, 993, "imap.migadu.com.", EMAIL_TTL()),
    SRV("_pop3s._tcp", 0, 1, 995, "pop.migadu.com.", EMAIL_TTL()),

    IGNORE_ACME(),
);
