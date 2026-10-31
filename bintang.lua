local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local args = {
    getgenv().DumpData = true,
    getgenv().DumpedScripts = {}
}

-- 1. Bypass fungsi loadstring asli
local oldLoadstring = loadstring or load

local function newLoadstring(source, chunkname)
    if type(source) == "string" and #source > 0 then
        print("[+] BYPASS: Nangkep script (" .. tostring(chunkname) .. ")")
        
        -- Simpen ke memory
        table.insert(getgenv().DumpedScripts, {
            name = chunkname or "unknown",
            code = source
        })
        
        -- Simpen ke file di workspace (kalau executor support writefile)
        pcall(function()
            if writefile then
                local filename = "Dump_" .. tick() .. ".lua"
                writefile(filename, source)
                print("[+] Tersimpan: " .. filename)
            end
        end)
    end
    
    -- Tetep jalanin script aslinya biar nggak crash
    return oldLoadstring(source, chunkname)
end

-- Pasang hook
getgenv().loadstring = newLoadstring

-- 2. Bypass fungsi load (biasanya Luarmor pake ini buat VM-nya)
local oldLoad = load
local function newLoad(chunk, chunkname, mode, env)
    if type(chunk) == "string" and #chunk > 0 then
        print("[+] BYPASS (load): Nangkep script!")
        table.insert(getgenv().DumpedScripts, {
            name = chunkname or "load",
            code = chunk
        })
        pcall(function()
            if writefile then
                writefile("Dump_Load_" .. tick() .. ".lua", chunk)
            end
        end)
    end
    return oldLoad(chunk, chunkname, mode, env)
end

getgenv().load = newLoad

-- 3. Logika eksekusi script lo (yang lo kirim tadi)
local function runScript()
    local placeId = 93978595733734
    local url = "https://api.luarmor.net/files/v4/loaders/82419a6df8b5b0d7c91a6affe9f3fb04.lua"

    if game.PlaceId ~= placeId then
        return warn("Akses Ditolak: Kamu bukan di Violence Discrtic!")
    end

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or not response then
        return warn("Gagal Execute Script. Cek koneksi lu!")
    end

    -- Disini script Luarmor mulai jalan, dan hook kita bakal nangkep payload aslinya
    local func, loadError = loadstring(response)
    if not func then
        return warn("Gagal compile: " .. tostring(loadError))
    end

    local execSuccess, execError = pcall(func)
    if not execSuccess then
        warn("Script error: " .. tostring(execError))
    end
end

runScript()
