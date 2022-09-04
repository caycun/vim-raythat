
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding

-- Encrypt text
local function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- Get visually highlighted text
local function visual_selection_range()
	local s_start = vim.fn.getpos("'<")
	local s_end = vim.fn.getpos("'>")
	local n_lines = math.abs(s_end[2] - s_start[2]) + 1
	local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
	lines[1] = string.sub(lines[1], s_start[3], -1)
	if n_lines == 1 then
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
	else
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
	end
	return table.concat(lines, '\n')
end

-- Generate code
local function generate_encoded()
	local str = visual_selection_range()
	return enc(str)
end

-- Get the language of your code based on file name
local function getLanguage()
	local file = vim.fn.expand("%.p")
	local args = {}

	for word in string.gmatch(file, '([^.]+)') do
		table.insert(args, word)
	end

	return args[#args]
end

-- Takes a screenshot of your code 
-- themes: candy, breeze, midnight, unset
local function activate(theme)  
	local url = "https://ray.so/?colors=" .. theme .. "t&background=true&darkMode=true&padding=64&title=" .. vim.fn.expand("%.p") .. "&code=" .. generate_encoded() .. "&language=" .. getLanguage() 
	vim.cmd("let @+=\""..url.."\"")	
end

return {
	activate = activate
}
