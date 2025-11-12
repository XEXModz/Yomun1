local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()

-- adjust chunk size for server performance
local chunkSize = 128 * 1024  -- smaller than default to reduce distortion

local function playDFPWM(path)
    for chunk in io.lines(path, chunkSize) do
        local buffer = decoder(chunk)
        -- wait until the speaker can accept audio
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

-- Play your file in folder "1"
playDFPWM("1/YoungBoy.dfpwm")

