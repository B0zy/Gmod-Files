util.AddNetworkString("boz_serverstatus")
util.AddNetworkString("boz_serverstatus_fpssync")
util.AddNetworkString("boz_serverstatus_connecttime")

BOZ_SERVERCHECKS = {
    ["Entity Count"] = {
        function()
            return (#ents.GetAll() <= 6000), #ents.GetAll().." / 8176"
        end
    },
    ["Server Uptime"] = {
        function()
            return (CurTime() < 86400), "Current uptime: "..(CurTime()/60).."min"
        end
    },
    ["Current Tickrate"] = {
        function()
            local shouldtick = math.floor(1/engine.TickInterval())
            local tickrate = math.floor(BozCurTickrate)+1
            return (tickrate >= shouldtick), tickrate.." / "..shouldtick
        end
    },
    ["Player FPS"] = {
        function()
            local all = 100
            local count = 1
            for k,v in pairs(BozPlayerStats) do
                all = all + v.fps
                count = count + 1
            end
            local avg = math.Round(all/count)
            if avg == 0 then
                return true, "Average N/A"
            end
            return (avg >= 100), "Average "..avg
        end
    },
    ["Player Ping"] = {
        function()
            local all = 100
            local count = 1
            for k,v in pairs(BozPlayerStats) do
                count = count + 1
                all = all + v.ping
            end
            local avg = math.Round(all/count)
            return (avg <= 100), "Average "..avg
        end
    },
    ["Player Connect time"] = {
        function()
            local count = 0
            local all = 0
            for k,v in pairs(BozConnectTimes) do
                count = count + 1
                all = all + v
            end
            if all == 0 then return true, "Average N/A" end
            local avg = math.Round(all/count)
            return (avg < 300), "Average "..avg
        end
    },
    ["Players cancel join"] = {
        function()
            local connected = table.Count(BozConnectTimes)
            local canceled = table.Count(BozCanceledConnects)
            return (canceled <= connected), "Canceled/Connected: "..canceled.." / "..connected
        end
    },
}


net.Receive("boz_serverstatus",function(len,ply)
    if not ply:IsAdmin() then return end
    local checktable = util.Compress(util.TableToJSON(BozDoServerChecks()))
    net.Start("boz_serverstatus")
        net.WriteInt(#checktable,18)
        net.WriteData(checktable,#checktable)
    net.Send(ply)
end)

function BozDoServerChecks()
    local returnTable = {}
    for k,v in pairs(BOZ_SERVERCHECKS) do
        returnTable[k] = {v[1]()}
    end
    return returnTable
end
concommand.Add("boz_serverstatus",function()
    PrintTable(BozDoServerChecks())
end)

--Tickrates
local lasttick = SysTime()
BozsCurTickrate = 0
local ticktimes = 0
local tickcount = 0
hook.Add("Tick", "boz_serverstatus_tickratecheck", function()
    tickcount = tickcount + 1
    ticktimes = ticktimes + SysTime() - lasttick
    lasttick = SysTime()
    if tickcount >= 100 then
        BozCurTickrate = 1/(ticktimes/tickcount)
        tickcount = 0
        ticktimes = 0
    end
end)

--Player stats (FPS/Ping)
BozPlayerStats = {}
net.Receive("boz_serverstatus_fpssync",function(len,ply)
    BozPlayerStats[ply:SteamID()] = {
        ["fps"] = net.ReadInt(16),
        ["ping"] = ply:Ping(),
        ["packetloss"] = ply:PacketLoss(),
    }
end)
hook.Add("PlayerDisconnected","boz_serverstatus",function(ply)
    BozPlayerStats[ply:SteamID()] = nil
end)

--Player connect times
BozConnectPlayer = {}
BozConnectTimes = {}
BozCanceledConnects = {}
gameevent.Listen("player_connect")
hook.Add("player_connect", "boz_serverstatus", function(data)
	BozConnectPlayer[data.networkid] = CurTime()
end)
net.Receive("boz_serverstatus_connecttime",function(len,ply)
    local sid = ply:SteamID()
    if BozConnectPlayer[sid] then
        BozConnectTimes[sid] = CurTime() - BozConnectPlayer[sid]
        BozConnectPlayer[sid] = nil
    end
end)
hook.Add("PlayerDisconnected","boz_serverstatus_cancel",function(ply)
    local sid = ply:SteamID()
    if BozConnectPlayer[sid] then
        BozCanceledConnects[sid] = CurTime() - BozConnectPlayer[sid]
        BozConnectPlayer[sid] = nil
    end
end)
