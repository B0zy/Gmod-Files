# Gmod Matrix Lib

## Install 

Tp install drag the lua folder into your ```GarrysMod/garrysmod ``` folder.

## Usage 

Here's a few examples 

- Multiplication of Matricies
```
local mtxObjA = OMatrix{{1,2,3},{4,5,6}}
local mtxObjB = OMatrix{{1,2,3},{4,5,6}}

local resultMatrix = mtxObjA:Mul(mtxObjB)

resultMatrix:printMatrix()
```

- Division of Matricies
```
local mtxObjA = MatrixFromTbl({1, 2, 3, 4, 5, 6}, 2, 3)
local mtxObjB = MatrixFromTbl({7, 8, 9, 10, 11, 12}, 2, 3)

local resultMatrix = matrix1:Div(mtxObjB)

resultMatrix:printMatrix()
```

- Inverse of a Matrix
```
local matrix = MatrixFromTbl({1, 2, 0, 0, 1, 2, 0, 0, 1}, 3, 3)

local inverseMatrix = matrix:Inverse()

inverseMatrix:printMatrix()
```

- Transpose Matrix 
```
local matrix = MatrixFromTbl({{1, 2, 3}, {4, 5, 6}})

local transposedMatrix = matrix:Transpose()

transposedMatrix:printMatrix()
```
Please note I have not tested the Inverse function as of 03/01/2024

This Library also include some more advanced Matrix equations like Dot product and Inverse. 