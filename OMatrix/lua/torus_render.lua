local sin, cos = math.sin, math.cos

local torusRadius = 50
local tubeRadius = 20
local numThetaSegments = 30
local numPhiSegments = 20

local BLACK = Color(0, 0, 0) -- background
local WHITE = Color(255, 255, 255) -- edges
local RED = Color(255, 0, 0) -- verts

SCREENWIDTH, SCREENHEIGHT = 800, 800

local mainScreen = vgui.Create("DFrame")
mainScreen:SetSize(SCREENWIDTH, SCREENHEIGHT)
mainScreen:Center()
mainScreen:SetTitle("3D Torus")
mainScreen:MakePopup()

local size = 5 -- simple 2D object scaling
local moveX = 400
local moveY = 400
local distance = 2

local function DrawPoint(x, y)
    surface.DrawCircle(x, y, 5, RED)
end

local function connect(i, j, tbl)
    surface.SetDrawColor(WHITE)
    surface.DrawLine(tbl[i][1], tbl[i][2], tbl[j][1], tbl[j][2])
end

mainScreen.Paint = function(self, w, h)
    local projectedPoints = {}
    draw.RoundedBox(0, 0, 0, w, h, BLACK)
    local IV = CurTime()

    for theta = 0, 2 * math.pi, 2 * math.pi / numThetaSegments do
        for phi = 0, 2 * math.pi, 2 * math.pi / numPhiSegments do

            local x = (torusRadius + tubeRadius * cos(phi)) * cos(theta)
            local y = (torusRadius + tubeRadius * cos(phi)) * sin(theta)
            local z = tubeRadius * sin(phi)

            local rotationMatrixX = OMatrix({{1, 0, 0}, {0, cos(IV), -sin(IV)}, {0, sin(IV), cos(IV)}})
            local rotationMatrixY = OMatrix({{cos(IV), 0, sin(IV)}, {0, 1, 0}, {-sin(IV), 0, cos(IV)}})
            local rotationMatrixZ = OMatrix({{cos(IV), -sin(IV), 0}, {sin(IV), cos(IV), 0}, {0, 0, 1}})

            local pointData = {x, y, z}
            local rotatedMatrix = OMatrix({pointData}):Mul(rotationMatrixY)
            rotatedMatrix = rotatedMatrix:Mul(rotationMatrixX)
            rotatedMatrix = rotatedMatrix:Mul(rotationMatrixZ)

            local z = 1 / (distance - rotatedMatrix:get(1, 3))
            local projectionMatrix = OMatrix({{1, 0, 0}, {0, 1, 0}, {0, 0, 0}})

            local projectedMatrix = rotatedMatrix:Mul(projectionMatrix)
            local x = projectedMatrix:get(1, 1) * size + moveX
            local y = projectedMatrix:get(1, 2) * size + moveY
            projectedPoints[#projectedPoints + 1] = {x, y}
            DrawPoint(x, y)

        end
    end

    -- Connect the points to form the torus
    for i = 1, numThetaSegments do
        for j = 1, numPhiSegments do
            local p1 = (i - 1) * numPhiSegments + j
            local p2 = i * numPhiSegments + j

            if j < numPhiSegments then
                connect(p1, p1 + 1, projectedPoints)
                connect(p1, p2, projectedPoints)
            else
                connect(p1, p1 - numPhiSegments + 1, projectedPoints)
                connect(p1, p2 - numPhiSegments, projectedPoints)
            end
        end
    end
end
