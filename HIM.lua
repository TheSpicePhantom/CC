--General Settings
lengthOfRows = 10
numberOfRows = 5
maxTorchDistance = 10
runningLowWarning = 16

-- User Input Settings
useTorches = false
useChest = false
clearInv = false
waitForTorches = false
allowMultipleStacks = false

-- Work Settings (DONT CHANGE...Changed by Program)
torchPlacement = 0
remoteStorage = false
remoteStorageNames = {"enderstorage:ender_storage"}
storageName = ""
firstOpenSlot = 2

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

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
      print("storageName: "..storageName)
    end
  end
  return storageName
end

function dropInventory (direction)
  for i=firstOpenSlot,16 do
    if (allowMultipleStacks and not (itemInSlot(i,storageName) or itemInSlot(i,"minecraft:torches"))) or not allowMultipleStacks then
      turtle.select(i)
      if direction == "up" then
        turtle.dropUp()
      else
        turtle.dropDown()
      end
      while turtle.getItemCount(i)>0 do
        print("Couldn't drop items... trying again")
        sleep(2)
        turtle.select(i)
        if direction == "up" then
          turtle.dropUp()
        elseif direction == "down" then
          turtle.dropDown()
        else
          error("Unknown direction to drop to")
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
    end
  else
    turtle.digDown()
    turtle.down()
    turtle.select(1)
    turtle.placeDown()
    turtle.up()
    turtle.select(chestSlot)
    turtle.placeDown()
    dropInventory("down")
  end
  turtle.select(1)
end

function checkInventoryFull(slot)
  if useChest and turtle.getItemCount(slot)>0 then
    clearInventory()
  end
end

function placeTorch()
  if torchPlacement>=10 then
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
    else
      if waitForTorches then
        sortItems(torchSlot,"minecraft:torch")
      else
        print("Out of torches!")
      end
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
  end
end

-- User Inputs ------------------------------------
term.clear()
term.setCursorPos(1,1)

local termInput = ""

print("Start new Mine? (y for yes):")
newMine = read()=="y" and true or false
print("Length of rows? (Default: "..String(lengthOfRows).."):")
termInput = read()
lengthOfRows = termInput=="" and lengthOfRows or tonumber(termInput)
print("Number of rows? (Default: 5): ")
termInput = read()
numberOfRows =  termInput=="" and numberOfRows or tonumber(termInput)
print("Following y for yes or anything else for no:")
print("Use Torches?:")
useTorches = read()=="y" and true
if useTorches then
  print("Wait for Torches?:")
  waitForTorches = read()=="y" and true
end
print("Use Chest?:")
useChest = read()=="y" and true
print("Clear Inventory at the end?:")
clearInv = read()=="y" and true
print("Allow MultipleStacks?:")
allowMultipleStacks = read()=="y" and true

term.clear()
term.setCursorPos(1,1)
print("Starting to mine with:")
print("New mine: "..tostring(newMine))
print("Row Length: "..tostring(lengthOfRows))
print("Number of rows: "..tostring(numberOfRows))
print("useTorches: "..tostring(useTorches))
print("waitForTorches: "..tostring(waitForTorches))
print("useChest: "..tostring(useChest))
print("clearInv: "..tostring(clearInv))
print("allowMultipleStacks: "..tostring(allowMultipleStacks))
write("Order of Items in Inventory does not matter. \nPlease add: 1x64 Cobblestone ")
if useTorches then
  write(", 1x64 Torches")
end
if useChest then
    write(", 1x64 Chest or 1x Remote Storage")
end
if allowMultipleStacks then
  write(". \nYou can also add more of Chests or Torches")
end
print("\nStart? (else CTRL+R)")
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

-- Main Programm --
turtle.select(1)
if(newMine) then
  forward(3)
end
for i = 1,tonumber(numberOfRows) do
  print("starting row: "..tostring(i) .. " " .. turtle.getFuelLevel())
  turtle.dig()
  turtle.turnLeft()
  forward(lengthOfRows)
  turtle.turnRight()
  -- Turnaround
  forward(3)
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
  forward(3)
  turtle.turnLeft()
  forward(lengthOfRows)
  turtle.turnLeft()
  turtle.dig()
  turtle.turnRight()
  turtle.turnRight()
end
if clearInv then
  print("Cleaning inventory!")
  clearInventory()
end

print("Finished Mine")
