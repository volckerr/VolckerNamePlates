--[[
-- VolckerNamePlates
-- Secure click overlay for visible nameplate units
]]
local addon = LibStub("AceAddon-3.0"):GetAddon("VolckerNamePlates")
local mod = addon:NewModule("ClickOverlay", addon.Prototype, "AceEvent-3.0")
local C_NamePlate = C_NamePlate
local MAX_NAMEPLATES = 60

local function UpdateOverlayGeometry(frame)
	if not (frame and frame.clickOverlay and frame.health and frame.name) then
		return
	end

	frame.clickOverlay:ClearAllPoints()
	frame.clickOverlay:SetPoint("TOPLEFT", frame.name, "TOPLEFT", -18, 14)

	if frame.castbar then
		frame.clickOverlay:SetPoint("BOTTOMRIGHT", frame.castbar.bg or frame.health, "BOTTOMRIGHT", 18, -10)
	else
		frame.clickOverlay:SetPoint("BOTTOMRIGHT", frame.health, "BOTTOMRIGHT", 18, -10)
	end
end

local function GetKuiFrameByUnit(unit)
	if not (unit and C_NamePlate and C_NamePlate.GetNamePlateForUnit) then
		return
	end

	local plate = C_NamePlate.GetNamePlateForUnit(unit)
	if plate and plate.kui then
		return plate.kui
	end
end

local function FindUnitForFrame(frame)
	if not (frame and frame.parentFrame and C_NamePlate and C_NamePlate.GetNamePlateForUnit) then
		return
	end

	for i = 1, MAX_NAMEPLATES do
		local unit = "nameplate" .. i
		if C_NamePlate.GetNamePlateForUnit(unit) == frame.parentFrame then
			return unit
		end
	end
end

local function SyncOverlayUnit(frame)
	if not (frame and frame.clickOverlay) then
		return
	end

	local unit = FindUnitForFrame(frame)
	if unit then
		UpdateOverlayGeometry(frame)
		frame.clickOverlay:SetAttribute("unit", unit)
		frame.clickOverlay:Show()
	else
		frame.clickOverlay:Hide()
	end
end

function mod:PostCreate(msg, frame)
	if frame.clickOverlay then
		return
	end

	local overlay = CreateFrame("Button", nil, UIParent, "SecureUnitButtonTemplate")
	overlay:SetFrameStrata("TOOLTIP")
	overlay:SetFrameLevel(1)
	overlay:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
	overlay:EnableMouse(true)
	overlay:SetAttribute("type1", "target")
	overlay:SetAttribute("*type1", "target")
	overlay:SetAlpha(0.02)
	overlay:SetNormalTexture("Interface\\Buttons\\WHITE8x8")
	overlay:GetNormalTexture():SetAlpha(0)
	overlay:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
	overlay:GetHighlightTexture():SetAlpha(0)
	overlay:Hide()
	overlay:SetClampedToScreen(false)
	overlay:SetToplevel(true)
	overlay:SetScript("OnEnter", function()
		if frame.HandleMouseEnter then
			frame:HandleMouseEnter()
		end
	end)
	overlay:SetScript("OnLeave", function()
		if frame.HandleMouseLeave then
			frame:HandleMouseLeave()
		end
	end)

	frame.clickOverlay = overlay
	frame.UpdateClickOverlay = UpdateOverlayGeometry
	UpdateOverlayGeometry(frame)
	SyncOverlayUnit(frame)
end

function mod:PostShow(msg, frame)
	if frame.clickOverlay then
		UpdateOverlayGeometry(frame)
		SyncOverlayUnit(frame)
	end
end

function mod:PostHide(msg, frame)
	if frame.clickOverlay then
		frame.clickOverlay:Hide()
	end
end

function mod:NAME_PLATE_UNIT_ADDED(event, unit)
	local frame = GetKuiFrameByUnit(unit)
	if not (frame and frame.clickOverlay) then
		return
	end

	SyncOverlayUnit(frame)
end

function mod:NAME_PLATE_UNIT_REMOVED(event, unit)
	local frame = GetKuiFrameByUnit(unit) or addon:GetUnitPlate(unit)
	if frame and frame.clickOverlay then
		frame.clickOverlay:Hide()
	end
end

function mod:OnEnable()
	self:RegisterMessage("VolckerNamePlates_PostCreate", "PostCreate")
	self:RegisterMessage("VolckerNamePlates_PostShow", "PostShow")
	self:RegisterMessage("VolckerNamePlates_PostHide", "PostHide")
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	for _, frame in pairs(addon.frameList) do
		if frame.kui and frame.kui.clickOverlay then
			SyncOverlayUnit(frame.kui)
		end
	end
end

function mod:OnDisable()
	self:UnregisterMessage("VolckerNamePlates_PostCreate", "PostCreate")
	self:UnregisterMessage("VolckerNamePlates_PostShow", "PostShow")
	self:UnregisterMessage("VolckerNamePlates_PostHide", "PostHide")
	self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
	self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
end
