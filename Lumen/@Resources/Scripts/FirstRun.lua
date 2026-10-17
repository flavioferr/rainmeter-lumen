-- Primeira execucao depois de instalar: carrega e posiciona os widgets da suite
-- conforme FirstRunLayout e abre as configuracoes. Roda uma unica vez.
--
-- FirstRunLayout = "Config,x,y|Config,x,y|..."
--   x/y positivo: distancia da esquerda/topo
--   x/y negativo: distancia da direita/base
--   c<tamanho>:   centralizado, para um widget com esse tamanho

function Initialize()
	done = false
end

local function coord(token, total, origin)
	local size = token:match('^c(%d+)$')
	if size then
		return origin + math.floor((total - tonumber(size)) / 2)
	end
	local n = tonumber(token) or 0
	if n < 0 then
		return origin + total + n
	end
	return origin + n
end

local function run()
	if tonumber(SKIN:GetVariable('FirstRun')) ~= 1 then return end
	SKIN:Bang('!WriteKeyValue', 'Variables', 'FirstRun', '0', SKIN:ReplaceVariables('#@#Variables.inc'))

	local root = SKIN:GetVariable('ROOTCONFIG')
	local current = SKIN:GetVariable('CURRENTCONFIG')
	local w = tonumber(SKIN:GetVariable('SCREENAREAWIDTH'))
	local h = tonumber(SKIN:GetVariable('SCREENAREAHEIGHT'))
	local x0 = tonumber(SKIN:GetVariable('SCREENAREAX'))
	local y0 = tonumber(SKIN:GetVariable('SCREENAREAY'))

	for item in string.gmatch(SKIN:GetVariable('FirstRunLayout') or '', '[^|]+') do
		local name, x, y = item:match('^([^,]+),([^,]+),([^,]+)$')
		if name then
			local config = root .. '\\' .. name
			if config ~= current then
				SKIN:Bang('!ActivateConfig', config, name .. '.ini')
			end
			SKIN:Bang('!Move', coord(x, w, x0), coord(y, h, y0), config)
		end
	end
end

function Update()
	if not done then
		done = true
		run()
	end
end
