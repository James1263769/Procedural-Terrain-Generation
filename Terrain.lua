local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local config = require("./Configuration")
local chunk = require("./Chunk")

local client = Players.LocalPlayer
local terrain = workspace.Terrain

local currentChunk = vector.zero
local chunkLength = config.BlockSize * config.ChunkSize

local chunkWireFrame = Instance.new("WireframeHandleAdornment")
chunkWireFrame.Adornee = terrain
chunkWireFrame.AdornCullingMode = Enum.AdornCullingMode.Never
chunkWireFrame.Color3 = Color3.fromRGB(0, 0, 255)
chunkWireFrame.Parent = terrain

for i = 0, chunkLength, config.BlockSize do
	chunkWireFrame:AddLine(vector.create(0, 0, i), vector.create(chunkLength, 0, i))
	chunkWireFrame:AddLine(vector.create(i, 0, 0), vector.create(i, 0, chunkLength))

	chunkWireFrame:AddLine(vector.create(0, chunkLength, i), vector.create(chunkLength, chunkLength, i))
	chunkWireFrame:AddLine(vector.create(i, chunkLength, 0), vector.create(i, chunkLength, chunkLength))

	chunkWireFrame:AddLine(vector.create(i, 0, 0), vector.create(i, chunkLength, 0))
	chunkWireFrame:AddLine(vector.create(i, 0, chunkLength), vector.create(i, chunkLength, chunkLength))

	chunkWireFrame:AddLine(vector.create(0, i, 0), vector.create(chunkLength, i, 0))
	chunkWireFrame:AddLine(vector.create(0, i, chunkLength), vector.create(chunkLength, i, chunkLength))

	chunkWireFrame:AddLine(vector.create(0, 0, i), vector.create(0, chunkLength, i))
	chunkWireFrame:AddLine(vector.create(chunkLength, 0, i), vector.create(chunkLength, chunkLength, i))

	chunkWireFrame:AddLine(vector.create(0, i, 0), vector.create(0, i, chunkLength))
	chunkWireFrame:AddLine(vector.create(chunkLength, i, 0), vector.create(chunkLength, i, chunkLength))
end

local function updateTerrain(deltaTime)
	debug.profilebegin("Terrain")

	local character = client.Character
	if (not character) then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if (not rootPart) then return end

	local renderDistance = config.RenderDistance

	local chunkPosition = rootPart.Position // chunkLength
	local chunkX = chunkPosition.X
	local chunkZ = chunkPosition.Z

	local chunkXDifference = chunkX - currentChunk.X
	local chunkZDifference = chunkZ - currentChunk.Z

	if (chunkXDifference ~= 0) then
		local chunkX = chunkX + renderDistance * chunkXDifference
		for z = -renderDistance, renderDistance do
			local chunkPosition = vector.create(chunkX, 0, chunkZ + z)
			task.spawn(chunk.loadChunk, chunk, chunkPosition)
		end

		local chunkX = currentChunk.X - renderDistance * chunkXDifference
		for z = -renderDistance, renderDistance do
			local chunkPosition = vector.create(chunkX, 0, chunkZ + z)
			task.spawn(chunk.unloadChunk, chunk, chunkPosition)
		end
	end

	if (chunkZDifference ~= 0) then
		local chunkZ = chunkZ + renderDistance * chunkZDifference
		for x = -renderDistance, renderDistance do
			local chunkPosition = vector.create(chunkX + x, 0, chunkZ)
			task.spawn(chunk.loadChunk, chunk, chunkPosition)
		end

		local chunkZ = currentChunk.Z - renderDistance * chunkZDifference
		for x = -renderDistance, renderDistance do
			local chunkPosition = vector.create(chunkX + x, 0, chunkZ)
			task.spawn(chunk.unloadChunk, chunk, chunkPosition)
		end
	end

	if (chunkPosition ~= currentChunk) then
		chunkWireFrame.CFrame = CFrame.new(chunkPosition * chunkLength)

		currentChunk = chunkPosition
	end

	debug.profileend()
end

local renderDistance = config.RenderDistance
for x = -renderDistance, renderDistance do
	for z = -renderDistance, renderDistance do
		local chunkPosition = vector.create(x, 0, z)
		task.spawn(chunk.loadChunk, chunk, chunkPosition)
	end
end

RunService.PostSimulation:Connect(updateTerrain)