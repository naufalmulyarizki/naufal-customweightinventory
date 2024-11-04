-- Fungsi untuk mengirim notifikasi ke Discord
local function sendDiscordNotification(name, steamhex, berat)
    if Config.DiscordWebhook and Config.DiscordWebhook ~= "" then
        PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
            username = "Username Logs",
            embeds = {
                {
                    ["color"] = 16711680,  -- Warna merah untuk notifikasi
                    ["title"] = "Admin Mengatur Kapasitas Inventory Player", -- Judul Logs
                    ["description"] = '**Player: ' .. name .. ' dengan steamhex: [' .. steamhex .. '] Merubah berat inventory menjadi '..berat..'kg**', -- Deskripsi Logs
                    ["footer"] = {
                        ["text"] = "Nama Server Kamu!" -- Footer Logs
                    }
                }
            }
        }), { ['Content-Type'] = 'application/json' })
    end
end

-- Add Command
lib.addCommand('beratbadan', { -- Nama Command
    help = 'Atur Berat Badan', -- Help Chat
    restricted = 'group.admin', -- Permissionn Khusus untuk admin
    params = {
        {type = 'playerId', name = 'id'},
        {type = 'number', name = 'brp', help = 'Berapa kilo?'},
    }
}, function(source, args)
    if Config.Framework == 'esx' then -- Validasi Framework
        local player = ESX.GetPlayerFromId(source) 
        local name = GetPlayerName(source) -- Get Steam Name Player 
        local steamhex = GetPlayerIdentifier(source) -- Get Steamhex Player
        player.setMeta('beratbadan', args.brp * 1000) -- Save Metadata Player
        exports.ox_inventory:SetMaxWeight(source, args.brp * 1000) -- Mengatur berat inventory setelah di set
        sendDiscordNotification(name, steamhex, args.brp) -- Kirim Ke Discord
    elseif Config.Framework == 'qb' then -- Validasi Framework
        local player = QBCore.Functions.GetPlayer(source)
        local name = GetPlayerName(source) -- Get Steam Name Player 
        local steamhex = GetPlayerIdentifier(source) -- Get Steamhex Player
        player.Functions.SetMetaData('beratbadan', args.brp * 1000) -- Save Metadata Player
        player.Functions.Save() -- Save Player
        exports.ox_inventory:SetMaxWeight(source, args.brp * 1000)
        sendDiscordNotification(name, steamhex, args.brp) -- Kirim Ke Discord
    elseif Config.Framework == 'qbx' then -- Validasi Framework
        local player = exports.qbx_core:GetPlayer(source)
        local name = GetPlayerName(source) -- Get Steam Name Player 
        local steamhex = GetPlayerIdentifier(source) -- Get Steamhex Player
        player.Functions.SetMetaData('beratbadan', args.brp * 1000) -- Save Metadata Player
        player.Functions.Save() -- Save Player
        exports.ox_inventory:SetMaxWeight(source, args.brp * 1000) -- Mengatur berat inventory setelah di set
        sendDiscordNotification(name, steamhex, args.brp) -- Kirim Ke Discord
    else
        print('masukkan sesuai framework yang di sedikan, yaitu esx, qb, qbx')
    end
end)

if Config.Framework == 'esx' then -- Validasi Framework
    AddEventHandler('esx:playerLoaded', function(player) -- Event Loaded Player
        Wait(5000) -- Prevent Bug
        local Player = ESX.GetPlayerFromId(player)
        if Player.metadata.beratbadan then -- Validasi pernah di atur weightnya atau tidak
            exports.ox_inventory:SetMaxWeight(player, Player.metadata.beratbadan) -- Set Max Weight diambil dari metadata player
        end
    end)
elseif Config.Framework == 'qb' then
    RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
        local src = source
        local player = QBCore.Functions.GetPlayer(src)
        if player.Functions.GetMetaData('beratbadan') then -- Validasi pernah di atur weightnya atau tidak
            exports.ox_inventory:SetMaxWeight(src, player.Functions.GetMetaData('beratbadan')) -- Set Max Weight diambil dari metadata player
        end
    end)
elseif Config.Framework == 'qbx' then
    RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
        local src = source
        local player = exports.qbx_core:GetPlayer(src)
        if player.Functions.GetMetaData('beratbadan') then -- Validasi pernah di atur weightnya atau tidak
            exports.ox_inventory:SetMaxWeight(src, player.Functions.GetMetaData('beratbadan')) -- Set Max Weight diambil dari metadata player
        end
    end)
end