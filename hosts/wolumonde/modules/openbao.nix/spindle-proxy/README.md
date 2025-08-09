see https://tangled.sh/@tangled.sh/core/blob/master/docs/spindle/openbao.md

set BAO_ADDRESS: `$env.BAO_ADDRESS = "http://bao.lan.gaze.systems"`
set BAO_TOKEN: `$env.BAO_TOKEN = "<root key>"`

create mount: `bao secrets enable -path=spindle -version=2 kv`

setup policy: `
bao policy write spindle /var/lib/openbao/policies/spindle.hcl
bao auth enable approle
bao write auth/approle/role/spindle \
    token_policies="spindle" \
    token_ttl=1h \
    token_max_ttl=4h \
    bind_secret_id=true \
    secret_id_ttl=0 \
    secret_id_num_uses=0
`

get role-id: `bao read -field=role_id auth/approle/role/spindle/role-id`
get secret-id: `bao write -f auth/approle/role/spindle/secret-id`
