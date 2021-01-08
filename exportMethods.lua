term.clear()
term.setCursorPos(1,1)
local tArgs = {...}
local methods = {}
local validArgs = {"left", "right", "back", "top", "bottom"}
local devices = peripheral.getNames()
print(textutils.serialize(devices))



if #tArgs >= 1 then
  side = tArgs[2]
  exp = fs.open(tArgs[1]..".txt", "w")
  if tArgs[2] == nil then
    for _, device in pairs(devices) do
      type = peripheral.getType(device)
      deviceMethods = peripheral.getMethods(device)
      print(textutils.serialize(deviceMethods))
      methods[type] = {}
      table.insert(methods.devicenames, device)
      table.insert(methods[type], deviceMethods)
    end
  else
    x = peripheral.getMethods(side)
    methods[peripheral.getType(side)] = x
  end
  exp.write(textutils.serialize(methods))
  print("The file: "..tArgs[1].."\nHas been stored to: saves/'worldname'/computercraft/"..os.computerID())
  exp.close()
else
  print("This is a program to help\nYOU stay on track with methods.\nIn order for this to work,\nyou need to pass arguments to this program.\nValid first arguments are:\n\n'Think of a filename'\n\nValid second arguments are:\n\nempty, left, right, back, top, bottom")
end
