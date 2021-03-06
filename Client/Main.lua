---@author ${RevengeBack_}
ESX, MenuActive = nil, false TriggerEvent('esx:getSharedObject', function(lib) ESX = lib end)

local markerAction = function(action)
    if action == 1 then
        upDown = false
        MTaille = 0.40
        Opacity = 10
    elseif action == 2 then
        upDown = true
        MTaille = 0.6
        Opacity = 80
    end
    return action
end

local isPlayerOnZone = function(zone)
	return #(GetEntityCoords(PlayerPedId())-zone)
end

-- > Blips
CreateThread(function()
    for _, v in pairs(Configuration.Superettes) do
        -- > Blips
        local _shops = AddBlipForCoord(v.Position)

		SetBlipSprite(_shops, 52)
		SetBlipScale (_shops, 0.62)
		SetBlipColour(_shops, 34)
		SetBlipAsShortRange(_shops, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName("Superette")
		EndTextCommandSetBlipName(_shops)


        -- > Peds
        local ModelHash = Configuration.Options.PedModel
        _rbShopsClientUtils.CreateGamePed(ModelHash, v.Ped.pos, v.Ped.heading)
	end

    --@ Main
    while true do
        local interval = 3500

        for _,v in pairs(Configuration.Superettes) do
            local MarkerPos = v.Position

            local pPed = PlayerPedId()
            local pCoords = GetEntityCoords(pPed)
        
            if isPlayerOnZone(MarkerPos) < 15.0 then
                interval = 1

                if pDist <= 10.0 then
                    MarkerOptions = Configuration.Options.Marker
                    DrawMarker(MarkerOptions.Type, MarkerPos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, MTaille, MTaille, MTaille, MarkerOptions.Couleur.r, MarkerOptions.Couleur.g, MarkerOptions.Couleur.b, Opacity, upDown, false)
                    markerAction(2)

                    if pDist <= 0.8 then
                        MarkerPos = MarkerPos
                        markerAction(1)
                        _rbShopsClientUtils.ShowHelpNotification(("Appuyez sur ~INPUT_CONTEXT~ pour ~b~parler~s~ à ~c~%s"):format(Configuration.Options.PedName))

                        if IsControlJustReleased(0, 38) then
                            print(("[Shop Opened]: %s"):format(tostring(MarkerPos)))
                            openShopMenu()
                        end
                        
                    else
                        MarkerPos = nil
                    end
                    
                end

                if pDist > 3.5 and MenuActive then
                    RageUI.CloseAll()
                    MenuActive = false
                end
            end

        end

        Wait(interval)
    end
end)

RegisterNetEvent("RevengeShops:ShopResult")
AddEventHandler("RevengeShops:ShopResult", function(result, price, money)
    if result then
        _rbShopsClientUtils.ShowAdvNotif("Épicerie", "Informations", ("Merci de votre achat de ~g~%s$~n~Mode de paiement: ~y~%s"):format(math.floor(price), ChoixPaiement), 'CHAR_BANK_FLEECA', 1)
        PlaySoundFrontend(-1, "PURCHASE", "HUD_LIQUOR_STORE_SOUNDSET", 1)
    else
        _rbShopsClientUtils.ShowAdvNotif("Épicerie", "Informations", ("Désolé mais vous ~r~n'avez pas~s~ assez!~n~Il vous manque: ~r~%s$"):format(math.floor(price-money)), 'CHAR_BLOCKED', 1)
        PlaySoundFrontend(-1, "Pin_Bad", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 1)
    end
end)
