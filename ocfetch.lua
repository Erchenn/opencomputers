local component = require("component")
local computer  = require("computer")
local fs        = require("filesystem")
local unicode   = require("unicode")

local function hr()
  print(string.rep("-", 40))
end

print("OpenComputers system info")
hr()

-- Lua / VM
print("Lua version:        ", _VERSION)
print("Uptime (s):         ", math.floor(computer.uptime()))
print("Tick time (s):      ", computer.getTickTime())
print("Energy (RF):        ", computer.energy(), "/", computer.maxEnergy())
hr()

-- Memory
print("Total RAM (bytes):  ", computer.totalMemory())
print("Free RAM (bytes):   ", computer.freeMemory())
print("Used RAM (bytes):   ", computer.totalMemory() - computer.freeMemory())
hr()

-- Filesystems
print("Filesystems:")
for addr in component.list("filesystem") do
  local proxy = component.proxy(addr)
  local label = proxy.getLabel() or addr:sub(1, 8)
  local size  = proxy.spaceTotal()
  local free  = proxy.spaceAvailable()
  print(string.format(
    "  %-12s %8d / %8d bytes",
    label, size - free, size
  ))
end
hr()

-- GPU / Screen
if component.isAvailable("gpu") then
  local gpu = component.gpu
  local w,h = gpu.getResolution()
  local mw,mh = gpu.maxResolution()
  print("GPU:")
  print("  Resolution:       ", w, "x", h)
  print("  Max resolution:   ", mw, "x", mh)
  print("  Color depth:      ", gpu.getDepth())
end
hr()

-- Components
print("Components:")
for ctype in component.list() do
  print("  -", ctype)
end
