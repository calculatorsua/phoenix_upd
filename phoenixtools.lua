---@diagnostic disable: undefined-global, need-check-nil, lowercase-global, cast-local-type, unused-local
script_author('calculator')
script_name('atools')
script_version('0.1')

function update()
    local raw = 'https://github.com/calculatorsua/phoenix_upd/blob/main/update.json'
    local dlstatus = require('moonloader').download_status
    local requests = require('requests')
    local f = {}
    function f:getLastVersion()
        local response = requests.get(raw)
        if response.status_code == 200 then
            return decodeJson(response.text)['last']
        else
            return 'UNKNOWN'
        end
    end
    function f:download()
        local response = requests.get(raw)
        if response.status_code == 200 then
            downloadUrlToFile(decodeJson(response.text)['url'], thisScript().path, function (id, status, p1, p2)
                print('Скачиваю '..decodeJson(response.text)['url']..' в '..thisScript().path)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    sampAddChatMessage('Скрипт обновлен, перезагрузка...', -1)
                    thisScript():reload()
                end
            end)
        else
            sampAddChatMessage('Ошибка, невозможно установить обновление, код: '..response.status_code, -1)
        end
    end
    return f
end

-- https://github.com/qrlk/qrlk.lua.moonloader
local enable_sentry = true -- false to disable error reports to sentry.io
if enable_sentry then
  local sentry_loaded, Sentry = pcall(loadstring, [=[return{init=function(a)local b,c,d=string.match(a.dsn,"https://(.+)@(.+)/(%d+)")local e=string.format("https://%s/api/%d/store/?sentry_key=%s&sentry_version=7&sentry_data=",c,d,b)local f=string.format("local target_id = %d local target_name = \"%s\" local target_path = \"%s\" local sentry_url = \"%s\"\n",thisScript().id,thisScript().name,thisScript().path:gsub("\\","\\\\"),e)..[[require"lib.moonloader"script_name("sentry-error-reporter-for: "..target_name.." (ID: "..target_id..")")script_description("Этот скрипт перехватывает вылеты скрипта '"..target_name.." (ID: "..target_id..")".."' и отправляет их в систему мониторинга ошибок Sentry.")local a=require"encoding"a.default='CP1251'local b=a.UTF8;local c="moonloader"function getVolumeSerial()local d=require"ffi"d.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local e=d.new("unsigned long[1]",0)d.C.GetVolumeInformationA(nil,nil,0,e,nil,nil,nil,0)e=e[0]return e end;function getNick()local f,g=pcall(function()local f,h=sampGetPlayerIdByCharHandle(PLAYER_PED)return sampGetPlayerNickname(h)end)if f then return g else return"unknown"end end;function getRealPath(i)if doesFileExist(i)then return i end;local j=-1;local k=getWorkingDirectory()while j*-1~=string.len(i)+1 do local l=string.sub(i,0,j)local m,n=string.find(string.sub(k,-string.len(l),-1),l)if m and n then return k:sub(0,-1*(m+string.len(l)))..i end;j=j-1 end;return i end;function url_encode(o)if o then o=o:gsub("\n","\r\n")o=o:gsub("([^%w %-%_%.%~])",function(p)return("%%%02X"):format(string.byte(p))end)o=o:gsub(" ","+")end;return o end;function parseType(q)local r=q:match("([^\n]*)\n?")local s=r:match('^.+:%d+: (.+)')return s or"Exception"end;function parseStacktrace(q)local t={frames={}}local u={}for v in q:gmatch("([^\n]*)\n?")do local w,x=v:match("^    *(.:.-):(%d+):")if not w then w,x=v:match("^    *%.%.%.(.-):(%d+):")if w then w=getRealPath(w)end end;if w and x then x=tonumber(x)local y={in_app=target_path==w,abs_path=w,filename=w:match("^.+\\(.+)$"),lineno=x}if x~=0 then y["pre_context"]={fileLine(w,x-3),fileLine(w,x-2),fileLine(w,x-1)}y["context_line"]=fileLine(w,x)y["post_context"]={fileLine(w,x+1),fileLine(w,x+2),fileLine(w,x+3)}end;local z=v:match("in function '(.-)'")if z then y["function"]=z else local A,B=v:match("in function <%.* *(.-):(%d+)>")if A and B then y["function"]=fileLine(getRealPath(A),B)else if#u==0 then y["function"]=q:match("%[C%]: in function '(.-)'\n")end end end;table.insert(u,y)end end;for j=#u,1,-1 do table.insert(t.frames,u[j])end;if#t.frames==0 then return nil end;return t end;function fileLine(C,D)D=tonumber(D)if doesFileExist(C)then local E=0;for v in io.lines(C)do E=E+1;if E==D then return v end end;return nil else return C..D end end;function onSystemMessage(q,F,i)if i and F==3 and i.id==target_id and i.name==target_name and i.path==target_path and not q:find("Script died due to an error.")then local G={tags={moonloader_version=getMoonloaderVersion(),sborka=string.match(getGameDirectory(),".+\\(.-)$")},level="error",exception={values={{type=parseType(q),value=q,mechanism={type="generic",handled=false},stacktrace=parseStacktrace(q)}}},environment="production",logger=c.." (no sampfuncs)",release=i.name.."@"..i.version,extra={uptime=os.clock()},user={id=getVolumeSerial()},sdk={name="qrlk.lua.moonloader",version="0.0.0"}}if isSampAvailable()and isSampfuncsLoaded()then G.logger=c;G.user.username=getNick().."@"..sampGetCurrentServerAddress()G.tags.game_state=sampGetGamestate()G.tags.server=sampGetCurrentServerAddress()G.tags.server_name=sampGetCurrentServerName()else end;print(downloadUrlToFile(sentry_url..url_encode(b:encode(encodeJson(G)))))end end;function onScriptTerminate(i,H)if not H and i.id==target_id then lua_thread.create(function()print("скрипт "..target_name.." (ID: "..target_id..")".."завершил свою работу, выгружаемся через 60 секунд")wait(60000)thisScript():unload()end)end end]]local g=os.tmpname()local h=io.open(g,"w+")h:write(f)h:close()script.load(g)os.remove(g)end}]=])
  if sentry_loaded and Sentry then
    --replace "https://f42fc8741da21aebd8c686ae0ebf867a@o4508247661543424.ingest.de.sentry.io/4508528831168592" with your DSN obtained from sentry.io after you create project
    --https://docs.sentry.io/product/sentry-basics/dsn-explainer/#where-to-find-your-dsn
    pcall(Sentry().init, { dsn = "https://f42fc8741da21aebd8c686ae0ebf867a@o4508247661543424.ingest.de.sentry.io/4508528831168592" })
  end
end
local ffi = require "ffi"
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
require "lib.moonloader"
local memory = require "memory"
local inicfg = require('inicfg')
local imgui = require 'mimgui'
local vkeys = require 'vkeys'
local font = renderCreateFont('Arial', 10, 5 + 10)
local samp = require 'lib.samp.events'
stop = 0
started = 0
prinato = 0
active_report = 0
active_report2 = 0

local active = false
local players = {}
local directIni = 'AirBrake.ini'
local ini = inicfg.load({
    cfg = {
        state = false,
        speed_onfoot = 0.7,
        speed_incar = 0.7,
        speed_passenger = 0.7,
        sync_onfoot = 0.7,
        sync_incar = 0.7,
        sync_passenger = 0.7,
    }
}, directIni)
local new, config = imgui.new, ini.cfg

ffi = require 'ffi'
ffi.cdef [[
    typedef unsigned long HANDLE;
    typedef HANDLE HWND;
    typedef const char *LPCTSTR;

    HWND GetActiveWindow(void);

    bool SetWindowTextA(HWND hWnd, LPCTSTR lpString);
]]


local sync = 0

local AirBrake = {
    state = new.bool(config.state),
    active = false,
    speed = {
        onfoot = new.float(config.speed_onfoot),
        incar = new.float(config.speed_incar),
        passenger = new.float(config.speed_passenger)
    },
    sync = {
        onfoot = new.float(config.sync_onfoot),
        incar = new.float(config.sync_incar),
        passenger = new.float(config.sync_passenger)
    }
}

whVisible = "all" -- Мод ВХ по умолчанию. Моды написаны в комментарии ниже
optionsCommand = "skeletal" -- Моды ВХ: bones - только кости / names - только ники, all - всё сразу
KEY = VK_F5 -- Кнопка активации ВХ
defaultState = false -- Запуск ВХ при старте игры

local wm = require 'windows.message'
local encoding = require 'encoding' -- загружаем библиотеку
encoding.default = 'CP1251' -- указываем кодировку по умолчанию, она должна совпадать с кодировкой файла. CP1251 - это Windows-1251
u8 = encoding.UTF8 -- и создаём короткий псевдоним для кодировщика UTF-8
local renderWindow = new.bool()
local autoreport = new.bool()
local statswindow = new.bool()
local renderWindow5 = new.bool()
local renderWindow4 = new.bool()
local renderWindow3 = new.bool()
local renderWindow2 = new.bool()
local renderWindow7 = new.bool()
local checkbox1 = new.bool()
local autoform = new.bool()
local tracera = new.bool()
local sizeX, sizeY = getScreenResolution()
local navigation = {
    current = 1,
    list = { u8"Головна", u8"Налаштування", u8"Функції", u8"Довідка", u8"Оновлення" }
}



local pravila = 
[[
Розробка
]]
local pravilad = 
[[
Розробка
]]

local pravilag = 
[[
Розробка
]]

function main()
    while not isSampAvailable() do wait(200) end
    sampAddChatMessage('{FF5051}[PHOENIX TOOLS]{FFFFFF} успішно завантажений, відкриття меню - X',0xFFFFFF)
    local lastver = update():getLastVersion()
    sampAddChatMessage('Скрипт загружен, версия: '..lastver, -1)
    if thisScript().version ~= lastver then
        sampRegisterChatCommand('scriptupd', function()
            update():download()
        end)
        sampAddChatMessage('Вышло обновление скрипта ('..thisScript().version..' -> '..lastver..'), введите /scriptupd для обновления!', -1)
    end
    ffi.C.SetWindowTextA(ffi.C.GetActiveWindow(), 'PHOENIX ONLINE')
    addEventHandler('onWindowMessage', function(msg, wparam, lparam)
        if   msg == wm.WM_KEYDOWN or msg == wm.WM_SYSKEYDOWN  then
            if wparam == vkeys.VK_X then
                renderWindow2[0] = not renderWindow2[0]
            end
            if sampIsCursorActive() or sampIsChatInputActive() then
                renderWindow2[0] = false
            end
        end
    end)
    sampRegisterChatCommand(optionsCommand, function(param)
		if param == "bones" then whVisible = param; nameTagOff()
		elseif param == "names" or param == "all" then whVisible = param if not nameTag then nameTagOn() end
		else sampAddChatMessage("Введіть корректний режим: {CCCCFF}names{4444FF}/{CCCCFF}bones{4444FF}/{CCCCFF}all", 0xFF4444FF) end
	end)
    sampRegisterChatCommand("gplat", function()
        active = not active
        sampAddChatMessage(string.format("GPLATFORMS | {FFFFFF}Статус: %s", active and "{27AE60}Увімкнено" or "{FF0202}Вимкнено"), 0x40E988)
    end)
	while not sampIsLocalPlayerSpawned() do wait(100) end
	if defaultState and not nameTag then nameTagOn() end
	while true do
		wait(0)
        if isKeyDown(71) and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() and not isSampfuncsConsoleActive() then
            while isKeyDown(71) do wait(0) end	
    if(active_report == 2) then					
        sampSendChat("/"..cmd.." "..other.." || "..admin_nick)
                        status("true", 1)
                        wait(2000)
              sampSendChat("/a [Forma] +")			
                    active_report2 = 1
    end
        end	
        if AirBrake.active then
            if isCharInAnyCar(PLAYER_PED) then 
                setCarHeading(getCarCharIsUsing(PLAYER_PED), getHeadingFromVector2d(select(1, getActiveCameraPointAt()) - select(1, getActiveCameraCoordinates()), 
                select(2, getActiveCameraPointAt()) - select(2, getActiveCameraCoordinates()))) 
                if getDriverOfCar(getCarCharIsUsing(PLAYER_PED)) == -1 then 
                    speed = getFullSpeed(AirBrake.speed.passenger[0], 0, 0) 
                else 
                    speed = getFullSpeed(AirBrake.speed.incar[0], 0, 0) 
                end 
            else 
                speed = getFullSpeed(AirBrake.speed.onfoot[0], 0, 0) 
                setCharHeading(PLAYER_PED, getHeadingFromVector2d(select(1, getActiveCameraPointAt()) - select(1, getActiveCameraCoordinates()), 
                select(2, getActiveCameraPointAt()) - select(2, getActiveCameraCoordinates()))) 
            end
    
            if sampIsCursorActive() then goto mark end
    
            if isKeyDown(VK_SPACE) then 
                airBrkCoords[3] = airBrkCoords[3] + speed / 2 
            elseif isKeyDown(VK_LSHIFT) and airBrkCoords[3] > -95.0 then 
                airBrkCoords[3] = airBrkCoords[3] - speed / 2  
            end
    
            if isKeyDown(VK_S) then 
                airBrkCoords[1] = airBrkCoords[1] - speed * math.sin(-math.rad(getCharHeading(PLAYER_PED))) 
                airBrkCoords[2] = airBrkCoords[2] - speed * math.cos(-math.rad(getCharHeading(PLAYER_PED))) 
            elseif isKeyDown(VK_W) then 
                airBrkCoords[1] = airBrkCoords[1] + speed * math.sin(-math.rad(getCharHeading(PLAYER_PED))) 
                airBrkCoords[2] = airBrkCoords[2] + speed * math.cos(-math.rad(getCharHeading(PLAYER_PED))) 
            end
            if isKeyDown(VK_D) then 
                airBrkCoords[1] = airBrkCoords[1] + speed * math.sin(-math.rad(getCharHeading(PLAYER_PED) - 90)) 
                airBrkCoords[2] = airBrkCoords[2] + speed * math.cos(-math.rad(getCharHeading(PLAYER_PED) - 90)) 
            elseif isKeyDown(VK_A) then 
                airBrkCoords[1] = airBrkCoords[1] - speed * math.sin(-math.rad(getCharHeading(PLAYER_PED) - 90)) 
                airBrkCoords[2] = airBrkCoords[2] - speed * math.cos(-math.rad(getCharHeading(PLAYER_PED) - 90)) 
            end
    
            ::mark::
                
            if isCharInAnyCar(PLAYER_PED) then
                setCharCoordinates(PLAYER_PED, airBrkCoords[1], airBrkCoords[2], airBrkCoords[3])
                sendVehiclePassenger(airBrkCoords[1], airBrkCoords[2], airBrkCoords[3])
            else
                setCharCoordinatesDontResetAnim(PLAYER_PED, airBrkCoords[1], airBrkCoords[2], airBrkCoords[3] + 0.5)
                sendPlayer(airBrkCoords[1], airBrkCoords[2], airBrkCoords[3] + 0.5)
                local ped = getCharPointer(playerPed)
                memory.setuint8(ped + 0x46C, 3, true)
                setCharVelocity(PLAYER_PED, 0, 0, 0)
            end
        end
        local sec = lastActivity()
        if sampIsChatInputActive() then
            local text = getSelectedText()
            local strEl = getStructElement(sampGetInputInfoPtr(), 0x8, 4)
            local X, Y = getStructElement(strEl, 0x8, 4), getStructElement(strEl, 0xC, 4)
            renderFontDrawText(font, ('{00ff00}[PTOOLS] {FFFFFF}Вибраний текст: {FFFFFF}%s {FF9DFF}(%d символів)'):format(text, #text), X + 5, Y + 50, 0xFFFF9DFF)
        end
        local peds = getAllChars()
        for i=2, #peds do
            local _, id = sampGetPlayerIdByCharHandle(peds[i])
            if peds[i] ~= nil and isCharOnScreen(peds[i]) and not sampIsPlayerNpc(id) then
                local x, y, z = getCharCoordinates(peds[i])
                local xs, ys = convert3DCoordsToScreen(x, y, z)
                if players[id] ~= nil and active then
                    if players[id] ~= "PC" then
                        renderFontDrawText(font, "Mobile", xs - 23, ys, 0xFF00FFC9)
                    end
                    if players[id] ~= "Mobile" then
                        renderFontDrawText(font, "PC", xs - 23, ys, 0xFFFF0000)
                    end
                end
            end
        end 
		if wasKeyPressed(KEY) then; 
			if defaultState then
				defaultState = false; 
				nameTagOff(); 
				while isKeyDown(KEY) do wait(100) end 
			else
				defaultState = true;
				if whVisible ~= "bones" and not nameTag then nameTagOn() end
				while isKeyDown(KEY) do wait(100) end 
			end 
		end
		if defaultState and whVisible ~= "names" then
			if not isPauseMenuActive() and not isKeyDown(VK_F8) then
				for i = 0, sampGetMaxPlayerId() do
				if sampIsPlayerConnected(i) then
					local result, cped = sampGetCharHandleBySampPlayerId(i)
					local color = sampGetPlayerColor(i)
					local aa, rr, gg, bb = explode_argb(color)
					local color = join_argb(255, rr, gg, bb)
					if result then
						if doesCharExist(cped) and isCharOnScreen(cped) then
							local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
							for v = 1, #t do
								pos1X, pos1Y, pos1Z = getBodyPartCoordinates(t[v], cped)
								pos2X, pos2Y, pos2Z = getBodyPartCoordinates(t[v] + 1, cped)
								pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
								pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
								renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
							end
							for v = 4, 5 do
								pos2X, pos2Y, pos2Z = getBodyPartCoordinates(v * 10 + 1, cped)
								pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
								renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
							end
							local t = {53, 43, 24, 34, 6}
							for v = 1, #t do
								posX, posY, posZ = getBodyPartCoordinates(t[v], cped)
								pos1, pos2 = convert3DCoordsToScreen(posX, posY, posZ)
							end
						end
					end
				end
			end
			else
				nameTagOff()
				while isPauseMenuActive() or isKeyDown(VK_F8) do wait(0) end
				nameTagOn()
			end
		end
    end
    local font = renderCreateFont('Arial', 9, 5)

end
function samp.onUnoccupiedSync(id, data)
    players[id] = "PC"
end

function samp.onPlayerSync(id, data)
    if data.keysData == 160 then
        players[id] = "PC"
    end
    if data.specialAction ~= 0 and data.specialAction ~= 1 then
        players[id] = "PC"
    end
    if data.leftRightKeys ~= nil then
        if data.leftRightKeys ~= 128 and data.leftRightKeys ~= 65408 then
            players[id] = "Mobile"
        else
            if players[id] ~= "Mobile" then
                players[id] = "PC"
            end
        end
    end
    if data.upDownKeys ~= nil then
        if data.upDownKeys ~= 128 and data.upDownKeys ~= 65408 then
            players[id] = "Mobile"
        else
            if players[id] ~= "Mobile" then
                players[id] = "PC"
            end
        end
    end
end

function samp.onVehicleSync(id, vehid, data)
    if data.leftRightKeys ~= 128 and data.leftRightKeys ~= 65408 then
        players[id] = "Mobile"
    end
end

function samp.onPlayerQuit(id)
    players[id] = nil
end

function imgui.Hint(str_id, hint, delay)
    local hovered = imgui.IsItemHovered()
    local animTime = 0.2
    local delay = delay or 0.00
    local show = true

    if not allHints then allHints = {} end
    if not allHints[str_id] then
        allHints[str_id] = {
            status = false,
            timer = 0
        }
    end

    if hovered then
        for k, v in pairs(allHints) do
            if k ~= str_id and os.clock() - v.timer <= animTime  then
                show = false
            end
        end
    end

    if show and allHints[str_id].status ~= hovered then
        allHints[str_id].status = hovered
        allHints[str_id].timer = os.clock() + delay
    end

    if show then
        local between = os.clock() - allHints[str_id].timer
        if between <= animTime then
            local s = function(f)
                return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
            end
            local alpha = hovered and s(between / animTime) or s(1.00 - between / animTime)
            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)
            imgui.SetTooltip(hint)
            imgui.PopStyleVar()
        elseif hovered then
            imgui.SetTooltip(hint)
        end
    end
end
function getBodyPartCoordinates(id, handle)
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
  end
  
  function nameTagOn()
      local pStSet = sampGetServerSettingsPtr();
      NTdist = memory.getfloat(pStSet + 39)
      NTwalls = memory.getint8(pStSet + 47)
      NTshow = memory.getint8(pStSet + 56)
      memory.setfloat(pStSet + 39, 1488.0)
      memory.setint8(pStSet + 47, 0)
      memory.setint8(pStSet + 56, 1)
      nameTag = true
  end
  
  function nameTagOff()
      local pStSet = sampGetServerSettingsPtr();
      memory.setfloat(pStSet + 39, NTdist)
      memory.setint8(pStSet + 47, NTwalls)
      memory.setint8(pStSet + 56, NTshow)
      nameTag = false
  end
  
  function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
  end
  
  function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
  end

imgui.OnInitialize(function() 
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    example = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\impact.ttf', 58, _, glyph_ranges)
    imgui.GetIO().IniFilename = nil
 -- Paste this in "imgui.OnInitialize"
local style = imgui.GetStyle();
local colors = style.Colors;
style.Alpha = 1;
style.WindowPadding = imgui.ImVec2(5.00, 8.00);
style.WindowRounding = 12;
style.WindowBorderSize = 0;
style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
style.WindowTitleAlign = imgui.ImVec2(0.52, 0.47);
style.ChildRounding = 0;
style.ChildBorderSize = 0;
style.PopupRounding = 0;
style.PopupBorderSize = 0;
style.FramePadding = imgui.ImVec2(4.00, 4.00);
style.FrameRounding = 12;
style.FrameBorderSize = 0;
style.ItemSpacing = imgui.ImVec2(11.00, 8.00);
style.ItemInnerSpacing = imgui.ImVec2(4.00, 5.00);
style.IndentSpacing = 18;
style.ScrollbarSize = 8;
style.ScrollbarRounding = 7;
style.GrabMinSize = 8;
style.GrabRounding = 12;
style.TabRounding = 8;
style.ButtonTextAlign = imgui.ImVec2(0.49, 0.55);
style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
colors[imgui.Col.Text] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.50, 0.50, 0.50, 1.00);
colors[imgui.Col.WindowBg] = imgui.ImVec4(0.06, 0.06, 0.06, 0.94);
colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
colors[imgui.Col.PopupBg] = imgui.ImVec4(0.08, 0.08, 0.08, 0.94);
colors[imgui.Col.Border] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
colors[imgui.Col.FrameBg] = imgui.ImVec4(0.38, 0.39, 0.41, 0.54);
colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 0.40);
colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.00, 0.00, 0.00, 0.67);
colors[imgui.Col.TitleBg] = imgui.ImVec4(0.04, 0.04, 0.04, 1.00);
colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.00, 0.00, 0.00, 0.51);
colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.14, 0.14, 0.14, 1.00);
colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.02, 0.02, 0.02, 0.53);
colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.31, 0.31, 0.31, 1.00);
colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
colors[imgui.Col.CheckMark] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
colors[imgui.Col.Button] = imgui.ImVec4(0.02, 0.02, 0.02, 0.40);
colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.02, 0.02, 0.02, 0.40);
colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.02, 0.02, 0.02, 0.40);
colors[imgui.Col.Header] = imgui.ImVec4(0.02, 0.02, 0.02, 0.40);
colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.02, 0.02, 0.02, 0.40);
colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.02, 0.02, 0.02, 0.40);
colors[imgui.Col.Separator] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.02, 0.02, 0.02, 0.40);
colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.47, 0.47, 0.47, 1.00);
colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.02, 0.02, 0.02, 0.40);
colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.37, 0.37, 0.37, 0.67);
colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.74, 0.74, 0.74, 0.40);
colors[imgui.Col.Tab] = imgui.ImVec4(0.02, 0.02, 0.02, 0.40);
colors[imgui.Col.TabHovered] = imgui.ImVec4(0.02, 0.02, 0.02, 0.40);
colors[imgui.Col.TabActive] = imgui.ImVec4(0.55, 0.55, 0.55, 1.00);
colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.07, 0.10, 0.15, 0.97);
colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.14, 0.26, 0.42, 1.00);
colors[imgui.Col.PlotLines] = imgui.ImVec4(0.61, 0.61, 0.61, 1.00);
colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.43, 0.35, 1.00);
colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00);
colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.26, 0.59, 0.98, 0.35);
colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90);
colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70);
colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20);
colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.35);
end)
local function upper_count(s)
    local count = 0
    for c in string.gmatch(s, '[A-ZА-Я]') do
        count = count + 1
    end
    return count
  end
  
  local function caps_coefficient(s, length)
      return upper_count(s) / length
  end
  
  function samp.onSendChat(text)
      local length = string.len(text)
      if caps_coefficient(text, length) > 0.5 and length > 1 then
          sampAddChatMessage('{FF6666}[PTOOLS]{FFFFFF} Повідомлення - ' .. text .. ' схоже на {FF0000}КАПС!!!', -1)
      end
  end
HeaderButton = function(bool, str_id)
    local DL = imgui.GetWindowDrawList()
    local ToU32 = imgui.ColorConvertFloat4ToU32
    local result = false
    local label = string.gsub(str_id, "##.*$", "")
    local duration = { 0.5, 0.3 }
    local cols = {
        idle = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        hovr = imgui.GetStyle().Colors[imgui.Col.Text],
        slct = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    }

    if not AI_HEADERBUT then AI_HEADERBUT = {} end
     if not AI_HEADERBUT[str_id] then
        AI_HEADERBUT[str_id] = {
            color = bool and cols.slct or cols.idle,
            clock = os.clock() + duration[1],
            h = {
                state = bool,
                alpha = bool and 1.00 or 0.00,
                clock = os.clock() + duration[2],
            }
        }
    end
    local pool = AI_HEADERBUT[str_id]

    local degrade = function(before, after, start_time, duration)
        local result = before
        local timer = os.clock() - start_time
        if timer >= 0.00 then
            local offs = {
                x = after.x - before.x,
                y = after.y - before.y,
                z = after.z - before.z,
                w = after.w - before.w
            }

            result.x = result.x + ( (offs.x / duration) * timer )
            result.y = result.y + ( (offs.y / duration) * timer )
            result.z = result.z + ( (offs.z / duration) * timer )
            result.w = result.w + ( (offs.w / duration) * timer )
        end
        return result
    end

    local pushFloatTo = function(p1, p2, clock, duration)
        local result = p1
        local timer = os.clock() - clock
        if timer >= 0.00 then
            local offs = p2 - p1
            result = result + ((offs / duration) * timer)
        end
        return result
    end

    local set_alpha = function(color, alpha)
        return imgui.ImVec4(color.x, color.y, color.z, alpha or 1.00)
    end

    imgui.BeginGroup()
        local pos = imgui.GetCursorPos()
        local p = imgui.GetCursorScreenPos()
      
        imgui.TextColored(pool.color, label)
        local s = imgui.GetItemRectSize()
        local hovered = imgui.IsItemHovered()
        local clicked = imgui.IsItemClicked()
      
        if pool.h.state ~= hovered and not bool then
            pool.h.state = hovered
            pool.h.clock = os.clock()
        end
      
        if clicked then
            pool.clock = os.clock()
            result = true
        end

        if os.clock() - pool.clock <= duration[1] then
            pool.color = degrade(
                imgui.ImVec4(pool.color),
                bool and cols.slct or (hovered and cols.hovr or cols.idle),
                pool.clock,
                duration[1]
            )
        else
            pool.color = bool and cols.slct or (hovered and cols.hovr or cols.idle)
        end

        if pool.h.clock ~= nil then
            if os.clock() - pool.h.clock <= duration[2] then
                pool.h.alpha = pushFloatTo(
                    pool.h.alpha,
                    pool.h.state and 1.00 or 0.00,
                    pool.h.clock,
                    duration[2]
                )
            else
                pool.h.alpha = pool.h.state and 1.00 or 0.00
                if not pool.h.state then
                    pool.h.clock = nil
                end
            end

            local max = s.x / 2
            local Y = p.y + s.y + 3
            local mid = p.x + max

            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid + (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid - (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
        end

    imgui.EndGroup()
    return result
end
local mimgui_loader_circle, mimgui_loader_time, mimgui_loader_finish = 1, os.clock(), 0
local function mimgui_loader(speed, color)
    if not color then color = 0xFFFFFFFF end
    local draw_list = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    if mimgui_loader_finish < 1 then
        draw_list:AddCircleFilled(imgui.ImVec2(p.x, p.y), 14.0, (mimgui_loader_circle == 1 and 0x25FFFFFF or color), 30)
        draw_list:AddCircleFilled(imgui.ImVec2(p.x + 64, p.y), 14.0, (mimgui_loader_circle == 2 and 0x25FFFFFF or color), 30)
        draw_list:AddCircleFilled(imgui.ImVec2(p.x + 128, p.y), 14.0, (mimgui_loader_circle == 3 and 0x25FFFFFF or color), 30)
        draw_list:AddCircleFilled(imgui.ImVec2(p.x + 192, p.y), 14.0, (mimgui_loader_circle == 4 and 0x25FFFFFF or color), 30)
        if mimgui_loader_time + speed < os.clock() then  mimgui_loader_time = os.clock()
            if mimgui_loader_circle == 4 then mimgui_loader_circle = 1
            else mimgui_loader_circle = mimgui_loader_circle + 1 end
        end
    elseif mimgui_loader_finish >= 1 then
        draw_list:AddCircleFilled(imgui.ImVec2(p.x + mimgui_loader_finish / 2, p.y), 14.0, color, 30)
        draw_list:AddCircleFilled(imgui.ImVec2(p.x + 64 + mimgui_loader_finish, p.y), 14.0, color, 30)
        draw_list:AddCircleFilled(imgui.ImVec2(p.x + 128 - mimgui_loader_finish, p.y), 14.0, color, 30)
        draw_list:AddCircleFilled(imgui.ImVec2(p.x + 192 - mimgui_loader_finish / 2, p.y), 14.0, color, 30)
        if mimgui_loader_time + speed < os.clock() then mimgui_loader_time = os.clock()
            if mimgui_loader_finish < 88 then mimgui_loader_finish = mimgui_loader_finish + 1 end
        end
    end
end
function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(u8(text)).x/2)
    imgui.Text(u8(text))
end
function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4
    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end
    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end
    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function getMyNick()
    return sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(1)))
end
function ShowMessage(text, title, style)
    ffi.cdef [[
        int MessageBoxA(
            void* hWnd,
            const char* lpText,
            const char* lpCaption,
            unsigned int uType
        );
    ]]
    local hwnd = ffi.cast('void*', readMemory(0x00C8CF88, 4, false))
    ffi.C.MessageBoxA(hwnd, text,  title, style and (style + 0x50000) or 0x50000)
end
function getMyId()
    return select(2, sampGetPlayerIdByCharHandle(1))
end
function imgui.Hint(str_id, hint, delay)
    local hovered = imgui.IsItemHovered()
    local animTime = 0.2
    local delay = delay or 0.00
    local show = true

    if not allHints then allHints = {} end
    if not allHints[str_id] then
        allHints[str_id] = {
            status = false,
            timer = 0
        }
    end

    if hovered then
        for k, v in pairs(allHints) do
            if k ~= str_id and os.clock() - v.timer <= animTime  then
                show = false
            end
        end
    end

    if show and allHints[str_id].status ~= hovered then
        allHints[str_id].status = hovered
        allHints[str_id].timer = os.clock() + delay
    end

    if show then
        local between = os.clock() - allHints[str_id].timer
        if between <= animTime then
            local s = function(f)
                return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
            end
            local alpha = hovered and s(between / animTime) or s(1.00 - between / animTime)
            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)
            imgui.SetTooltip(hint)
            imgui.PopStyleVar()
        elseif hovered then
            imgui.SetTooltip(hint)
        end
    end
end
local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver,  imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(780, 450), imgui.Cond.FirstUseEver)
        imgui.Begin("LOADING SCREEN", renderWindow,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize +  imgui.WindowFlags.NoMove)
        lua_thread.create(function()
            wait(5000) 
            mimgui_loader_finish = 1 
        end)
        imgui.SetCursorPos(imgui.ImVec2(780 / 2 - 110, 300))
        local lspeed = 0.3 
        if mimgui_loader_finish >= 1 then lspeed = 0.005 end 
        mimgui_loader(lspeed, 0xFFFFFFFF) 
        if  mimgui_loader_finish == 1 then
            renderWindow[0] = false
            renderWindow2[0] = true
        end 
        imgui.SetCursorPos(imgui.ImVec2(780 / 2 - 110, 150))
        imgui.PushFont(example)
        imgui.CenterText('ATOOLS GHOST LOADING...')
        imgui.PopFont() 
        imgui.End()
    end
)
imgui.OnFrame(
    function() return renderWindow2[0] end,
    function(player)
        
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver,  imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(780, 450), imgui.Cond.FirstUseEver)
        imgui.Begin("ATOOLS MAIN", renderWindow2,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize +  imgui.WindowFlags.NoMove)
        for i, title in ipairs(navigation.list) do
            if HeaderButton(navigation.current == i, title) then
                navigation.current = i
            end
            if i ~= #navigation.list then
                imgui.SameLine(nil, 110)
            end
        end 
        if navigation.current == 5 then
            renderWindow7[0] = true
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = false
        end
        if navigation.current == 3 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = true
            renderWindow5[0] = false
            renderWindow4[0] = false
        end
        if navigation.current == 4 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = true
            renderWindow5[0] = false
        end
        if navigation.current == 2 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = true
        end
        imgui.SetCursorPos(imgui.ImVec2(780 / 2 - 135, 110))
        imgui.PushFont(example)
        imgui.TextColoredRGB('{FF0000}PHOENIX TOOLS')
        imgui.PopFont() 
        imgui.CenterText('Скріпт створений тільки для адміністрації PHOENIX ONLINE')
        imgui.CenterText('/gplat - Детект платформи гравця')
        imgui.CenterText('F5 - Активація валлхаку')
        imgui.CenterText('F4 - Телепорт на найближчу дорогу')
        imgui.CenterText('Прийняття форми з чату на клавішу G')
        imgui.CenterText('Версія скріпту - 0.1')
        imgui.End()
    end
)
imgui.OnFrame(
    function() return renderWindow5[0] end,
    function(player)
        
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver,  imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(780, 450), imgui.Cond.FirstUseEver)
        imgui.Begin("PTOOLS MISC", renderWindow5,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize +  imgui.WindowFlags.NoMove)
        for i, title in ipairs(navigation.list) do
            if HeaderButton(navigation.current == i, title) then
                navigation.current = i
            end
            if i ~= #navigation.list then
                imgui.SameLine(nil, 110)
            end
        end 
        if navigation.current == 5 then
            renderWindow7[0] = true
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = false
        end
        if navigation.current == 1 then
            renderWindow2[0] = true
            renderWindow3[0] = false
            renderWindow7[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = false
        end
        if navigation.current == 3 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = true
            renderWindow5[0] = false
            renderWindow4[0] = false
        end
        if navigation.current == 4 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = true
            renderWindow5[0] = false
        end
        imgui.SetCursorPos(imgui.ImVec2(780 / 2 - 110, 110))
        imgui.PushFont(example)
        imgui.TextColoredRGB('{FFFFFF}В розробці')
        imgui.PopFont() 
        imgui.End()
    end
)
imgui.OnFrame(
    function() return renderWindow7[0] end,
    function(player)
       
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver,  imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(780, 450), imgui.Cond.FirstUseEver)
        imgui.Begin("PTOOLS INFO", renderWindow7,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize +  imgui.WindowFlags.NoMove)
        for i, title in ipairs(navigation.list) do
            if HeaderButton(navigation.current == i, title) then
                navigation.current = i
            end
            if i ~= #navigation.list then
                imgui.SameLine(nil, 110)
            end
        end
        if navigation.current == 1 then
            renderWindow2[0] = true
            renderWindow3[0] = false
            renderWindow7[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = false
        end
        if navigation.current == 3 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = true
            renderWindow5[0] = false
            renderWindow4[0] = false
        end
        if navigation.current == 4 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = true
            renderWindow5[0] = false
        end
        if navigation.current == 2 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = true
        end
        imgui.SetCursorPos(imgui.ImVec2(550, 420))
        imgui.TextColoredRGB('{FFFFFF}Власник скріпту - {FF0000}Artemich_Calculator')
        imgui.SetCursorPos(imgui.ImVec2(550, 430))
        imgui.TextColoredRGB('{FFFFFF}Всі права {00ff00}захищені.')
        imgui.End()
    end
)
imgui.OnFrame(
    function() return statswindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(1800,500), imgui.Cond.FirstUseEver,  imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(200, 250), imgui.Cond.FirstUseEver)
        imgui.Begin("PTOOLS STATS", nil,  imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)
    
        imgui.CenterText('Нік: '..getMyNick())
        imgui.CenterText('ІД: '..getMyId())
        imgui.CenterText((string.format(os.date("Час: %H:%M:%S", os.time()))))
        imgui.CenterText((string.format(os.date("Дата: %d.%m.%y"))))
        imgui.End()
    end
)
imgui.OnFrame(
    function() return renderWindow3[0] end,
    function(player)
        
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver,  imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(780, 450), imgui.Cond.FirstUseEver)
        imgui.Begin("PTOOLS FUNC", renderWindow3,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize +  imgui.WindowFlags.NoMove)
        for i, title in ipairs(navigation.list) do
            if HeaderButton(navigation.current == i, title) then
                navigation.current = i
            end
            if i ~= #navigation.list then
                imgui.SameLine(nil, 110)
            end
        end
        if navigation.current == 5 then
            renderWindow7[0] = true
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = false
        end
        if navigation.current == 1 then
            renderWindow2[0] = true
            renderWindow3[0] = false
            renderWindow7[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = false
        end
        if navigation.current == 4 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = true
            renderWindow5[0] = false
        end
        if navigation.current == 2 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = true
        end
        if imgui.CollapsingHeader('AIRBRAKE') then
        imgui.CustomCheckbox('Enable', AirBrake.state, 0.1)
        imgui.Separator()
        imgui.Text('Local speed')
        imgui.CustomSlider('Onfoot##LOCAL', AirBrake.speed.onfoot, false, 0.1, 5, '%0.1f')
        imgui.CustomSlider('Incar##LOCAL', AirBrake.speed.incar, false, 0.1, 5, '%0.1f')
        imgui.CustomSlider('Passenger##LOCAL', AirBrake.speed.passenger, false, 0.1, 5, '%0.1f')
        imgui.Separator()
        imgui.Text('Synchronization speed')
        imgui.CustomSlider('Onfoot##SYNC', AirBrake.sync.onfoot, false, 0.1, 2, '%0.2f')
        imgui.CustomSlider('Incar##SYNC', AirBrake.sync.incar, false, 0.1, 2, '%0.2f')
        imgui.CustomSlider('Passenger##SYNC', AirBrake.sync.passenger, false, 0.1, 2, '%0.2f')
        end
        if imgui.Checkbox(u8'Трейсера', tracera) then
            ShowMessage('Тимчасово знаходиться в розробці.', 'PTOOLS', 0x10)
        end
        imgui.SameLine()
        if imgui.Checkbox(u8'Увімкнути статистику', checkbox1) then
            sampAddChatMessage('Не працює', -1)
        end
        imgui.End()
    end
)
imgui.OnFrame(
    function() return renderWindow4[0] end,
    function(player)
        
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver,  imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(780, 450), imgui.Cond.FirstUseEver)
        imgui.Begin("PTOOLS RULES", renderWindow4,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize +  imgui.WindowFlags.NoMove)
        for i, title in ipairs(navigation.list) do
            if HeaderButton(navigation.current == i, title) then
                navigation.current = i
            end
            if i ~= #navigation.list then
                imgui.SameLine(nil, 110)
            end
        end
        if navigation.current == 5 then
            renderWindow7[0] = true
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = false
        end
        if navigation.current == 1 then
            renderWindow2[0] = true
            renderWindow3[0] = false
            renderWindow7[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = false
        end
        if navigation.current == 3 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = true
            renderWindow5[0] = false
            renderWindow4[0] = false
        end
        if navigation.current == 2 then
            renderWindow7[0] = false
            renderWindow2[0] = false
            renderWindow3[0] = false
            renderWindow4[0] = false
            renderWindow5[0] = true
        end
        if imgui.CollapsingHeader(u8'Основні правила') then
            imgui.Text(u8(pravila))
        end
        if imgui.CollapsingHeader(u8'Правила Держ.Структур') then
            imgui.Text(u8(pravilad))
        end
        if imgui.CollapsingHeader(u8'Правила Нелегал.Структур') then
            imgui.Text(u8(pravilag))
        end
        imgui.End()
    end
)
imgui.OnFrame(
    function() return autoreport[0] end,
    function(player)
        imgui.SetNextWindowSize(imgui.ImVec2(550, 250), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(700,830), imgui.Cond.FirstUseEver)
        imgui.Begin("PTOOLS REPORT", autoreport,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
        if imgui.Button(u8'Скаргу на форум') then
            local text = ("Вітаю, оскаржити своє покарання можна на форумі.")
            sampSendDialogResponse(sampGetCurrentDialogId(), 1, 0, text)
            sampCloseCurrentDialogWithButton(0)
            autoreport[0] = false
        end
        imgui.SameLine()
        if imgui.Button(u8'Зверніться в Технічний розділ на форумі') then 
            local text = ("Вітаю, зверніться в Технічний розділ на форумі. Гарної гри!")
            sampSendDialogResponse(sampGetCurrentDialogId(), 1, 0, text)
            sampCloseCurrentDialogWithButton(0)
            autoreport[0] = false
        end
        imgui.SameLine()
        if imgui.Button(u8'Слідкую') then 
            local text = ("Вітаю, слідкую.")
            sampSendDialogResponse(sampGetCurrentDialogId(), 1, 0, text)
            sampCloseCurrentDialogWithButton(0)
            autoreport[0] = false
        end

        imgui.End()
    end)
function getNearestRoadCoordinates(radius)
    local A = { getCharCoordinates(PLAYER_PED) }
    local B = { getClosestStraightRoad(A[1], A[2], A[3], 0, radius or 600) }
    if B[1] ~= 0 and B[2] ~= 0 and B[3] ~= 0 then
        return true, B[1], B[2], B[3]
    end
    return false
end
function onExitScript()
    config.state            = AirBrake.state[0]
    config.speed_onfoot     = AirBrake.speed.onfoot[0]
    config.speed_incar      = AirBrake.speed.incar[0]
    config.speed_passenger  = AirBrake.speed.passenger[0]
    config.sync_onfoot      = AirBrake.sync.onfoot[0]
    config.sync_incar       = AirBrake.sync.incar[0]
    config.sync_passenger   = AirBrake.sync.passenger[0]
    inicfg.save(ini, directIni)
end

function isAirBrakeKeyDown()
    return (isKeyDown(87) or isKeyDown(65) or isKeyDown(83) or isKeyDown(68) or isKeyDown(32) or isKeyDown(16))
end

function samp.onPlayerJoin(id, color, npc, nick)
    if npc == false then
        sampAddChatMessage( '{FFFFFF}'..nick..' ({008000}підключився{FFFFFF})', -1)
    end
end
function setEntityCoordinates(entityPtr, x, y, z)
    if entityPtr ~= 0 then
        local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
        if matrixPtr ~= 0 then
            local posPtr = matrixPtr + 0x30
            writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
            writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
            writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
        end
    end
end
function getFullSpeed(speed, ping, min_ping) 
    local fps = memory.getfloat(0xB7CB50, true) 
    local result = (speed / (fps / 60)) 
    if ping == 1 then 
        local ping = sampGetPlayerPing(getMyId()) 
        if min_ping < ping then 
            result = (result / (min_ping / ping)) 
        end 
    end 
    return result 
end 

function onSendPacket(id) 
    if AirBrake.active and (id == 200 or id == 207 or id == 211) then
        sync = id
        return false
    end
end
function samp.onShowDialog(did, style, text)
    if did == 4547 then
        autoreport[0] = true
    end
end
function sendPlayer(x, y, z)
    local player = CreateSync('player')
    -- player.quaternion = {0, 0, math.random(-1, 1), 0}
    player.health = 0
    player.armor = getCharArmour(PLAYER_PED)
    player.weapon = getCurrentCharWeapon(PLAYER_PED)
    player.specialAction = 3
    player.keysData = 0
    if isAirBrakeKeyDown() then
        player.leftRightKeys = isKeyDown(68) and 128 or (isKeyDown(65) and 65408 or 0)
        player.upDownKeys = isKeyDown(83) and 128 or (isKeyDown(87) and 65408 or 0)
        player.animationId = 1231
        player.animationFlags = 32770
        local speed = getMoveSpeed(getCharHeading(PLAYER_PED), AirBrake.sync.onfoot[0])
        player.moveSpeed = {speed.x, speed.y, speed.z}
    else
        player.animationId = 1189
        player.animationFlags = 32772
        player.moveSpeed = {0, 0, 0}
    end
    player.position = {x, y, z}
    player.send()
end

function sendVehiclePassenger(x, y, z)
    if sync == 200 then
        local vehicle = CreateSync('vehicle')
        -- vehicle.quaternion = {0, 0, math.random(-1, 1), 0}
        local speed = getMoveSpeed(getCharHeading(PLAYER_PED), AirBrake.sync.incar[0])
        vehicle.moveSpeed = {speed.x, speed.y, speed.z}
        vehicle.playerHealth = 0
        vehicle.armor = getCharArmour(PLAYER_PED)
        vehicle.currentWeapon = getCurrentCharWeapon(PLAYER_PED)
        vehicle.keysData = 0
        vehicle.position = {x, y, z}
        vehicle.send()
    elseif sync == 211 then
        local passenger = CreateSync('passenger')
        passenger.health = 0
        passenger.armor = getCharArmour(PLAYER_PED)
        passenger.currentWeapon = getCurrentCharWeapon(PLAYER_PED)
        passenger.keysData = 0
        passenger.position = {x, y, z}
        passenger.driveBy = false
        passenger.send()
    end
end

function CreateSync(sync_type, copy_from_player)
    local ffi = require('ffi')
    local sampfuncs = require('sampfuncs')
    -- from SAMP.Lua
    local raknet = require ('samp.raknet')
    require('samp.synchronization')
    copy_from_player = copy_from_player or true
    local sync_traits = { 
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData}, 
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData}, 
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData}, 
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData}, 
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData}, 
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil}, 
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil}, 
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local function func_send()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function getMoveSpeed(heading, speed)
    moveSpeed = {x = math.sin(-math.rad(heading)) * (speed), y = math.cos(-math.rad(heading)) * (speed), z = 0} 
    return moveSpeed
end
function samp.onServerMessage(color, text)

    local reasons = {"kick", "mute", "jail", "jailoff", "sethp", "sban", "banoff", "muteoff", "sbanoff", "spplayer", "slap", "unmute", "unjail", "sban", "spcar", "ban", "sban", "warn", "skick", "setskin", "ao", "unban", "unwarn", "setskin", "skick", "banip", "offban", "offwarn", "plveh", "sban", "ptp", "o", "aad", "givegun", "avig", "aunvig", "setadmin", "givedonate", "spawncars",
    "mpwin", "prefix", "asellhouse", "delacc", "asellbiz", "money", "test", 'iban'}	
    
    for k,v in ipairs(reasons) do
        if text:match("%[.*%] (%w+_?%w+) %[(%d+)%]: /"..v.."%s") then
            started = started + 1 
                if started < 2 then
            prikoll = "true"
            admin_nick, admin_id, other = text:match("%[.+%] (%w+_?%w+) %[(%d+)%]: /"..v.."%s(.*)")
            sampAddChatMessage('{FF5051}[PHOENIX]{FFFFFF} Прийшла нова форма, клавіша прийняття - G', -1)
                cmd = v
                paramssss = other
                if stop == 0 then
                lua_thread.create(function()
                for i = 1, 10 do
                    if active_report2 == 0 then
                    status("false", i)
                    else
                    status("true", i)
                    end
                    end
                    if prikoll == "true" then
                    wait(0)
                    printStyledString("You missed form", 1000, 5)
                active_report = 1
                active_report2 = 0
                started = 0
                bbstart = -1
                end
                end)
                end
                end
                end
    end
    end
    
    function status(parsasm, ggbc)
        if parsasm == "true" then
        active_report2 = 1
        prikoll = "false"
            if ggbc == 10 then
            active_report2 = 0
            started = 0
            end
            active_report = 1
            printStyledString("Admin form accepted", 5000, 5)
            bbstart = -1
        else
        bbstart = -1
        bbstart = bbstart + ggbc
        if bbstart == 0 then
        active_report = 2
        end
            if active_report2 == 0 then
            wait(1000)
            printStyledString('Admin form '..ggbc.." wait", 1000, 5)
            end
        end
    end
function isKeyCheckAvailable()
	return not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() and not sampIsScoreboardOpen()
end

addEventHandler('onWindowMessage', function(msg, wparam, lparam)
    if AirBrake.state[0] and msg == 0x100 and lparam == 3538945 and isKeyCheckAvailable() then 
        airBrkCoords = {getCharCoordinates(PLAYER_PED)} 
        if not isCharInAnyCar(PLAYER_PED) then 
            airBrkCoords[3] = airBrkCoords[3] - 1 
        end
        AirBrake.active = not AirBrake.active
        printStringNow(AirBrake.active and '~S~Air~P~Brake ~B~Activated' or '~S~Air~P~Brake ~B~De-Activated', 2000)
    end
    if AirBrake.active and (wparam == 16 or wparam == 32) and isKeyCheckAvailable() then
        consumeWindowMessage(true, false)
    end
end)

function imgui.CustomCheckbox(str_id, bool, a_speed)
    local p         = imgui.GetCursorScreenPos()
    local DL        = imgui.GetWindowDrawList()

    local label     = str_id:gsub('##.+', '') or ""
    local h         = imgui.GetTextLineHeightWithSpacing() - 2
    local speed     = a_speed or 0.2

    local function bringVec2To(from, to, start_time, duration)
		local timer = os.clock() - start_time
		if timer >= 0.00 and timer <= duration then
			local count = timer / (duration / 100)
			return imgui.ImVec2(
				from.x + (count * (to.x - from.x) / 100),
				from.y + (count * (to.y - from.y) / 100)
			), true
		end
		return (timer > duration) and to or from, false
	end
    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end
    
    

    local c = {
        {0.18536826495, 0.42833250947},
        {0.44109925858, 0.70010380622},
        {0.38825341901, 0.70010380622},
        {0.81248970176, 0.28238693976},
    }

    if UI_CUSTOM_CHECKBOX == nil then UI_CUSTOM_CHECKBOX = {} end
    if UI_CUSTOM_CHECKBOX[str_id] == nil then
        UI_CUSTOM_CHECKBOX[str_id] = {
            lines = {
                {
                    from = imgui.ImVec2(0, 0), 
                    to = imgui.ImVec2(h*c[1][1], h*c[1][2]), 
                    start = 0,
                    anim = false,
                },
                {
                    from = imgui.ImVec2(0, 0), 
                    to = bool[0] and imgui.ImVec2(h*c[2][1], h*c[2][2]) or imgui.ImVec2(h*c[1][1], h*c[1][2]), 
                    start = 0,
                    anim = false,
                },
                {
                    from = imgui.ImVec2(0, 0), 
                    to = imgui.ImVec2(h*c[3][1], h*c[3][2]), 
                    start = 0,
                    anim = false,
                },
                {      
                    from = imgui.ImVec2(0, 0),    
                    to = bool[0] and imgui.ImVec2(h*c[4][1], h*c[4][2]) or imgui.ImVec2(h*c[3][1], h*c[3][2]), 
                    start = 0,
                    anim = false,
                },
            },
            hovered = false,
            h_start = 0,
        }
    end

    local pool = UI_CUSTOM_CHECKBOX[str_id]

    imgui.BeginGroup()
        imgui.InvisibleButton(str_id, imgui.ImVec2(h, h))
        imgui.SameLine()
        local pp = imgui.GetCursorPos()
        imgui.SetCursorPos(imgui.ImVec2(pp.x - 5, pp.y + h/2 - imgui.CalcTextSize(label).y/2))
        imgui.Text(label)
    imgui.EndGroup()

    local clicked = imgui.IsItemClicked()
    if pool.hovered ~= imgui.IsItemHovered() then
        pool.hovered = imgui.IsItemHovered()
        local timer = os.clock() - pool.h_start
        if timer <= speed and timer >= 0 then
            pool.h_start = os.clock() - (speed - timer)
        else
            pool.h_start = os.clock()
        end
    end

    if clicked then
        local isAnim = false

        for i = 1, 4 do
            if pool.lines[i].anim then
                isAnim = true
            end
        end

        if not isAnim then
            bool[0] = not bool[0]

            pool.lines[1].from = imgui.ImVec2(h*c[1][1], h*c[1][2])
            pool.lines[1].to = bool[0] and imgui.ImVec2(h*c[1][1], h*c[1][2]) or imgui.ImVec2(h*c[2][1], h*c[2][2])
            pool.lines[1].start = bool[0] and 0 or os.clock()

            pool.lines[2].from = bool[0] and imgui.ImVec2(h*c[1][1], h*c[1][2]) or imgui.ImVec2(h*c[2][1], h*c[2][2])
            pool.lines[2].to = bool[0] and imgui.ImVec2(h*c[2][1], h*c[2][2]) or imgui.ImVec2(h*c[2][1], h*c[2][2])
            pool.lines[2].start = bool[0] and os.clock() or 0

            pool.lines[3].from = imgui.ImVec2(h*c[3][1], h*c[3][2])
            pool.lines[3].to = bool[0] and imgui.ImVec2(h*c[3][1], h*c[3][2]) or imgui.ImVec2(h*c[4][1], h*c[4][2])
            pool.lines[3].start = bool[0] and 0 or os.clock() + speed

            pool.lines[4].from = bool[0] and imgui.ImVec2(h*c[3][1], h*c[3][2]) or imgui.ImVec2(h*c[4][1], h*c[4][2])
            pool.lines[4].to = imgui.ImVec2(h*c[4][1], h*c[4][2]) or imgui.ImVec2(h*c[4][1], h*c[4][2])
            pool.lines[4].start = bool[0] and os.clock() + speed or 0
        end
    end

    local pos = {}

    for i = 1, 4 do
        pos[i], pool.lines[i].anim = bringVec2To(
            p + pool.lines[i].from,
            p + pool.lines[i].to,
            pool.lines[i].start,
            speed
        )
    end

    local color = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    local c = imgui.GetStyle().Colors[imgui.Col.ButtonHovered]
    local colorHovered = bringVec4To(
        pool.hovered and imgui.ImVec4(c.x, c.y, c.z, 0) or imgui.ImVec4(c.x, c.y, c.z, 0.2),
        pool.hovered and imgui.ImVec4(c.x, c.y, c.z, 0.2) or imgui.ImVec4(c.x, c.y, c.z, 0),
        pool.h_start,
        speed
    )

    DL:AddRectFilled(p, imgui.ImVec2(p.x + h, p.y + h), imgui.GetColorU32Vec4(colorHovered), h/15, 15)
    DL:AddRect(p, imgui.ImVec2(p.x + h, p.y + h), imgui.GetColorU32Vec4(color), h/15, 15, 1.5)
    DL:AddLine(pos[1], pos[2], imgui.GetColorU32Vec4(color), h/10)
    DL:AddLine(pos[3], pos[4], imgui.GetColorU32Vec4(color), h/10)

    return clicked
end
function imgui.CustomSlider(str_id, value, type, min, max, sformat, width)
    local text      = str_id:gsub('##.+', '')
    local sformat   = sformat or (type and '%d' or '%0.3f')
    local width     = width or 200

    local DL        = imgui.GetWindowDrawList()
    local p         = imgui.GetCursorScreenPos()

    local function math_round(x)
        local a = tostring(x):gsub('%d+%.', '0.')
        if tonumber(a) > 0.5 then
            return math.ceil(x)
        else
            return math.floor(x)
        end
    end
    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end

    if UI_CUSTOM_SLIDER == nil then UI_CUSTOM_SLIDER = {} end
    if UI_CUSTOM_SLIDER[str_id] == nil then 
        UI_CUSTOM_SLIDER[str_id] = {
            active = false,
            hovered = false,
            start = 0
        } 
    end

    imgui.InvisibleButton(str_id, imgui.ImVec2(width, 20))

    UI_CUSTOM_SLIDER[str_id].active = imgui.IsItemActive()
    if UI_CUSTOM_SLIDER[str_id].hovered ~= imgui.IsItemHovered() then
        UI_CUSTOM_SLIDER[str_id].hovered = imgui.IsItemHovered()
        UI_CUSTOM_SLIDER[str_id].start = os.clock()
    end

    local colorPadding = bringVec4To(
        UI_CUSTOM_SLIDER[str_id].hovered and imgui.GetStyle().Colors[imgui.Col.Button] or imgui.GetStyle().Colors[imgui.Col.ButtonHovered], 
        UI_CUSTOM_SLIDER[str_id].hovered and imgui.GetStyle().Colors[imgui.Col.ButtonHovered] or imgui.GetStyle().Colors[imgui.Col.Button], 
        UI_CUSTOM_SLIDER[str_id].start, 0.2
    )
    
    local colorBackGroundBefore = imgui.GetStyle().Colors[imgui.Col.Button]
    local colorBackGroundAfter = imgui.ImVec4(0,0,0,0)
    local colorCircle = imgui.GetStyle().Colors[imgui.Col.ButtonActive]

    if UI_CUSTOM_SLIDER[str_id].active then
        local c = imgui.GetMousePos()
        if c.x - p.x >= 0 and c.x - p.x <= width then
            local s = c.x - p.x - 10
            local pr = s / (width - 20)
            local v = min + (max - min) * pr
            if v >= min and v <= max then
                value[0] = type and math_round(v) or v
            else
                value[0] = v < min and min or max
            end
        end
    end

    local posCircleX = p.x + 10 + (width - 20) / (max - min) * (value[0] - min)

    if posCircleX > p.x + 10 then DL:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(posCircleX, p.y + 20), imgui.GetColorU32Vec4(colorBackGroundBefore), 10, 15) end
    if posCircleX < p.x + width - 10 then DL:AddRectFilled(imgui.ImVec2(posCircleX, p.y), imgui.ImVec2(p.x + width, p.y + 20), imgui.GetColorU32Vec4(colorBackGroundAfter), 10, 15) end
    DL:AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + width, p.y + 20), imgui.GetColorU32Vec4(colorPadding), 10, 15)
    DL:AddCircleFilled(imgui.ImVec2(posCircleX, p.y + 10), 10, imgui.GetColorU32Vec4(colorCircle))

    local sf = imgui.CalcTextSize(string.format(sformat, value[0]))
    local st = imgui.CalcTextSize(text)
    DL:AddText(imgui.ImVec2(p.x + width / 2 - sf.x / 2, p.y + 10 - sf.y / 2), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.Text]), string.format(sformat, value[0]))
    imgui.SameLine()
    local p = imgui.GetCursorPos()
    imgui.SetCursorPos(imgui.ImVec2(p.x - 5, p.y + 10 - st.y / 2))
    imgui.Text(text)

    return UI_CUSTOM_SLIDER[str_id].active
end
function onWindowMessage(msg, wparam, lparam)
    if msg == 0x0100 and wparam == 0x73 then -- F4
        local result, x, y, z = getNearestRoadCoordinates()
        if result then
            local dist = getDistanceBetweenCoords3d(x, y, z, getCharCoordinates(PLAYER_PED))
            setCharCoordinates(PLAYER_PED, x, y, z + 1)
            sampAddChatMessage(("Ви телепортовані на найближчу до Вас дорогу (%dm.)"):format(dist), 0xAAFFAA)
        else
            sampAddChatMessage("Не знайшлось дороги поблизу", 0xFFAAAA)
        end
    end
end
local ffi = require 'ffi'
ffi.cdef[[
    typedef unsigned long DWORD;
    typedef unsigned int UINT;

    typedef struct tagLASTINPUTINFO {
        UINT  cbSize;
        DWORD dwTime;
    } LASTINPUTINFO, *PLASTINPUTINFO;

    bool GetLastInputInfo(
        PLASTINPUTINFO plii
    );

    DWORD GetTickCount();
]]

function lastActivity()
    local info = ffi.new("LASTINPUTINFO[1]")
    info[0].cbSize = 8
    ffi.C.GetLastInputInfo(info)
    return (ffi.C.GetTickCount() - info[0].dwTime) / 1000
end


function getSelectedText()
    local input = sampGetChatInputText()
    local ptr = sampGetInputInfoPtr()
    local chat = getStructElement(ptr, 0x8, 4)
    local pos1 = readMemory(chat + 0x11E, 4, false)
    local pos2 = readMemory(chat + 0x119, 4, false)
    local count = pos2 - pos1
    return string.sub(input, count < 0 and pos2 + 1 or pos1 + 1, count < 0 and pos2 - count or pos2)
end
    



