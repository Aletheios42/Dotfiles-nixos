{ pkgs, lib, config, ... }:
let
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
  '';
in
{
  options.ai.litellm.enable = lib.mkEnableOption "Activa LiteLLM proxy (enruta DeepSeek + llama-server work)";
  options.ai.litellm.puerto = lib.mkOption { type = lib.types.port; };

  config = lib.mkIf config.ai.litellm.enable {
    assertions = [{
      assertion = config.sops.enable;
      message = "ai.litellm requiere sops para DEEPSEEK_API_KEY y master key";
    }];

    sops.secrets."ai/deepseek_api_key" = {};
    sops.secrets."ai/litellm_master_key" = {};

    sops.templates."litellm.env" = {
      content = ''
        DEEPSEEK_API_KEY=${config.sops.placeholder."ai/deepseek_api_key"}
        LITELLM_MASTER_KEY=${config.sops.placeholder."ai/litellm_master_key"}
      '';
    };

    systemd.services.litellm = {
      description = "LiteLLM AI Gateway proxy";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3.withPackages (ps: [
          ps.litellm
          # Si necesita expression u otros, los puedes listar aquí si existen, 
          # o dejar que python3.withPackages gestione los paquetes compatibles.
        ])}/bin/litellm"
          + " --config ${litellmConfigYaml}"
          + " --host 127.0.0.1"
          + " --port ${toString config.ai.litellm.puerto}";
        EnvironmentFile = config.sops.templates."litellm.env".path;
        Restart               = "on-failure";
        RestartSec            = "5s";
      };
    };
  };
}
