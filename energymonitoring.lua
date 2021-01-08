local funcTable = {}
local deviceRegister = {}
deviceRegister.core = {}
deviceRegister.monitor = {}

deviceRegister.core.delayInSeconds = 2

devices = peripheral.getNames()

function attachDevices()
  for _, device in pairs(devices) do
    type = peripheral.getType(device)
    if type == "draconic_rf_storage" then
      dr_core = peripheral.wrap(device)
      --print(device.." connected")
      deviceRegister.core.name = device
      deviceRegister.core.available = true
    elseif type == "monitor" then
      mon = peripheral.wrap(device)
      --print(device.." connected")
      deviceRegister.monitor.name = device
      deviceRegister.monitor.available = true
    end
  end
end

function checkDeviceAvailability()
  if deviceRegister ~= nil then
    for _, device in pairs(deviceRegister) do
      print("Device: "..device.name)
      if device.available then
        print("Status: Online")
      else
        print("Status: Offline")
      end
    end
  end
end

--Calls

attachDevices()
checkDeviceAvailability()

if deviceRegister.core.available then
  ticks = 0
    deviceRegister.core.maxEnergy = dr_core.getMaxEnergyStored()
    function funcTable:coreGetEnergy()
      deviceRegister.core.currentEnergy = dr_core.getEnergyStored()
      return deviceRegister.core.currentEnergy
    end
    function funcTable:coreSleepSecondsToTicks()
      seconds = deviceRegister.core.delayInSeconds
      ticks = seconds/20
      deviceRegister.core.sleepTimer = ticks
      --return deviceRegister.core.sleepTimer
    end
    function funcTable:coreEnergyOverTime()
      seconds = deviceRegister.core.delayInSeconds
      funcTable.coreSleepSecondsToTicks(seconds)
      timer = deviceRegister.core.sleepTimer
      while timer <= seconds do
        term.setCursorPos(1,1)
        --print("Waiting on energy!")
        timer = timer + 0.05
        print("Seconds: "..timer.."   ")
        sleep(0.05)
        if timer == seconds then
          break
        end
      end
      deviceRegister.core.timedEnergy = dr_core.getEnergyStored()
    end
else
  print("Device of type 'draconic_rf_storage' has not been connected.")
end

print(deviceRegister.core.maxEnergy)

while true do
  term.clear()
  term.setCursorPos(1,1)
  funcTable.coreGetEnergy()
  funcTable.coreEnergyOverTime()
  print(deviceRegister.core.timedEnergy)
  sleep(1)
end
