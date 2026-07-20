{ pkgs, lib, config, open-design, ... }:
let
  user = config.vars.usuarioPrincipal;
  home = config.vars.home;

  codebaseMem = pkgs.stdenv.mkDerivation {
    name = "codebase-memory-mcp-0.8.1";
    src = pkgs.fetchurl {
      url  = "https://github.com/DeusData/codebase-memory-mcp/releases/download/v0.8.1/codebase-memory-mcp-linux-amd64-portable.tar.gz";
      hash = "sha256-arh6bAXQSd3ldwCAPKCrQZn88llzoGBmGK8Pzuc/Wr0=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      tar xzf $src
      cp codebase-memory-mcp $out/bin/codebase-memory-mcp
    '';
  };

  mcpKnowledgeGraph = pkgs.writeShellApplication {
    name = "mcp-knowledge-graph";
    runtimeInputs = [ pkgs.nodejs ];
    text = ''
      exec ${pkgs.nodejs}/bin/npx -y --prefer-offline mcp-knowledge-graph "$@"
    '';
  };

  squeez = pkgs.stdenv.mkDerivation {
    name = "squeez-1.32.1";
    src = pkgs.fetchurl {
      url    = "https://github.com/claudioemmanuel/squeez/releases/download/v1.32.1/squeez-linux-x86_64";
      sha256 = "sha256-XVfAuA8rNPXcyYtzyx9whvISazdCKNejzgS3KbNmxtw=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/squeez
      chmod +x $out/bin/squeez
    '';
  };

  odDaemon = open-design.packages.${pkgs.system}.daemon;

  mcpEntries = lib.concatStringsSep ",\n              " [
    "\"context7\": {\"type\": \"remote\", \"url\": \"https://mcp.context7.com/mcp\"}"
    "\"squeez\": {\"type\": \"local\", \"command\": [\"${squeez}/bin/squeez\", \"mcp\"]}"
    "\"codebase\": {\"type\": \"local\", \"command\": [\"${codebaseMem}/bin/codebase-memory-mcp\"]}"
    "\"memoryGraph\": {\"type\": \"local\", \"command\": [\"${mcpKnowledgeGraph}/bin/mcp-knowledge-graph\", \"--memory-path\", \"${home}/.aim/memory.jsonl\"]}"
    "\"open-design\": {\"type\": \"local\", \"command\": [\"${odDaemon}/bin/od\", \"mcp\", \"--daemon-url\", \"http://127.0.0.1:${toString config.opendesign.port}\"]}"
  ];

  litellmConfigYaml = pkgs.writeText "litellm-config.yaml" ''
    model_list:
      - model_name: deepseek-flash
        litellm_params:
          model: deepseek/deepseek-chat
          api_key: os.environ/DEEPSEEK_API_KEY
      - model_name: deepseek-pro
        litellm_params:
          model: deepseek/deepseek-reasoner
          api_key: os.environ/DEEPSEEK_API_KEY
      - model_name: qwen-coder-37-4b
        litellm_params:
          model: openai/llama-work
          api_base: http://${config.ai.llama.work.host}:${toString config.ai.llama.work.port}/v1
          api_key: llama-local
  '';
in
{
  options.ai = {
    enable = lib.mkEnableOption "Activa el modulo de herramientas AI";

    opencode = {
      enable = lib.mkEnableOption "Activa OpenCode (incluye context7, squeez, codebase-memory-mcp y mcp-knowledge-graph)";
    };

    litellm = {
      enable = lib.mkEnableOption "Activa LiteLLM proxy (enruta DeepSeek + llama-server work)";
      port   = lib.mkOption {
        type    = lib.types.port;
        default = 4000;
        description = "Puerto del proxy LiteLLM";
      };
    };

    llama = {
      fim = {
        enable = lib.mkEnableOption "llama-server FIM (siempre on, modelo ligero)";
        host   = lib.mkOption { type = lib.types.str; default = "127.0.0.1"; };
        port   = lib.mkOption { type = lib.types.port; default = 8080; };
        model  = lib.mkOption { type = lib.types.str; default = "qwen2.5-coder-1.5b-instruct-q4_k_m.gguf"; };
      };
      work = {
        enable = lib.mkEnableOption "llama-server trabajo (toggle manual via systemctl)";
        host   = lib.mkOption { type = lib.types.str; default = "127.0.0.1"; };
        port   = lib.mkOption { type = lib.types.port; default = 8081; };
        model  = lib.mkOption { type = lib.types.str; default = "qwen2.5-coder-7b-instruct-q4_k_m.gguf"; description = "Modelo por defecto para el symlink ~/models/work-model.gguf"; };
      };
    };
  };

  config = lib.mkIf config.ai.enable (lib.mkMerge [

    (lib.mkIf config.ai.opencode.enable {
      assertions = [{
        assertion = config.mi_sops.enable;
        message = "ai.opencode requiere sops (mi_sops.enable) para las claves de proveedores";
      }];

      userPackages.ai = [ pkgs.opencode squeez codebaseMem mcpKnowledgeGraph ];

      sops.secrets."opencode/opencode_go_key" = {};

      myImpermanence.users.${user}.directories = [
        ".config/opencode"
        ".local/share/opencode"
        ".local/state/opencode"
        ".cache/codebase-memory-mcp"
        ".aim"
        ".npm"
      ];

      system.activationScripts.opencode-squeez-setup = {
        deps = [ "users" ];
        text = ''
          if [ ! -f ${home}/.config/opencode/plugins/squeez.js ]; then
            mkdir -p ${home}/.config/opencode/plugins
            HOME=${home} ${squeez}/bin/squeez setup --host=opencode
            ${pkgs.coreutils}/bin/chown -R ${user}:${user} ${home}/.config/opencode
          fi
        '';
      };

      system.activationScripts.opencode-config = {
        deps = [ "setupSecrets" "users" "opencode-squeez-setup" ];
        text = ''
          oc_key=$(${pkgs.coreutils}/bin/cat ${config.sops.secrets."opencode/opencode_go_key".path} 2>/dev/null || echo "CHANGE_ME")
          ll_key=$(${pkgs.coreutils}/bin/cat ${config.sops.secrets."ai/litellm_master_key".path} 2>/dev/null || echo "CHANGE_ME")

          mkdir -p ${home}/.config/opencode/agents
          mkdir -p ${home}/.local/share/opencode

          ${pkgs.coreutils}/bin/cat > ${home}/.config/opencode/opencode.jsonc << ENDCONFIG
          {
            "\$schema": "https://opencode.ai/config.json",
            "lsp": true,
            "autoupdate": false,
            "share": "disabled",
            "experimental": { "openTelemetry": false },
            "permission": { "edit": "ask" },
            "skills": {
              "urls": ["https://www.skills.sh/.well-known/skills/opencode/"]
            },
            "provider": {
              "opencode-go": {
                "options": { "apiKey": "$oc_key" }
              }${lib.optionalString config.ai.litellm.enable '',
              "openai-compatible": {
                "npm": "@ai-sdk/openai-compatible",
                "name": "LiteLLM proxy",
                "options": { "baseURL": "http://127.0.0.1:${toString config.ai.litellm.port}/v1", "apiKey": "$ll_key" },
                "models": {
                  "deepseek-flash": {
                    "name": "DeepSeek Flash (via LiteLLM)",
                    "limit": { "context": 65536, "output": 8192 }
                  },
                  "deepseek-pro": {
                    "name": "DeepSeek Pro (via LiteLLM)",
                    "limit": { "context": 65536, "output": 8192 }
                  },
                  "qwen-coder-37-4b": {
                    "name": "Qwen3.7-Coder 4B (local via LiteLLM)",
                    "limit": { "context": 16384 , "output": 4096 }
                  }
                }
              }''}
            },
            "mcp": {
              ${mcpEntries}
            }${lib.optionalString config.ai.litellm.enable '',
            "model": "openai-compatible/qwen-coder-37-4b",
            "agent": {
              "build": {
                "mode": "primary",
                "model": "openai-compatible/qwen-coder-37-4b",
                "permission": { "edit": "allow", "bash": "allow" }
                },
              "plan": {
                "mode": "primary",
                "model": "openai-compatible/deepseek-pro",
                "permission": { "edit": "ask", "bash": "ask" }
                }
                }''}
          }
          ENDCONFIG

          ${pkgs.coreutils}/bin/chown -R ${user}:${user} ${home}/.config/opencode
        '';
      };
    })

    (lib.mkIf config.ai.litellm.enable {
      assertions = [{
        assertion = config.mi_sops.enable;
        message = "ai.litellm requiere sops para DEEPSEEK_API_KEY y master key";
      }];

      sops.secrets."ai/deepseek_api_key" = {
        owner = config.vars.usuarioPrincipal;
        group = "users";
        mode  = "0640";
      };
      sops.secrets."ai/litellm_master_key" = {
        owner = config.vars.usuarioPrincipal;
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
    })

    (lib.mkIf (config.ai.llama.fim.enable || config.ai.llama.work.enable) {
      users.users.${user}.linger = true;
      userPackages.ai = [ pkgs.llama-cpp ];
    })

    (lib.mkIf config.ai.llama.fim.enable {
      systemd.user.services.llama-server-fim = {
        description = "llama.cpp FIM server (lightweight, toggle via systemctl)";
        wantedBy    = [];
        after       = [ "network.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.llama-cpp}/bin/llama-server"
            + " --host ${config.ai.llama.fim.host}"
            + " --port ${toString config.ai.llama.fim.port}"
            + " --model ${home}/models/${config.ai.llama.fim.model}"
            + " --ctx-size 2048"
            + " --n-predict -1";
          Restart         = "always";
          RestartSec      = "5s";
          ExecStartPre    = "${pkgs.coreutils}/bin/test -f ${home}/models/${config.ai.llama.fim.model}";
        };
      };
    })

    (lib.mkIf config.ai.enable {
      myImpermanence.users.${user}.directories = [ "models" ];
    })

    (lib.mkIf config.ai.llama.work.enable {
      systemd.user.services.llama-server-work = {
        description = "llama.cpp work server (heavy, toggle via systemctl)";
        wantedBy    = [];
        after       = [ "network.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.llama-cpp}/bin/llama-server"
            + " --host ${config.ai.llama.work.host}"
            + " --port ${toString config.ai.llama.work.port}"
            + " --model ${home}/models/work-model.gguf"
            + " --ctx-size 8192"
            + " --n-predict -1"
            + " --cont-batching";
          Restart         = "on-failure";
          RestartSec      = "5s";
          ExecStartPre    = "${pkgs.coreutils}/bin/test -f ${home}/models/work-model.gguf";
        };
      };

      system.activationScripts.llama-work-symlink = {
        deps = [ "users" ];
        text = ''
          if [ ! -L ${home}/models/work-model.gguf ]; then
            ln -sf ${home}/models/${config.ai.llama.work.model} ${home}/models/work-model.gguf
            ${pkgs.coreutils}/bin/chown -h ${user}:${user} ${home}/models/work-model.gguf
          fi
        '';
      };
    })

  ]);
}
