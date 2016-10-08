local https = require("ssl.https")
local ltn12 = require "ltn12"

local mashape = load_from_file('data/mashape.lua', {
   })

local function request(text)
   local api_key = mashape.api_key
   if api_key:isempty() then
      return nil, 'Configure your Mashape API Key'
   end

   local url = "https://shl-mp.p.mashape.com/webresources/jammin/emotionV2"
   local payload = "lang=en&text=" .. text
   --[[ {"lang":"en","text":text} ]]
   local respbody = {}
   local headers = {
      ["X-Mashape-Key"] = api_key,
      ["Accept"] = "application/json",
      ['Content-Type'] = 'application/x-www-form-urlencoded', 
      ["Content-Length"] = payload:len(),
   }

   
   local body, code = https.request{
      url = url,
      method = "POST",
      headers = headers,
      source = ltn12.source.string(payload),
      sink = ltn12.sink.table(respbody),
      protocol = "tlsv1"
   }
   if code ~= 200 then return "", code end
   local body = json:decode(table.concat(respbody))
   return body, code
end

local function parseData(data,msg)
	local str
	local ambiguous= data.ambiguous == 'yes'

	str="<code>"..msg.from.first_name.."</code> is "

	if (data.bullying == "yes") then
		str=str .."a <code>bully</code>. \n\nSigns of "
	else
		str=str .."in "
   	end
   	
   	if (ambiguous==true) then
   		str = str .. "either "
   	end
   	
   	for i=1, #data.groups  do
   		
   		str= str.. "<code>"..data.groups[i].name.."</code> ("
   		for j=1, #data.groups[i].emotions do
   			str = str .. data.groups[i].emotions[j]
   			if (j ~= #data.groups[i].emotions) then
   				str = str .. ", "
   			end
   		end

   		str=str .. ") "
   		if (ambiguous==true and i ~= #data.groups) then
   			str = str .. " \t or \t"
   		elseif (ambiguous==false and i ~= #data.groups) then
   			str = str .. " as well as "
   		end
   	end
	return str
end


local function mood(msg,text)
   --vardump(text[1])
   if (string.len(text)<5) then
   		return "That text was so short :/"
   end
   local data, code = request(text)
   if code ~= 200 then return "There was an error. "..code end
   vardump(data)

   return parseData(data,msg)
end

local function pre_process(msg)
  -- Ignore service msg
  if msg.service then
    return msg
  end
  
  local resp
  local rnd=math.random(1,15)

  if (
  --	msg.to.type == 'channel' and 
  	string.match(msg.from.username,nocase("bot$")) == nil and 
  	(msg.to.id == '1049517247' or -- wormhole group
  	msg.to.username == 'dangou' or
  	msg.from.username == 'tomokochan') and
  	string.match(msg.text,"^[!/#]") == nil and 
  	rnd==3
  	) then
    	resp=mood(msg,msg.text)
    	print(resp)
    	--send_msg(msg.from.peer_type.."#"..msg.from.id, resp , ok_cb, false)
    	reply_msg(msg.id, resp , ok_cb, false)
  end

  --print (rnd)
  --vardump(msg)

  return msg
end


local function run(msg, matches)
   --return request('http://www.uni-regensburg.de/Fakultaeten/phil_Fak_II/Psychologie/Psy_II/beautycheck/english/durchschnittsgesichter/m(01-32)_gr.jpg')
 	return mood(msg,matches[1])
   --return data
end

return {
   description = "detect emotions",
   usage = {
      "[!/#]mood [text]"   },
   patterns = {
      "^[!/#]mood (.*)$"
   },
   run = run,
   -- pre_process=pre_process
}
