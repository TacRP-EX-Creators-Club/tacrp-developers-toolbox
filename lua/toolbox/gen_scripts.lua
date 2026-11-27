local interesting_weapons = {
	"tacrp_pa_lapd",
	"tacrp_amd65",
	"tacrp_ak47",
	"tacrp_k1a",
	"tacrp_base",
}

local DROP_KEYS = {
	["NoRMR"] = true,
	["Slot"] = true,
	["SlotOrig"] = true,
	["Category"] = true,
	["SubCategory"] = true,
	["ClassName"] = true,
	["Folder"] = true,
	["Primary"] = true,
	["Secondary"] = true,
}

local function round6(val)
	return math.Round(val, 6)
end

local function script_string(val, key)
	if val == nil then
		return "nil"
	end
	if val == NULL then
		return "NULL"
	end
	if isnumber(val) or isbool(val) then
		return tostring(val)
	end
	if isstring(val) then
		local fixed = val:gsub("\"", "\\\""):gsub("\n", "\\n")
		return '"' .. fixed .. '"'
	end
	if isvector(val) then
		return string.format(
			"Vector(%s, %s, %s)",
			round6(val.x),
			round6(val.y),
			round6(val.z)
		)
	end
	if isangle(val) then
		return string.format(
			"Angle(%s, %s, %s)",
			round6(val.x),
			round6(val.y),
			round6(val.z)
		)
	end
	if IsColor(val) then
		if val.a ~= 255 then
			return string.format(
				"Color(%s, %s, %s, %s)",
				round6(val.r),
				round6(val.g),
				round6(val.b),
				round6(val.a)
			)
		end
		return string.format(
		"Color(%s, %s, %s)",
			round6(val.r),
			round6(val.g),
			round6(val.b)
		)
	end
	if isfunction(val) then
		return "function() end"
	end
end

local T = "\t"
local function script_value(input, indent, key)
	if not input then
		return false
	end
	local ez = script_string(input, key)
	if ez ~= nil then
		return ez
	end
	if not indent then indent = 1 end

	local t = T:rep(indent)
	local result = "{\n"
	local passed = {}
	
	local array = false
	for i, v in ipairs(input) do
		passed[i] = true
		array = true
	end
	for k, v in pairs(input) do
		if passed[k] then continue end
		array = false
	end

	for i, v in ipairs(input) do
		local part_key = array and "" or '[' .. script_string(i, key) .. '] = '
		local part_value = script_value(v, indent+1, key)
		if part_value == false then continue end
		result = result .. t .. part_key .. part_value .. ",\n"
	end
	for k, v in SortedPairs(input) do
		if passed[k] then continue end

		local safe = false
		local k_str = tostring(k)
		if k_str:Left(1):match("%a") then -- could be more robust
			safe = true
		end
		local part_key = safe and k_str .. " = " or '[' .. script_string(k, key) .. '] = '
		local part_value = script_value(v, indent+1, key)
		if part_value == false then continue end
		result = result .. t .. part_key .. part_value .. ',\n'
	end
	result = result .. T:rep(indent-1) .. "}"
	return result
end

file.CreateDir("tacrp_rewrite")

for _, classname in ipairs(interesting_weapons) do
	local output = ""
	local function nl()
		output = output .. "\n"
	end
	local function n(str)
		output = output .. str .. "\n"
	end
	local weapon_stored = weapons.GetStored(classname)
	local accounted = {}
	local function kv(key, suffix)
		accounted[key] = true
		local val = script_value(weapon_stored[key], nil, key) or "nil"
		n("SWEP." .. key .. " = " .. val .. (suffix or ""))
	end
	local function kv_optional(key)
		accounted[key] = true
		local val = script_value(weapon_stored[key], nil, key)
		if not val then return end
		n("SWEP." .. key .. " = " .. val)
		return true
	end

	kv("Base")
	kv("Spawnable")
	nl()
	kv("PrintName")
	kv("AbbrevName")
	kv("SubCatType")
	kv("SubCatTier")
	kv("Description")
	kv("Description_Quote")
	kv("Trivia_Caliber")
	kv("Trivia_Manufacturer")
	kv("Trivia_Year")
	kv("Faction")
	kv("Credits")

	n("\n-- Model")
	kv("ViewModel")
	kv("WorldModel")
	kv("MuzzleEffect")
	kv("EjectEffect")
	kv("QCA_Muzzle")
	kv("QCA_Eject")
	kv("DropMagazineModel")
	kv("DropMagazineImpact")

	n("\n-- Action")
	kv("ClipSize")
	kv("Ammo")
	kv("RPM")
	if not kv_optional("Firemodes") then
		kv("Firemode")
	end

	n("\n-- Terminal Effect")
	kv("Damage_Max")
	kv("Damage_Min")
	kv("Range_Min")
	kv("Range_Max")
	
	n("\n-- Ballistics")
	kv("Spread")
	kv("MuzzleVelocity")
	kv("Penetration")
	kv("ArmorPenetration")
	kv("ArmorBonus")

	n("\n-- Recoil & Bloom")
	kv("RecoilKick")
	kv("RecoilStability")
	kv("RecoilSpreadPenalty", " -- Bloom to Spread")
	kv("RecoilAltMultiplier", " -- Bloom to Spread")
	kv("RecoilDissipationRate", " -- Bloom Recovery")
	kv("RecoilResetTime", " -- Bloom Cooldown")
	kv("RecoilResetInstant")
	kv("RecoilFirstShotMult", " -- Initial Bloom")
	kv("RecoilMaximum", " -- Maximum Bloom")
	kv("RecoilVisualKick")
	kv("RecoilPerShot", " -- Bloom Gain")

	n("\n-- Mobility")
	kv("MoveSpeedMult")
	kv("ShootingSpeedMult")
	kv("SightedSpeedMult")
	kv("ReloadSpeedMult")
	kv("MeleeSpeedMult")

	n("\n-- Manuevering")
	kv("FreeAimMaxAngle")
	kv("MidAirSpreadPenalty")
	kv("HipFireSpreadPenalty")
	
	n("\n-- Sway")
	kv("Sway")
	kv("ScopedSway")
	kv("SwayCrouchMult")

	n("\n-- Handling")
	kv("AimDownSightsTime")
	kv("SprintToFireTime")
	kv("DropMagazineTime")
	kv("ReloadTimeMult")
	kv("ReloadUpInTime")
	
	n("\n-- Miscellaneous")
	kv("ShootTimeMult")
	kv("SightPos")
	kv("SightAng")
	kv("CorrectivePos")
	kv("CorrectiveAng")
	kv("PassivePos")
	kv("PassiveAng")
	kv("SprintPos")
	kv("SprintAng")
	kv("HoldType")
	kv("HoldTypeSprint")
	kv("HoldTypeBlindFire")
	kv("CanBlindFire")
	kv("BlindFirePos")
	kv("BlindFireAng")
	kv("HolsterVisible")
	kv("HolsterSlot")
	kv("HolsterPos")
	kv("HolsterAng")
	kv("GestureShoot")
	kv("GestureReload")

	n("\n-- Sound")
	kv("Sound_Shoot")
	kv("Sound_Shoot_Silenced")
	kv("ShootPitchVariance")
	kv("Vol_Shoot")
	
	n("\n-- Unaccounted")
	for k, v in SortedPairs( weapon_stored ) do
		if not accounted[k] and not DROP_KEYS[k] then
			kv_optional(k)
		end
	end

	local path = "tacrp_rewrite/" .. classname .. ".lua.txt"
	print("Wrote " .. path)
	file.Write(path, output)
end
