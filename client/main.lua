---@diagnostic disable: undefined-global
local isOpening = false

---Handle opening the police loot box
RegisterNetEvent('police_lootbox:client:openBox', function()
    if isOpening then
        lib.notify({
            title = 'Police Loot Box',
            description = Config.Locales['already_opening'],
            type = 'warning'
        })
        return
    end

    isOpening = true

    -- Check if player has the box on server
    local canOpen, errorMsg = lib.callback.await('police_lootbox:server:canOpenBox', false)
    if not canOpen then
        lib.notify({
            title = 'Police Loot Box',
            description = errorMsg or 'You cannot open this right now.',
            type = 'error'
        })
        isOpening = false
        return
    end

    -- Animation & Prop Configuration
    local animConfig = {
        dict = Config.Opening.Animation.Dict,
        clip = Config.Opening.Animation.Clip,
        flag = Config.Opening.Animation.Flag
    }

    local propConfig = nil
    if Config.Opening.Prop.Enabled then
        propConfig = {
            model = joaat(Config.Opening.Prop.Model),
            bone = Config.Opening.Prop.Bone,
            pos = Config.Opening.Prop.Pos,
            rot = Config.Opening.Prop.Rot
        }
    end

    -- Progress Bar
    local completed = lib.progressBar({
        duration = Config.Opening.Duration,
        label = Config.Opening.Label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            sprint = true
        },
        anim = animConfig,
        prop = propConfig
    })

    if completed then
        -- Successfully opened -> Claim police armory rewards
        TriggerServerEvent('police_lootbox:server:claimRewards')
        lib.notify({
            title = 'Police Loot Box',
            description = Config.Locales['box_opened_success'],
            type = 'success'
        })
    else
        -- Cancelled
        lib.notify({
            title = 'Police Loot Box',
            description = Config.Locales['cancelled'],
            type = 'inform'
        })
    end

    isOpening = false
end)
