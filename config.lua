---@diagnostic disable: lowercase-global, undefined-global
Config = {}

-- ====================================================================
-- General Settings
-- ====================================================================
Config.ItemName = 'police_lootbox' -- The usable item name in ox_inventory

-- ====================================================================
-- Opening & Animation Settings
-- ====================================================================
Config.Opening = {
    Duration = 5000, -- Duration in milliseconds (5 seconds)
    Label = 'Opening Police Loot Box...',
    
    -- Animation Settings
    Animation = {
        Dict = 'anim@gangops@facility@servers@bodysearch@',
        Clip = 'player_search',
        Flag = 49
    },

    -- Optional attached prop while opening
    Prop = {
        Enabled = true,
        Model = 'prop_cs_box_clothes',
        Bone = 28422,
        Pos = vec3(0.0, -0.05, -0.05),
        Rot = vec3(0.0, 0.0, 0.0)
    }
}

-- ====================================================================
-- Police Armory Loot Rewards Array (Given to Player's Inventory)
-- ====================================================================
Config.Rewards = {
    -- Guaranteed Items: Player ALWAYS receives these items
    Guaranteed = {
        { name = 'weapon_combatpistol', min = 1, max = 1, chance = 100, metadata = { durability = 100, generateSerial = true, description = 'Police Standard Issue Pistol' } },
        { name = 'ammo-9',              min = 50, max = 100, chance = 100 },
        { name = 'armour',              min = 1, max = 2, chance = 100 },
        { name = 'handcuffs',           min = 1, max = 2, chance = 100 }
    },

    -- Random Armory Items Pool: Rolls between MinItems and MaxItems from this array
    RandomRolls = {
        MinItems = 2, -- Minimum number of random items rewarded
        MaxItems = 5, -- Maximum number of random items rewarded
        Pool = {
            { name = 'weapon_stungun',       min = 1,  max = 1,   chance = 70, metadata = { durability = 100, generateSerial = true } },
            { name = 'weapon_nightstick',     min = 1,  max = 1,   chance = 80 },
            { name = 'weapon_flashlight',     min = 1,  max = 1,   chance = 85 },
            { name = 'weapon_carbinerifle',   min = 1,  max = 1,   chance = 35, metadata = { durability = 100, generateSerial = true } },
            { name = 'weapon_pumpshotgun',    min = 1,  max = 1,   chance = 45, metadata = { durability = 100, generateSerial = true } },
            { name = 'ammo-rifle',           min = 30, max = 90,  chance = 70 },
            { name = 'ammo-shotgun',         min = 10, max = 30,  chance = 70 },
            { name = 'radio',                min = 1,  max = 1,   chance = 80 },
            { name = 'bandage',              min = 3,  max = 6,   chance = 85 },
            { name = 'medikit',              min = 1,  max = 3,   chance = 75 },
            { name = 'spikestrip',           min = 1,  max = 2,   chance = 50 },
            { name = 'heavyarmor',           min = 1,  max = 2,   chance = 40 }
        }
    }
}

-- ====================================================================
-- Discord Webhook Logging
-- ====================================================================
Config.DiscordWebhook = {
    Enabled = false,
    WebhookURL = 'PASTE_YOUR_DISCORD_WEBHOOK_URL_HERE',
    BotName = 'Nexora Police Loot Box Logger',
    Color = 3447003
}

-- ====================================================================
-- Locales / Notifications
-- ====================================================================
Config.Locales = {
    ['already_opening'] = 'You are already opening a police loot box!',
    ['cancelled'] = 'Cancelled opening police loot box.',
    ['inventory_full'] = 'Your inventory is too full! Some items were dropped at your feet.',
    ['received_item'] = 'Received %sx %s',
    ['box_opened_success'] = 'You successfully opened the Police Loot Box!'
}
