--[[
-- VolckerNamePlates
-- By Kesava at curse.com
-- All rights reserved
-- Lightweight target debuff display above nameplates
]]
local addon = LibStub("AceAddon-3.0"):GetAddon("VolckerNamePlates")
local mod = addon:NewModule("Auras", addon.Prototype, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("VolckerNamePlates")
local C_NamePlate = C_NamePlate

local floor = math.floor
local max = math.max
local min = math.min
local GetTime = GetTime
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local sort = table.sort

mod.uiName = L["Auras"]

local ICON_SIZE = 18
local ICON_SPACING = 2
local MAX_AURAS = 8
local AURAS_PER_ROW = 4
local AURA_Y_OFFSET = 14
local AURA_SYNC_INTERVAL = 0.2
local ArrangeButtons, UpdateTargetAuras, HideAuras, SyncFrameAuras

local function ApplyLayout(frame)
	if not frame.auras then
		return
	end

	frame.auras:ClearAllPoints()
	frame.auras:SetPoint("BOTTOM", frame.health, "TOP", 0, AURA_Y_OFFSET)

	for _, button in ipairs(frame.auras.buttons) do
		button:SetSize(ICON_SIZE, ICON_SIZE)
	end

	ArrangeButtons(frame.auras)
end

local function GetFrameByUnit(unit)
	if not (unit and UnitExists(unit)) then
		return
	end

	if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
		local plate = C_NamePlate.GetNamePlateForUnit(unit)
		if plate and plate.kui then
			return plate.kui
		end
	end
end

local function GetUnitByFrame(frame)
	if not (frame and frame.parentFrame and C_NamePlate and C_NamePlate.GetNamePlateForUnit) then
		return
	end

	for i = 1, 60 do
		local unit = "nameplate" .. i
		if UnitExists(unit) and C_NamePlate.GetNamePlateForUnit(unit) == frame.parentFrame then
			return unit
		end
	end
end

SyncFrameAuras = function(frame)
	if not (frame and frame.auras) then
		return
	end

	local unit = GetUnitByFrame(frame)
	if not unit then
		HideAuras(frame)
		return
	end

	local guid = UnitGUID(unit)
	if not guid or (frame.auras.guid and frame.auras.guid ~= guid) then
		HideAuras(frame)
		if not guid then
			return
		end
	end

	UpdateTargetAuras(frame, unit)
end

local function HideAuraButton(button)
	button:SetScript("OnUpdate", nil)
	button.expirationTime = nil
	button.duration = nil
	button.icon:SetTexture(nil)
	button.time:SetText("")
	button.time:Hide()
	button.count:SetText("")
	button.count:Hide()
	button:Hide()
end

local function OnAuraUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) - elapsed
	if self.elapsed > 0 then
		return
	end

	if not self.expirationTime or not self.duration or self.duration <= 0 then
		self.time:Hide()
		self:SetScript("OnUpdate", nil)
		return
	end

	local timeLeft = self.expirationTime - GetTime()
	if timeLeft <= 0 then
		self.time:Hide()
		self:SetScript("OnUpdate", nil)
		return
	end

	if timeLeft <= 5 then
		self.time:SetTextColor(1, 0.2, 0.2)
	elseif timeLeft <= 20 then
		self.time:SetTextColor(1, 1, 0)
	else
		self.time:SetTextColor(1, 1, 1)
	end

	if timeLeft > 60 then
		self.time:SetText(floor((timeLeft / 60) + 0.999) .. "m")
	else
		self.time:SetText(floor(timeLeft + 0.5))
	end

	self.time:Show()
	self.elapsed = timeLeft <= 5 and 0.1 or 0.5
end

ArrangeButtons = function(container)
	local width = (ICON_SIZE * AURAS_PER_ROW) + (ICON_SPACING * (AURAS_PER_ROW - 1))
	local visible = 0

	for _, button in ipairs(container.buttons) do
		if button:IsShown() then
			local row = floor(visible / AURAS_PER_ROW)
			local column = visible % AURAS_PER_ROW

			button:ClearAllPoints()
			button:SetPoint(
				"BOTTOMLEFT",
				container,
				"BOTTOMLEFT",
				column * (ICON_SIZE + ICON_SPACING),
				row * (ICON_SIZE + ICON_SPACING)
			)

			visible = visible + 1
		end
	end

	if visible == 0 then
		container:Hide()
		return
	end

	container:SetWidth(width)
	container:SetHeight((max(1, floor((visible - 1) / AURAS_PER_ROW) + 1) * ICON_SIZE) + (max(0, floor((visible - 1) / AURAS_PER_ROW)) * ICON_SPACING))
	container:Show()
end

local function CreateAuraButton(container, index)
	local button = CreateFrame("Frame", nil, container)
	button:SetSize(ICON_SIZE, ICON_SIZE)
	button:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
	button:SetBackdropColor(0, 0, 0, 0.8)

	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	button.time = container.frame:CreateFontString(button, {
		font = addon.font,
		size = "small",
		outline = "OUTLINE"
	})
	button.time:SetPoint("TOPLEFT", -1, 1)
	button.time:SetJustifyH("LEFT")
	button.time:Hide()

	button.count = container.frame:CreateFontString(button, {
		font = addon.font,
		size = "small",
		outline = "OUTLINE"
	})
	button.count:SetPoint("BOTTOMRIGHT", 1, -1)
	button.count:SetJustifyH("RIGHT")
	button.count:Hide()

	container.buttons[index] = button
	return button
end

local function GetAuraButton(container, index)
	return container.buttons[index] or CreateAuraButton(container, index)
end

HideAuras = function(frame)
	if not (frame and frame.auras) then
		return
	end

	for _, button in ipairs(frame.auras.buttons) do
		HideAuraButton(button)
	end

	frame.auras:Hide()
	frame.auras.unit = nil
	frame.auras.guid = nil
end

local function UpdateAuraButton(button, icon, count, duration, expirationTime)
	button.icon:SetTexture(icon)
	button.duration = duration
	button.expirationTime = expirationTime
	button.elapsed = 0

	if count and count > 1 then
		button.count:SetText(count)
		button.count:Show()
	else
		button.count:SetText("")
		button.count:Hide()
	end

	if duration and duration > 0 and expirationTime then
		button:SetScript("OnUpdate", OnAuraUpdate)
		OnAuraUpdate(button, 0)
	else
		button:SetScript("OnUpdate", nil)
		button.time:SetText("")
		button.time:Hide()
	end

	button:Show()
end

UpdateTargetAuras = function(frame, unit)
	if not (frame and frame.auras and unit and UnitExists(unit)) then
		if frame and frame.auras then
			HideAuras(frame)
		end
		return
	end

	local guid = UnitGUID(unit)
	if not guid then
		HideAuras(frame)
		return
	end

	frame.auras.unit = unit
	frame.auras.guid = guid

	if frame.friend then
		HideAuras(frame)
		return
	end

	local shown = 0
	local auraData = {}

	for i = 1, 40 do
		local _, _, icon, count, _, duration, expirationTime, unitCaster = UnitDebuff(unit, i)
		if not icon then
			break
		end
		if unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle" then
			tinsert(auraData, {
				icon = icon,
				count = count,
				duration = duration,
				expirationTime = expirationTime
			})
		end
	end

	sort(auraData, function(a, b)
		local aExpires = a.expirationTime and a.expirationTime > 0
		local bExpires = b.expirationTime and b.expirationTime > 0

		if aExpires ~= bExpires then
			return aExpires
		end

		if aExpires and bExpires and a.expirationTime ~= b.expirationTime then
			return a.expirationTime < b.expirationTime
		end

		local aDuration = a.duration or 0
		local bDuration = b.duration or 0
		if aDuration ~= bDuration then
			return aDuration < bDuration
		end

		return false
	end)

	for i = 1, min(MAX_AURAS, #auraData) do
		local aura = auraData[i]
		shown = shown + 1
		UpdateAuraButton(GetAuraButton(frame.auras, shown), aura.icon, aura.count, aura.duration, aura.expirationTime)
	end

	for i = shown + 1, #frame.auras.buttons do
		HideAuraButton(frame.auras.buttons[i])
	end

	ArrangeButtons(frame.auras)
end

function mod:PostCreate(msg, frame)
	frame.auras = CreateFrame("Frame", nil, frame)
	frame.auras.frame = frame
	frame.auras.buttons = {}
	frame.auras:SetFrameLevel(frame:GetFrameLevel() + 5)
	frame.auras:Hide()

	ApplyLayout(frame)
end

function mod:PostShow(msg, frame)
	if not frame.auras then
		return
	end

	ApplyLayout(frame)
	SyncFrameAuras(frame)
end

function mod:PostHide(msg, frame)
	HideAuras(frame)
end

function mod:PostTarget(msg, frame, isTarget)
	if isTarget then
		UpdateTargetAuras(frame, "target")
	end
end

function mod:UNIT_AURA(event, unit)
	if not unit then
		return
	end

	local frame = GetFrameByUnit(unit)
	if frame and frame.auras and frame.auras.guid == UnitGUID(unit) then
		UpdateTargetAuras(frame, unit)
	end
end

function mod:NAME_PLATE_UNIT_ADDED(event, unit)
	local frame = GetFrameByUnit(unit)
	if frame then
		HideAuras(frame)
		UpdateTargetAuras(frame, unit)
	end
end

function mod:NAME_PLATE_UNIT_REMOVED(event, unit)
	local guid = UnitGUID(unit)

	for _, entry in pairs(addon.frameList) do
		local frame = entry.kui
		if frame and frame.auras and (frame.auras.unit == unit or (guid and frame.auras.guid == guid)) then
			HideAuras(frame)
		end
	end

	local frame = GetFrameByUnit(unit)
	if frame and frame.auras and (frame.auras.unit == unit or (guid and frame.auras.guid == guid)) then
		HideAuras(frame)
	end
end

local function RefreshAllFrames()
	for _, frame in pairs(addon.frameList) do
		if frame.kui and frame.kui.auras then
			ApplyLayout(frame.kui)
			SyncFrameAuras(frame.kui)
		end
	end
end

local function RefreshVisibleAuras()
	for _, frame in pairs(addon.frameList) do
		if frame.kui and frame.kui:IsShown() and frame.kui.auras then
			SyncFrameAuras(frame.kui)
		end
	end
end

mod:AddConfigChanged("enabled", function(v) mod:Toggle(v) end)
mod:AddConfigChanged("icon_size", function(v)
	ICON_SIZE = v
	RefreshAllFrames()
end)
mod:AddConfigChanged("icons_per_row", function(v)
	AURAS_PER_ROW = v
	RefreshAllFrames()
end)
mod:AddConfigChanged("max_auras", function(v)
	MAX_AURAS = v
	RefreshAllFrames()
end)
mod:AddConfigChanged("y_offset", function(v)
	AURA_Y_OFFSET = v
	RefreshAllFrames()
end)

function mod:GetOptions()
	return {
		enabled = {
			type = "toggle",
			name = L["Show nameplate debuffs"],
			desc = L["Show your debuffs above visible enemy nameplates."],
			order = 10
		},
		icon_size = {
			type = "range",
			name = L["Icon size"],
			desc = L["Size of the debuff icons shown above the target nameplate."],
			order = 20,
			min = 10,
			max = 32,
			step = 1
		},
		icons_per_row = {
			type = "range",
			name = L["Icons per row"],
			desc = L["How many debuff icons to show on each row."],
			order = 30,
			min = 1,
			max = 8,
			step = 1
		},
		max_auras = {
			type = "range",
			name = L["Maximum auras"],
			desc = L["Maximum number of target debuffs to display."],
			order = 40,
			min = 1,
			max = 16,
			step = 1
		},
		y_offset = {
			type = "range",
			name = L["Aura Y offset"],
			desc = L["Vertical offset for the target debuffs above the nameplate."],
			order = 50,
			min = 0,
			max = 40,
			step = 1
		}
	}
end

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, {profile = {
		enabled = true,
		icon_size = 18,
		icons_per_row = 4,
		max_auras = 8,
		y_offset = 14
	}})

	addon:InitModuleOptions(self)

	ICON_SIZE = self.db.profile.icon_size
	AURAS_PER_ROW = self.db.profile.icons_per_row
	MAX_AURAS = self.db.profile.max_auras
	AURA_Y_OFFSET = self.db.profile.y_offset

	self:SetEnabledState(self.db.profile.enabled)
end

function mod:OnEnable()
	self:RegisterMessage("VolckerNamePlates_PostCreate", "PostCreate")
	self:RegisterMessage("VolckerNamePlates_PostShow", "PostShow")
	self:RegisterMessage("VolckerNamePlates_PostHide", "PostHide")
	self:RegisterMessage("VolckerNamePlates_PostTarget", "PostTarget")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	self.refreshTimer = addon:ScheduleRepeatingTimer(RefreshVisibleAuras, AURA_SYNC_INTERVAL)
	RefreshAllFrames()
end

function mod:OnDisable()
	self:UnregisterMessage("VolckerNamePlates_PostCreate", "PostCreate")
	self:UnregisterMessage("VolckerNamePlates_PostShow", "PostShow")
	self:UnregisterMessage("VolckerNamePlates_PostHide", "PostHide")
	self:UnregisterMessage("VolckerNamePlates_PostTarget", "PostTarget")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
	self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
	if self.refreshTimer then
		addon:CancelTimer(self.refreshTimer)
		self.refreshTimer = nil
	end

	for _, frame in pairs(addon.frameList) do
		if frame.kui then
			HideAuras(frame.kui)
		end
	end
end
