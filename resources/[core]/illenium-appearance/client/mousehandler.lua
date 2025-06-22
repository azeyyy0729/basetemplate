local menuType = "FE_MENU_VERSION_EMPTY_NO_BACKGROUND"
enableMenuLoop = false
local resourceName = GetCurrentResourceName()

local entityType = 0
local toIgnore = 0
local flags = 8
local raycastLength = 50.0
local abs = math.abs
local cos = math.cos
local sin = math.sin
local pi = math.pi

local mouseStartX = 0

--Lots of math stuff i have no idea how works but its awesome :)
local cameras = constants.CAMERAS
local offsets = constants.OFFSETS

function ScreenToWorld(flags, toIgnore)
    local activeCamera = currentCamera

    local currentcam = cameras[activeCamera]
    local currentoffset = offsets[activeCamera]
    if not currentcam then return false end
    local isReverse = reverseCamera and -1 or 1

    local posVector = GetCamCoord(cameraHandle)
    local rotVector = GetCamRot(cameraHandle, 2)
    
    local camRot = rotVector --GetGameplayCamRot(0)
    local camPos = posVector --GetGameplayCamCoord()
    local posX = GetControlNormal(0, 239)
    local posY = GetControlNormal(0, 240)
    local cursor = vector2(posX, posY)
    local cam3DPos, forwardDir = ScreenRelToWorld(camPos, camRot, cursor)
    local direction = camPos + forwardDir * raycastLength
    local rayHandle = StartShapeTestRay(cam3DPos, direction, flags, toIgnore, 0)
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    if entityHit >= 1 then
        entityType = GetEntityType(entityHit)
    end
    return hit, endCoords, surfaceNormal, entityHit, entityType, direction
end
 
function ScreenRelToWorld(camPos, camRot, cursor)
    local camForward = RotationToDirection(camRot)
    local rotUp = vector3(camRot.x + 1.0, camRot.y, camRot.z)
    local rotDown = vector3(camRot.x - 1.0, camRot.y, camRot.z)
    local rotLeft = vector3(camRot.x, camRot.y, camRot.z - 1.0)
    local rotRight = vector3(camRot.x, camRot.y, camRot.z + 1.0)
    local camRight = RotationToDirection(rotRight) - RotationToDirection(rotLeft)
    local camUp = RotationToDirection(rotUp) - RotationToDirection(rotDown)
    local rollRad = -(camRot.y * pi / 180.0)
    local camRightRoll = camRight * cos(rollRad) - camUp * sin(rollRad)
    local camUpRoll = camRight * sin(rollRad) + camUp * cos(rollRad)
    local point3DZero = camPos + camForward * 1.0
    local point3D = point3DZero + camRightRoll + camUpRoll
    local point2D = World3DToScreen2D(point3D)
    local point2DZero = World3DToScreen2D(point3DZero)
    local scaleX = (cursor.x - point2DZero.x) / (point2D.x - point2DZero.x)
    local scaleY = (cursor.y - point2DZero.y) / (point2D.y - point2DZero.y)
    local point3Dret = point3DZero + camRightRoll * scaleX + camUpRoll * scaleY
    local forwardDir = camForward + camRightRoll * scaleX + camUpRoll * scaleY
    return point3Dret, forwardDir
end
 
function RotationToDirection(rotation)
    local x = rotation.x * pi / 180.0
    --local y = rotation.y * pi / 180.0
    local z = rotation.z * pi / 180.0
    local num = abs(cos(x))
    return vector3((-sin(z) * num), (cos(z) * num), sin(x))
end
 
function World3DToScreen2D(pos)
    local _, sX, sY = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
    return vector2(sX, sY)
end

SetFrontendActive(false)
LeaveCursorMode()
RegisterNUICallback("on_menu_entered", function(data, cb)
    enableMenuLoop = false
    SetNuiFocusKeepInput(false, false)
    -- SetFrontendActive(false)
    -- SetMouseCursorVisibleInMenus(false)
    -- LeaveCursorMode()
end)

RegisterNUICallback("on_menu_left", function(data, cb)
    enableMenuLoop = true
    SetNuiFocusKeepInput(true, true)
    -- EnterCursorMode()
    -- SetFrontendActive(true)
    -- ActivateFrontendMenu(GetHashKey(menuType), true, -1)
    -- --100 works as well
    -- Citizen.Wait(100)
    -- --Hide frontend cursor
    -- SetMouseCursorVisibleInMenus(true)
end)

function GetCursorScreenPosition()
    if (not IsControlEnabled(0, 239)) then
        EnableControlAction(0, 239, true)
    end
    if (not IsControlEnabled(0, 240)) then
        EnableControlAction(0, 240, true)
    end

    return vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
end


local function GetPedBoneIndexByCoords(ped, coords)
    local closestBone = -1
    local minDistance = 1000.0
    for bone = 0, GetEntityBoneCount(ped) do
        local boneCoords = GetWorldPositionOfEntityBone(ped, bone)
        local distance = #(coords - boneCoords)
        if distance < minDistance then
            minDistance = distance
            closestBone = bone
        end
    end
    return closestBone
end

local function toFixed(num, digits)
    local mult = 10 ^ (digits or 0)
    return math.floor(num * mult + 0.5) / mult
end

Citizen.CreateThread(function()
    local pedHeading = 0.0
    local interpoling = false
    while true do
        if enableMenuLoop then
            DisableControlAction(0, 200)
            local hit, endCoords, surfaceNormal, entityHit, entityType, direction = ScreenToWorld(flags, toIgnore)
            local playerPed = PlayerPedId()
            if hit and entityHit == playerPed then
                DrawMarker(28, endCoords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.02, 0.02, 0.02, 0, 255, 0, 255, false, false, false, true, false, false, false)
                
                if IsControlJustPressed(0, 15) and not interpoling then
                    local camCoords = GetCamCoord(cameraHandle)
                    local bone = GetPedBoneIndexByCoords(playerPed, endCoords)
                    local boneCoords = GetWorldPositionOfEntityBone(playerPed, bone)
                    local pedCoords = GetEntityCoords(playerPed)
                    local fov = GetCamFov(cameraHandle)

                    local endFov = fov - 15
                    interpoling = true                    
                    local setCoords = false
                    while fov > endFov do
                        if fov - 0.5 < constants.minFov then
                            break
                        end
                        if not setCoords then
                            local newCoords = vector3(camCoords.x, camCoords.y, boneCoords.z)
                            SetCamCoord(cameraHandle, newCoords)
                            PointCamAtCoord(cameraHandle, newCoords)
                            setCoords = true
                        end
                        fov = fov - 0.5
                        SetCamFov(cameraHandle, fov)
                        Citizen.Wait(0)
                        -- PointCamAtCoord(cameraHandle, endCoords)
                    end

                    -- print(GetCamRot(cameraHandle, 2))

                    interpoling = false
                end
            end

            if IsControlJustPressed(0, 14) and not interpoling then
                local fov = GetCamFov(cameraHandle)
                local endFov = fov + 15
                interpoling = true

                while fov < endFov do
                    if fov + 0.5 > constants.maxFov then
                        local camCoords = GetCamCoord(cameraHandle)
                        local boneCoords = GetWorldPositionOfEntityBone(playerPed, 0)
                        local newCoords = vector3(camCoords.x, camCoords.y, boneCoords.z)
                        SetCamCoord(cameraHandle, newCoords)
                        PointCamAtCoord(cameraHandle, newCoords)
                        break
                    end
                    fov = fov + 0.5
                    SetCamFov(cameraHandle, fov)
                    Citizen.Wait(0)
                end
                interpoling = false
            end
            
            if IsControlJustPressed(0, 24) then
                mouseStartX = GetControlNormal(0, 239)
                pedHeading = GetEntityHeading(playerPed)
                SendNUIMessage({
                    type = "setCursor",
                    cursor = "grabbing"
                })
            end

            if IsControlJustReleased(0, 24) then
                SendNUIMessage({
                    type = "setCursor",
                    cursor = "default"
                })
            end

            if IsControlPressed(0, 24) then
                local mouseX = GetControlNormal(0, 239)
                local diff = mouseStartX - mouseX
                local newHeading = pedHeading - diff * 600.0
                SetEntityHeading(playerPed, newHeading)
            end
        end
        Wait(0)
    end
end)