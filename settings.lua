local settings = {}
local json = require("json")
local crypto = require("crypto")
local mime = require("mime")
local hashKey = nil
local defaults = {}

local setDefaults, reset, save, load
----------------------------------------
-- DEFINE DEFAULT SETTINGS
----------------------------------------
function setDefaults()
	local function updateTable(source, destination)
		for k, v in pairs(source) do
			if type(v) == "table" then
				destination[k] = destination[k] or {}
				updateTable(v, destination[k])
			else
				destination[k] = destination[k] or v
			end
		end
	end
	updateTable(defaults, settings)
	save()
end

----------------------------------------
-- RESET TO DEFAULT SETTINGS
----------------------------------------
function reset()
	print("Resetting to default settings...")
	for k,v in pairs(settings) do
		if type(v) ~= "function" then
			settings[k] = nil
		end
	end
	setDefaults(defaults)
end

----------------------------------------
-- SAVE SETTINGS
----------------------------------------
function save()
	print("Saving Settings...")
	local tempTable = {}
	for k,v in pairs(settings) do
		if type(v) ~= "function" then
			tempTable[k] = v
		end
	end

	local p1 = system.pathForFile("settings.data", system.DocumentsDirectory)
	local p2 = system.pathForFile("_settings.data", system.DocumentsDirectory)
	local settingsJSON = json.encode(tempTable)
	settingsJSON = mime.b64(settingsJSON)
	local settingsHash = crypto.hmac(crypto.sha512, settingsJSON, hashKey)
	local settingsFile = io.open(p1, "w")
	settingsFile:write(settingsJSON)
	io.close(settingsFile)
	local settingsHashFile = io.open(p2, "w")
	settingsHashFile:write(settingsHash)
	io.close(settingsHashFile)
	tempTable = nil
	if system.getInfo("platformName") == "iPhone OS" then
		local results, errStr = native.setSync("settings.json", {iCloudBackup = false})
	end
end

----------------------------------------
-- LOAD SETTINGS
----------------------------------------
function load()
	local p1 = system.pathForFile("settings.data", system.DocumentsDirectory)
	local p2 = system.pathForFile("_settings.data", system.DocumentsDirectory)

	local settingsFile, e1 = io.open(p1, "r")
	local settingsHashFile, e2 = io.open(p2, "r")

	local function loadEmUp(t)
		for k,v in pairs(t) do
			settings[k] = v
		end
		setDefaults()
	end

	if settingsFile and settingsHashFile then
		local settingsJSON = settingsFile:read("*a")
		local settingsHash = settingsHashFile:read("*a")
		io.close(settingsFile)
		io.close(settingsHashFile)
		settingsFile = nil
		settingsHashFile = nil
		local hashTest = crypto.hmac(crypto.sha512, settingsJSON, hashKey)
		if settingsHash == hashTest then
			settingsJSON = mime.unb64(settingsJSON)
			local settingsLua = json.decode(settingsJSON)
			loadEmUp(settingsLua)
		else
			print("settings.json was tampered with. Resetting to default values now.")
			reset()
		end
	else
		print("One or both settings files missing. Resetting to default values now.")
		reset()
	end
end

----------------------------------------
-- UNINITIALIZED ALERT:
----------------------------------------
local function initAlert()
	error("You must call settings.init() before you can call settings.save() or settings.reset().")
end
settings.save = initAlert
settings.reset = initAlert

----------------------------------------
-- SET HASH KEY:
----------------------------------------
function settings.setKey(self, key)
	if key == nil then key = self end
	if type(key) ~= "string" then
		print("Your settings hash key must be a string.")
	else
		hashKey = key
		function settings.setKey()
			print("Settings hash key already set!")
		end
	end
end

----------------------------------------
-- INITIALIZE SETTINGS:
----------------------------------------
function settings.init(self, params)
	if hashKey == nil then settings.setKey("schroederapps") end
	if params == nil and self ~= settings then params = self end
	defaults = params or {}
	settings.save = save
	settings.reset = reset
	load()
	function settings.init()
		print("Settings already initialized!")
	end
end

return settings
