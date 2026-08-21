{ pkgs, lib, config, ... }:
let
  user = config.vars.usuarioPrincipal;
  litellmConfigYaml = pkgs.writeText "litellm-config.yaml" ''
    model_list:
      - model_name: deepseek-flash
        litellm_params:
          model: deepseek/deepseek-v4-flash
          api_key: os.environ/DEEPSEEK_API_KEY
      - model_name: deepseek-pro
        litellm_params:
          model: deepseek/deepseek-v4-pro
          api_key: os.environ/DEEPSEEK_API_KEY
      - model_name: work
        litellm_params:
          model: openai/llama-work
          api_base: http://${config.ai.llama.work.host}:${toString config.ai.llama.work.port}/v1
          api_key: llama-local
  '';
in
{
  options.ai.litellm.enable = lib.mkEnableOption "Activa LiteLLM proxy (enruta DeepSeek + llama-server work)";
  options.ai.litellm.port = lib.mkOption {
    type = lib.types.port;
    default = 4000;
    description = "Puerto del proxy LiteLLM";
  };
  options.ai.llama.work.host = lib.mkOption { type = lib.types.str; default = "127.0.0.1"; };
  options.ai.llama.work.port = lib.mkOption { type = lib.types.port; default = 8081; };

  config = lib.mkIf config.ai.litellm.enable {
    assertions = [{
      assertion = config.mi_sops.enable;
      message = "ai.litellm requiere sops para DEEPSEEK_API_KEY y master key";
    }];

    sops.secrets."ai/deepseek_api_key" = {
      owner = user;
      group = "users";
      mode  = "0640";
    };
    sops.secrets."ai/litellm_master_key" = {
      owner = user;
      group = "users";
      mode  = "0640";
    };

    sops.templates."litellm.env" = {
      content = ''
        DEEPSEEK_API_KEY=${config.sops.placeholder."ai/deepseek_api_key"}
        LITELLM_MASTER_KEY=${config.sops.placeholder."ai/litellm_master_key"}
      '';
      owner = user;
    };

    systemd.services.litellm = {
      description = "LiteLLM AI Gateway proxy";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.litellm}/bin/litellm"
          + " --config ${litellmConfigYaml}"
          + " --host 127.0.0.1"
          + " --port ${toString config.ai.litellm.port}";
        EnvironmentFile = config.sops.templates."litellm.env".path;
        User            = user;
        Group           = "users";
        Restart         = "on-failure";
        RestartSec      = "5s";
      };
    };
  };
}
