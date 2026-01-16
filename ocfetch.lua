local component = require("component")
local computer  = require("computer")
local fs        = require("filesystem")
local unicode   = require("unicode")

local function hr()
  print(string.rep("-", 40))
end

local function fmtBytes(n)
  n = tonumber(n) or 0
  local units = {"B", "KB", "MB", "GB", "TB"}
  local i = 1
  while n >= 1024 and i < #units do
    n = n / 1024
    i = i + 1
  end
  return string.format("%.1f %s", n, units[i])
end

local function pct(used, total)
  if not total or total <= 0 then return "n/a" end
  return string.format("%.1f%%", (used / total) * 100)
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
print("Total RAM:", fmtBytes(computer.totalMemory()))
print("Free  RAM:", fmtBytes(computer.freeMemory()))
print("Used  RAM:", fmtBytes(computer.totalMemory() - computer.freeMemory()))
hr()

-- Filesystems
print("Filesystems:")
for addr in component.list("filesystem") do
  local proxy = component.proxy(addr)
  local label = (proxy.getLabel and proxy.getLabel()) or addr:sub(1, 8)

  local total, free, used

  if type(proxy.spaceTotal) == "function" and type(proxy.spaceAvailable) == "function" then
    total = proxy.spaceTotal() or 0
    free  = proxy.spaceAvailable() or 0
    used  = math.max(total - free, 0)

    print(string.format(" %-12s %s / %s (%s)",
      label, fmtBytes(used), fmtBytes(total), pct(used, total)
    ))
  else
    -- ФС без информации о размере (tmpfs/romfs/прочее)
    print(string.format(" %-12s %s", label, "n/a"))
  end
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
for addr, ctype in component.list() do
  print(string.format("  - %-12s %s", ctype, addr)
end
