local mode = {
  "mode",
  fmt = function(s)
    local mode_map = {
      ["NORMAL"] = "N",
      ["O-PENDING"] = "N?",
      ["INSERT"] = "I",
      ["VISUAL"] = "V",
      ["V-BLOCK"] = "VB",
      ["V-LINE"] = "VL",
      ["V-REPLACE"] = "VR",
      ["REPLACE"] = "R",
      ["COMMAND"] = "!",
      ["SHELL"] = "SH",
      ["TERMINAL"] = "T",
      ["EX"] = "X",
      ["S-BLOCK"] = "SB",
      ["S-LINE"] = "SL",
      ["SELECT"] = "S",
      ["CONFIRM"] = "Y?",
      ["MORE"] = "M",
    }
    return mode_map[s] or s
  end,
}

local function codecompanion_adapter_name()
  local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
  if not chat then
    return nil
  end

  return " " .. chat.adapter.formatted_name
end

local function codecompanion_current_model_name()
  local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
  if not chat then
    return nil
  end

  return chat.settings.model
end

return {
  { "folke/todo-comments.nvim", version = "*" },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      win = { border = "single" },
    },
  },

  {
    "amrbashir/nvim-docs-view",
    lazy = true,
    cmd = "DocsViewToggle",
    opts = {
      position = "right",
      width = 60,
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    requires = { "nvim-tree/nvim-web-devicons", opt = true },
    opts = {
      options = {
        theme = "gentleman-kanagawa-blur",
        icons_enabled = true,
      },
      sections = {
        lualine_a = {
          {
            "mode",
            icon = " 🪐",
          },
        },
      },
      extensions = {
        "quickfix",
        {
          filetypes = { "oil" },
          sections = {
            lualine_a = {
              mode,
            },
            lualine_b = {
              function()
                local ok, oil = pcall(require, "oil")
                if not ok then
                  return ""
                end
                local path = vim.fn.fnamemodify(oil.get_current_dir(), ":~")
                return path .. " %m"
              end,
            },
          },
        },
        {
          filetypes = { "codecompanion" },
          sections = {
            lualine_a = {
              mode,
            },
            lualine_b = {
              codecompanion_adapter_name,
            },
            lualine_c = {
              codecompanion_current_model_name,
            },
            lualine_x = {},
            lualine_y = {
              "progress",
            },
            lualine_z = {
              "location",
            },
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {
              codecompanion_adapter_name,
            },
            lualine_c = {},
            lualine_x = {},
            lualine_y = {
              "progress",
            },
            lualine_z = {},
          },
        },
      },
    },
  },

  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    priority = 1200,
    config = function()
      require("incline").setup({
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = {
          cursorline = true,
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[+] " .. filename
          end

          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          return { { icon, guifg = color }, { " " }, { filename } }
        end,
      })
    end,
  },

  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      plugins = {
        gitsigns = true,
        tmux = true,
        kitty = { enabled = false, font = "+2" },
        twilight = { enabled = true },
      },
    },
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
  },

  {
    "folke/snacks.nvim",
    opts = {
      notifier = {},
      image = {},
      picker = {
        exclude = {
          ".git",
          "node_modules",
        },
        matcher = {
          fuzzy = true,
          smartcase = true,
          ignorecase = true,
          filename_bonus = true,
        },
        sources = {},
      },
      dashboard = {
        sections = {
          { section = "header" },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
        preset = {
          header = [[
                                                  _.oo.
                          _.u[[/;:,.          .odMMMMMM'
                       .o888UU[[[/;:-.  .o@P^    MMM^
                      oN88888UU[[[/;::-.        dP^     
                     dNMMNN888UU[[[/;:--.   .o@P^      
                    ,MMMMMMN888UU[[/;::-. o@^          
                    NNMMMNN888UU[[[/~.o@P^              
                    888888888UU[[[/o@^-..              
                   oI8888UU[[[/o@P^:--..                
                .@^  YUU[[[/o@^;::---..                
              oMP     ^/o@P^;:::---..                  
           .dMMM    .o@^ ^;::---...                    
          dMMMMMMM@^`        `^^^^                        
          YMMMUP^                                         
           ^^                                             
                                                          
]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      -- Colores personalizados para Snacks Dashboard
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#ffcc66" })
      vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = "#ffcc66" })
      vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = "#ffcc66", bold = true })
      vim.api.nvim_set_hl(0, "SnacksDashboardTitle", { fg = "#ffcc66" })
      vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = "#FFFFFF" }) -- Cambia texto azul a blanco
    end,
  },
}
