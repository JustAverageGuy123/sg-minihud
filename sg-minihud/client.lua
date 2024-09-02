local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData
local display = false

-------------------------
---     Functions     ---
-------------------------
local function formatNumber(num)
  return string.format('%d', num):reverse():gsub('%d%d%d', '%1,'):reverse():gsub('^,', '')
end

local function isHudActive()
  return display
end
exports('isHudActive', isHudActive)

--@param boolean | true/false to show/hide the display
local function ToggleHud(toggle)
  if display then
    SendNUIMessage({
      action = 'toggleDisplay',
      show = toggle
    })
  end
end
exports('ToggleHud', ToggleHud)

-------------------------
---     Commands      ---
-------------------------


-------------------------
---   NUI Callbacks   ---
-------------------------
RegisterNUICallback('stopMove', function(data, cb)
  SetNuiFocus(false, false)
  cb({})
end)

RegisterNUICallback('setDisplayState', function(data, cb)
  display = data.displayState
  cb({})
end)

-------------------------
---    Base Events    ---
-------------------------
RegisterNetEvent('QBCore:Client:OnMoneyChange', function(moneyType, _, changeType)
  local playerData = QBCore.Functions.GetPlayerData()
  local account, amount
  if moneyType == 'cash' then
    account = 'cash'
    amount = formatNumber(playerData.money['cash'])
  elseif moneyType == 'bank' then
    account = 'bank'
    amount = formatNumber(playerData.money['bank'])
  end

  if Config.Debug then print('OnMoneyChange', account, amount, changeType) end
  if account and amount then
    SendNUIMessage({
      action = 'moneyChange',
      account = account,
      amount = amount,
      changeType = changeType
    })
  end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
  if Config.Debug then QBCore.Debug(JobInfo) end
  SendNUIMessage({
    action = 'jobChange',
    job = JobInfo.label
  })
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(InfoGang)
  if Config.Debug then QBCore.Debug(InfoGang) end
  SendNUIMessage({
    action = 'gangChange',
    gang = InfoGang.label
  })
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function ()
  Wait(2000)
  PlayerData = QBCore.Functions.GetPlayerData()
  local cash = formatNumber(PlayerData.money['cash'])
  local bank = formatNumber(PlayerData.money['bank'])

  if Config.Debug then print('OnPlayerLoaded', PlayerData.source, PlayerData.job.label, PlayerData.gang.label, cash, bank) end
  SendNuiMessage(json.encode({
    action = 'playerData',
    id = PlayerData.source,
    job = PlayerData.job.label,
    gang = PlayerData.gang.label,
    cash = cash,
    bank = bank
  }))

  Wait(1000)
  SendNUIMessage({
    action = 'toggleDisplay',
    init = true
  })
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
  PlayerData = {}
end)

AddEventHandler('onResourceStart', function(resource)
  if resource ~= GetCurrentResourceName() then return end
  Wait(1000)
  PlayerData = QBCore.Functions.GetPlayerData()
  local cash = formatNumber(PlayerData.money['cash'])
  local bank = formatNumber(PlayerData.money['bank'])

  if Config.Debug then print('onResourceStart', PlayerData.source, PlayerData.job.label, PlayerData.gang.label, cash, bank) end
  SendNuiMessage(json.encode({
    action = 'playerData',
    id = PlayerData.source,
    job = PlayerData.job.label,
    gang = PlayerData.gang.label,
    cash = cash,
    bank = bank
  }))

  Wait(1000)
  SendNUIMessage({
    action = 'toggleDisplay',
    init = true
  })
end)