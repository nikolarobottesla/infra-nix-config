# Keep a Cloudflare IP list in sync with IPs published by one or more sources.
# Sources are either HTTP(S) URLs whose response body is scanned for addresses,
# or DNS names (e.g. DuckDNS subdomains) whose A/AAAA records are collected.
# The source list, account ID, list ID, and API token are read from sops
# secrets via systemd LoadCredential so the token never appears in the unit or
# process arguments. The list is replaced wholesale (Cloudflare's PUT
# semantics), which makes the sources the single source of truth.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.cloudflareIpList;

  script = pkgs.writeText "cloudflare-ip-list.py" ''
    #!/usr/bin/env python3
    import ipaddress
    import json
    import os
    import re
    import socket
    import ssl
    import subprocess
    import sys
    import urllib.request

    CREDENTIALS = os.environ["CREDENTIALS_DIRECTORY"]
    RUNTIME = os.environ["RUNTIME_DIRECTORY"]

    # Candidate tokens: anything composed of hex digits, dots and colons,
    # optionally followed by a CIDR prefix. Every candidate is validated by
    # the ipaddress module, so timestamps and ordinary words are discarded.
    CANDIDATE = re.compile(r"[0-9A-Fa-f:.]{2,}(?:/[0-9]{1,3})?")


    def credential(name):
        with open(os.path.join(CREDENTIALS, name), encoding="utf-8") as f:
            return f.read().strip()


    def identifier(name):
        value = credential(name).strip("\"'").strip("/")
        if "/" in value or "://" in value:
            raise RuntimeError(
                name + " must be a bare ID, not a URL or path: " + value
            )
        return value


    def sources():
        entries = []
        for line in credential("sources").splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("dns://"):
                entries.append(("dns", line[len("dns://"):].rstrip("/")))
            elif line.startswith("dns:"):
                entries.append(("dns", line[len("dns:"):].rstrip("/")))
            elif "://" in line:
                entries.append(("url", line))
            else:
                # A bare hostname is treated as a DNS source.
                entries.append(("dns", line.rstrip("/")))
        if not entries:
            raise RuntimeError("no sources found in credentials/sources")
        return entries


    def resolve(host):
        found = set()
        for _, _, _, _, sockaddr in socket.getaddrinfo(
            host, None, family=socket.AF_UNSPEC, type=socket.SOCK_STREAM
        ):
            address = sockaddr[0].split("%", 1)[0]
            try:
                found.add(ipaddress.ip_network(address, strict=False))
            except ValueError:
                continue
        if not found:
            raise RuntimeError("DNS returned no usable addresses for " + host)
        return found


    def fetch(url):
        request = urllib.request.Request(
            url,
            headers={
                "User-Agent": "cloudflare-ip-list/1.0",
                "Accept": "text/plain, application/json, text/html, */*",
            },
        )
        context = ssl.create_default_context()
        with urllib.request.urlopen(request, timeout=30, context=context) as response:
            return response.read().decode("utf-8", "replace")


    def extract(text):
        found = set()
        for token in CANDIDATE.findall(text):
            token = token.strip(".")
            try:
                network = ipaddress.ip_network(token, strict=False)
            except ValueError:
                continue
            # Skip the unspecified placeholder addresses (:: and 0.0.0.0)
            # that commonly appear in HTML/CSS/JS rather than IP lists.
            if network.num_addresses == 1 and network.network_address.is_unspecified:
                continue
            found.add(network)
        return found


    def render(network):
        # Match Cloudflare's examples by emitting bare addresses for /32 and
        # /128, and canonical CIDR notation for everything else.
        if network.num_addresses == 1:
            return str(network.network_address)
        return str(network)


    def main():
        # Fail closed: if any source cannot be read, do not replace the list
        # with a partial result.
        networks = set()
        for kind, target in sources():
            if kind == "dns":
                print("resolving " + target, flush=True)
                networks.update(resolve(target))
            else:
                print("fetching " + target, flush=True)
                networks.update(extract(fetch(target)))

        if not networks:
            raise RuntimeError("no IP addresses or CIDRs found in any source")

        ordered = sorted(
            networks,
            key=lambda n: (n.version, int(n.network_address), n.prefixlen),
        )
        payload = [{"ip": render(network)} for network in ordered]

        payload_path = os.path.join(RUNTIME, "payload.json")
        with open(payload_path, "w", encoding="utf-8") as f:
            json.dump(payload, f)
        os.chmod(payload_path, 0o600)

        list_id = identifier("list-id")
        account_id = identifier("account-id")
        token = credential("token")

        # Keep the bearer token out of argv by passing it through a curl
        # config file with restrictive permissions.
        curl_config = os.path.join(RUNTIME, "curl.conf")
        with open(curl_config, "w", encoding="utf-8") as f:
            f.write('header = "Authorization: Bearer ' + token + '"\n')
            f.write('header = "Content-Type: application/json"\n')
        os.chmod(curl_config, 0o600)

        url = (
            "https://api.cloudflare.com/client/v4/accounts/"
            + account_id
            + "/rules/lists/"
            + list_id
            + "/items"
        )

        print("replacing " + str(len(payload)) + " list items", flush=True)
        print("PUT " + url, flush=True)
        result = subprocess.run(
            [
                "curl",
                "--config",
                curl_config,
                "--fail-with-body",
                "--silent",
                "--show-error",
                "--request",
                "PUT",
                "--data-binary",
                "@" + payload_path,
                url,
            ],
            text=True,
            capture_output=True,
        )

        if result.stdout:
            print(result.stdout)
        if result.returncode != 0:
            print(result.stderr, file=sys.stderr)
            if "404" in result.stdout or "404" in result.stderr:
                print(
                    "hint: verify that account-id and list-id belong to the same "
                    "Cloudflare account, that the list is under WAF custom lists "
                    "(not Zero Trust Gateway lists), and that the token has "
                    "Account Filter Lists: Edit permission",
                    file=sys.stderr,
                )
            return result.returncode
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        return 0


    if __name__ == "__main__":
        try:
            sys.exit(main())
        except Exception as error:
            print("error: " + str(error), file=sys.stderr)
            sys.exit(1)
  '';
in {
  options.my.cloudflareIpList = {
    enable = mkEnableOption "synchronise a Cloudflare IP list from remote sources";

    sourcesFile = mkOption {
      type = types.path;
      description = ''
        File containing one source per line. Each line is either:

        - an `http://` or `https://` URL whose response body is scanned for
          IPv4, IPv6, and CIDR values; or
        - a hostname whose A/AAAA records are used. Use a bare hostname or the
          explicit `dns:hostname` form. This is the recommended mode for
          DuckDNS names, since DuckDNS does not issue TLS certificates for
          subdomains and a router's self-signed certificate cannot be verified.

        Blank lines and lines starting with `#` are ignored.
      '';
    };

    accountIdFile = mkOption {
      type = types.path;
      description = "File containing the Cloudflare account ID.";
    };

    listIdFile = mkOption {
      type = types.path;
      description = "File containing the Cloudflare list ID.";
    };

    tokenFile = mkOption {
      type = types.path;
      description = "File containing a Cloudflare API token with Rulesets/Lists write access.";
    };

    interval = mkOption {
      type = types.str;
      default = "*:0/15";
      description = "systemd OnCalendar expression for the sync timer.";
    };

    randomizedDelaySec = mkOption {
      type = types.str;
      default = "5m";
      description = "Random delay added to timer runs to avoid a thundering herd.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cloudflare-ip-list = {
      description = "Synchronise Cloudflare IP list from remote sources";
      after = ["network-online.target"];
      wants = ["network-online.target"];

      path = [pkgs.curl];

      serviceConfig = {
        Type = "oneshot";
        DynamicUser = true;
        RuntimeDirectory = "cloudflare-ip-list";
        RuntimeDirectoryMode = "0700";
        UMask = "0077";

        # Read as root before privileges are dropped, so the secrets do not
        # need to be readable by the dynamic user.
        LoadCredential = [
          "sources:${cfg.sourcesFile}"
          "account-id:${cfg.accountIdFile}"
          "list-id:${cfg.listIdFile}"
          "token:${cfg.tokenFile}"
        ];

        ExecStart = "${pkgs.python3}/bin/python3 ${script}";

        # Hardening: only outbound network, a private /tmp, and no privileges.
        CapabilityBoundingSet = [""];
        AmbientCapabilities = [""];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service"];
      };
    };

    systemd.timers.cloudflare-ip-list = {
      description = "Synchronise Cloudflare IP list from remote sources";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
        RandomizedDelaySec = cfg.randomizedDelaySec;
        Unit = "cloudflare-ip-list.service";
      };
    };
  };
}
