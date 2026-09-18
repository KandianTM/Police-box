---@diagnostic disable: undefined-global
local ox_inventory = exports.ox_inventory

---Generate a realistic police weapon serial number
---@param prefix? string
---@return string
local function GenerateSerialNumber(prefix)
    prefix = prefix or 'LSPD'
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local serial = prefix .. '-'
    for _ = 1, 6 do
        local rand = math.random(1, #chars)
        serial = serial .. string.sub(chars, rand, rand)
    end
    return serial
end

---Send Discord Webhook Log
---@param src number
---@param itemsRewarded table
local function SendDiscordLog(src, itemsRewarded)
    if not Config.DiscordWebhook.Enabled or Config.DiscordWebhook.WebhookURL == '' or Config.DiscordWebhook.WebhookURL == 'PASTE_YOUR_DISCORD_WEBHOOK_URL_HERE' then
        return
    end

    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local name = GetPlayerName(src)
    local citizenid = player.PlayerData.citizenid or 'N/A'
    local license = player.PlayerData.license or 'N/A'

    local lootList = ''
    for _, item in ipairs(itemsRewarded) do
        local metaExtra = ''
        if item.metadata and item.metadata.serial then
            metaExtra = string.format(' `[Serial: %s]`', item.metadata.serial)
        end
        lootList = lootList .. string.format('• **%s** x%s%s\n', item.name, item.count, metaExtra)
    end

    if lootList == '' then
        lootList = 'None'
    end

    local embedData = {
        {
            ['title'] = '📦 Police Loot Box Opened',
            ['color'] = Config.DiscordWebhook.Color or 3447003,
            ['fields'] = {
                { ['name'] = 'Player', ['value'] = string.format('%s (ID: %s)', name, src), ['inline'] = true },
                { ['name'] = 'Citizen ID', ['value'] = citizenid, ['inline'] = true },
                { ['name'] = 'License', ['value'] = license, ['inline'] = false },
                { ['name'] = 'Armory Items Obtained', ['value'] = lootList, ['inline'] = false },
            },
            ['footer'] = {
                ['text'] = os.date('%Y-%m-%d %H:%M:%S') .. ' | ' .. (Config.DiscordWebhook.BotName or 'Nexora Police Loot Box')
            }
        }
    }

    PerformHttpRequest(Config.DiscordWebhook.WebhookURL, function() end, 'POST', json.encode({
        username = Config.DiscordWebhook.BotName or 'Nexora Loot Box',
        embeds = embedData
    }), { ['Content-Type'] = 'application/json' })
end

---Server Callback: Check if player has the box
lib.callback.register('police_lootbox:server:canOpenBox', function(src)
    local itemCount = ox_inventory:GetItemCount(src, Config.ItemName)
    if not itemCount or itemCount < 1 then
        return false, 'You do not have a police loot box in your inventory!'
    end

    return true
end)

---Reward player with police armory items
RegisterNetEvent('police_lootbox:server:claimRewards', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    -- Verify player still has the police loot box
    local boxCount = ox_inventory:GetItemCount(src, Config.ItemName)
    if not boxCount or boxCount < 1 then return end

    -- Remove 1x police loot box from inventory
    local removed = ox_inventory:RemoveItem(src, Config.ItemName, 1)
    if not removed then return end

    local rewardedItems = {}
    local rewardsConfig = Config.Rewards

    -- 1. Guaranteed Armory Items
    if rewardsConfig.Guaranteed and #rewardsConfig.Guaranteed > 0 then
        for _, item in ipairs(rewardsConfig.Guaranteed) do
            local roll = math.random(1, 100)
            if roll <= (item.chance or 100) then
                local amount = math.random(item.min, item.max)
                if amount > 0 then
                    local metadata = item.metadata or {}
                    if item.metadata and item.metadata.generateSerial then
                        metadata.serial = GenerateSerialNumber('LSPD')
                    end

                    local success = ox_inventory:AddItem(src, item.name, amount, metadata)
                    if success then
                        table.insert(rewardedItems, { name = item.name, count = amount, metadata = metadata })
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Armory Item Received',
                            description = string.format(Config.Locales['received_item'], amount, item.name),
                            type = 'success',
                            duration = 4000
                        })
                    else
                        local coords = GetEntityCoords(GetPlayerPed(src))
                        ox_inventory:CustomDrop('Police Armory Drop', {
                            { item.name, amount, metadata }
                        }, coords)
                        table.insert(rewardedItems, { name = item.name .. ' (Dropped on ground)', count = amount, metadata = metadata })
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Inventory Full',
                            description = Config.Locales['inventory_full'],
                            type = 'warning',
                            duration = 5000
                        })
                    end
                end
            end
        end
    end

    -- 2. Random Armory Item Pool
    if rewardsConfig.RandomRolls and rewardsConfig.RandomRolls.Pool and #rewardsConfig.RandomRolls.Pool > 0 then
        local minRolls = rewardsConfig.RandomRolls.MinItems or 1
        local maxRolls = rewardsConfig.RandomRolls.MaxItems or 3
        local rollCount = math.random(minRolls, maxRolls)

        -- Shallow copy pool for shuffling
        local poolCopy = {}
        for _, v in ipairs(rewardsConfig.RandomRolls.Pool) do
            table.insert(poolCopy, v)
        end

        for i = #poolCopy, 2, -1 do
            local j = math.random(i)
            poolCopy[i], poolCopy[j] = poolCopy[j], poolCopy[i]
        end

        local itemsGiven = 0
        for _, item in ipairs(poolCopy) do
            if itemsGiven >= rollCount then break end

            local chanceRoll = math.random(1, 100)
            if chanceRoll <= (item.chance or 50) then
                local amount = math.random(item.min, item.max)
                if amount > 0 then
                    local metadata = item.metadata or {}
                    if item.metadata and item.metadata.generateSerial then
                        metadata.serial = GenerateSerialNumber('LSPD')
                    end

                    local success = ox_inventory:AddItem(src, item.name, amount, metadata)
                    if success then
                        table.insert(rewardedItems, { name = item.name, count = amount, metadata = metadata })
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Armory Item Received',
                            description = string.format(Config.Locales['received_item'], amount, item.name),
                            type = 'success',
                            duration = 4000
                        })
                    else
                        local coords = GetEntityCoords(GetPlayerPed(src))
                        ox_inventory:CustomDrop('Police Armory Drop', {
                            { item.name, amount, metadata }
                        }, coords)
                        table.insert(rewardedItems, { name = item.name .. ' (Dropped on ground)', count = amount, metadata = metadata })
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Inventory Full',
                            description = Config.Locales['inventory_full'],
                            type = 'warning',
                            duration = 5000
                        })
                    end
                    itemsGiven = itemsGiven + 1
                end
            end
        end
    end

    -- Webhook logging
    SendDiscordLog(src, rewardedItems)
end)

---Register Usable Item in qbx_core
exports.qbx_core:CreateUseableItem(Config.ItemName, function(src)
    TriggerClientEvent('police_lootbox:client:openBox', src)
end)

---ox_inventory usable item hook
exports('police_lootbox', function(event, _, inventory)
    if event == 'usingItem' then
        local src = inventory.id
        TriggerClientEvent('police_lootbox:client:openBox', src)
        return false -- Prevent premature auto-consumption before progress bar completes
    end
end)
