local url = "https://cokeboys-luaprot-pilot.cokeboysclient.workers.dev/testers/experimental.lua"
local downloaded, source = pcall(function() return game:HttpGet(url, true) end)
if not downloaded or type(source) ~= "string" or #source == 0 or #source > 1048576 then
    warn("Cokeboys: unable to download the loader. Please try again shortly.")
    return
end
local compiled, entry = pcall(loadstring, source)
if not compiled or type(entry) ~= "function" then
    warn("Cokeboys: loader unavailable. Please try again shortly.")
    return
end
entry()
