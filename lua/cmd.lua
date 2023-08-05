local M = {}

function M.setup() end

function M.fold()
	local file_path = vim.api.nvim_exec("echo bufname()", true)
	local file_path_split = vim.split(file_path, "/")
	local file_name = file_path_split[#file_path_split]
	local file_type = require("telescope.utils").file_extension(file_name)
	if file_type == "json" then
		fold_json_file(file_path)
	elseif file_type == "go" then
		fold_go_file(file_path)
	end
end

function M.format()
	local file_path = vim.api.nvim_exec("echo bufname()", true)
	local file_path_split = vim.split(file_path, "/")
	local file_name = file_path_split[#file_path_split]
	local file_type = require("telescope.utils").file_extension(file_name)

	local command = ""
	if file_type == "proto" then
		command = "buf format " .. file_path
	elseif file_type == "sql" or file_type == "mysql" then
		command = "sql-formatter " .. file_path
	end

	if command == "" then
		return
	end

	vim.print("command: " .. command)
	local output = vim.fn.system(command)
	local output_list = vim.split(output, "\n")

	local current_buffer = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(current_buffer, 0, -1, false, output_list)
end

function fold_go_file(file_path)
	local output = vim.fn.system("gopls folding_ranges " .. file_path .. " 2>/dev/null")
	local output_list = vim.split(output, "\n")
	for i = 1, #output_list do
		if vim.trim(output_list[i]) == "" then
			goto continue
		end

		local item = vim.split(output_list[i], ":")
		vim.cmd(string.format("%d,%dfold", item[1], vim.split(item[2], "-")[2]))

		::continue::
	end
end

function fold_json_file(file_path)
	local inputFile = io.open(file_path, "r")
	if not inputFile then
		error("无法打开文件 " .. file_path)
	end

	local stack = {}
	local lineNum = 0

	for line in inputFile:lines() do
		lineNum = lineNum + 1

		-- 检查左大括号或左中括号以开始折叠
		if string.find(line, "{") or string.find(line, "%[") then
			table.insert(stack, { char = string.match(line, "[{%[]"), lineNum = lineNum })
		end

		-- 检查右大括号或右中括号以结束折叠
		if string.find(line, "}") or string.find(line, "%]") then
			if #stack == 0 then
				-- 防止无匹配的右括号/中括号
				goto continue
			end

			local last = table.remove(stack)

			-- 确保左右括号匹配
			if (last.char == "{" and string.find(line, "}")) or (last.char == "[" and string.find(line, "%]")) then
				vim.cmd(string.format("%d,%dfold", last.lineNum, lineNum))
			end
		end

		::continue::
	end

	inputFile:close()
end

return M
