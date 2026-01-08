local M = {}

local wezterm = require("wezterm")

local cache = {
  throttle = 5,
  ram_usage = {
    last_update = 0,
    value = "",
  },
  cpu_usage = {
    last_update = 0,
    value = "",
  },
}

local fetch_cache_value = function(key, fetch_function)
  local current_time = os.time()
  local cache_entry = cache[key]

  if current_time - cache_entry.last_update >= cache.throttle then
    cache_entry.value = fetch_function()
    cache_entry.last_update = current_time
  end

  return cache_entry.value
end

local target_darwin = function()
  return wezterm.target_triple:find("darwin")
end

local ram_usage_darwin = function()
  local success, result = wezterm.run_child_process({ "vm_stat" })

  if not success or not result then
    return "N/A"
  end

  local page_size = result:match("page size of (%d+) bytes")
  local anonymous_pages = result:match("Anonymous pages: +(%d+).")
  local pages_purgeable = result:match("Pages purgeable: +(%d+).")
  local app_memory = anonymous_pages - pages_purgeable
  local wired_memory = result:match("Pages wired down: +(%d+).")
  local compressed_memory = result:match("Pages occupied by compressor: +(%d+).")
  local used_memory = (app_memory + wired_memory + compressed_memory) * page_size / 1024 / 1024 / 1024

  return string.format("%.2f GB", used_memory)
end

local cpu_usage_darwin = function()
  local success, result = wezterm.run_child_process({ "sh", "-c", "top -l 1 | grep 'CPU usage'" })

  if not success or not result then
    return "N/A"
  end

  local idle_cpu = result:match("(%d+%.%d+)%% idle")
  local used_cpu = 100 - tonumber(idle_cpu)

  return string.format("%.2f %%", used_cpu)
end

M.ram_usage = function()
  if target_darwin() then
    return fetch_cache_value("ram_usage", ram_usage_darwin)
  end

  return nil
end

M.cpu_usage = function()
  if target_darwin() then
    return fetch_cache_value("cpu_usage", cpu_usage_darwin)
  end

  return nil
end

return M
