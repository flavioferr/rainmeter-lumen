-- Troca o idioma da suite: grava Lang em Variables.inc e recarrega cada widget ativo com o .ini do idioma
-- (<Widget>.ini em portugues, <Widget>_en.ini em ingles). Os widgets ativos sao lidos do Rainmeter.ini.

function Initialize()
end

local function readText(path)
	local f = io.open(path, 'rb')
	if not f then return '' end
	local s = f:read('*a')
	f:close()
	if s:sub(1, 2) == '\255\254' then
		s = s:sub(3):gsub('(.)%z', '%1')
	end
	return s
end

function Set(lang)
	local root = SKIN:GetVariable('ROOTCONFIG')
	local current = SKIN:GetVariable('CURRENTCONFIG')
	SKIN:Bang('!WriteKeyValue', 'Variables', 'Lang', lang, SKIN:ReplaceVariables('#@#Variables.inc'))
	local suffix = (lang == 'en') and '_en.ini' or '.ini'
	local ini = readText(SKIN:GetVariable('SETTINGSPATH') .. 'Rainmeter.ini')
	local section, selfActive = nil, false
	for line in ini:gmatch('[^\r\n]+') do
		local sec = line:match('^%[(.+)%]%s*$')
		if sec then
			section = sec
		elseif section and line:match('^Active=') then
			local active = tonumber(line:match('^Active=(%d+)')) or 0
			local prefix = root .. '\\'
			if active > 0 and section:sub(1, #prefix):lower() == prefix:lower() then
				local name = section:sub(#prefix + 1)
				if not name:find('\\', 1, true) then
					if section:lower() == current:lower() then
						selfActive = true
					else
						SKIN:Bang('!ActivateConfig', section, name .. suffix)
					end
				end
			end
		end
	end
	local own = current:match('([^\\]+)$')
	SKIN:Bang('!ActivateConfig', current, own .. suffix)
end
