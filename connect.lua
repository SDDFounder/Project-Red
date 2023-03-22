local speaker = peripheral.find("speaker")

--/ Redhack Access Tool / Reactified /--
if not net then
    printError("Not running in Redhack environment.")
    speaker.playSound("ErrorR.dfpwm")
    return
end
if not net.ping then
    printError("System not online, reboot with modem.")
    speaker.playSound("ErrorR.dfpwm")
    return
end
if cfg.sec.ghost then
    printError("Can't hack while in ghost mode.")
    speaker.playSound("ErrorR.dfpwm")
    return
end
local args = {...}
if not args[1] then
    printError("Usage: connect <IP>")
    speaker.playSound("ErrorR.dfpwm")
    return
end
local label = net.ping(args[1])
if not label then
    printError("Invalid target.")
    speaker.playSound("ErrorR.dfpwm")
    return
end
local normal = term.getTextColor()
local fancy = ui.theme.txtAccent
term.setTextColor(fancy)
print("Target online")
term.setTextColor(normal)
sleep(0.5)
write("Probing... ")
sleep(0.5)
net.send(args[1],{packet = "probe"})
local ip,data = net.receive(1,args[1])
if not ip then
    printError("Failed.")
    speaker.playSound("ErrorR.dfpwm")
    return
end
term.setTextColor(fancy)
print("Done!")
sleep(0.1)
term.setTextColor(normal)
write("Name: ")
sleep(0.1)
term.setTextColor(fancy)
print(label)
sleep(0.1)
if not data.hash then
    printError("Target is in Ghost Mode")
    speaker.playSound("ErrorR.dfpwm")
    return
end
term.setTextColor(normal)
write("Level: ")
sleep(0.1)
term.setTextColor(fancy)
print(tostring(#data.hash))
term.setTextColor(normal)
write("Hash: ")
sleep(0.1)
term.setTextColor(fancy)
print(data.hash)
sleep(0.1)
print("E = exit")
print("A = auto solve")
print("M = manual solve")
local e,k = os.pullEvent("key")
sleep()
local solve = false
if k == keys.m then
    print("Manual Solving")
    print("'quit' to exit this mode'")
    term.setTextColor(normal)
    print("To manually solve a hash you")
    print("must find a value that when")
    print("hashed with SHA256, the first")
    term.setTextColor(fancy)
    write(tostring(#data.hash))
    term.setTextColor(normal)
    write(" chars are ")
    term.setTextColor(fancy)
    print(data.hash)
    term.setTextColor(normal)
    while true do
        print("Enter your attempt")
        write("> ")
        local entry = read()
        if entry == "quit" then return end
        local solved,attempt = net.verifyHash(entry,data.hash)
        if solved then
            term.setTextColor(fancy)
            print("!!! HASH ACCEPTED !!!")
            print(entry.." -> "..attempt)
            solve = entry
            break
        else
            print("Hash "..attempt.." Invalid")
        end
    end
elseif k == keys.a then
    print("Automatic Solving")
    term.setTextColor(normal)
    print("Please be patient, this")
    print("could take a long time...")
    sleep(2)
    local counter = 0
    while true do 
        local solved,attempt = net.verifyHash(tostring(counter),data.hash)
        if solved then 
            term.setTextColor(fancy)
            print("!!! HASH SOLVED !!!")
            print(tostring(counter).." -> "..attempt)
            solve = tostring(counter)
            break 
        else
            print(tostring(counter).." -> "..attempt)
        end
        counter = counter + 1
        sleep()
    end
else
    return
end
term.setTextColor(normal)
write("Validating.. ")
sleep(2)
net.send(args[1],{packet = "solve",solve=solve})
local ip,data = net.receive(1,args[1])
if not ip then
    printError("Failed.")
    speaker.playSound("ErrorR.dfpwm")
    return
end
if data.verified then
    term.setTextColor(fancy)
    print("Accepted!")
else
    printError("Denied.")
    speaker.playSound("ErrorR.dfpwm")
    return
end
print("Interactive Remote Lua")
term.setTextColor(normal)
print("'dc' to disconnect")
print("'return <cmd>' for output")
while true do
    term.setTextColor(fancy)
    write("> ")
    term.setTextColor(normal)
    local input = read()
    if input == "dc" then
        print("Disconnected")
        return
    end
    net.send(args[1],{packet = "remote",solve=solve,code=input})
    local ip,data = net.receive(5,args[1])
    if not ip then
        printError("Timed out.")
        speaker.playSound("ErrorR.dfpwm")
    else
        if data.result then
            term.setTextColor(fancy)
            print(data.result)
        end
    end
end
