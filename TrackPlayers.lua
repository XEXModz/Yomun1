trackMonID = "monitor"
radMonID = "top"

stationX = 0
stationZ = 0
scale = 50


testContact = {
    ["x"] = -100,
    ["z"] = 30,
    ["id"] = "Unknown",
    ["icon"] = "?",
    ["lastSeen"] = 0,
    ["type"] = "MCWS"
}

contact = {testContact}

permContacts = {
    testContact
}

pd = peripheral.find("playerDetector")
mon = peripheral.wrap(radMonID)
mon.setTextScale(0.5)
trackMon = peripheral.wrap(trackMonID)
mon.setTextScale(0.5)

sizeX, sizeY = mon.getSize()
cx = sizeX/2
cy = sizeY/2

table.insert(contact,testContact)

function systemCheck()
    contact[1].x = math.random(-300,500)
    contact[1].z = math.random(-500,500)
end

function writeRednetContact()
    while true do
        inMsg = rednet.receive("redar_track")
        packet = textutils.unserializeJSON(inMsg)
        if packet then
            if packet.type == "telData" then
                newCon = {
                    ["x"] = packet.x,
                    ["z"] = packet.z,
                    ["id"] = packet.id,
                    ["icon"] = string.sub(packet.id,1,1),
                    ["type"] = "REDAR"
                }
                table.insert(contact,newCon)
            end
        end
        sleep(0.5)
    end
end

function writeMCWSContacts()
    while true do
        inMsg = ws.receive()
        packet = textutils.unserializeJSON(inMsg)
        if packet then
            if packet.type == "telData" then
                newCon = {
                    ["x"] = packet.x,
                    ["z"] = packet.z,
                    ["id"] = packet.id,
                    ["icon"] = string.sub(packet.id,1,1),
                    ["type"] = "MCWS"
                }
                table.insert(contact,newCon)
            end
        end
        sleep(0.5)
    end
end

trackOffset = 0

function drawContacts()

    for _,radCon in pairs(contact) do
        local screenX = (((stationX-radCon.x))/scale)*-1
        local screenY = (((stationZ-radCon.z))/scale)*-1
        local distanceCalc = math.sqrt(math.pow(radCon.x-stationX,2) - math.pow(radCon.z-stationZ,2))
        if radCon.type == "player" then
            term.setCursorPos(cx+screenX, cy+screenY)
            term.blit(radCon.icon, "0", "e")
        end
        if radCon.type == "MCWS" then
            term.setCursorPos(cx+screenX, cy+screenY)
            term.blit(radCon.icon, "0", "1")
        end
        term.setBackgroundColor(colors.black)
        term.setCursorPos(cx+screenX,cy+screenY-1)
        term.write("ID: "..radCon.id)
        term.setCursorPos(cx+screenX,cy+screenY-2)
        term.write("["..tostring("X:"..radCon.x).."|"..tostring("Z:"..radCon.z).."]")
    end
end

function drawContactArray()
    for _, radCon in pairs(contact) do
        local distanceCalc = math.sqrt(math.pow(radCon.x-stationX,2) - math.pow(radCon.z-stationZ,2))
        trackMon.setCursorPos(1,trackOffset)
        trackMon.write("["..radCon.icon.."]".." ID: "..radCon.id)
        trackMon.setCursorPos(1,trackOffset+1)
        trackMon.write("["..tostring("X:"..radCon.x).."|"..tostring("Z:"..radCon.z).."]")
        trackMon.setCursorPos(1,trackOffset+2)
        trackMon.write("RNG: "..tostring(math.ceil(distanceCalc)).."m")
        trackOffset = trackOffset + 4
    end
end

function drawCircle(x, y, r)
    prevX = x
    prevY = y
    drawContacts()
    for i = 0,360, 1 do
        drawContacts()
        angle = i;
        x1 = r * math.cos(angle * math.pi / 180)
        y1 = r * math.sin(angle * math.pi / 180)
        term.setCursorPos(x + x1, y + y1)
        paintutils.drawLine(x,y,x+x1,y+y1,colors.lime)
        drawContacts()
        prevX = x1
        prevY = y1
        sleep(0.000001)
        paintutils.drawLine(x,y,x+prevX,y+prevY,colors.black)
        drawContacts()
        if i == 270 then
            term.clear()
            contact = permContacts
        end
        
    end
end

function listenKeyboard()
    while true do
        event, key, held = os.pullEvent("key")
        if key == keys.equals then
            scale = scale + 50
            if scale < 0 then
                scale = 1
            end
            sleep(0.1)
            mon.setBackgroundColor(colors.black)
            mon.clear()
        end
        if key == keys.minus then
            scale = scale - 50
            if scale < 0 then
                scale = 1
            end
            sleep(0.1)
            mon.setBackgroundColor(colors.black)
            mon.clear()
        end
        if key == keys.up then
            scale = scale + 1
            if scale < 0 then
                scale = 1
            end
            sleep(0.1)
            mon.setBackgroundColor(colors.black)
            mon.clear()
        end
        if key == keys.down then
            scale = scale - 1
            if scale < 0 then
                scale = 1
            end
            sleep(0.1)
            mon.setBackgroundColor(colors.black)
            mon.clear()
        end

    end
end

function radar()
    term.redirect(mon)
    controlTerm = term.native()
    controlTerm.setBackgroundColor(colors.black)
    controlTerm.clear()
    while true do
        drawCircle(cx,cy,100)
    end
end

function updateContact()
    while true do
        sleep(1)
        trackOffset = 1
       -- trackMon.clear()
      --  trackMon.setCursorPos(1,1)
        contact = {}
       -- writePlayerContacts()
        --drawContactArray()
    end
end

function controlPanel()
    controlTerm = term.native()
    while true do
        controlTerm.setCursorPos(1,1)
        controlTerm.clear()
        controlTerm.write("Rednet Distance and Ranging | REDAR")
        controlTerm.setCursorPos(1,3)
        controlTerm.write("+ / - | +50 / -50 Scale")
        controlTerm.setCursorPos(1,4)
        controlTerm.write("Up / Down | +1 / -1 Scale")
        controlTerm.setCursorPos(1,6)
        controlTerm.write("Current Scale: "..tostring(scale).." Meters per pixel")
        sleep(0.25)
    end
end


systemCheck()
parallel.waitForAll(listenKeyboard,radar,controlPanel,writeMCWSContacts)
