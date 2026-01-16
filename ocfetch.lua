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
--print("Tick time (s):      ", computer.getTickTime())
print("Energy (RF):        ", computer.energy(), "/", computer.maxEnergy())
hr()

-- Memory
print("Total RAM:", fmtBytes(computer.totalMemory()))
print("Free  RAM:", fmtBytes(computer.freeMemory()))
print("Used  RAM:", fmtBytes(computer.totalMemory() - computer.freeMemory()))
hr()

-- Filesystems

print("Filesystems:")
local mountsByAddr = {}
for proxy, path in fs.mounts() do
  if proxy and proxy.address then
    mountsByAddr[proxy.address] = path
  end
end

for addr in component.list("filesystem") do
  local p = component.proxy(addr)
  local label = (p.getLabel and p.getLabel()) or addr:sub(1,8)
  local mnt = mountsByAddr[addr] or "?"
  local ro  = (p.isReadOnly and p.isReadOnly()) and " RO" or ""

  local total = (type(p.spaceTotal) == "function") and p.spaceTotal() or nil

  local used
  if type(p.spaceUsed) == "function" then
    used = p.spaceUsed()
  elseif type(p.spaceAvailable) == "function" and total then
    used = total - p.spaceAvailable()
  end

  if total and used then
    print(string.format(" %-10s %-8s %s / %s (%s)%s",
      label, mnt, fmtBytes(used), fmtBytes(total), pct(used,total), ro
    ))
  else
    print(string.format(" %-10s %-8s %s%s", label, mnt, "n/a", ro))
  end
end

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
  print(string.format("  - %-12s %s", ctype, addr))
end
