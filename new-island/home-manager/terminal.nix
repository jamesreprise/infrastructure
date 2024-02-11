{ config, lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    initExtra = ''
      # PATH and envvars
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#d78700"
      export GPG_TTY=$(tty)
      export REPO_VATICLE_USERNAME=...
      export REPO_VATICLE_PASSWORD=...
      export ARTIFACT_USERNAME=$REPO_VATICLE_USERNAME
      export ARTIFACT_PASSWORD=$REPO_VATICLE_PASSWORD
      export DEPLOY_HELM_USERNAME=$REPO_VATICLE_USERNAME
      export DEPLOY_HELM_PASSWORD=$REPO_VATICLE_PASSWORD
      # Gcloud
      export USE_GKE_GCLOUD_AUTH_PLUGIN=True
      # Aliases
      alias vim=nvim
      alias cd=z
      # Don't like it? Come kill me. 
      alias nano=nvim
      alias k=kubectl
      alias b=bazel
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
    prezto = {
      enable = true;
      pmodules = [
        "editor"
        "history"
        "completion"
        "prompt"
        "autosuggestions"
      ];
      prompt = {
        theme = "powerlevel10k";
        pwdLength = "full";
        showReturnVal = true;
      };
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --hidden";
  };

  programs.zoxide = {
    enable = true;
  };

  programs.lsd = {
    enable = true;
    enableAliases = true;
    settings = {
        icons = {
            when = "never";
        };
    };
  };

  programs.direnv.enable = true;
}

