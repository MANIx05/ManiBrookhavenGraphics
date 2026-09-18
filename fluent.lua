--========================================================
-- 🎃 MANI PUMPKIN ROBO V.1
-- SMALL GUI / PC + MOBILE
--========================================================

repeat task.wait() until game:IsLoaded()

--========================================================
-- SERVICES
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local char = player.Character
	or player.CharacterAdded:Wait()

local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

--========================================================
-- CONFIG
--========================================================

local MAX_PROPS = 15

local MOVE_SPEED = 28
local TURN_SPEED = 7

local HEIGHT_MIN = 0.50
local HEIGHT_MAX = 2.00
local HEIGHT_STEP = 0.25

local ROBOT_RADIUS = 12

local heightScale = 1

--========================================================
-- PROP FOLDER
--========================================================

local propsFolder =
	workspace:FindFirstChild("WorkspaceCom")
	and workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")

--========================================================
-- STATE
--========================================================

local myProps = {}

local robotProps = {}

local robotActive = false

local robotAnchor = nil

local jumpRequested = false

local connections = {}

local oldCameraType
local oldCameraSubject
local oldWalkSpeed
local oldJumpPower
local oldAutoRotate

--========================================================
-- ROBOT ORDER
--========================================================

local PART_NAMES = {

	[1] = "HEAD",
	[2] = "WAIST",

	[3] = "RIGHT HAND",
	[4] = "LEFT HAND",

	[5] = "RIGHT LEG 1",
	[6] = "RIGHT LEG 2",
	[7] = "RIGHT LEG 3",

	[8] = "LEFT LEG 1",
	[9] = "LEFT LEG 2",
	[10] = "LEFT LEG 3",

	[11] = "EXTRA 1",
	[12] = "EXTRA 2",
	[13] = "EXTRA 3",
	[14] = "EXTRA 4",
	[15] = "EXTRA 5",
}

--========================================================
-- ROBOT POSITIONS
--========================================================

local OFFSETS = {

	[1] = Vector3.new(0, 5.5, 0),

	[2] = Vector3.new(0, 3.2, 0),

	[3] = Vector3.new(2.4, 3.5, 0),
	[4] = Vector3.new(-2.4, 3.5, 0),

	[5] = Vector3.new(1.2, 1.7, 0),
	[6] = Vector3.new(1.2, 0.4, 0),
	[7] = Vector3.new(1.2, -0.9, 0),

	[8] = Vector3.new(-1.2, 1.7, 0),
	[9] = Vector3.new(-1.2, 0.4, 0),
	[10] = Vector3.new(-1.2, -0.9, 0),

	[11] = Vector3.new(0, 4.2, 0.7),
	[12] = Vector3.new(0, 3.6, 0.8),
	[13] = Vector3.new(0, 2.8, 0.8),
	[14] = Vector3.new(0, 1.8, 0.7),
	[15] = Vector3.new(0, 0.8, 0.6),
}

--========================================================
-- GUI
--========================================================

local gui = Instance.new("ScreenGui")

gui.Name = "MANI_PUMPKIN_ROBO_V1"

gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

gui.Parent = player:WaitForChild("PlayerGui")

--========================================================
-- MAIN GUI
-- SMALL SIZE
--========================================================

local main = Instance.new("Frame")

main.Name = "Main"

main.Size = UDim2.fromOffset(220, 315)

main.Position = UDim2.new(
	0,
	15,
	0.5,
	-157
)

main.BackgroundColor3 =
	Color3.fromRGB(14, 14, 18)

main.BorderSizePixel = 0

main.Active = true

main.Parent = gui

local corner = Instance.new("UICorner", main)

corner.CornerRadius =
	UDim.new(0, 12)

local stroke = Instance.new("UIStroke", main)

stroke.Color =
	Color3.fromRGB(255, 140, 35)

stroke.Thickness = 1

stroke.Transparency = 0.35

--========================================================
-- TOP BAR
--========================================================

local top = Instance.new("Frame", main)

top.Size =
	UDim2.new(1, 0, 0, 36)

top.BackgroundColor3 =
	Color3.fromRGB(23, 23, 29)

top.BorderSizePixel = 0

top.Active = true

local topCorner = Instance.new("UICorner", top)

topCorner.CornerRadius =
	UDim.new(0, 12)

--========================================================
-- TITLE
--========================================================

local title = Instance.new("TextLabel", top)

title.Size =
	UDim2.new(1, -62, 1, 0)

title.Position =
	UDim2.fromOffset(10, 0)

title.BackgroundTransparency = 1

title.Text =
	"🎃 MANI PUMPKIN ROBO"

title.Font =
	Enum.Font.GothamBold

title.TextSize = 10

title.TextColor3 =
	Color3.fromRGB(255, 165, 65)

title.TextXAlignment =
	Enum.TextXAlignment.Left

--========================================================
-- MIN
--========================================================

local minimize = Instance.new("TextButton", top)

minimize.Size =
	UDim2.fromOffset(23, 23)

minimize.Position =
	UDim2.new(1, -52, 0, 6)

minimize.BackgroundColor3 =
	Color3.fromRGB(43, 43, 51)

minimize.Text = "—"

minimize.Font =
	Enum.Font.GothamBold

minimize.TextSize = 13

minimize.TextColor3 =
	Color3.fromRGB(220, 220, 225)

minimize.BorderSizePixel = 0

Instance.new(
	"UICorner",
	minimize
).CornerRadius =
	UDim.new(0, 6)

--========================================================
-- CLOSE
--========================================================

local close = Instance.new("TextButton", top)

close.Size =
	UDim2.fromOffset(23, 23)

close.Position =
	UDim2.new(1, -26, 0, 6)

close.BackgroundColor3 =
	Color3.fromRGB(60, 28, 32)

close.Text = "×"

close.Font =
	Enum.Font.GothamBold

close.TextSize = 14

close.TextColor3 =
	Color3.fromRGB(255, 120, 125)

close.BorderSizePixel = 0

Instance.new(
	"UICorner",
	close
).CornerRadius =
	UDim.new(0, 6)

--========================================================
-- DRAG
--========================================================

local dragging = false
local dragStart
local startPos

top.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		dragging = true

		dragStart = input.Position
		startPos = main.Position

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseMovement
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		local delta =
			input.Position - dragStart

		main.Position =
			UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)

	end

end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch then

		dragging = false

	end

end)

--========================================================
-- CONTENT
--========================================================

local content = Instance.new("Frame", main)

content.Size =
	UDim2.new(1, -14, 1, -43)

content.Position =
	UDim2.fromOffset(7, 40)

content.BackgroundTransparency = 1

--========================================================
-- STATUS
--========================================================

local status = Instance.new("TextLabel", content)

status.Size =
	UDim2.new(1, 0, 0, 24)

status.BackgroundColor3 =
	Color3.fromRGB(25, 27, 32)

status.Text =
	"● READY"

status.Font =
	Enum.Font.GothamBold

status.TextSize = 8

status.TextColor3 =
	Color3.fromRGB(120, 255, 165)

Instance.new(
	"UICorner",
	status
).CornerRadius =
	UDim.new(0, 7)

--========================================================
-- COUNT
--========================================================

local countLabel = Instance.new(
	"TextLabel",
	content
)

countLabel.Size =
	UDim2.new(1, 0, 0, 17)

countLabel.Position =
	UDim2.fromOffset(0, 27)

countLabel.BackgroundTransparency = 1

countLabel.Text =
	"PROPS 0 / 15"

countLabel.Font =
	Enum.Font.GothamBold

countLabel.TextSize = 8

countLabel.TextColor3 =
	Color3.fromRGB(145, 145, 155)

countLabel.TextXAlignment =
	Enum.TextXAlignment.Left

--========================================================
-- BUTTON FUNCTION
--========================================================

local function makeButton(
	text,
	y,
	bg,
	fg
)

	local b = Instance.new(
		"TextButton",
		content
	)

	b.Size =
		UDim2.new(1, 0, 0, 31)

	b.Position =
		UDim2.fromOffset(0, y)

	b.BackgroundColor3 = bg

	b.Text = text

	b.Font =
		Enum.Font.GothamBold

	b.TextSize = 8

	b.TextColor3 = fg

	b.BorderSizePixel = 0

	b.AutoButtonColor = false

	Instance.new(
		"UICorner",
		b
	).CornerRadius =
		UDim.new(0, 7)

	return b
end

--========================================================
-- BUTTONS
--========================================================

local scanButton =
	makeButton(
		"📦  RESCAN PROPS",
		47,
		Color3.fromRGB(27, 40, 58),
		Color3.fromRGB(130, 195, 255)
	)

local assembleButton =
	makeButton(
		"🤖  ASSEMBLE ROBOT",
		83,
		Color3.fromRGB(55, 39, 22),
		Color3.fromRGB(255, 190, 85)
	)

local controlButton =
	makeButton(
		"🎮  CONTROL ROBOT",
		119,
		Color3.fromRGB(24, 51, 36),
		Color3.fromRGB(125, 255, 170)
	)

local resetButton =
	makeButton(
		"♻  RESET PROPS",
		155,
		Color3.fromRGB(54, 28, 32),
		Color3.fromRGB(255, 135, 140)
	)

--========================================================
-- HEIGHT PANEL
--========================================================

local heightFrame =
	Instance.new("Frame", content)

heightFrame.Size =
	UDim2.new(1, 0, 0, 44)

heightFrame.Position =
	UDim2.fromOffset(0, 191)

heightFrame.BackgroundColor3 =
	Color3.fromRGB(23, 23, 29)

heightFrame.BorderSizePixel = 0

Instance.new(
	"UICorner",
	heightFrame
).CornerRadius =
	UDim.new(0, 7)

local heightText =
	Instance.new(
		"TextLabel",
		heightFrame
	)

heightText.Size =
	UDim2.new(
		1,
		-10,
		0,
		17
	)

heightText.Position =
	UDim2.fromOffset(5, 2)

heightText.BackgroundTransparency = 1

heightText.Text =
	"HEIGHT"

heightText.Font =
	Enum.Font.GothamBold

heightText.TextSize = 7

heightText.TextColor3 =
	Color3.fromRGB(255, 190, 95)

heightText.TextXAlignment =
	Enum.TextXAlignment.Left

--========================================================
-- MINUS
--========================================================

local minus =
	Instance.new(
		"TextButton",
		heightFrame
	)

minus.Size =
	UDim2.fromOffset(35, 21)

minus.Position =
	UDim2.fromOffset(5, 20)

minus.BackgroundColor3 =
	Color3.fromRGB(55, 28, 32)

minus.Text = "−"

minus.Font =
	Enum.Font.GothamBold

minus.TextSize = 13

minus.TextColor3 =
	Color3.fromRGB(255, 125, 130)

minus.BorderSizePixel = 0

Instance.new(
	"UICorner",
	minus
).CornerRadius =
	UDim.new(0, 5)

--========================================================
-- HEIGHT VALUE
--========================================================

local heightValue =
	Instance.new(
		"TextLabel",
		heightFrame
	)

heightValue.Size =
	UDim2.new(
		1,
		-90,
		0,
		21
	)

heightValue.Position =
	UDim2.fromOffset(45, 20)

heightValue.BackgroundColor3 =
	Color3.fromRGB(13, 13, 17)

heightValue.Text =
	"1.00x"

heightValue.Font =
	Enum.Font.GothamBold

heightValue.TextSize = 8

heightValue.TextColor3 =
	Color3.fromRGB(255, 215, 145)

Instance.new(
	"UICorner",
	heightValue
).CornerRadius =
	UDim.new(0, 5)

--========================================================
-- PLUS
--========================================================

local plus =
	Instance.new(
		"TextButton",
		heightFrame
	)

plus.Size =
	UDim2.fromOffset(35, 21)

plus.Position =
	UDim2.new(
		1,
		-40,
		0,
		20
	)

plus.BackgroundColor3 =
	Color3.fromRGB(24, 52, 36)

plus.Text = "+"

plus.Font =
	Enum.Font.GothamBold

plus.TextSize = 13

plus.TextColor3 =
	Color3.fromRGB(120, 255, 165)

plus.BorderSizePixel = 0

Instance.new(
	"UICorner",
	plus
).CornerRadius =
	UDim.new(0, 5)

--========================================================
-- PROP LIST
--========================================================

local propList =
	Instance.new(
		"ScrollingFrame",
		content
	)

propList.Size =
	UDim2.new(
		1,
		0,
		0,
		67
	)

propList.Position =
	UDim2.fromOffset(0, 240)

propList.BackgroundColor3 =
	Color3.fromRGB(18, 18, 23)

propList.BorderSizePixel = 0

propList.ScrollBarThickness = 2

propList.AutomaticCanvasSize =
	Enum.AutomaticSize.Y

propList.CanvasSize =
	UDim2.new()

Instance.new(
	"UICorner",
	propList
).CornerRadius =
	UDim.new(0, 7)

local listLayout =
	Instance.new(
		"UIListLayout",
		propList
	)

listLayout.Padding =
	UDim.new(0, 1)

listLayout.SortOrder =
	Enum.SortOrder.LayoutOrder

--========================================================
-- SCAN
--========================================================

local function scanProps()

	myProps = {}

	if not propsFolder then

		propsFolder =
			workspace:FindFirstChild(
				"WorkspaceCom"
			)
			and workspace.WorkspaceCom:
				FindFirstChild(
					"001_TrafficCones"
				)

	end

	if not propsFolder then

		status.Text =
			"● FOLDER NOT FOUND"

		status.TextColor3 =
			Color3.fromRGB(
				255,
				100,
				100
			)

		return

	end

	for _, v in pairs(
		propsFolder:GetChildren()
	) do

		if string.find(
			v.Name,
			player.Name
		) then

			table.insert(
				myProps,
				v
			)

		end

	end

	-- numeric order
	table.sort(
		myProps,
		function(a, b)

			local na =
				tonumber(
					string.match(
						a.Name,
						"%d+$"
					)
				) or 9999

			local nb =
				tonumber(
					string.match(
						b.Name,
						"%d+$"
					)
				) or 9999

			if na == nb then
				return a.Name < b.Name
			end

			return na < nb

		end
	)

	--====================================================
	-- LIST UPDATE
	--====================================================

	for _, child in pairs(
		propList:GetChildren()
	) do

		if child:IsA("TextLabel") then
			child:Destroy()
		end

	end

	for i, prop in ipairs(
		myProps
	) do

		if i > MAX_PROPS then
			break
		end

		local label =
			Instance.new(
				"TextLabel",
				propList
			)

		label.Size =
			UDim2.new(
				1,
				-4,
				0,
				15
			)

		label.BackgroundTransparency = 1

		label.Text =
			string.format(
				"%02d  %s",
				i,
				PART_NAMES[i]
					or "EXTRA"
			)

		label.Font =
			Enum.Font.GothamMedium

		label.TextSize = 7

		label.TextColor3 =
			Color3.fromRGB(
				185,
				185,
				195
			)

		label.TextXAlignment =
			Enum.TextXAlignment.Left

	end

	countLabel.Text =
		"PROPS "
		.. math.min(
			#myProps,
			MAX_PROPS
		)
		.. " / 15"

	if #myProps >= 15 then

		status.Text =
			"● 15 PROPS READY"

	else

		status.Text =
			"● "
			.. #myProps
			.. " PROPS FOUND"

	end

end

--========================================================
-- REMOTE MOVE
--========================================================

local function moveProp(
	prop,
	cframe
)

	if not prop
		or not prop.Parent then

		return

	end

	local remote =
		prop:FindFirstChild(
			"SetCurrentCFrame"
		)

	if remote
		and remote:IsA(
			"RemoteFunction"
		) then

		pcall(function()

			remote:InvokeServer(
				cframe
			)

		end)

	end

end

--========================================================
-- ASSEMBLE
--========================================================

local function assembleRobot()

	if robotActive then

		status.Text =
			"● STOP ROBOT FIRST"

		return

	end

	if #myProps == 0 then

		scanProps()

	end

	if #myProps == 0 then
		return
	end

	status.Text =
		"● ASSEMBLING..."

	status.TextColor3 =
		Color3.fromRGB(
			255,
			190,
			90
		)

	robotProps = {}

	local center =
		hrp.Position
		+ hrp.CFrame.LookVector
		* 8

	for i = 1,
		math.min(
			#myProps,
			MAX_PROPS
		) do

		local prop =
			myProps[i]

		local offset =
			OFFSETS[i]
			or Vector3.zero

		local finalOffset =
			Vector3.new(
				offset.X,
				offset.Y * heightScale,
				offset.Z
			)

		local target =
			CFrame.new(
				center + finalOffset
			)

		moveProp(
			prop,
			target
		)

		robotProps[i] =
			prop

		task.wait(0.12)

	end

	status.Text =
		"● ROBOT ASSEMBLED"

	status.TextColor3 =
		Color3.fromRGB(
			120,
			255,
			165
		)

end

--========================================================
-- CONTROL
--========================================================

local function stopRobot()

	if not robotActive then
		return
	end

	robotActive = false

	jumpRequested = false

	for _, connection in pairs(
		connections
	) do

		pcall(function()
			connection:Disconnect()
		end)

	end

	connections = {}

	if robotAnchor then

		robotAnchor:Destroy()

		robotAnchor = nil

	end

	hrp.Anchored = false

	humanoid.WalkSpeed =
		oldWalkSpeed or 16

	humanoid.JumpPower =
		oldJumpPower or 50

	humanoid.AutoRotate =
		oldAutoRotate

	local camera =
		workspace.CurrentCamera

	camera.CameraType =
		oldCameraType
		or Enum.CameraType.Custom

	camera.CameraSubject =
		oldCameraSubject
		or humanoid

	controlButton.Text =
		"🎮  CONTROL ROBOT"

	status.Text =
		"● CONTROL STOPPED"

end

local function startRobot()

	if #robotProps == 0 then

		status.Text =
			"● ASSEMBLE FIRST"

		return

	end

	--====================================================
	-- CENTER
	--====================================================

	local center =
		Vector3.zero

	local count = 0

	for _, prop in pairs(
		robotProps
	) do

		if prop
			and prop.Parent then

			center +=
				prop.Position

			count += 1

		end

	end

	if count == 0 then
		return
	end

	center /=
		count

	--====================================================
	-- SAVE
	--====================================================

	oldWalkSpeed =
		humanoid.WalkSpeed

	oldJumpPower =
		humanoid.JumpPower

	oldAutoRotate =
		humanoid.AutoRotate

	local camera =
		workspace.CurrentCamera

	oldCameraType =
		camera.CameraType

	oldCameraSubject =
		camera.CameraSubject

	--====================================================
	-- ROBOT ANCHOR
	--====================================================

	robotAnchor =
		Instance.new("Part")

	robotAnchor.Name =
		"MANI_ROBOT_ANCHOR"

	robotAnchor.Size =
		Vector3.new(1,1,1)

	robotAnchor.Transparency = 1

	robotAnchor.Anchored = true

	robotAnchor.CanCollide = false

	robotAnchor.CanTouch = false

	robotAnchor.CanQuery = false

	robotAnchor.CFrame =
		CFrame.new(center)

	robotAnchor.Parent =
		workspace

	--====================================================
	-- PLAYER
	--====================================================

	robotActive = true

	hrp.Anchored = true

	humanoid.AutoRotate = false

	--====================================================
	-- CAMERA
	--====================================================

	camera.CameraType =
		Enum.CameraType.Scriptable

	--====================================================
	-- MOVEMENT
	--====================================================

	table.insert(
		connections,

		RunService.Heartbeat:Connect(
			function(dt)

				if not robotActive then
					return
				end

				if not robotAnchor then
					return
				end

				--============================================
				-- DEFAULT ROBLOX JOYSTICK
				--============================================

				local move =
					humanoid.MoveDirection

				local moveVector =
					Vector3.new(
						move.X,
						0,
						move.Z
					)

				if moveVector.Magnitude
					> 0.05 then

					moveVector =
						moveVector.Unit

					local current =
						robotAnchor.CFrame

					local rotation =
						CFrame.lookAt(
							current.Position,
							current.Position
								+ moveVector
						)

					local smoothRotation =
						current:Lerp(
							rotation,
							math.clamp(
								TURN_SPEED * dt,
								0,
								1
							)
						)

					local position =
						current.Position
						+ moveVector
						* MOVE_SPEED
						* dt

					robotAnchor.CFrame =
						CFrame.new(
							position
						)
						* CFrame.fromMatrix(
							Vector3.zero,
							smoothRotation.RightVector,
							smoothRotation.UpVector
						)

				end

				--============================================
				-- JUMP
				--============================================

				if jumpRequested then

					jumpRequested = false

					local startCF =
						robotAnchor.CFrame

					local upCF =
						startCF
						+ Vector3.new(
							0,
							5,
							0
						)

					TweenService:Create(
						robotAnchor,
						TweenInfo.new(
							0.22,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						{
							CFrame = upCF
						}
					):Play()

					task.delay(
						0.22,
						function()

							if not robotActive then
								return
							end

							if not robotAnchor then
								return
							end

							TweenService:Create(
								robotAnchor,
								TweenInfo.new(
									0.28,
									Enum.EasingStyle.Quad,
									Enum.EasingDirection.In
								),
								{
									CFrame =
										startCF
								}
							):Play()

						end
					)

				end

				--============================================
				-- MOVE ALL PROPS
				--============================================

				for i, prop in ipairs(
					robotProps
				) do

					if prop
						and prop.Parent then

						local offset =
							OFFSETS[i]
							or Vector3.zero

						offset =
							Vector3.new(
								offset.X,
								offset.Y
									* heightScale,
								offset.Z
							)

						local target =
							robotAnchor.CFrame
							* CFrame.new(
								offset
							)

						-- EXACT PROP METHOD
						moveProp(
							prop,
							target
						)

					end

				end

			end
		)
	)

	--====================================================
	-- CAMERA LOOP
	--====================================================

	table.insert(
		connections,

		RunService.RenderStepped:Connect(
			function()

				if not robotActive then
					return
				end

				if not robotAnchor then
					return
				end

				local cf =
					robotAnchor.CFrame

				local camPos =
					cf.Position
					- cf.LookVector * 14
					+ Vector3.new(
						0,
						5,
						0
					)

				local lookPos =
					cf.Position
					+ Vector3.new(
						0,
						2.5,
						0
					)

				camera.CFrame =
					CFrame.lookAt(
						camPos,
						lookPos
					)

			end
		)
	)

	--====================================================
	-- DEFAULT JUMP BUTTON
	--====================================================

	table.insert(
		connections,

		UserInputService.JumpRequest:Connect(
			function()

				if robotActive then

					jumpRequested = true

				end

			end
		)
	)

	controlButton.Text =
		"🛑  STOP ROBOT"

	status.Text =
		"● ROBOT CONTROL ACTIVE"

	status.TextColor3 =
		Color3.fromRGB(
			120,
			255,
			165
		)

end

--========================================================
-- BUTTON EVENTS
--========================================================

scanButton.MouseButton1Click:Connect(
	function()

		scanProps()

	end
)

assembleButton.MouseButton1Click:Connect(
	function()

		assembleRobot()

	end
)

controlButton.MouseButton1Click:Connect(
	function()

		if robotActive then

			stopRobot()

		else

			startRobot()

		end

	end
)

--========================================================
-- RESET
--========================================================

resetButton.MouseButton1Click:Connect(
	function()

		if robotActive then
			stopRobot()
		end

		scanProps()

		local total =
			math.min(
				#myProps,
				MAX_PROPS
			)

		if total == 0 then
			return
		end

		local center =
			hrp.Position

		for i = 1, total do

			local prop =
				myProps[i]

			if prop
				and prop.Parent then

				local angle =
					(2 * math.pi / total)
					* i

				local pos =
					center
					+ Vector3.new(
						math.cos(angle)
							* ROBOT_RADIUS,
						0,
						math.sin(angle)
							* ROBOT_RADIUS
					)

				local cf =
					CFrame.new(
						pos,
						center
					)

				-- EXACT WORKING METHOD
				moveProp(
					prop,
					cf
				)

				task.wait(0.2)

			end

		end

		robotProps = {}

		status.Text =
			"● PROPS RESET"

	end
)

--========================================================
-- HEIGHT
--========================================================

local function updateHeight()

	heightValue.Text =
		string.format(
			"%.2fx",
			heightScale
		)

end

plus.MouseButton1Click:Connect(
	function()

		heightScale =
			math.min(
				HEIGHT_MAX,
				heightScale
					+ HEIGHT_STEP
			)

		updateHeight()

	end
)

minus.MouseButton1Click.Connect = nil

minus.MouseButton1Click:Connect(
	function()

		heightScale =
			math.max(
				HEIGHT_MIN,
				heightScale
					- HEIGHT_STEP
			)

		updateHeight()

	end
)

updateHeight()

--========================================================
-- MINIMIZE
--========================================================

local minimized = false

minimize.MouseButton1Click:Connect(
	function()

		minimized =
			not minimized

		content.Visible =
			not minimized

		if minimized then

			main.Size =
				UDim2.fromOffset(
					220,
					36
				)

			minimize.Text = "+"

		else

			main.Size =
				UDim2.fromOffset(
					220,
					315
				)

			minimize.Text = "—"

		end

	end
)

--========================================================
-- CLOSE
--========================================================

close.MouseButton1Click:Connect(
	function()

		if robotActive then
			stopRobot()
		end

		gui:Destroy()

	end
)

--========================================================
-- INITIAL SCAN
--========================================================

scanProps()

print(
	"🎃 MANI PUMPKIN ROBO V.1 LOADED"
)
