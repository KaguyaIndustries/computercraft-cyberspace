-- Cyberspace.online program
-- by kaguya
-- site: https://catb.it

-- TODO Error Handling
-- TODO write .token function


local args = {...}
local baseUrl = "https://api.cyberspace.online"

debugMode = false
idToken = ""
refreshToken = ""
rtdbToken = ""

-- start of login function
function login()
  local url = baseUrl .. "/v1/auth/login"
  -- get infos
  term.clear()
  print("================")
  print("Cyberspace login")
  print("================")
  print("e-mail pls:")
  local rmail = read()
  print("password pls:")
  local rpassword = read("*")
  
  -- Crafting Request Body
  local creds = {
    email = rmail,
    password = rpassword
  }
  
  local rbody = textutils.serializeJSON(creds)

  local headers = {
    ["Content-Type"] = "application/json"
  }
  
  -- Sending http post
  local response, error = http.post(url, rbody, headers)

  if response then
  
  local rtext = response.readAll()
  response.close()
  
  local rdata = textutils.unserializeJSON(rtext)

if debugMode then
  print("token: " .. rdata.data.idToken)
  print("rtoken: " .. rdata.data.refreshToken)
  print("rtdbToken: " .. rdata.data.rtdbToken)
end

-- write .token file

local file = fs.open(".token", "w")
if file then
  file.write(rtext)
  file.close()
else
  print("cant open .token file lol")
end

else
  print("Login Error: " .. tostring(error))
end
end
-- end of login function

-- start of prepare function
function prepare()
  local file = fs.open(".token", "r")
  local fcontent = file.readAll()
  file.close()
  
  local fcjson = textutils.unserializeJSON(fcontent)
  
  idToken = fcjson.data.idToken
  refreshToken = fcjson.data.refreshToken
  rtdbToken = fcjson.data.rtdbToken
  if debugMode then
    print("that should work")
  --  print(idToken)
  end
end
-- end of prepare function

-- start of viewProfile
function viewProfile(username)
  local url = baseUrl .. "/v1/users/" .. username
  local header = {
    ["Authorization"] = "Bearer " .. idToken
  }
  
  local response, error = http.get(url, header)
  if response then
    local rtext = response.readAll()
    response.close()
    
    local rdata = textutils.unserializeJSON(rtext)
    
    print("Name: " .. rdata.data.username)
    print("Guild: " .. rdata.data.guildSlug)
    print("Following: " .. rdata.data.followingCount)
    print("Followers: " .. rdata.data.followersCount)
    print("Website: " .. rdata.data.websiteUrl)
    print("Website Name: " .. rdata.data.websiteName)
    print("-------------")
    print("Banned = " .. tostring(rdata.data.isBanned))
    print("Immortal = " .. tostring(rdata.data.isImmortal))
    print("Supporter = " .. tostring(rdata.data.isSupporter))
    print("Hacker = " .. tostring(rdata.data.isHacker))
    
    
  else
    print("viewProfile Error: " .. error)
  end  
end

-- end of viewProfile

-- start of refresh Function

function refresh()
    local url = baseUrl .. "/v1/auth/refresh"
    
    local header = {
    ["Content-Type"] = "application/json"
    }

    local rtokenbody = {
      refreshToken = refreshToken
    }

    local rbody = textutils.serializeJSON(rtokenbody)

    local response, error = http.post(url, rbody, headers)

    if response then
      local rtext = response.readAll()
      response.close()
    
      local rdata = textutils.unserializeJSON(rtext)

      idToken = rdata.data.idToken
      rtdbToken = rdata.data.rtdbToken

    else
      print("refresh error: " .. error)
    end


end

-- end of refresh Function

if args[1] == "zerofucksgiven" then
  debugMode = true
end

if not fs.exists(".token") then
  login()
else
  prepare()
  refresh()
  viewProfile("me")
end
