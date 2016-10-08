
local function run(msg, matches)
	wassup={"hi","wassup?","hey","wassup?","hows u?","what r u doing?","how was ur day?","hello","yo","hieeeeeee"}

	i=math.random(0,9)
--[[
  local text = matches[1]
  local b = 1

  while b ~= 0 do
    text = text:trim()
    text,b = text:gsub('^!+','')
  end
]]--
  -- return text
     if (msg.to.type == 'user') --or msg.to.type == 'chat')
     	return wassup[i]
     else
     	return false
     end
end

return {
  description = "Simplest plugin ever!",
  usage = "!echo [whatever]: echoes the msg",
  patterns = {
    -- "^[/!]echo +(.+)$"
	nocase("^hi"),nocase("^hey"),nocase("^hello") --,nocase("^how"),nocase("^yo")
  }, 
  run = run 
}
