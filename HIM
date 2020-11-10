lengthOfRows = 10
numberOfRows = 5
maxTorchDistance = 10
useTorches = false
torchPlacement = 0
useChest = false
remoteStorage = false
remoteStorageName = {"enderstorage:ender_storage"}
storageName = ""

function forward(times)
  times = times or 1
  for i=1,times do
    while (not turtle.forward()) do
      turtle.dig()
      sleep(0.4)
    end
    while (turtle.detectUp()) do
      b, k = turtle.inspectUp()
      if b == true and k.name ~= "minecraft:torch" then
        turtle.digUp()
        sleep(0.4)
      else
        break
      end
    end
    if turtle.getItemCount(1) < 16 then
      sortItems("minecraft:cobblestone",1)
    end
    turtle.select(1)
    turtle.placeDown()
    checkInventoryFull(16)
    placeTorch()
  end
end

function nextRow()
  forward(3)
end
----------------
function sortItems(name, slot)
  waitForItem(name)
  details = turtle.getItemDetail(slot)
  if details ~= nil and details.name ~= name then
    freeUpSlot(slot)
  end
  for i,v in ipairs(checkForItemInInventory(name,slot)) do
    turtle.select(v)
    turtle.transferTo(slot)
    if turtle.getItemCount(slot)>=63 then
      turtle.select(1)
      break
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

function checkForItemInInventory (name,deadSlot)
  local outputarray = {}
  for i=1,16 do
    if i ~= deadSlot then
      details = turtle.getItemDetail(i)
      if details ~= nil then
        if details.name == name then
          outputarray[#outputarray+1]= i
        end
      end
    end
  end
  return outputarray
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

function __checkForStorageName()
  if not missingItem("minecraft:chest") then
    return "minecraft:chest"
  end
  for k,v in pairs(remoteStorageName) do
    if not missingItem(v) then
      remoteStorage = true
      return v
    end
  end
  return ""
end

function placeTorch()
  if torchPlacement>=10 then
      if turtle.getItemCount(2)>0 then
        if turtle.getItemDetail(2).name == "minecraft:torch" then
          turtle.turnLeft()
          turtle.turnLeft()
          turtle.select(2)
          while not turtle.place() do
            turtle.dig()
            sleep(0.5)
          end
          turtle.turnLeft()
          turtle.turnLeft()
        else
          print("Out of torches!")
        end
      end
      turtle.select(1)
      torchPlacement = 0
  end
  torchPlacement = torchPlacement + 1
end

function missingItem (name)
  return (next(checkForItemInInventory(name)) == nil) and true or false
end

function checkInventoryFull(slot)
  if useChest and turtle.getItemCount(slot)>0 then
    if not missingItem(storageName) then --sortItems(chest, 3)
      if remoteStorage then
        turtle.select(3)
        turtle.placeUp()
        for i=4,16 do
          turtle.select(i)
          turtle.dropUp()
          while turtle.getItemCount(i)>0 do
            print("Couldn't drop items... trying again")
            sleep(2)
            turtle.select(3)
            turtle.digUp()
          end
        end
      else
        turtle.digDown()
        turtle.down()
        turtle.select(1)
        turtle.placeDown()
        turtle.up()
        turtle.select(3)
        turtle.placeDown()
        for i=4,16 do
          turtle.select(i)
          turtle.dropDown()
        end
      end
    else
      sortItems(storageName,3)
    end
    turtle.select(1)
  end
end

function waitForItem (name)
  if missingItem(name)  then
    print("Please insert: "..name)
    while missingItem(name) do
      sleep(0.5)
    end
  end
end

--User Inputs--
term.clear()
term.setCursorPos(1,1)

local termInput = ""

print("Start new Mine? (y for yes):")
newMine = read()=="y" and true or false
print("Length of rows? (Default: 10):")
termInput = read()
lengthOfRows = termInput=="" and lengthOfRows or tonumber(termInput)
print("Number of rows? (Default: 5): ")
termInput = read()
numberOfRows =  termInput=="" and numberOfRows or tonumber(termInput)
print("Use Torches? (y for yes):")
useTorches = read()=="y" and true
print("Use Chest? (y for yes):")
useChest = read()=="y" and true

term.clear()
term.setCursorPos(1,1)
print("Starting to mine with:")
print("New mine: "..tostring(newMine))
print("Row Length: "..tostring(lengthOfRows))
print("Number of rows: "..tostring(numberOfRows))
print("useTorches: "..tostring(useTorches))
print("useChest: "..tostring(useChest))
write("Order of Items in Inventory does not matter. \nPlease add: 1x64 Cobblestone ")
if useTorches then
  write(", 1x64 Torches")
end
if useChest then
    write(", 1x64 Chest or 1x Remote Storage")
end
print("\nStart? (else CTRL+R)")
read()

term.clear()
term.setCursorPos(1,1)

sortItems("minecraft:cobblestone",1)

if useTorches then
  sortItems("minecraft:torch",2)
end
if useChest then
  -- checkForStorageName()
  sortItems(checkForStorageName(),3)
end

-- Main Programm --

turtle.select(1)
if(newMine) then
  nextRow()
end
for i = 1,tonumber(numberOfRows) do
  print("starting row: "..tostring(i) .. " " .. turtle.getFuelLevel())
  turtle.dig()
  turtle.turnLeft()
  forward(lengthOfRows)
  turtle.turnRight()
  -- Turnaround
  nextRow()
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
  nextRow()
  turtle.turnLeft()
  forward(lengthOfRows)
  turtle.turnLeft()
  turtle.dig()
  turtle.turnRight()
  turtle.turnRight()
end
print("Cleaning inventory!")
for i=3,16 do
  if turtle.getItemCount(i) > 1 and i > 5 then
    checkInventoryFull(i)
  end
end
print("Finished Mine")
