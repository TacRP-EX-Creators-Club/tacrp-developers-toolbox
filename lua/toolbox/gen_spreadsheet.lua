local round = math.Round
local function places(value, digits)
	return string.format("%." .. digits .. "f", value)
end

local function style_range_meters(value)
	return places(value * TacRP.HUToM, 1) .. "m"
end
local function style_range_inches(value)
	return round(value) .. '"'
end
local function style_velocity_meters(value)
	return places(value * TacRP.HUToM, 1) .. "m/s"
end
local function style_angle_minute(value)
	return places(math.deg(value * 60), 1) .. "`"
end
local function style_angle_degree(value)
	return places(math.deg(value), 1) .. "°"
end
local function style_multiplier(value)
	return round(value, 3) .. "×"
end
local function style_percentage(value)
	return round(value * 100) .. "%"
end
local function style_time_seconds(value)
	return places(value, 1) .. "s"
end
local function style_per_second(value)
	return round(value, 1) .. "/s"
end
local function style_rpm(value)
	return round(value, 0) .. "rpm"
end
local function compute_nil_if_0(wep, value)
	if not value then return end
	if value == 0 then return end
	return value
end
local function compute_nil_if_1(wep, value)
	if not value then return end
	if value == 1 then return end
	return value
end

local sheet_data = {
	{
		Title = "Print Name",
		Stat = "PrintName",
	},
	{
		Title = "Class Name",
		Stat = "ClassName",
		Style = function(val)
			return val:TrimLeft("tacrp_")
		end,
	},
	{
		Title = "Tier",
		Stat = "SubCatTier",
	},
	{
		Title = "Raw DPS",
		Compute = function(wep)
			local valfunc = wep.GetBaseValue
			local bfm = wep:GetBestFiremode(true)
			local rrpm = wep:GetRPM(true, bfm)
			local erpm = rrpm
			local pbd = valfunc(wep, "PostBurstDelay")
			if bfm < 0 then
				erpm = 60 / ((1 / (rrpm / 60)) + (pbd / -bfm))
			end
			local num = valfunc(wep, "Num")
			local dmg = math.max(valfunc(wep, "Damage_Max"), valfunc(wep, "Damage_Min"))
			return string.format("%0.1f", dmg * num * erpm / 60)
		end,
	},
	{
		Title = "Minimum TTK",
		Compute = function(wep)
			local valfunc = wep.GetBaseValue
			local bfm = wep:GetBestFiremode(true)
			local rpm = wep:GetEffectiveRPM(true, bfm)

			local num = valfunc(wep, "Num")
			local dmg = math.max(valfunc(wep, "Damage_Max"), valfunc(wep, "Damage_Min"))
			local stk = math.ceil(100 / (dmg * num))
			local ttk = stk * (60 / rpm)

			if bfm < 0 and stk > -bfm then
				local pbd = valfunc(wep, "PostBurstDelay")
				ttk = ttk + pbd * math.floor(stk / -bfm)
			end
			return style_time_seconds(ttk)
		end,
	},
	{
		Title = "Damage Close",
		Stat = "Damage_Max",
	},
	{
		Title = "Damage Far",
		Stat = "Damage_Min",
	},
	{
		Title = "Minimum Range",
		Stat = "Range_Min",
		Style = style_range_meters,
	},
	{
		Title = "Maximum Range",
		Stat = "Range_Max",
		Style = style_range_meters,
	},
	{
		Title = "Material Penetration",
		Stat = "Penetration",
		Style = style_range_inches,
	},
	{
		Title = "Armor Penetration",
		Stat = "ArmorPenetration",
		Style = style_percentage,
	},
	{
		Title = "Armor Shredding",
		Stat = "ArmorBonus",
		Style = style_multiplier,
	},
	{
		Title = "Muzzle Velocity",
		Stat = "MuzzleVelocity",
		Style = style_velocity_meters,
	},
	{
		Title = "Clip Size",
		Stat = "ClipSize",
	},
	{
		Title = "Recoil Kick",
		Stat = "RecoilKick",
	},
	{
		Title = "Recoil Stability",
		Stat = "RecoilStability",
		Style = style_percentage,
	},
	{
		Title = "Movespeed",
		Stat = "MoveSpeedMult",
		Style = style_percentage,
	},
	{
		Title = "Shooting Movespeed",
		Stat = "ShootingSpeedMult",
		Style = style_percentage,
	},
	{
		Title = "Reloading Movespeed",
		Stat = "ReloadSpeedMult",
		Style = style_percentage,
	},
	{
		Title = "Sighted Movespeed",
		Stat = "SightedSpeedMult",
		Style = style_percentage,
	},
	{
		Title = "Melee Movespeed",
		Stat = "MeleeSpeedMult",
		Style = style_percentage,
	},
	{
		Title = "Reload Time",
		Compute = function(wep)
			local csmdl = ClientsideModel(wep.ViewModel)
			if not csmdl then return end
			local result = wep:GetReloadTime(true, csmdl)
			csmdl:Remove()
			return result
		end,
		Style = style_time_seconds,
	},
	{
		Title = "Aim Down Sights Time",
		Stat = "AimDownSightsTime",
		Style = style_time_seconds,
	},
	{
		Title = "Sprint To Fire Time",
		Stat = "SprintToFireTime",
		Style = style_time_seconds,
	},
	{
		Title = "Spread",
		Stat = "Spread",
		Style = style_angle_minute,
	},
	{
		Title = "Bloom to Spread",
		Stat = "RecoilSpreadPenalty",
		Style = style_angle_minute,
	},
	{
		Title = "Bloom to Recoil",
		Stat = "RecoilSpreadPenalty",
		Compute = function(wep, value)
			return value * wep:GetBaseValue("RecoilAltMultiplier")
		end,
	},
	{
		Title = "Bloom Recovery",
		Stat = "RecoilDissipationRate",
		Style = style_per_second,
	},
	{
		Title = "Maximum Bloom",
		Stat = "RecoilMaximum"
	},
	{
		Title = "Initial Bloom",
		Stat = "RecoilFirstShotMult"
	},
	{
		Title = "Hipfire Spread Penalty",
		Stat = "HipFireSpreadPenalty",
		Style = style_angle_degree,
	},
	{
		Title = "Midair Spread Penalty",
		Stat = "MidAirSpreadPenalty",
		Style = style_angle_degree,
	},
	{
		Title = "Moving Spread Penalty",
		Stat = "MoveSpreadPenalty",
		Style = style_angle_degree,
	},
	{
		Title = "Quickscope Spread Penalty",
		Stat = "QuickScopeSpreadPenalty",
		Style = style_angle_degree,
	},
	{
		Title = "RPM",
		Stat = "RPM",
		Style = style_rpm,
	},
	{
		Title = "RPM in Burst",
		Stat = "RPMMultBurst",
		Compute = function(wep, value)
			if not value then return end
			if value == 1 then return end
			return value * wep:GetBaseValue("RPM")
		end,
		Style = style_rpm,
	},
	{
		Title = "RPM Mult in Burst",
		Stat = "RPMMultBurst",
		Compute = compute_nil_if_1,
		Style = style_multiplier,
	},
	{
		Title = "Post Burst Delay",
		Stat = "PostBurstDelay",
		Compute = compute_nil_if_0,
		Style = style_time_seconds,
	},
	{
		Title = "RPM in Semi",
		Stat = "RPMMultSemi",
		Compute = function(wep, value)
			if not value then return end
			if value == 1 then return end
			return value * wep:GetBaseValue("RPM")
		end,
		Style = style_rpm,
	},
	{
		Title = "RPM Mult in Semi",
		Stat = "RPMMultSemi",
		Compute = compute_nil_if_1,
		Style = style_multiplier,
	},
}

for _, column in ipairs(sheet_data) do
	column.Class = column.Title:lower():gsub("%s+", "_")
end

local function export()
	-- Sort the weaponlist
	local weapons_to_sort = {}
	-- table.insert(weapons_to_sort, "tacrp_base")
	table.Add(weapons_to_sort, TacRP.Packs["tacrp"].WeaponsArray)
	table.Add(weapons_to_sort, TacRP.Packs["extras"].WeaponsArray)
	table.Add(weapons_to_sort, TacRP.Packs["interops"].WeaponsArray)
	table.insert(weapons_to_sort, "tacrp_base")
	local weapons_cloned = {}
	local classname_to_weapon = {}
	local classname_to_weapon_stored = {}
	for _, classname in ipairs(weapons_to_sort) do
		local wep = weapons.Get(classname)
		table.insert(weapons_cloned, wep)
		classname_to_weapon[classname] = wep
		classname_to_weapon_stored[classname] = weapons.GetStored(classname)
	end

	table.sort(weapons_cloned, function(a, b)
		if TacRP.Type_SortOrder[a.SubCatType] ~= TacRP.Type_SortOrder[b.SubCatType] then
			return TacRP.Type_SortOrder[a.SubCatType] < TacRP.Type_SortOrder[b.SubCatType]
		end

		if TacRP.Tier_SortOrder[a.SubCatTier] ~= TacRP.Tier_SortOrder[b.SubCatTier] then
			return TacRP.Tier_SortOrder[a.SubCatTier] < TacRP.Tier_SortOrder[b.SubCatTier]
		end

		return a.PrintName < b.PrintName
	end)

	local computed = {}

	-- Data
	for _, wep in ipairs(weapons_cloned) do
		local classname = wep.ClassName
		local final = {}
		computed[classname] = final
		for column_index, column in ipairs(sheet_data) do
			local result
			if column.Stat then
				result = wep:GetBaseValue(column.Stat)
				if column.Compute then
					result = column.Compute(wep, result)
				end
			elseif column.Compute then
				result = column.Compute(wep, result)
			end
			if result and column.Style then
				result = column.Style(result)
			end
			computed[classname][column_index] = {
				Result = result
			}
		end
	end

	local subcats = {}
	for _, wep in ipairs(weapons_cloned) do
		local classname = wep.ClassName
		local weapon_type = wep.SubCatType or "[missing]"
		local weapon_tier = wep.SubCatTier or "[missing]"
		if not subcats[weapon_type] then
			subcats[weapon_type] = {
				all_weapons = { --[[
                    "tacrp_ak47",
                ]] },
				tiered_weapons = { --[[
                    ["Consumer"] = {
                        "tacrp_ak47",
                    },
                ]] },
			}
		end
		if not subcats[weapon_type].tiered_weapons[weapon_tier] then
			subcats[weapon_type].tiered_weapons[weapon_tier] = {}
		end
		table.insert(subcats[weapon_type].all_weapons, classname)
		table.insert(subcats[weapon_type].tiered_weapons[weapon_tier], classname)
	end

	local output_html = ""
	local function n(str)
		output_html = output_html .. (str or "") .. "\n"
	end

	n("<!DOCTYPE html>")
	n("<html lang='en'>")
	n("<head>")
	n("<title>TacRP Weapon Spreadsheet</title>")
	n("<meta charset='utf-8'>")
	n("<link rel='stylesheet' href='tacrp_stylesheet.css'>")
	n("</head>")
	n("<body>")

	local subcats_keys = table.GetKeys(subcats)
	table.sort(subcats_keys, function(a, b)
		return (TacRP.Type_SortOrder[a] or math.huge) < (TacRP.Type_SortOrder[b] or math.huge)
	end)
	for _, subcat_name in ipairs(subcats_keys) do
		local subcat_data = subcats[subcat_name]
		n("<table class='" .. subcat_name .. "'>")
		n("<tr>")
		n("<caption>" .. subcat_name .. "</caption>")
		for _, column_data in ipairs(sheet_data) do
			n("<th class='stat_" .. column_data.Class .. "'>")
			n(column_data.Title)
			n("</th>")
		end
		n("</tr>")

		local weapons_sorted = {}
		for i, classname in ipairs(subcat_data.all_weapons) do weapons_sorted[i] = classname end
		table.sort(weapons_sorted, function(a, b)
			local a_def = classname_to_weapon[a]
			local b_def = classname_to_weapon[b]
			local a_tier = TacRP.Tier_SortOrder[a_def.SubCatTier] or math.huge
			local b_tier = TacRP.Tier_SortOrder[b_def.SubCatTier] or math.huge
			if a_tier ~= b_tier then
				return a_tier < b_tier
			end
			return a_def.PrintName < b_def.PrintName
		end)
		for _, classname in ipairs(weapons_sorted) do
			local def = classname_to_weapon[classname]
			n("<tr class='tier_" .. def.SubCatTier:lower() .. "'>")
			for column_index, column_data in ipairs(sheet_data) do
				local result = computed[classname][column_index].Result
				local class = "stat_" .. column_data.Class
				if computed["tacrp_base"] and result == computed["tacrp_base"][column_index].Result then
					class = class .. " stat_is_base"
				end
				local undefined = false
				if column_data.Stat and not classname_to_weapon_stored[classname][column_data.Stat] then
					class = class .. " stat_is_undefined"
					undefined = true
				end
				undefined = undefined and " title='This stat is undefined'" or ""
				n("<td class='" .. class .. "'" .. undefined .. ">")
				n(result)
				n("</td>")
			end
			n("</tr>")
		end
		n("</table>")
	end

	n("</body>")
	n("</html>")

	file.Write("tacrp_weaponstats.html.dat", output_html)
end

export()
