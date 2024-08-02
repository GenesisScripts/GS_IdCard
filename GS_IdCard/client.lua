ESX = nil

-- Retry mechanism to ensure ESX is loaded
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end
end)

-- Load the configuration
local Config = require('config')

-- Display the badge
RegisterNetEvent('GS_IdCard:displayID')
AddEventHandler('GS_IdCard:displayID', function(data)
    SendNUIMessage({
        type = "displayBadge",
        data = data
    })
    SetNuiFocus(true, true) -- Optionally set focus to the NUI
end)

local function showBadge()
    local badgeData = lib.callback.await("GS_IdCard:retrieveInfo", false)

    SendNUIMessage({ type = "displayBadge", data = badgeData })

    lib.progressBar({
        duration = Config.ID_show_time,
        label = Config.locales.progress_label,
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = "paper_1_rcm_alt1-8",
            clip = "player_one_dual-8"
        },
        prop = {
            bone = 28422,
            model = "p_ld_id_card_01",
            pos = vec3(0.0600, 0.0210, -0.0400),
            rot = vec3(-90.00, -180.00, -0.999)
        },
    })

    local players = lib.getNearbyPlayers(cache.coords, 3, false)
    if #players > 0 then
        local ply = {}
        for i = 1, #players do
            table.insert(ply, GetPlayerServerId(players[i].id))
        end
        TriggerServerEvent('GS_IdCard:showID', badgeData, ply)
    end
end

exports('use', function()
    showBadge()
end)

-- Set ID Photo
RegisterNetEvent('GS_IdCard:SetPhoto')
AddEventHandler('GS_IdCard:SetPhoto', function()
    local input = lib.inputDialog(Config.locales.input_title, {Config.locales.input_text})

    if not input then 
        ESX.ShowNotification(Config.locales.no_photo, 'error', 3000)
        return 
    end

    local success = lib.callback.await("GS_IdCard:setIDphoto", false, input[1])
    lib.alertDialog({
        header = Config.locales.department_name,
        content = Config.locales.update_badge_photo_success,
        centered = true,
        cancel = false
    })
end)

-- Set Address
RegisterNetEvent('GS_IdCard:SetAddress')
AddEventHandler('GS_IdCard:SetAddress', function()
    local input = lib.inputDialog(Config.locales.ad_input_title, {Config.locales.ad_input_text})

    if not input then
        ESX.ShowNotification(Config.locales.no_ad, 'error', 3000)
        return
    end

    local success = lib.callback.await("GS_IdCard:setaddress", false, input[1])
    lib.alertDialog({
        header = Config.locales.department_name,
        content = Config.locales.update_address_success,
        centered = true,
        cancel = false
    })
end)

function createMenus()
    local options = {}
    local hasID = #exports.ox_inventory:GetSlotsWithItem(Config.ID_item) > 0

    if hasID then
        table.insert(options, {
            title = 'Set ID Photo',
            description = 'Set your ID photo',
            icon = 'camera',
            onSelect = function()
                TriggerEvent('GS_IdCard:SetPhoto')
            end
        })
        table.insert(options, {
            title = 'Change Address',
            description = 'Change your address',
            icon = 'home',
            onSelect = function()
                TriggerEvent('GS_IdCard:SetAddress')
            end
        })
        table.insert(options, {
            title = 'Renew License',
            description = 'Renew your license for another 30 days',
            icon = 'calendar',
            onSelect = function()
                lib.callback.await('GS_IdCard:renewLicense')
            end
        })
    else
        table.insert(options, {
            title = 'Get ID',
            description = 'Get your ID card',
            icon = 'id-card',
            onSelect = function()
                TriggerServerEvent('GS_IdCard:getID')
            end
        })
    end

    lib.registerContext({
        id = 'license_menu',
        title = 'License Menu',
        options = options,
        onExit = function()
            inMenu = false
        end
    })

    lib.showContext('license_menu', true)
end

exports.ox_target:addBoxZone({
    coords = vec3(Config.target.ox_target_coords.x, Config.target.ox_target_coords.y, Config.target.ox_target_coords.z),
    rotation = Config.target.ox_target_rotation,
    debug = Config.target.ox_target_debug,
    options = {
        {
            onSelect = function()
                createMenus()
            end,
            icon = 'id-card',
            label = 'Licence Appointments'
        }
    }
})
