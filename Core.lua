local SLOTS = {
	"HeadSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"ShirtSlot",
	"TabardSlot",
	"WristSlot",
	
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	
	"MainHandSlot",
	"SecondaryHandSlot",
}

local HIDDEN_SOURCES = {
	[77344] = true, -- head
	[77343] = true, -- shoulder
	[77345] = true, -- back
	[83202] = true, -- shirt
	[83203] = true, -- tabard
	[84223] = true, -- waist
}

local buttons = {}

local function onClick(self, button)
	if self.item and IsModifiedClick() then
		HandleModifiedItemClick(self.item)
	elseif button == "RightButton" then
		local slotID, slotTexture = GetInventorySlotInfo(self.slot)
		DressUpModel:UndressSlot(slotID)
	end
end

local function onEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if self.item then
		GameTooltip:SetHyperlink(self.item)
	else
		GameTooltip:SetText(self.text or _G[string.upper(self.slot)])
	end
end

for i, slot in ipairs(SLOTS) do
	local button = CreateFrame("Button", nil, DressUpModel)
	button:SetSize(43, 43)
	if i <= 7 then
		button:SetPoint("TOPLEFT", 2, -3 - (43 + 4) * (i - 1))
	elseif i <= 11 then
		button:SetPoint("TOPRIGHT", -2, -73 - (43 + 4) * (i - 8))
	else
		button:SetPoint("BOTTOMLEFT", DressUpModel, "BOTTOM", 1 + (43 + 4) * (i - 13), 3)
	end
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetMotionScriptsWhileDisabled(true)
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button.slot = slot

	button.icon = button:CreateTexture(nil, "BACKGROUND")
	button.icon:SetSize(36, 36)
	button.icon:SetPoint("CENTER")
	
	button.border = button:CreateTexture(nil, "BORDER")
	button.border:SetPoint("CENTER")
	button.border:SetAtlas("transmog-frame", true)
	
	button.highlight = button:CreateTexture()
	button.highlight:SetSize(44, 41)
	button.highlight:SetPoint("CENTER")
	button.highlight:SetAtlas("transmog-frame-highlighted")
	button.highlight:SetBlendMode("ADD")
	button:SetHighlightTexture(button.highlight)
	
	-- if i >= 12 then
		-- button.enchant = CreateFrame("Button", nil, button)
		-- button.enchant:SetSize(27, 27)
		-- button.enchant:SetPoint("CENTER", 0, 25)
		
		-- button.enchant.icon = button.enchant:CreateTexture(nil, "BACKGROUND")
		-- button.enchant.icon:SetSize(18, 18)
		-- button.enchant.icon:SetPoint("CENTER")
		
		-- button.enchant.border = button.enchant:CreateTexture(nil, "BORDER")
		-- button.enchant.border:SetPoint("CENTER")
		-- button.enchant.border:SetAtlas("transmog-frame-small", true)
		
		-- button.enchant.highlight = button.enchant:CreateTexture()
		-- button.enchant.highlight:SetSize(24, 24)
		-- button.enchant.highlight:SetPoint("CENTER")
		-- button.enchant.highlight:SetAtlas("transmog-frame-highlighted-small")
		-- button.enchant.highlight:SetBlendMode("ADD")
		-- button.enchant:SetHighlightTexture(button.enchant.highlight)
	-- end
	
	buttons[slot] = button
end

local function updateSlots(self)
	for slot, button in pairs(buttons) do
		local slotID, slotTexture = GetInventorySlotInfo(slot)
		local sourceID = self:GetSlotTransmogSources(slotID)
		if sourceID == NO_TRANSMOG_SOURCE_ID or HIDDEN_SOURCES[sourceID] then
			button.item = nil
			button.text = nil
			button.icon:SetTexture(slotTexture)
			button:Disable()
		else
			local categoryID, appearanceID, canEnchant, icon, isCollected, link = C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
			button.item = link
			button.text = UNKNOWN
			button.icon:SetTexture(icon or [[Interface\Icons\INV_Misc_QuestionMark]])
			button:Enable()
		end
	end
end

DressUpModel:HookScript("OnDressModel", updateSlots)
hooksecurefunc(DressUpModel, "Dress", updateSlots)