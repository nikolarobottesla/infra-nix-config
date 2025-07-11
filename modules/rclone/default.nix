{userName, remote-name, ...}: { config, pkgs, ... }:
let
  su-c = "su ${userName} -c";
in
{
  # install rclone
  users.users."${userName}".packages = [ pkgs.rclone ];

  # need because running as user 
  programs.fuse.userAllowOther = true;

  systemd.services."${remote-name}-mount" = {
    enable = true;
    description = "${remote-name} mounting service";
    # after = [ "remote-fs.target" ];  # would probably also work
    wants = [ "network-online.target" ];
    after = [ "multi-user.target" ];

    path = [ pkgs.su pkgs.coreutils];

    preStart = "${su-c} 'fusermount -u /home/${userName}/${remote-name} | cat'
      ${su-c} 'rm -r /home/${userName}/${remote-name}'
      ${su-c} 'mkdir -p /home/${userName}/${remote-name}'";
    script = "${su-c} 'rclone mount ${remote-name}: /home/${userName}/${remote-name} --vfs-cache-mode full --allow-other --allow-non-empty'";
    postStop = 
      "${su-c} 'fusermount -u /home/${userName}/${remote-name} | cat'
      ${su-c} 'rmdir /home/${userName}/${remote-name}'";

    restartIfChanged = true;
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";  # is this working?
      RestartSec = 10;
    };
  };
}