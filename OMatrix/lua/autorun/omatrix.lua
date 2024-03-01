--[[OMatrix:matrixToTbl(tbl, rows, cols)]]--
-- Example input table ({{1,2,3}, {4,5,6}, {7,8,9}}, 3, 3)
-- tbl output:
--[[
	1 2 3 - row1
	4 5 6 - row2
	7 8 9 - row3
--]]


OMatrix = {}

function OMatrix:new(tbl)
    local matrix = {}

    for _, v in pairs (tbl) do
        matrix[#matrix+1] = v
    end

    setmetatable(matrix, OMatrix)
end


function OMatrix:printMatrix()
    for i = 1, #self do
        local row = self[i]
        local rowString = "| "
        for j = 1, #row do
            rowString = rowString .. row[j] .. " "
        end
        print(rowString.."|")
    end
end

function OMatrix:get(row, col)
    return self[row][col]
end

function OMatrix:tostring()
	local str = ""
	for i = 1, #matrix do
		local row = matrix[i]
		for j = 1, #row do
			str = str .. row[j] .. " "
		end
	end
	return str
end


function MatrixFromTbl(tbl, rows, columns)
	local mtx = {}
    if (rows * columns) < #tbl then
        return
    end

    for i = 1, rows do
        mtx[i] = {}
        for j = 1, columns do
            mtx[i][j] = tbl[(i-1)*columns + j]
        end
    end

	return OMatrix:new(mtx)
end

--[[ OMatrix:matrixToTbl()]]--
-- Turns a Matrix into a normal table
function OMatrix:matrixToTbl()
    local tbl = {}
    for i = 1,#self do
        for j = 1,#self[i] do
            tbl[#tbl+1] = self[i][j]
        end
    end
    return tbl
end

--[[OMatrix:Add(m1)]]--
-- Adds two matrix tables toghether performing a matrix addition
function OMatrix:Add(m1)
    local matrix = {}
	for i = 1,#self do
		local m3i = {}
		matrix[i] = m3i
		for j = 1,#self[1] do
			m3i[j] = self[i][j] + m1[i][j]
		end
	end
	return self:new(matrix)
end

--[[OMatrix:Sub(m1)]]--
-- Subtracts two matrix tables toghether
function OMatrix:Sub(m1)
    local mtx = {}
	for i = 1,#self do
		local m3i = {}
		mtx[i] = m3i
		for j = 1,#self[1] do
			m3i[j] = self[i][j] - m1[i][j]
		end
	end
	return self:new(mtx)
end

--[[OMatrix:Mul(m1)]]--
-- Multiplys two matrix tables toghether
function OMatrix:Mul(m1)
    local mtx = {}
	for i = 1,#self do
		mtx[i] = {}
		for j = 1,#m1[1] do
			local num = self[i][1] * m1[1][j]
			for n = 2,#self[1] do
				num = num + self[i][n] * m1[n][j]
			end
			mtx[i][j] = num
		end
	end
	return self:new(mtx) -- return the table 
end

--[[OMatrix:Div(m1)]]--
-- Divides two matrix tables by each other.
function OMatrix:Div(m1)
    local num_rows = #self
    local num_cols = #self[1]
    if num_rows ~= #m1 or num_cols ~= #m1[1] then
        return
    end
    local result = {}
    for i = 1, num_rows do
        result[i] = {}
        for j = 1, num_cols do
            result[i][j] = self[i][j] / m1[i][j]
        end
    end
    return self:new(result)
end

--[[OMatrix:Transpose()]]--
function OMatrix:Transpose()
    local num_rows, num_cols = #self, #self[1]
    local transposedMatrix = {}

    for i = 1, num_cols do
        transposedMatrix[i] = {}
        for j = 1, num_rows do
            transposedMatrix[i][j] = self[j][i]
        end
    end

    return self:new(transposedMatrix)
end


--[[OMatrix:Inverse()]]--
-- Matrix inversion using Gaussian elimination
function OMatrix:Inverse()
    local num_rows, num_cols = #self, #self[1]

    if num_rows ~= num_cols then
        print("Error: Matrix must be square for inversion")
        return
    end

    -- Augment the matrix with the identity matrix
    local augmentedMatrix = {}
    for i = 1, num_rows do
        augmentedMatrix[i] = {}
        for j = 1, num_cols * 2 do
            augmentedMatrix[i][j] = j <= num_cols and self[i][j] or (i == j - num_cols and 1 or 0)
        end
    end

    -- Perform Gaussian elimination
    for i = 1, num_rows do
        -- Make the diagonal element 1
        local pivot = augmentedMatrix[i][i]
        for j = 1, num_cols * 2 do
            augmentedMatrix[i][j] = augmentedMatrix[i][j] / pivot
        end

        -- Make other elements in the column zero
        for k = 1, num_rows do
            if k ~= i then
                local factor = augmentedMatrix[k][i]
                for j = 1, num_cols * 2 do
                    augmentedMatrix[k][j] = augmentedMatrix[k][j] - factor * augmentedMatrix[i][j]
                end
            end
        end
    end

    -- Extract the inverse matrix
    local inverseMatrix = {}
    for i = 1, num_rows do
        inverseMatrix[i] = {}
        for j = num_cols + 1, num_cols * 2 do
            inverseMatrix[i][j - num_cols] = augmentedMatrix[i][j]
        end
    end

    return self:new(inverseMatrix)
end


setmetatable(OMatrix, {__call = OMatrix.new})
OMatrix.__index = OMatrix