local Chunk = {}

local config = require("./Configuration")

local chunkContainer = Instance.new("Folder")
chunkContainer.Name = "Chunks"
chunkContainer.Parent = workspace

local chunks = {}
local amplitude = config.Amplitude
local frequency = config.Frequency
local blockSize = config.BlockSize
local chunkSize = config.ChunkSize
local chunkLength = config.BlockSize * config.ChunkSize

local function loadTree(blockContainer, blocks, position)
	local trunkHeight = math.random(2, 5)
	for i = 0, trunkHeight - 1 do
		local block = Instance.new("Part")
		block.Anchored = true
		block.AudioCanCollide = false
		block.CanQuery = false
		block.CanTouch = false
		block.EnableFluidForces = false
		block.Color = Color3.fromRGB(75, 50, 0)
		block.Material = Enum.Material.Wood
		block.Size = vector.create(blockSize, blockSize, blockSize)
		block.Position = position + block.Size / 2 + vector.create(0, (i + 1) * blockSize, 0)
		block.Parent = blockContainer
		
		table.insert(blocks, block)
	end

	local r = 2
	for dx = -r, r do
		for dy = -r + 1, r do
			for dz = -r, r do
				if dx*dx + dy*dy + dz*dz <= r*r then
					local block = Instance.new("Part")
					block.Anchored = true
					block.AudioCanCollide = false
					block.CanQuery = false
					block.CanTouch = false
					block.EnableFluidForces = false
					block.Color = Color3.fromRGB(0, 100, 0)
					block.Material = Enum.Material.LeafyGrass
					block.Size = vector.create(blockSize, blockSize, blockSize)
					block.Position = position + block.Size / 2 + vector.create(dx, (trunkHeight + 2) + dy, dz) * blockSize
					block.Parent = blockContainer

					table.insert(blocks, block)
				end
			end
		end
	end
end

function Chunk.loadChunk(self, chunk)
	local chunkPosition = chunk * chunkLength
	local chunkName = ("%d, %d, %d"):format(chunk.X, chunk.Y, chunk.Z)

	local blockContainer = Instance.new("Folder")
	blockContainer.Name = chunkName
	blockContainer.Parent = chunkContainer

	local blocks = table.create(chunkSize * chunkSize)
	chunks[chunkName] = blocks

	for x = 0, chunkSize - 1 do
		for z = 0, chunkSize - 1 do
			local y = math.noise((chunk.X * chunkSize + x) / frequency, (chunk.Z * chunkSize + z) / frequency) * amplitude // blockSize

			local position = chunkPosition + vector.create(x, y, z) * blockSize

			local block = Instance.new("Part")
			block.Anchored = true
			block.AudioCanCollide = false
			block.CanQuery = false
			block.CanTouch = false
			block.EnableFluidForces = false
			block.Color = Color3.fromRGB(0, 150, 0)
			block.Material = Enum.Material.Grass
			block.Size = vector.create(blockSize, blockSize, blockSize)
			block.Position = position + block.Size / 2
			block.Parent = blockContainer

			table.insert(blocks, block)
			
			if (math.random() < 0.001) then
				loadTree(blockContainer, blocks, position)
			end
			
			task.wait()
		end
	end
end

function Chunk.unloadChunk(self, chunk)
	local chunkName = ("%d, %d, %d"):format(chunk.X, chunk.Y, chunk.Z)
	
	local blocks = chunks[chunkName]
	if (not blocks) then return end
	
	local blockContainer = chunkContainer:FindFirstChild(chunkName)
	if (not blockContainer) then return end
	
	for _, block in blocks do
		block:Destroy()
		task.wait()
	end
	
	blockContainer:Destroy()
	chunks[chunkName] = nil
end

return Chunk