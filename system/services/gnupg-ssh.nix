{
  # GPG agent for managing GPG keys and SSH agent emulation
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # disable the above if you want to use gpg-agent
  # environment.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
  /*
    programs.ssh.extraConfig = ''
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/id_ed25519
    '';
  */
}
