{user-name, remote-name, ...}: { config, pkgs, ... }:
let
  su-c = "su ${user-name} -c";
in
{
  # install rclone
  users.users.${user-name}.packages = [ pkgs.rclone ];

  # need because running as user 
  programs.fuse.userAllowOther = true;

  systemd.services."${remote-name}-mount" = {
    enable = true;
    description = "${remote-name} mounting service";
    # after = [ "remote-fs.target" ];  # would probably also work
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.su ];
    preStart = "${su-c} 'mkdir -p /home/${user-name}/${remote-name}'";
    script = "${su-c} 'rclone mount ${remote-name}: /home/${user-name}/${remote-name} --vfs-cache-mode full --allow-other --allow-non-empty'";
    preStop = "${su-c} 'fusermount -u /home/${user-name}/${remote-name}'";
    postStop = "${su-c} 'rmdir /home/${user-name}/${remote-name}'";

    restartIfChanged = true;  # doesn't seem to do anything
    restartTriggers = [ "on-failure" ]; # doesn't seem to work
    serviceConfig = {
      Type = "simple";
      # Restart = "on-failure"; 
    };
  };
}