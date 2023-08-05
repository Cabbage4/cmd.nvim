local m = {}

function m.setup()
	m.keyBind()
end

function m.keyBind()
	vim.api.nvim_set_keymap("n", "<leader>cmd", ":lua require'cmd'.feature()<cr>", { silent = true })
end

function m.feature()
	newBuffer({ "ma-cn-password: http://1.com", "ma-cn-verify: http://2.com" })
end

function openChrome(url)
	vim.fn.jobstart("open -a '/Applications/Google Chrome.app' '" .. url .. "'")
end

function newBuffer(data)
	local curBuffer = vim.api.nvim_get_current_win()
	local curBufferHeight = vim.api.nvim_win_get_height(curBuffer)
	local curBufferWith = vim.api.nvim_win_get_width(curBuffer)

	local buffer = vim.api.nvim_create_buf(false, true)
	local width = math.floor(curBufferWith * 0.5)
	local height = math.floor(curBufferHeight * 0.5)

	vim.api.nvim_open_win(buffer, true, {
		relative = "win",
		width = width,
		height = height,
		row = math.floor((curBufferHeight - height) / 2),
		col = math.floor((curBufferWith - width) / 2),
		border = "double",
		zindex = 100,
	})

	vim.api.nvim_buf_set_lines(buffer, 0, 0, false, data)
end

return m
