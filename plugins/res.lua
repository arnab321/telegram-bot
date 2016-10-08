local function callbackres(extra, success, result)
	local msg
	-- vardump(result)
	
	if result ~= false then
		msg=result.peer_type .. "#id" .. result.peer_id .. "\n\n".. result.print_name
	else
		msg="<code>lookup failed</code>"	
	end
	
	print(get_receiver(extra))
	send_msg(get_receiver(extra), msg , ok_cb, false)
	
end

local function run(msg, matches)

  local text = matches[1]
  resolve_username(matches[1],  callbackres,msg)

  return false
   
end

return {
  description = "Simplest plugin ever!",
  usage = "!res [username]",
  patterns = {
     "^[/!]res +@(.+)$"
  }, 
  run = run 
}
