{ pkgs
, host ? "127.0.0.1"
, port ? 8080
, model ? "qwen2.5-coder-1.5b-instruct-q4_k_m.gguf"
}:
{
  vim = {
    options = {
      number = true; relativenumber = true;
      splitbelow = true; splitright = true;
      wrap = false; expandtab = true; tabstop = 2; shiftwidth = 2;
      scrolloff = 6;
      virtualedit = "block";
      inccommand = "split";
      ignorecase = true;
      termguicolors = true;
      undofile = true;
      conceallevel = 2;
      concealcursor = "nc";
      autoread = true;
    };

    globals.mapleader = " ";

    theme = { enable = true; name = "gruvbox"; style = "dark"; };

    treesitter = {
      enable = true;
      highlight.enable = true;
      grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        go lua python rust nix bash c scheme
      ];
      textobjects = {
        enable = true;
      };
    };

    luaConfigRC.treesitter-path = ''
      local parser_dirs = vim.api.nvim_get_runtime_file("parser", true)
      for _, dir in ipairs(parser_dirs) do
        vim.opt.runtimepath:prepend(vim.fn.fnamemodify(dir, ":h"))
      end
    '';

    luaConfigRC.textobjects-fix = ''
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })
      local ts_sel = require("nvim-treesitter-textobjects.select")
      local ts_move = require("nvim-treesitter-textobjects.move")
      local ts_swap = require("nvim-treesitter-textobjects.swap")
      local sel = function(qs) return function() ts_sel.select_textobject(qs, "textobjects") end end

      vim.keymap.set({ "x", "o" }, "af", sel("@function.outer"))
      vim.keymap.set({ "x", "o" }, "if", sel("@function.inner"))
      vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"))
      vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"))
      vim.keymap.set({ "x", "o" }, "aa", sel("@call.outer"))
      vim.keymap.set({ "x", "o" }, "ia", sel("@call.inner"))
      vim.keymap.set({ "x", "o" }, "a,", sel("@parameter.outer"))
      vim.keymap.set({ "x", "o" }, "i,", sel("@parameter.inner"))
      vim.keymap.set({ "x", "o" }, "ab", sel("@block.outer"))
      vim.keymap.set({ "x", "o" }, "ib", sel("@block.inner"))
      vim.keymap.set({ "x", "o" }, "al", sel("@loop.outer"))
      vim.keymap.set({ "x", "o" }, "il", sel("@loop.inner"))
      vim.keymap.set({ "x", "o" }, "ai", sel("@conditional.outer"))
      vim.keymap.set({ "x", "o" }, "ii", sel("@conditional.inner"))
      vim.keymap.set({ "x", "o" }, "a/", sel("@comment.outer"))
      vim.keymap.set({ "x", "o" }, "i/", sel("@comment.inner"))
      vim.keymap.set({ "x", "o" }, "a=", sel("@assignment.outer"))
      vim.keymap.set({ "x", "o" }, "i=", sel("@assignment.inner"))
      vim.keymap.set({ "x", "o" }, "ar", sel("@return.outer"))
      vim.keymap.set({ "x", "o" }, "ir", sel("@return.inner"))
      vim.keymap.set({ "x", "o" }, "as", sel("@statement.outer"))
      vim.keymap.set({ "x", "o" }, "a#", sel("@number.outer"))

      vim.keymap.set({ "n", "x", "o" }, "]m", function() ts_move.goto_next_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[m", function() ts_move.goto_previous_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]M", function() ts_move.goto_next_end("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[M", function() ts_move.goto_previous_end("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]]", function() ts_move.goto_next_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[[", function() ts_move.goto_previous_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "][", function() ts_move.goto_next_end("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[]", function() ts_move.goto_previous_end("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]o", function() ts_move.goto_next_start("@loop.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[o", function() ts_move.goto_previous_start("@loop.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]O", function() ts_move.goto_next_end("@loop.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[O", function() ts_move.goto_previous_end("@loop.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]d", function() ts_move.goto_next("@conditional.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[d", function() ts_move.goto_previous("@conditional.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]a", function() ts_move.goto_next_start("@call.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[a", function() ts_move.goto_previous_start("@call.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]c", function() ts_move.goto_next_start("@comment.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[c", function() ts_move.goto_previous_start("@comment.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]s", function() ts_move.goto_next_start("@statement.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[s", function() ts_move.goto_previous_start("@statement.outer", "textobjects") end)

      vim.keymap.set("n", "<leader>a", function() ts_swap.swap_next("@parameter.inner", "textobjects") end)
      vim.keymap.set("n", "<leader>A", function() ts_swap.swap_previous("@parameter.inner", "textobjects") end)
    '';

    lsp = { enable = true; lspconfig.enable = true; };

    git = {
      enable = true;
      gitsigns = {
        enable = true;
        mappings = {
          nextHunk = "]g";
          previousHunk = "[g";
        };
      };
    };

    languages = {
      enableTreesitter = true;  nix.enable = true;      lua.enable = true;      bash.enable = true;
      clang.enable = true;      rust.enable = true;     zig.enable = true;      typst.enable = true;        yaml.enable = true;       markdown.enable = true;
      assembly.enable = true;   go.enable = true;       python.enable = true;   terraform.enable = true;    helm.enable = true;       hcl.enable = true;
      sql.enable = true;        html.enable = true;     css.enable = true;      svelte.enable = true;       typescript.enable = true; php.enable = true;
    };

    autocomplete.blink-cmp = {
      enable = true;
      mappings = {
        complete       = "<C-Space>";
        confirm        = "<C-y>";
        next           = "<C-n>";
        previous       = "<C-p>";
        close          = "<C-e>";
        scrollDocsUp   = "<C-u>";
        scrollDocsDown = "<C-d>";
      };
      friendly-snippets.enable = true;
    };

    luaConfigRC.blink-disable-tab = ''
      local blink = require("blink.cmp")
      blink.setup({
        keymap = {
          ["<Tab>"]   = { function() return false end },
          ["<S-Tab>"] = { function() return false end },
          ["<CR>"]    = { function() return false end },
        },
      })
    '';

    luaConfigRC.conceal-toggle = ''
      local conceal_states = {
        { level = 2, cursor = "nc" },
        { level = 2, cursor = "n"  },
        { level = 0, cursor = ""   },
        { level = 3, cursor = "nc" },
      }
      local conceal_idx = 1
      vim.keymap.set("n", "<leader>vc", function()
        conceal_idx = (conceal_idx % #conceal_states) + 1
        local s = conceal_states[conceal_idx]
        vim.o.conceallevel = s.level
        vim.o.concealcursor = s.cursor
        vim.notify("conceal: level=" .. s.level .. " cursor=" .. (s.cursor == "" and "off" or s.cursor))
      end, { desc = "Cycle conceal level" })
    '';

    luaConfigRC.autoread-checktime = ''
      vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
        command = "checktime",
      })
    '';

    luaConfigRC.no-auto-comment = ''
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          vim.opt_local.formatoptions:remove({ "c", "r", "o" })
        end,
      })
    '';

    statusline.lualine = { enable = true; theme = "gruvbox"; };
    binds.whichKey.enable = true;
    telescope.enable = true;

    extraPlugins = {
      vim-tmux-navigator = {
        package = pkgs.vimPlugins.vim-tmux-navigator;
        setup = "";
      };
      mini-files = {
        package = pkgs.vimPlugins.mini-nvim;
        setup = ''require('mini.files').setup({ content = { filter = nil } })'';
      };
      snacks = {
        package = pkgs.vimPlugins.snacks-nvim;
        setup = ''require('snacks').setup({ image = { enabled = true } })'';
      };
      fzf-lua = {
        package = pkgs.vimPlugins.fzf-lua;
        setup = "require('fzf-lua').setup()";
      };
      vimtex = {
        package = pkgs.vimPlugins.vimtex;
        setup = ''
          vim.g.vimtex_view_method = 'zathura'
          vim.g.vimtex_compiler_method = 'latexmk'
          vim.g.vimtex_compiler_latexmk = { out_dir = '/tmp/vimtex' }
        '';
      };
      markdown-preview = {
        package = pkgs.vimPlugins.markdown-preview-nvim;
        setup = "";
      };
      nvim-ts-autotag = {
        package = pkgs.vimPlugins.nvim-ts-autotag;
        setup = "require('nvim-ts-autotag').setup()";
      };
      flash = {
        package = pkgs.vimPlugins.flash-nvim;
        setup = ''
          require("flash").setup({
            modes = {
              char = { enabled = false },
            },
          })
        '';
      };
      code-preview = {
        package = pkgs.vimUtils.buildVimPlugin {
          pname = "code-preview-nvim";
          version = "2.3.0";
          src = pkgs.fetchFromGitHub {
            owner  = "Cannon07";
            repo   = "code-preview.nvim";
            rev    = "v2.3.0";
            hash   = "sha256-V/V6gYexosGWa2vt6cd0Gg1RZNEMRZvFLgsoQNnKzbk=";
          };
        };
        setup = ''
          require("code-preview").setup({
            diff = { layout = "tab" },
          })
        '';
      };
      llama-vim = {
        package = pkgs.vimPlugins.llama-vim;
        setup = ''
          vim.g.llama_config = {
            endpoint_fim  = 'http://${host}:${toString port}/infill',
            endpoint_inst = 'http://${host}:${toString port}/v1/chat/completions',
            model_fim     = '${model}',
            auto_fim      = true,
            keymap_fim_accept_full = '<C-y>',
            keymap_fim_accept_line = '<C-Y>',
            keymap_inst_accept     = ${"''"},
          }
        '';
      };
    };

    keymaps = [
      { key = "<A-j>"; mode = "n"; action = ":m .+1<CR>==";      desc = "Move line down"; }
      { key = "<A-k>"; mode = "n"; action = ":m .-2<CR>==";      desc = "Move line up"; }
      { key = "<A-j>"; mode = "v"; action = ":m '>+1<CR>gv=gv";  desc = "Move block down"; }
      { key = "<A-k>"; mode = "v"; action = ":m '<-2<CR>gv=gv";  desc = "Move block up"; }

      { key = "<Tab>";   mode = "n"; action = ":tabnext<CR>";     desc = "Next tab"; }
      { key = "<S-Tab>"; mode = "n"; action = ":tabprevious<CR>"; desc = "Prev tab"; }

      { key = "<F1>";  mode = "n"; action = ":set number! relativenumber!<CR>"; desc = "Toggle line numbers"; }
      { key = "<F2>";  mode = "n"; action = ":set listchars=space:·,tab:→\\ ,eol:↲,trail:•<CR>:set list!<CR>"; desc = "Toggle listchars"; }
      { key = "<F3>";  mode = "n"; action = ":set cursorline!<CR>"; desc = "Toggle cursorline"; }
      { key = "<F4>";  mode = "n"; action = "<cmd>lua local ft = vim.bo.ft; if ft=='markdown' then vim.cmd('MarkdownPreviewToggle') elseif ft=='tex' then vim.cmd('VimtexCompile') vim.cmd('VimtexView') elseif ft=='pdf' then vim.fn.jobstart({'zathura', vim.fn.expand('%')}) end<CR>"; desc = "Preview markup"; }
      { key = "<F5>";  mode = "n"; action = "za";  desc = "Toggle fold (current)"; }
      { key = "<F6>";  mode = "n"; action = "zA";  desc = "Toggle fold (recursive)"; }
      { key = "<F7>";  mode = "n"; action = "zi";  desc = "Toggle foldenable (all)"; }
      { key = "<F8>";  mode = "n"; action = ":set fdm=indent<CR>"; desc = "Fold all by indent"; }
      { key = "<F9>";  mode = "n"; action = ":set hlsearch!<CR>"; desc = "Toggle hlsearch"; }
      { key = "<F10>"; mode = "n"; action = ":noh<CR>"; desc = "Clear search highlight"; }
      { key = "<F11>"; mode = "n"; action = ":set spell!<CR>"; desc = "Toggle spell"; }
      { key = "<F12>"; mode = "n"; action = "<cmd>lua local d = vim.diagnostic; if d.is_disabled(0) then d.enable(0) else d.disable(0) end<CR>"; desc = "Toggle diagnostics"; }

      { key = "<leader>bl"; mode = "n"; action = "<cmd>lua require('fzf-lua').buffers()<CR>"; desc = "List buffers"; }
      { key = "<leader>bn"; mode = "n"; action = ":bnext<CR>";     desc = "Next buffer"; }
      { key = "<leader>bp"; mode = "n"; action = ":bprevious<CR>"; desc = "Prev buffer"; }
      { key = "<leader>bd"; mode = "n"; action = ":bdelete<CR>";   desc = "Delete buffer"; }

      { key = "gd"; mode = "n"; action = "<cmd>lua require('fzf-lua').lsp_definitions()<CR>";     desc = "Go to definition"; }
      { key = "gr"; mode = "n"; action = "<cmd>lua require('fzf-lua').lsp_references()<CR>";      desc = "Go to references"; }
      { key = "gt"; mode = "n"; action = "<cmd>lua require('fzf-lua').lsp_typedefs()<CR>";        desc = "Go to type def"; }
      { key = "gi"; mode = "n"; action = "<cmd>lua require('fzf-lua').lsp_implementations()<CR>"; desc = "Go to implementation"; }
      { key = "K";  mode = "n"; action = "<cmd>lua vim.lsp.buf.hover()<CR>"; desc = "Hover docs"; }

      { key = "<leader>ff"; mode = "n"; action = "<cmd>lua require('fzf-lua').files()<CR>";        desc = "Find files"; }
      { key = "<leader>fF"; mode = "n"; action = "<cmd>lua require('fzf-lua').files({ fd_opts = '--color=never --type f --hidden --follow --no-ignore' })<CR>"; desc = "Find files (incl. gitignore)"; }
      { key = "<leader>fg"; mode = "n"; action = "<cmd>lua require('fzf-lua').live_grep()<CR>";    desc = "Live grep"; }
      { key = "<leader>fw"; mode = "n"; action = "<cmd>lua require('fzf-lua').grep_cword()<CR>";   desc = "Find word"; }
      { key = "<leader>fW"; mode = "n"; action = "<cmd>lua require('fzf-lua').grep_cWORD()<CR>";   desc = "Find WORD"; }
      { key = "<leader>fs"; mode = "n"; action = "<cmd>lua require('fzf-lua').grep_project()<CR>"; desc = "Search project"; }
      { key = "<leader>fo"; mode = "n"; action = "<cmd>lua require('fzf-lua').oldfiles()<CR>";     desc = "Find recent"; }
      { key = "<leader>fc"; mode = "n"; action = "<cmd>lua require('fzf-lua').files({cwd=vim.fn.stdpath('config')})<CR>"; desc = "Find in config"; }

      { key = "<leader>ls"; mode = "n"; action = "<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>";  desc = "Doc symbols"; }
      { key = "<leader>lS"; mode = "n"; action = "<cmd>lua require('fzf-lua').lsp_workspace_symbols()<CR>"; desc = "Workspace symbols"; }
      { key = "<leader>ld"; mode = "n"; action = "<cmd>lua require('fzf-lua').diagnostics_document()<CR>";  desc = "Diagnostics"; }
      { key = "<leader>lD"; mode = "n"; action = "<cmd>lua require('fzf-lua').diagnostics_workspace()<CR>"; desc = "Workspace diagnostics"; }
      { key = "<leader>lr"; mode = "n"; action = "<cmd>lua vim.lsp.buf.rename()<CR>";      desc = "Rename"; }
      { key = "<leader>la"; mode = "n"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; desc = "Code action"; }
      { key = "<leader>lf"; mode = "n"; action = "<cmd>lua vim.lsp.buf.format()<CR>";      desc = "Format"; }
      { key = "<leader>le"; mode = "n"; action = "<cmd>lua vim.diagnostic.open_float()<CR>"; desc = "Show error"; }
      { key = "<leader>ln"; mode = "n"; action = "<cmd>lua vim.diagnostic.goto_next()<CR>";  desc = "Next diagnostic"; }
      { key = "<leader>lp"; mode = "n"; action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";  desc = "Prev diagnostic"; }

      { key = "<leader>gc"; mode = "n"; action = "<cmd>lua require('fzf-lua').git_commits()<CR>";  desc = "Git commits"; }
      { key = "<leader>gb"; mode = "n"; action = "<cmd>lua require('fzf-lua').git_branches()<CR>"; desc = "Git branches"; }
      { key = "<leader>gf"; mode = "n"; action = "<cmd>lua require('fzf-lua').git_files()<CR>";    desc = "Git files"; }

      { key = "<leader>hh"; mode = "n"; action = "<cmd>lua require('fzf-lua').helptags()<CR>"; desc = "Help tags"; }
      { key = "<leader>hk"; mode = "n"; action = "<cmd>lua require('fzf-lua').keymaps()<CR>";  desc = "Keymaps"; }
      { key = "<leader>hm"; mode = "n"; action = "<cmd>lua require('fzf-lua').manpages()<CR>"; desc = "Man pages"; }
      { key = "<leader>hc"; mode = "n"; action = "<cmd>lua require('fzf-lua').commands()<CR>"; desc = "Commands"; }

      { key = "<leader>qo"; mode = "n"; action = ":copen<CR>";  desc = "Open quickfix"; }
      { key = "<leader>qc"; mode = "n"; action = ":cclose<CR>"; desc = "Close quickfix"; }
      { key = "<leader>qn"; mode = "n"; action = ":cnext<CR>";  desc = "Next quickfix"; }
      { key = "<leader>qp"; mode = "n"; action = ":cprev<CR>";  desc = "Prev quickfix"; }

      { key = "<leader>e"; mode = "n"; action = "<cmd>lua require('mini.files').open()<CR>"; desc = "Open mini.files"; }
      { key = "<leader>E"; mode = "n"; action = "<cmd>lua require('mini.files').open(vim.api.nvim_buf_get_name(0))<CR>"; desc = "mini.files (current)"; }

      { key = "s";  mode = [ "n" "x" "o" ]; action = "<cmd>lua require('flash').jump()<CR>"; desc = "Flash jump"; }
      { key = "S";  mode = [ "n" "x" "o" ]; action = "<cmd>lua require('flash').treesitter()<CR>"; desc = "Flash treesitter"; }
      { key = "<leader>dp"; mode = "n"; action = "<cmd>CodePreviewCloseDiff<CR>"; desc = "Close code-preview diff"; }
    ];
  };
}
