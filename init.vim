let mapleader = " "    " hoặc ',' tùy bạn"

call plug#begin('~/.local/share/nvim/plugged')

	Plug 'nvim-treesitter/nvim-treesitter'
	Plug 'ribru17/bamboo.nvim'
    Plug 'windwp/nvim-autopairs'
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'neovim/nvim-lspconfig'           " LSP client gốc của Neovim
    Plug 'hrsh7th/nvim-cmp'                " Plugin gợi ý chính
    Plug 'hrsh7th/cmp-nvim-lsp'            " Lấy gợi ý từ LSP
    Plug 'hrsh7th/cmp-buffer'              " Gợi ý từ văn bản đang mở
    Plug 'hrsh7th/cmp-path'                " Gợi ý đường dẫn file
    Plug 'L3MON4D3/LuaSnip'                " Snippet engine
    Plug 'saadparwaiz1/cmp_luasnip'        " Cho phép cmp dùng LuaSnip


call plug#end()

colorscheme bamboo

" Bật airline
let g:airline#extensions#tabline#enabled = 1

" Hiển thị tên file đầy đủ trong tabline
let g:airline#extensions#tabline#formatter = 'unique_tail'

" Dùng powerline symbols (nếu font hỗ trợ)
let g:airline_powerline_fonts = 1

" Chọn theme (ví dụ seoul256, gruvbox, onehalfdark...)
" let g:airline_theme = ''

syntax on
set number
set tabstop=4
set shiftwidth=4
set expandtab
set cursorline
set termguicolors
set encoding=utf-8
set fileencoding=utf-8

lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'c', 'cpp', 'objc', 'python', 'make', 'java', 'lua', 'go' },
  highlight = { enable = true },
  indent = { enable = true }
}
EOF

" Di chuyển giữa các buffer
nnoremap <S-l> :bnext<CR>      " Shift + L → buffer kế
nnoremap <S-h> :bprevious<CR>  " Shift + H → buffer trước

" Đóng buffer hiện tại
nnoremap <leader>q :bd<CR>     " <leader> thường là dấu \ hoặc phím bạn đặt

lua << EOF
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Cấu hình diagnostic
vim.diagnostic.config({
    virtual_text = true,          -- Hiện lỗi inline
    signs = true,                 -- Hiện icon bên lề
    underline = true,             -- Gạch chân code bị lỗi
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})

-- Hiện diagnostic khi hover (cách tốt nhất)
vim.o.updatetime = 250
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false,
            close_events = { "CursorMoved", "CursorMovedI", "InsertEnter" },
            border = 'rounded',
            source = 'always',
        })
    end,
})

vim.lsp.config['clangd'] = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'python', 'make', 'java', 'lua' },
    root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
    capabilities = capabilities,
        on_attach = function(client, bufnr)
        local opts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    end,
    settings = {
        clangd = {
            fallbackFlags = { "-std=c++17" },
        },
    },
}

vim.lsp.enable('clangd')
EOF


lua << EOF
local cmp = require'cmp'
local luasnip = require'luasnip'

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line-1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif luasnip.jumpable(1) then
                luasnip.jump(1)
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
    {
        { name = 'buffer' },
        { name = 'path' },
    })
})
EOF


lua << EOF
require("nvim-autopairs").setup {}
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
EOF

augroup MyTemplates
    autocmd!
    autocmd BufNewFile *.cpp 0r $HOME/.config/nvim/templates/skeleton.cpp
augroup END
