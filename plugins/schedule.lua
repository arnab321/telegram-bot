local filename='data/schedule.lua'
local cronned = load_from_file(filename)

local function save_cron(origin, text,date)
  --local origin = get_receiver(msg)
  if not cronned[date] then
    cronned[date] = {}
  end
  local arr = { origin,  text } ;
  table.insert(cronned[date], arr)
  serialize_to_file(cronned, filename)
  return 'Saved!'
end

local function delete_cron(date)
  for k,v in pairs(cronned) do
    if k == date then
	  cronned[k]=nil
    end
  end
  serialize_to_file(cronned, filename)
end

local function cron()
  for date, values in pairs(cronned) do
  	if date < os.time() then --time's up
	  	send_msg(values[1][1], values[1][2], ok_cb, false)
  		delete_cron(date) --TODO: Maybe check for something else? Like user
	end

  end
end
--[[
local function actually_run(msg, delay,text)
  if (not delay or not text) then
  	return "Usage: !sch [delay: 2h3m1s] text"
  end
  save_cron(msg, text,delay)
  return "I'll remind you on " .. os.date("%x at %H:%M:%S",delay) .. " about '" .. text .. "'"
end
]]--
local function callbackres(extra, success, result)
	-- 1=msg 2=delay 3=text
	local msg
	--vardump(extra[1])
	if (not extra[2] or not extra[3] ) then
  		msg= "Usage: !sch username [delay: 2h3m1s] text"
	elseif result ~= false then
		msg=  result.peer_type .. "#id" .. result.peer_id 
		save_cron(msg, extra[3],extra[2])
		msg= msg .. " will receive: '" ..  extra[3]  .. "' on " .. os.date("%x at %H:%M:%S",extra[2] )
	
	else
		msg="username lookup failed"	
	end

	send_msg(get_receiver(extra[1]), msg , ok_cb, false)
	
	
end

local function run(msg, matches)
  local delay = 0
  for i = 2, #matches-1 do
    local b,_ = string.gsub(matches[i],"[a-zA-Z]","")
    if string.find(matches[i], "s") then
      delay=delay+b
    end
    if string.find(matches[i], "m") then
      delay=delay+b*60
    end
    if string.find(matches[i], "h") then
      delay=delay+b*3600
    end
  end

  local datetime = os.date ("*t")
  local nowsecs = datetime.hour *3600 + datetime.min *60 + datetime.sec
  local text = matches[#matches]

  if (delay<=nowsecs) then
  	delay = delay -nowsecs + 24*3600 + os.time() 
  else
  	delay = delay - nowsecs +os.time()
  end

  print(matches[1])
  resolve_username(matches[1],  callbackres,{msg, delay, text})

  --local text = actually_run(msg, date, text)
  --return text
  return false
  
end

return {
  description = "scheduler plugin",
  usage = {
  	"[!/#]sch [delay: 2hms] text",
  	"[!/#]sch [delay: 2h3m] text",
  	"[!/#]sch [delay: 2h3m1s] text"
  },
  patterns = {
    "^[!/#]sch (%w+) ([0-9]+[hmsdHMSD]) (.+)$",
    "^[!/#]sch (%w+) ([0-9]+[hmsdHMSD])([0-9]+[hmsdHMSD]) (.+)$",
    "^[!/#]sch (%w+) ([0-9]+[hmsdHMSD])([0-9]+[hmsdHMSD])([0-9]+[hmsdHMSD]) (.+)$"
  }, 
  run = run,
  cron = cron
}
