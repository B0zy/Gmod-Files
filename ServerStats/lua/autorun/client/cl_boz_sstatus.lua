BozStatFrame = nil
BozStatList = nil
BozServerStatus = "N/A"
BozServerStatusColor = white

local white = Color(255,255,255)
local red = Color(255,0,0)
local green = Color(0,255,0)

function BozOpenServerStatus()
    if BozStatFrame and IsValid(BozStatFrame) then return end
    net.Start("boz_serverstatus")
    net.SendToServer()
    --Main Window
    BozStatFrame = vgui.Create("DFrame")
    BozStatFrame:SetSize(700,400)
    BozStatFrame:SetTitle("Boz Serverstatus")
    BozStatFrame:Center()
    BozStatFrame:MakePopup()
    BozStatFrame:ShowCloseButton(false)
    BozStatFrame.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    local frameX, frameY = BozStatFrame:GetSize()
  
    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", BozStatFrame)
    CloseButton:SetText("X")
    CloseButton:SetPos(frameX-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(243, 45, 10))
    CloseButton.DoClick = function()
        BozStatFrame:Close()
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    
    local topPanel = vgui.Create("DPanel", BozStatFrame)
    topPanel:Dock(TOP)
    topPanel:SetHeight(140)
    function topPanel:Paint() end


    local statText = vgui.Create("DPanel", topPanel)
    statText:Dock(RIGHT)
    statText:SetWide(frameX)
    statText:SetText("")
    statText:SetPaintBackground(false)
    function statText:Paint(w,h)
        draw.DrawText(GetHostName(),"DermaLarge",10,10,white,TEXT_ALIGN_LEFT)
        draw.DrawText("Players: "..#player.GetAll(),"DermaLarge",10,50,white,TEXT_ALIGN_LEFT)
        draw.DrawText("Status: "..BozServerStatus,"DermaLarge",10,90,BozServerStatusColor,TEXT_ALIGN_LEFT)
    end
    
    BozStatList = vgui.Create("DListView", BozStatFrame)
    BozStatList:Dock(FILL)
    BozStatList:DockMargin(2,5,2,2)
    BozStatList:AddColumn("Name")
    BozStatList:AddColumn("Status")
    BozStatList:AddColumn("Value")
end

net.Receive("boz_serverstatus",function()
    local lenge = net.ReadInt(18)
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local tab = util.JSONToTable(jtext)
    
    BozServerStatus = "OK"
    BozServerStatusColor = green
    BozStatList:Clear()
    for k,v in pairs(tab) do
        if not v[1] then
            BozServerStatus = "WARNING"
            BozServerStatusColor = red
        end
        if BozStatList and IsValid(BozStatList) then
            BozStatList:AddLine(k,v[1] and "OK" or "WARNING",v[2])
        end
    end
end)

--Chatcommands
hook.Add("OnPlayerChat","boz_serverstatus_open",function(ply,text,team,dead)
    if(ply == LocalPlayer() and text == "!serverstatus")then
        BozOpenServerStatus()
    end
end)
concommand.Add("boz_serverstatus",BozOpenServerStatus)


--Statistics
BozStatCurFPS = -1
timer.Create("boz_serverstatus_fps",1,0,function()
    if system.HasFocus() then
        if (1/RealFrameTime()) > 0 then
            BozStatCurFPS = 1 / RealFrameTime()
        end
    end
end)
timer.Create("boz_serverstatus_send",60,0,function()
    net.Start("boz_serverstatus_fpssync")
        net.WriteInt(BozStatCurFPS,16)
    net.SendToServer()
end)

--Player connect times
hook.Add("InitPostEntity", "Boz_serverstatus_connecttime", function()
	net.Start("Boz_serverstatus_connecttime")
	net.SendToServer()
end)
