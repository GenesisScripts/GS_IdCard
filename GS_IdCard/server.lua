ESX = nil
local config = require('config')

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    if ESX == nil then
        print("Error: ESX is not initialized. Please check the resource order in your server.cfg.")
    else
        print("ESX successfully initialized.")
    end
end)

local genericAddresses = {
    "Strawberry, Los Santos", "Grapeseed, Blaine County", "Paleto Bay, Blaine County", "Sandy Shores, Blaine County",
    "Harmony, Blaine County", "Vinewood Hills, Los Santos", "Pillbox Hill, Los Santos", "Rockford Hills, Los Santos",
    "Vespucci Beach, Los Santos", "Little Seoul, Los Santos", "Rancho, Los Santos", "Davis, Los Santos",
    "South Los Santos", "Elysian Island, Los Santos", "El Burro Heights, Los Santos", "Cypress Flats, Los Santos",
    "Vinewood, Los Santos", "Little Seoul, Los Santos", "West Vinewood, Los Santos", "Morningwood, Los Santos",
    "Burton, Los Santos", "Hawick, Los Santos", "La Mesa, Los Santos", "Vespucci, Los Santos",
    "Downtown Vinewood, Los Santos", "Alta, Los Santos", "Del Perro Beach, Los Santos", "Vespucci Canals, Los Santos",
    "Textile City, Los Santos", "Grand Senora Desert, Blaine County", "Mount Chiliad, Blaine County",
    "Mount Chiliad Wilderness, Blaine County", "Banham Canyon, Blaine County"
}

lib.callback.register("GS_IdCard:retrieveInfo", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local badgeData = {}

    -- Fetch ID photo
    local result_photo = MySQL.Sync.fetchAll('SELECT `image` FROM `GS_IdCard` WHERE `identifier` = ? LIMIT 1', {identifier})
    badgeData.photo = result_photo[1] and result_photo[1].image or nil

    -- Fetch date of birth
    local result_dob = MySQL.Sync.fetchAll('SELECT `dateofbirth` FROM `users` WHERE `identifier` = ? LIMIT 1', {identifier})
    badgeData.dob = result_dob[1] and result_dob[1].dateofbirth or nil

    -- Fetch license types
    local result_lic = MySQL.Sync.fetchAll('SELECT `type` FROM `user_licenses` WHERE `owner` = ?', {identifier})
    local license_labels = {drive = config.car_lic, drive_bike = config.bike_lic, drive_truck = config.truck_lic}
    badgeData.license_types = {}
    for _, lic in ipairs(result_lic) do
        if license_labels[lic.type] then
            table.insert(badgeData.license_types, license_labels[lic.type])
        end
    end

    -- Fetch address and expiration date
    local result_id_info = MySQL.Sync.fetchAll('SELECT `address`, DATE_FORMAT(`expiry_date`, "%d-%m-%Y") as `expiry_date` FROM `GS_IdCard` WHERE `identifier` = ? LIMIT 1', {identifier})
    if result_id_info[1] then
        badgeData.address = result_id_info[1].address
        badgeData.license_expired = result_id_info[1].expiry_date
    else
        -- Assign a random address and current date as expiry date
        badgeData.address = genericAddresses[math.random(#genericAddresses)]
        badgeData.license_expired = os.date('%d-%m-%Y')

        -- Insert the new address and expiry date into the database
        MySQL.Sync.execute('INSERT INTO `GS_IdCard` (identifier, address, expiry_date) VALUES (?, ?, ?)', {identifier, badgeData.address, os.date('%Y-%m-%d')})
    end

    badgeData.name = xPlayer.getName()
    return badgeData
end)

RegisterNetEvent('GS_IdCard:showID')
AddEventHandler('GS_IdCard:showID', function(data, ply)
    TriggerClientEvent('GS_IdCard:displayID', ply, data)
end)

lib.callback.register("GS_IdCard:setIDphoto", function(source, photo)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    -- Fetch the existing record
    local result = MySQL.Sync.fetchAll('SELECT `image`, `expiry_date` FROM `GS_IdCard` WHERE `identifier` = ? LIMIT 1', {identifier})
    local currentDate = os.date('%Y-%m-%d')  -- Current date

    if not result[1] then
        -- Insert a new record if no existing record found
        MySQL.Sync.insert('INSERT INTO `GS_IdCard` (identifier, image, expiry_date) VALUES (?, ?, ?)', {identifier, photo, currentDate})
    else
        -- Update the photo but preserve the existing expiry date
        local existingExpiryDate = result[1].expiry_date
        MySQL.Sync.execute('UPDATE `GS_IdCard` SET image = ? WHERE identifier = ?',  {photo, identifier})
        
        -- If no expiry date was set (i.e., it was NULL), set it to the current date
        if not existingExpiryDate then
            existingExpiryDate = currentDate
        end
        
        -- Only update the expiry date if it was previously not set
        if not existingExpiryDate then
            MySQL.Sync.execute('UPDATE `GS_IdCard` SET expiry_date = ? WHERE identifier = ?',  {currentDate, identifier})
        end
    end
end)

lib.callback.register("GS_IdCard:setaddress", function(source, newAddress)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    local result = MySQL.Sync.fetchAll('SELECT `address` FROM `GS_IdCard` WHERE `identifier` = ? LIMIT 1', {identifier})

    if result[1] then
        MySQL.Sync.execute('UPDATE `GS_IdCard` SET address = ? WHERE identifier = ?',  {newAddress, identifier})
        return true
    else
        return false
    end
end)

lib.callback.register("GS_IdCard:renewLicense", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local new_expiry_date = os.date('%Y-%m-%d', os.time() + 30 * 24 * 60 * 60) -- 30 days from now

    MySQL.Sync.execute('UPDATE `GS_IdCard` SET expiry_date = ? WHERE identifier = ?', {new_expiry_date, identifier})

    return new_expiry_date
end)

RegisterServerEvent('GS_IdCard:getID')
AddEventHandler('GS_IdCard:getID', function()
    local src = source
    local itemName = config.ID_item
    local count = 1 

    local inventoryId = src

    if not exports.ox_inventory:CanCarryItem(src, itemName, count) then
        return
    end

    local success, response = exports.ox_inventory:AddItem(inventoryId, itemName, count)

    if success then
        TriggerClientEvent('esx:showNotification', src, 'You have been given an ID card.')
    end
end)

-------------------------------- Dont touch this -------------------------------------
                                                                                
CreateThread(function()
    local success, result = pcall(MySQL.Sync.scalar, 'SELECT 1 FROM GS_IdCard')
    
    if not success then
        MySQL.Sync.execute([[CREATE TABLE IF NOT EXISTS `GS_IdCard` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(50) NOT NULL,
            `image` LONGTEXT,
            `expiry_date` DATE,
            `address` VARCHAR(50),
            PRIMARY KEY (`id`)
        )]])
        print('The database for GS_IdCard has been deployed')
    end
end)

-------------------------------------------------------------------------------


