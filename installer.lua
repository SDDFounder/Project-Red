--/ Redhack Installer / Reactified /--
local repo = "https://raw.githubusercontent.com/SDDFounder/Project-Red/master/"
local themes = {
    Blue = "x-server-blue.sys",
    Red = "x-server-red.sys",
}
local files = {
    {"startup.lua","startup.lua"},
    {"config.sys","sys/config.sys"},
    {"edit.lua","bin/edit.lua"},
    {"connect.lua","bin/hack.lua"},
    {"sha256.lua","sys/apis/sha256.lua"},
}
local folders = {
    "log",
    "home",
    "bin/modules",
}

--/ Functions /--
local w,h = term.getSize()
local accent = colors.red
if not term.isColor() then
    accent = colors.black
end
local function drawTab(tab)
    term.setBackgroundColor(colors.gray)
    term.clear()
    term.setCursorPos(1,1)
    term.setBackgroundColor(accent)
    term.clearLine()
    term.setCursorPos(2,1)
    term.setTextColor(colors.white)
    term.write("Project Red Installer")
    term.setCursorPos(w-#tab,1)
    term.setTextColor(colors.lightGray)
    term.write(tab)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
end
function prompt(name,options,question)
    local cursor = 1
    while true do
        drawTab(name)
        term.setCursorPos(2,3)
        write(question)
        for i,v in pairs(options) do
            term.setCursorPos(2,4+i)
            if cursor == i then
                if colors[string.lower(v)] and term.isColor() then
                    term.setBackgroundColor(colors[string.lower(v)])
                else
                    term.setBackgroundColor(colors.black)
                end
                term.setTextColor(colors.white)
            else
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.lightGray)
            end
            write(" "..v.." ")   
        end
        local e,k = os.pullEvent("key")
        if k == keys.down then
            if cursor < #options then
                cursor = cursor + 1
            end
        elseif k == keys.enter then
            return cursor
        elseif k == keys.up then
            if cursor > 1 then
                cursor = cursor - 1
            end
        end
    end
end
local function getfile(gitfile,target)
    h = http.get(repo..gitfile)
    if h then
        local data = h.readAll()
        f = fs.open(target,"w")
        f.writeLine(data)
        f.close()
        h.close()
        return true
    else
        return false
    end
end

--/ Routine /--
local h = http.get(repo.."version.dat")
local version = 0
if h then
    version = tonumber(h.readAll()) or 0
    h.close()
end
drawTab("Init")
term.setCursorPos(2,3)
write("Welcome to Project Red")
term.setCursorPos(2,4)
term.setTextColor(colors.lightGray)
if version == 0 then
    write("! Repo disconnected")
elseif version >= 1 then
    write("Release v"..tostring(version))
else
    write("Alpha v"..tostring(version))
end
if fs.exists("/startup") or fs.exists("/startup.lua") then
    term.setCursorPos(2,9)
    if term.isColor() then term.setTextColor(colors.red) end
    write("! Current startup will be lost")
end
term.setCursorPos(2,6)
term.setTextColor(colors.white)
write("Would you like to install")
term.setCursorPos(2,7)
write("Project Red OS? y/n")
local evt,key = os.pullEvent("key")
if key ~= keys.y then
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.lightGray)
    write("Installation cancelled.")
    return
end
if version == 0 then
    drawTab("Warning")
    term.setCursorPos(2,3)
    write("The installer was unable to reach")
    term.setCursorPos(2,4)
    write("the OS repository to gather version")
    term.setCursorPos(2,5)
    write("data, continuing with the install may")
    term.setCursorPos(2,6)
    write("leave you with a damaged system!")
    term.setCursorPos(2,8)
    write("Continue anyway? y/n")
    local evt,key = os.pullEvent("key")
    if key ~= keys.y then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        term.setTextColor(colors.lightGray)
        write("Installation cancelled.")
        return
    end
end
local options = {}
for i,v in pairs(themes) do
    options[#options+1] = i
end
local theme = options[prompt("Theme",options,"Select a theme")]
if colors[string.lower(theme)] and term.isColor() then
    accent = colors[string.lower(theme)]
end
files[#files+1] = {themes[theme],"sys/x-server.sys"}
drawTab("Install")
term.setCursorPos(1,3)
for i,v in pairs(folders) do
    fs.makeDir(v)
end
for i,v in pairs(files) do
    term.setTextColor(accent)
    write(" "..v[1])
    term.setTextColor(colors.lightGray)
    write(" -> ")
    term.setTextColor(colors.white)
    write(v[2])
    term.setTextColor(colors.lightGray)
    write(".. ")
    local success = getfile(v[1],v[2])
    if not success then
        if term.isColor() then
            term.setTextColor(colors.red)
        else
            term.setTextColor(colors.lightGray)
        end
        print("Failed")
    else
        if term.isColor() then
            term.setTextColor(colors.lime)
        else
            term.setTextColor(colors.lightGray)
        end
        print("Done")
    end
    sleep(0.1)
end
local timer = os.startTimer(3)
while true do
    e,k = os.pullEvent()
    if e == "key" or e == "timer" and k == timer then
        break
    end
end
drawTab("Done")
term.setCursorPos(2,3)
write("Thank you for installing")
term.setCursorPos(2,4)
write("Project Red OS!")
for i=5,0,-1 do
    term.setCursorPos(2,6)
    write("Rebooting in "..tostring(i).." seconds.")
    sleep(1)
end
os.reboot()
