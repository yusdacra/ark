{ config, lib, ... }:
let
  l = lib // builtins;
  t = l.types;

  cfg = config.services.headscale.acl;
  ruleType = t.submodule {
    options = {
      action = l.mkOption {
        type = t.enum [ "accept" ];
        default = "accept";
      };
      proto = l.mkOption {
        type = t.nullOr (
          t.enum [
            "tcp"
            "udp"
          ]
        );
        default = null;
      };
      src = l.mkOption {
        type = t.listOf t.str;
      };
      dst = l.mkOption {
        type = t.listOf t.str;
      };
    };
  };
  sshRuleType = t.submodule {
    options = {
      action = l.mkOption {
        type = t.enum [ "accept" ];
        default = "accept";
      };
      users = l.mkOption {
        type = t.listOf t.str;
      };
      src = l.mkOption {
        type = t.listOf t.str;
      };
      dst = l.mkOption {
        type = t.listOf t.str;
      };
    };
  };
in
{
  options = {
    services.headscale.acl = {
      groups = l.mkOption {
        type = t.attrsOf (t.listOf t.str);
        default = [ ];
      };
      tagOwners = l.mkOption {
        type = t.attrsOf (t.listOf t.str);
        default = [ ];
      };
      hosts = l.mkOption {
        type = t.attrsOf t.str;
        default = [ ];
      };
      rules = l.mkOption {
        type = t.listOf ruleType;
        default = [ ];
      };
      sshRules = l.mkOption {
        type = t.listOf sshRuleType;
        default = [];
      };
    };
  };

  config =
    let
      generated = l.toFile "policy.hujson" (
        l.toJSON {
          groups = l.mapAttrs' (k: v: l.nameValuePair "group:${k}" v) cfg.groups;
          tagOwners = l.mapAttrs' (k: v: l.nameValuePair "tag:${k}" v) cfg.tagOwners;
          hosts = cfg.hosts;
          acls = l.map (rule: if rule.proto == null then l.removeAttrs rule [ "proto" ] else rule) cfg.rules;
          ssh = cfg.sshRules;
        }
      );
    in
    {
      services.headscale.settings.policy = {
        mode = "file";
        path = generated;
      };
    };
}
