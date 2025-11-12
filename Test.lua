local speaker = peripheral.find("speaker")

local t, dt = 0, 2 * math.pi * 220 / 48000
while true do
    local buffer = {}
    for i = 1, 16 * 1024 * 8 do
        buffer[i] = math.floor(math.sin(t) * 127)
        t = (t + dt) % (math.pi * 2)
    end

    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end
