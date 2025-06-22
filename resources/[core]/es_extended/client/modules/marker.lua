local CIRCLE_INTERACT = {}

local function Create(label, pos, use)
    local self = {}

    self.pos = pos
    self.use = use
    self.label = label

    table.insert(CIRCLE_INTERACT, self)
    return self
end
exports("Create", Create)

local function RenderSprite(TextureDictionary, TextureName, X, Y, Width, Height, Heading, R, G, B, A)
    ---@type number
    local X, Y, Width, Height = (tonumber(X) or 0) / 1920, (tonumber(Y) or 0) / 1080, (tonumber(Width) or 0) / 1920, (tonumber(Height) or 0) / 1080

    if not HasStreamedTextureDictLoaded(TextureDictionary) then
        RequestStreamedTextureDict(TextureDictionary, true)
    end

    DrawSprite(TextureDictionary, TextureName, X + Width * 0.5, Y + Height * 0.5, Width, Height, Heading or 0, tonumber(R) or 255, tonumber(G) or 255, tonumber(B) or 255, tonumber(A) or 255)
end

local function DrawText2D(x, y, width, height, scale, text, r, g, b, a, outline)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x - width/2, y - height/2 + 0.005)
end

local function MeasureStringWidth(str, font, scale)
    local len
    local function Execute(str, font, scale)
        local x,y = GetActiveScreenResolution()
        BeginTextCommandGetWidth("CELL_EMAIL_BCON")
        AddTextComponentSubstringPlayerName(str)
        SetTextFont(font or 0)
        SetTextScale(scale, scale or 0)
        len = EndTextCommandGetWidth(true) * x
    end
    Execute(str, font, scale)
    return len
end

local currentSprite = ""
Citizen.CreateThread(function()
    local alpha = 0
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)

        for _, v in pairs(CIRCLE_INTERACT) do
            local dist = #(playerCoords - v.pos)

            if dist < 3.0 then
                sleep = 0 -- On continue à tourner vite si un point est proche

                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(v.pos.x, v.pos.y, v.pos.z)
                local coordsscreen = {
                    x = math.floor(screenX * 1920),
                    y = math.floor(screenY * 1080)
                }

                if dist > 1.0 then
                    if currentSprite ~= "control" then
                        currentSprite = "control"
                        alpha = 0
                    end
                    if alpha <= 253 then alpha = alpha + 2 end
                    RenderSprite("marker", currentSprite, coordsscreen.x, coordsscreen.y, 30, 30, 100, nil, nil, nil, alpha)

                else
                    if currentSprite ~= "key" then
                        currentSprite = "key"
                        alpha = 0
                    end
                    if alpha <= 253 then alpha = alpha + 2 end
                    RenderSprite("marker", currentSprite, coordsscreen.x, coordsscreen.y, 30, 30, 100, nil, nil, nil, alpha)
                    DrawText2D(screenX + (140 / 1920), screenY + 0.05, 0.1, 0.1, 0.2, v.label, 255, 255, 255, alpha, 0)
                    RenderSprite("marker", "label", coordsscreen.x + 40, coordsscreen.y, MeasureStringWidth(v.label, 0, 0.2) + 7, 30, 100, nil, nil, nil, alpha)

                    if IsControlJustPressed(0, 38) then
                        v.use()
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
