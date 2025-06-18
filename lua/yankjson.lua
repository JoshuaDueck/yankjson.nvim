local M = {}

local config = {}

local function yankjson()
	local ts_utils = require("nvim-treesitter.ts_utils")
	local node = ts_utils.get_node_at_cursor()

	-- Walk up to find the key node
	while node and node:type() ~= "pair" do
		node = node:parent()
	end

	if not node then
		return
	end

	local path = {}

	local function get_key(n)
		if n:type() == "pair" then
			local key_node = n:child(0)
			local key = vim.treesitter.get_node_text(key_node, 0):gsub('"', "")
			table.insert(path, 1, key)
		end
	end

	while node do
		get_key(node)
		node = node:parent()
		while node and node:type() ~= "pair" do
			node = node:parent()
		end
	end

	local result = table.concat(path, ".")
	vim.fn.setreg("+", result)
	print("Copied: " .. result)
end

function M.setup(opts)
	-- Merge user options with default config
	config = vim.tbl_deep_extend("force", config, opts or {})

	vim.api.nvim_create_user_command("YJ", function()
		yankjson()
	end, { nargs = "?", count = true })
end

vim.api.nvim_set_keymap("n", "<leader>yj", ":YJ<CR>", { noremap = true, silent = true })

return M
