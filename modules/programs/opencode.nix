{ pkgs, lib, config, open-design, ... }:
let
  user = config.usuarioPrincipal;
  home = config.users.users.${config.usuarioPrincipal}.home;

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

  odDaemon = open-design.packages.${pkgs.system}.daemon;

  mcpEntries = lib.concatStringsSep ",\n              " [
    "\"context7\": {\"type\": \"remote\", \"url\": \"https://mcp.context7.com/mcp\"}"
    "\"codebase\": {\"type\": \"local\", \"command\": [\"${codebaseMem}/bin/codebase-memory-mcp\"]}"
    "\"memoryGraph\": {\"type\": \"local\", \"command\": [\"${mcpKnowledgeGraph}/bin/mcp-knowledge-graph\", \"--memory-path\", \"${home}/.aim/memory.jsonl\"]}"
    "\"open-design\": {\"type\": \"local\", \"command\": [\"${odDaemon}/bin/od\", \"mcp\", \"--daemon-url\", \"http://127.0.0.1:${toString config.ai.opendesign.puerto}\"]}"
    "\"playwright\": {\"type\": \"local\", \"command\": [\"${pkgs.playwright-mcp}/bin/playwright-mcp\"]}"
  ];
in
{
  options.ai.opencode.enable = lib.mkEnableOption "Activa OpenCode (incluye context7, codebase-memory-mcp y mcp-knowledge-graph)";

  config = lib.mkIf config.ai.opencode.enable {
    assertions = [{
      assertion = config.sops.enable;
      message = "ai.opencode requiere sops (sops.enable) para las claves de proveedores";
    }];

    userPackages.ai = [ pkgs.opencode codebaseMem mcpKnowledgeGraph pkgs.playwright-mcp ];

    sops.secrets."opencode/opencode_go_key" = {};

    myImpermanence.users.${user}.directories = [
      ".config/opencode"
      ".local/share/opencode"
      ".local/state/opencode"
      ".cache/codebase-memory-mcp"
      ".aim"
      ".npm"
    ];

    system.activationScripts.opencode-config = {
      deps = [ "setupSecrets" "users" ];
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
          "permission": { "edit": "allow", "bash": "allow", "filesystem": "allow" },
          "skills": {
            "urls": ["https://www.skills.sh/.well-known/skills/opencode/"]
          },
          "provider": {
            "opencode-go": {
              "options": { "apiKey": "$oc_key" }
            }${lib.optionalString (config ? ai && config.ai ? litellm && config.ai.litellm.enable) '',
            "openai-compatible": {
              "npm": "@ai-sdk/openai-compatible",
              "name": "LiteLLM proxy",
              "options": { "baseURL": "http://127.0.0.1:${toString config.ai.litellm.puerto}/v1", "apiKey": "$ll_key" },
              "models": {
                "deepseek-flash": {
                  "name": "DeepSeek Flash (via LiteLLM)",
                  "limit": { "context": 65536, "output": 8192 }
                },
                "deepseek-pro": {
                  "name": "DeepSeek Pro (via LiteLLM)",
                  "limit": { "context": 65536, "output": 8192 }
                }
              }
            }''}
          },
          "mcp": {
            ${mcpEntries}
          }${lib.optionalString (config ? ai && config.ai ? litellm && config.ai.litellm.enable) '',
          "model": "openai-compatible/deepseek-flash",
          "agent": {
            "build": {
              "mode": "primary",
              "model": "openai-compatible/deepseek-flash",
              "permission": { "edit": "allow", "bash": "allow" }
            },
            "plan": {
              "mode": "primary",
              "model": "openai-compatible/deepseek-pro",
              "permission": { "edit": "allow", "bash": "allow", "filesystem": "allow" }
            }
          }''}
        }
        ENDCONFIG

        ${pkgs.coreutils}/bin/chown -R ${user}:${user} ${home}/.config/opencode
      '';
    };
  };
}
