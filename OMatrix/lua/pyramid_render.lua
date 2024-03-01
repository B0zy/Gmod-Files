local sin, cos = math.sin, math.cos

local pyramid = {
    {0, 0, -1},
    {1, 0, 1},
    {-1, 0, 1},
    {0, 1, 0},
}

local BLACK = Color(0, 0, 0) -- background
local WHITE = Color(255, 255, 255) -- edges
local RED = Color(255, 0, 0) -- verts

SCREENWIDTH, SCREENHEIGHT = 600, 600

local mainScreen = vgui.Create("DFrame")
mainScreen:SetSize(SCREENWIDTH, SCREENHEIGHT)
mainScreen:Center()
mainScreen:SetTitle("3D Pyramid")
mainScreen:MakePopup()

local size = 100 -- simple 2D object scaling
local moveX = 300
local moveY = 300
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

    for i = 1, #pyramid do

        local rotationMatrixX = OMatrix({{1, 0, 0}, {0, cos(IV), -sin(IV)}, {0, sin(IV), cos(IV)}})
        local rotationMatrixY = OMatrix({{cos(IV), 0, sin(IV)}, {0,1,0}, {-sin(IV), 0, cos(IV)}})
        local rotationMatrixZ = OMatrix({{cos(IV), -sin(IV), 0}, {sin(IV), cos(IV), 0}, {0,0,1}})

        local pointData = pyramid[i]
        local rotatedMatrix = OMatrix({pointData}):Mul(rotationMatrixY)
        rotatedMatrix = rotatedMatrix:Mul(rotationMatrixX)
        rotatedMatrix = rotatedMatrix:Mul(rotationMatrixZ)

        local z = 1/(distance - rotatedMatrix:get(1,3))
        local projectionMatrix = OMatrix({{1,0,0}, {0,1,0}, {0,0,0}})

        local projectedMatrix = rotatedMatrix:Mul(projectionMatrix)
        local x = projectedMatrix:get(1,1) * size + moveX
        local y = projectedMatrix:get(1,2) * size + moveY
        projectedPoints[i] = {x, y}
        DrawPoint(x, y)

    end

    connect(1, 2, projectedPoints)
    connect(2, 3, projectedPoints)
    connect(3, 1, projectedPoints)

    connect(1, 4, projectedPoints)
    connect(2, 4, projectedPoints)
    connect(3, 4, projectedPoints)
    
end
