vim.lsp.set_log_level 'trace'
require('vim.lsp.log').set_format_func(vim.inspect)
local nvim_lsp = require 'lspconfig'
local on_attach = function(_, bufnr)
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
end

-- Add the server that troubles you here
local name = 'norgls'
local cmd = { 'norgls' } -- needed for elixirls, omnisharp, sumneko_lua

local function escape_wildcards(path)
    return path:gsub('([%[%]%?%*])', '\\%1')
end

local function path_join(...)
    return table.concat(vim.tbl_flatten { ... }, '/')
end

local function exists(filename)
    local stat = vim.loop.fs_stat(filename)
    return stat and stat.type or false
end

function strip_archive_subpath(path)
    -- Matches regex from zip.vim / tar.vim
    path = vim.fn.substitute(path, 'zipfile://\\(.\\{-}\\)::[^\\\\].*$', '\\1', '')
    path = vim.fn.substitute(path, 'tarfile:\\(.\\{-}\\)::.*$', '\\1', '')
    return path
end

local function dirname(path)
    local strip_dir_pat = '/([^/]+)$'
    local strip_sep_pat = '/$'
    if not path or #path == 0 then
        return
    end
    local result = path:gsub(strip_sep_pat, ''):gsub(strip_dir_pat, '')
    if #result == 0 then
        return '/'
    end
    return result
end

local function iterate_parents(path)
    local function it(_, v)
        if v and not (v == "/") then
            v = dirname(v)
        else
            return
        end
        if v and vim.loop.fs_realpath(v) then
            return v, path
        else
            return
        end
    end

    return it, path, path
end

function search_ancestors(startpath, func)
    vim.validate { func = { func, 'f' } }
    if func(startpath) then
        return startpath
    end
    local guard = 100
    for path in iterate_parents(startpath) do
        -- Prevent infinite recursion if our algorithm breaks
        guard = guard - 1
        if guard == 0 then
            return
        end

        if func(path) then
            return path
        end
    end
end

local function root_pattern(...)
    local patterns = vim.tbl_flatten { ... }
    local function matcher(path)
        for _, pattern in ipairs(patterns) do
            for _, p in ipairs(vim.fn.glob(path_join(escape_wildcards(path), pattern), true, true)) do
                if exists(p) then
                    return path
                end
            end
        end
    end

    return function(startpath)
        startpath = strip_archive_subpath(startpath)
        return search_ancestors(startpath, matcher)
    end
end

nvim_lsp[name].setup {
    cmd = cmd,
    filetypes = { "norg" },
    on_attach = on_attach,
    root_dir = root_pattern("index.norg")
}
