--General Settings
lengthOfRows = 5
rowSpacing = 3
numberOfRows = 1
maxTorchDistance = 10
runningLowWarning = 16

-- User Input Settings
useTorches = false
useChest = false
useCoal = false
useLava = false
clearInv = false
fastMode = false
waitForTorches = false
allowMultipleStacks = false
returnToStart = false

-- Work Settings (DONT CHANGE...Changed by Program)
torchPlacement = 0
remoteStorage = false
remoteStorageNames = {"enderstorage:ender_storage"}
storageName = ""
firstOpenSlot = 2
torchSlot = 0
chestSlot = 0
bucketSlot = 0

function itemInSlot(slot,name)
  details = turtle.getItemDetail(slot)
  if details ~= nil and details.name == name then
      return true
  end
  return false
end

function itemInInventory (name,deadSlot)
  local outputarray = {}
  for i=1,16 do
    if i ~= deadSlot then
      if itemInSlot(i,name) then
        outputarray[#outputarray+1]= i
      end
    end
  end
  return outputarray
end

function missingItem (name)
  return (next(itemInInventory(name)) == nil) and true or false
end

function waitForItem (name)
  if missingItem(name)  then
    print("Please insert: "..name)
    while missingItem(name) do
      sleep(0.5)
    end
  end
end

function freeUpSlot(slot) -- can return slot number
  if turtle.getItemCount(slot)==0 then
    return 0
  end
  for i=1,16 do
    if i~=slot then
      if turtle.getItemCount(i)==0 then
        turtle.select(slot)
        turtle.transferTo(i)
        return i
      end
    end
  end
  turtle.select(slot)
  turtle.dropUp()
  return slot
end

function sortItems(slot,name)
  waitForItem(name)
  if not itemInSlot(slot,name) then
    freeUpSlot(slot)
  end
  for i,v in ipairs(itemInInventory(name,slot)) do
    turtle.select(v)
    turtle.transferTo(slot)
    if turtle.getItemCount(slot)>=64 then
      turtle.select(1)
      break
    end
  end
end

function __checkForStorageName()
  if not missingItem("minecraft:chest") then
    return "minecraft:chest"
  end
  for k,v in pairs(remoteStorageNames) do
    if not missingItem(v) then
      remoteStorage = true
      return v
    end
  end
  return ""
end

function checkForStorageName()
  storageName=__checkForStorageName()
  if storageName=="" then
    print("Please insert a storage medium")
    while storageName=="" do
      storageName=__checkForStorageName()
      sleep(0.5)
    end
  end
  return storageName
end

function dropInventory (direction)
  for i=firstOpenSlot,16 do
    if (allowMultipleStacks and not (itemInSlot(i,storageName) or itemInSlot(i,"minecraft:torches"))) or not allowMultipleStacks then
      turtle.select(i)
      if direction == "up" then
        drop = turtle.dropUp
      elseif direction == "down" then
        drop = turtle.dropDown
      else
        error("Unknown direction to drop to, error in program")
      end
      drop()
      while turtle.getItemCount(i)>0 do
        print("Couldn't drop items... trying again")
        sleep(2)
        drop()
      end
    end
  end
end

function clearInventory ()
  sortItems(chestSlot,storageName)
  if remoteStorage then
    turtle.select(chestSlot)
    turtle.placeUp()
    dropInventory("up")
    turtle.select(chestSlot)
    turtle.digUp()
  else
    turtle.digDown()
    turtle.select(chestSlot)
    turtle.placeDown()
    dropInventory("down")
  end
  turtle.select(1)
end

function checkInventoryFull()
  if turtle.getItemCount(16)>0 then
    clearInventory()
  end
end

function calculateFuelNeed()
  fuelneeded = 0
  if newMine then
    fuelneeded = fuelneeded + rowSpacing
  end
  fuelneeded = fuelneeded + lengthOfRows*4*numberOfRows
  fuelneeded = fuelneeded + rowSpacing*2*numberOfRows
  if returnToStart then
    fuelneeded = fuelneeded + numberOfRows*rowSpacing*2
  end
  return fuelneeded
end

function burnCoal()
  for i,v in ipairs(itemInInventory("minecraft:coal")) do
    turtle.select(v)
    turtle.refuel()
  end
end

function oneBucket()
  if itemInSlot(bucketSlot,"minecraft:bucket") then
    details = turtle.getItemDetail(bucketSlot)
    if details.count >1 then
      turtle.select(bucketSlot)
      turtle.dropUp(details.count - 1)
      turtle.select(1)
    end
    return true
  end
  return false
end

function checkForLava()
  bool,details = turtle.inspectDown()
  if details.name == "minecraft:lava" and details.state.level == 0 and oneBucket() then
    turtle.select(bucketSlot)
    turtle.placeDown()
    turtle.refuel()
    turtle.select(1)
  end
end

function placeTorch()
  if torchPlacement>=10 then
    if not itemInSlot(torchSlot,"minecraft:torch") then
      if not missingItem("minecraft:torch") then
        sortItems(torchSlot,"minecraft:torch")
      else
        if waitForTorches then
          sortItems(torchSlot,"minecraft:torch")
        else
          print("Out of torches!")
        end
      end
    end
    if itemInSlot(torchSlot,"minecraft:torch") then
      turtle.turnLeft()
      turtle.turnLeft()
      turtle.select(torchSlot)
      while not turtle.place() do
        turtle.dig()
        sleep(0.5)
      end
      turtle.turnLeft()
      turtle.turnLeft()
      turtle.select(1)
      if turtle.getItemCount(torchSlot) <= runningLowWarning then
        print("Running low on torches")
      end
      torchPlacement = 0
    end
  end
  torchPlacement = torchPlacement + 1
end

function forward(times)
  times = times or 1
  for i=1,times do
    while (not turtle.forward()) do
      turtle.dig()
      sleep(0.4)
    end
    while (turtle.detectUp()) do
      turtle.digUp()
      sleep(0.4)
    end
    if not fastMode then
      if useLava then
        checkForLava()
      end
      if turtle.getItemCount(1) < 16 then
        sortItems(1,"minecraft:cobblestone")
      end
      turtle.select(1)
      turtle.placeDown()
      if useChest then
        checkInventoryFull()
      end
      if useTorches then
        placeTorch()
      end
    else
      turtle.select(1)
      turtle.placeDown()
    end
  end
end

-- User Inputs ------------------------------------
term.clear()
term.setCursorPos(1,1)

confirmationScreen = "Starting to mine with:\n"
itemsNeeded = "Order of Items in Inventory does not matter. \nPlease add: 1x64 Cobblestone"
local termInput = ""

print("Start new Mine? (y for yes):")
newMine = read()=="y" and true or false
confirmationScreen = newMine and confirmationScreen.."New mine: true\n" or confirmationScreen
print("Length of rows? (Default: "..tostring(lengthOfRows).."):")
termInput = read()
lengthOfRows = termInput=="" and lengthOfRows or tonumber(termInput)
confirmationScreen = confirmationScreen.."Row Length: "..tostring(lengthOfRows).."\n"
print("Number of rows? (Default: 5): ")
termInput = read()
numberOfRows =  termInput=="" and numberOfRows or tonumber(termInput)
confirmationScreen = confirmationScreen.."Row Length: "..tostring(lengthOfRows).."\n"
print("Following y for yes or anything else for no:")
print("Fast Mode?:")
fastMode = read()=="y" and true
confirmationScreen = confirmationScreen.."Fast Mode: "..tostring(fastMode).."\n"
if not fastMode then
  print("Use Torches?:")
  useTorches = read()=="y" and true
  if useTorches then
    confirmationScreen = confirmationScreen.."useTorches: true\n"
    itemsNeeded = itemsNeeded..", 1x64 Torches"
    print("Wait for Torches?:")
    waitForTorches = read()=="y" and true
    confirmationScreen = waitForTorches and confirmationScreen.."waitForTorches: true\n" or confirmationScreen
  end
  print("Use Chest?:")
  useChest = read()=="y" and true
  if useChest then
    confirmationScreen = confirmationScreen.."useChest: true\n"
    itemsNeeded = itemsNeeded..", 1x64 Chests"
    print("Clear Inventory at the end?:")
    clearInv = read()=="y" and true
    confirmationScreen = clearInv and confirmationScreen.."clearInv: true\n" or confirmationScreen
  end
  if useChest or useTorches then
    print("Allow MultipleStacks?:")
    allowMultipleStacks = read()=="y" and true
    confirmationScreen = allowMultipleStacks and confirmationScreen.."allowMultipleStacks: true\n" or confirmationScreen
  end
  print("Burn Coal: ")
  useCoal = read()=="y" and true
  confirmationScreen = useCoal and confirmationScreen.."useCoal: true\n" or confirmationScreen
  print("Warning: Lava only useful on height 11")
  print("Burn Lava: ")
  useLava = read()=="y" and true
  if useLava then
    confirmationScreen = confirmationScreen.."useLava: true\n"
    itemsNeeded = itemsNeeded..", 1x Bucket"
  end
end
print("Return to start Point?: ")
returnToStart = read()=="y" and true
confirmationScreen = returnToStart and confirmationScreen.."returnToStart: true\n" or confirmationScreen

term.clear()
term.setCursorPos(1,1)
write(confirmationScreen)
read()

term.clear()
term.setCursorPos(1,1)
confirmationScreen = ""
if (turtle.getFuelLevel()-calculateFuelNeed())<=0 then
  confirmationScreen = confirmationScreen.."Not Enough Fuel\n"
  if useCoal or useLava then
    confirmationScreen = confirmationScreen.."Burn Coal is active could be enough\n"
  end
else
  confirmationScreen = confirmationScreen.."Enough Fuel\n"
end
confirmationScreen = confirmationScreen..itemsNeeded..".\n"
if allowMultipleStacks then
  confirmationScreen = confirmationScreen.."You can also add more Torches or Chests\n"
end
confirmationScreen = confirmationScreen.."Start? (else CTRL+R)"
  print(confirmationScreen)
  read()

term.clear()
term.setCursorPos(1,1)

sortItems(1,"minecraft:cobblestone")

if useTorches then
  torchSlot = firstOpenSlot
  firstOpenSlot = firstOpenSlot + 1
  sortItems(torchSlot,"minecraft:torch")
end
if useChest then
  chestSlot = firstOpenSlot
  firstOpenSlot = firstOpenSlot + 1
  sortItems(chestSlot,checkForStorageName())
end
if useLava then
  bucketSlot = firstOpenSlot
  firstOpenSlot = firstOpenSlot + 1
  sortItems(bucketSlot, "minecraft:bucket")
  oneBucket()
end

-- Main Programm --
turtle.select(1)
if(newMine) then
  forward(rowSpacing)
end
for i = 1,tonumber(numberOfRows) do
  print("starting row: "..tostring(i) .. " " .. turtle.getFuelLevel())
  turtle.dig()
  turtle.turnLeft()
  forward(lengthOfRows)
  turtle.turnRight()
  -- Turnaround
  forward(rowSpacing)
  turtle.turnRight()
  forward(lengthOfRows)
  turtle.turnRight()
  turtle.dig()
  -- In middle
  turtle.turnLeft()
  turtle.turnLeft()
  turtle.dig()
  turtle.turnRight()
  forward(lengthOfRows)
  turtle.turnLeft()
  -- Turnaround
  forward(rowSpacing)
  turtle.turnLeft()
  forward(lengthOfRows)
  turtle.turnLeft()
  turtle.dig()
  turtle.turnRight()
  turtle.turnRight()
  if useCoal then
    burnCoal()
  end
end
if returnToStart then
  turtle.turnLeft()
  turtle.turnLeft()
  forward(numberOfRows*rowSpacing*2)
  turtle.turnLeft()
  turtle.turnLeft()
end
if clearInv then
  print("Cleaning inventory!")
  clearInventory()
end
print("Finished Mine")
