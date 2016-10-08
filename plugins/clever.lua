do

function run(msg, matches)
 local text = matches[1] --msg.text
 local url = "https://brawlbot.tk/apis/chatter-bot-api/cleverbot.php?text="..URL.escape(text) --- replace with your url
 local query = https.request(url)
 print(query)
 if query == nil then return 'An error happened :(' end
 local decode = json:decode(query)
 return decode.clever
end


return {
  description = "chat with cleverbot!", 
  usage = "!clever [text]: chat with cleverbot",
  patterns = {
    "^!clever (.*)$"
 },
 run = run
}

end