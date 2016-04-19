--local aibot="talk2cleverbot"
local pendingUsers={}

local function callbackres(extra, success, result)
	-- 1=msg 2=text
	local msg
	--vardump(extra[1])
	if result ~= false then
		msg=  result.peer_type .. "#id" .. result.peer_id
		send_msg(msg, extra[2] , ok_cb, false)
		table.insert(pendingUsers,get_receiver(extra[1]))
	
	else
		msg="username lookup failed"	
		send_msg(get_receiver(extra[1]), msg , ok_cb, false)
	end

end

local function pre_process(msg)
  -- Ignore service msg
  if msg.service then
    return msg
  end
  
  if (msg.to.type == 'user' and string.match(msg.from.username,nocase("bot$")) == nil and msg.from.username ~= 'flaminSnow' and string.match(msg.text,"^[!/#]") == nil) then
    resolve_username(_config.proxyUsername,  callbackres,{msg, msg.text})
    
  end
    
  if (msg.from.username == _config.proxyUsername and next(pendingUsers) ~= nil) then
    send_msg(pendingUsers[#pendingUsers], msg.text , ok_cb, false)
    table.remove(pendingUsers,#pendingUsers)
  end
  --vardump(msg)
  return msg
end

local function run(msg, matches)
	print(matches[1])
   if matches[1]=="set" and matches[2] ~= nil then
   	_config.proxyUsername=matches[2]
   	save_config()
   	return "I will proxy to @" .. matches[2] 
   else
   	resolve_username(_config.proxyUsername,  callbackres,{msg, matches[1]})
   	return nil
   end
   
   
end

return {
  description = "sends and receives from another user/bot",
  usage = "!p [whatever], !p set @[username],",
  patterns = {
     "^[/!#]p (set) @+(.+)$",
     "^[/!#]p +(.+)$"
     
  }, 
  run = run,
  pre_process = pre_process
}
