
local io = { popen = io.popen }
local setmetatable = setmetatable
module("vicious.widgets.nvidia")
local function worker()

--f = io.popen("sensors | awk '/Core 0/ {print($3)}'")
--f = io.popen("nvidia-smi | awk '/Core 0/ {print($3)}' | awk -F '[+.]' '{print($2)}'")

f = io.popen("nvidia-smi | awk '/C  N/ {print($3)}' | awk -F '[C ]' '{print($1)}'")
for line in f:lines() do
gputemp = line
end

f = io.popen("nvidia-smi | awk '/% / {print($10)}'")
for line in f:lines() do
gpumem = line
end

return "GPU: " .. gpumem .. " · " .. gputemp .. "° ⁝ "
end

setmetatable(_M, { __call = function(_, ...) return worker(...) end })

