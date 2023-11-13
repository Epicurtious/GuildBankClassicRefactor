GBC_LOADED = 0;
-- This can be 20, but to stay consistent with the addon, it will reamin 16
-- chaning this to be more accurate would require changing the excel sheet it goes to
local NUM_INVENTORY_BACKPACK_SPACES = 16;
local NUM_MAX_BAG_SPACES = 18;
local NUM_BANK_SPACES = NUM_BANKGENERIC_SLOTS;


GBC_UNLOADER = CreateFrame("FRAME", "GBC_UNLOADER");
GBC_UNLOADER:RegisterEvent("BANKFRAME_CLOSED");
GBC_UNLOADER:SetScript("OnEvent", function() 
	GBC_LOADED = 0; 
	GuildBankClassic:Hide(); 
	GuildBankClassicButton1:Hide();
end);

GBC_LOADER = CreateFrame("FRAME", "GBC_LOADER");
GBC_LOADER:RegisterEvent("BANKFRAME_OPENED");
GBC_LOADER:SetScript("OnEvent", function()
	GBC_LOADED = 1; 
	GuildBankClassicButton1 = CreateFrame("BUTTON", "Button", CENTER, "UIPanelButtonTemplate");
	GuildBankClassicButton1:SetWidth(45);
	GuildBankClassicButton1:SetHeight(24);
	GuildBankClassicButton1:SetPoint("CENTER", UIParent, "BOTTOM", 0, 150);
	GuildBankClassicButton1:SetText("GBC");
	GuildBankClassicButton1:SetMovable(true);
	GuildBankClassicButton1:EnableMouse(true);
	GuildBankClassicButton1:RegisterForDrag("LeftButton");
	GuildBankClassicButton1:SetScript("OnDragStart", GuildBankClassicButton1.StartMoving);
	GuildBankClassicButton1:SetScript("OnDragStop", GuildBankClassicButton1.StopMovingOrSizing);
	GuildBankClassicButton1:SetScript("OnClick", function() 

		local GBC_Editbox_Text = "";

		if GBC_LOADED == 0 then
			print("ERROR");
			GuildBankClassic.EditBox:SetText("ERROR");
		else
			local bank_inv_index = 1;

			-- each entry in the array is in the form: {ID, Count}
			local GBC_Bank_And_Backpack_Items = {}
			-- populates array with items in bank
			for i=1,NUM_BANK_SPACES do
				local itemID = C_Container.GetContainerItemID(BANK_CONTAINER,i);
				if itemID ~= nil then
					local itemCount = C_Container.GetContainerItemInfo(BANK_CONTAINER,i).stackCount;
					GBC_Bank_And_Backpack_Items[bank_inv_index] = {itemID, itemCount};
				else
					GBC_Bank_And_Backpack_Items[bank_inv_index] = {"", ""};
				end
				bank_inv_index = bank_inv_index + 1;
			end
			-- populates array with items in the bag slots of the bank
			for bag=1, NUM_BANKBAGSLOTS do
				bag = bag + NUM_BAG_SLOTS;
				for i=1,NUM_MAX_BAG_SPACES do
					local itemID = C_Container.GetContainerItemID(bag,i);
					if itemID ~= nil then
						local itemCount = C_Container.GetContainerItemInfo(bag,i).stackCount;
						GBC_Bank_And_Backpack_Items[bank_inv_index] = {itemID, itemCount};
					else
						GBC_Bank_And_Backpack_Items[bank_inv_index] = {"", ""};
					end
					bank_inv_index = bank_inv_index + 1;
				end
			end
			-- populates array with items in player's bag slots
			for bag=BACKPACK_CONTAINER+1, NUM_BAG_SLOTS do
				for i=1,NUM_MAX_BAG_SPACES do
					local itemID = C_Container.GetContainerItemID(bag,i);
					if itemID ~= nil then
						local itemCount = C_Container.GetContainerItemInfo(bag,i).stackCount;
						GBC_Bank_And_Backpack_Items[bank_inv_index] = {itemID, itemCount};
					else
						GBC_Bank_And_Backpack_Items[bank_inv_index] = {"", ""};
					end
					bank_inv_index = bank_inv_index + 1;
				end
			end
			-- populates array with items in player's backpack
			for i=1,NUM_INVENTORY_BACKPACK_SPACES do
				local itemID = C_Container.GetContainerItemID(BACKPACK_CONTAINER,i);
				if itemID ~= nil then
					local itemCount = C_Container.GetContainerItemInfo(BACKPACK_CONTAINER,i).stackCount;
					GBC_Bank_And_Backpack_Items[bank_inv_index] = {itemID, itemCount};
				else
					GBC_Bank_And_Backpack_Items[bank_inv_index] = {"", ""};
				end
				bank_inv_index = bank_inv_index + 1;
			end

			-- debugging for bank and backpack items
			-- for i=1,#GBC_Bank_And_Backpack_Items do
			-- 	print(i .. " -> " .. GBC_Bank_And_Backpack_Items[i][1] .. " : " .. GBC_Bank_And_Backpack_Items[i][2])
			-- end

			local GBC_Bags_Info = {}
			for i = 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
				local invID = C_Container.ContainerIDToInventoryID(i);
				local bagID = GetInventoryItemID("player", invID);
				if bagID ~= nil then
					GBC_Bags_Info[i] = bagID;
				else
					GBC_Bags_Info[i] = "";
				end
			end

			-- debugging for bag item ids
			-- for i=1,#GBC_Bags_Info do
			-- 	print(i .. " -> " .. GBC_Bags_Info[i])
			-- end

			GBC_money = GetMoney();
			GBC_Money_Data = (("%dg %ds %dc"):format(GBC_money / 100 / 100, (GBC_money / 100) % 100, GBC_money % 100));

			-- add all the inventory data to string for editbox
			for i=1,#GBC_Bank_And_Backpack_Items do
				GBC_Editbox_Text = GBC_Editbox_Text .. GBC_Bank_And_Backpack_Items[i][1] .. "\t" .. GBC_Bank_And_Backpack_Items[i][2] .. "\n";
			end
			
			-- adds bag id data to string for editbox
			for i=1,#GBC_Bags_Info do
				GBC_Editbox_Text = GBC_Editbox_Text .. GBC_Bags_Info[i] .. "\n";
			end
			
			-- append date and money on the end of editbox string
			GBC_Editbox_Text = GBC_Editbox_Text .. date().."\n".. "\t" .. GBC_Money_Data .. "\n"
			
			-- debug for editbox string
			-- print(GBC_Editbox_Text)
			print("test1")
			GuildBankClassic.EditBox:SetText(GBC_Editbox_Text);
			print("test2")
		end
		GuildBankClassic:Show(); 
		GuildBankClassic.EditBox:HighlightText();
		
		GuildBankClassic.Comment = CreateFrame("EditBox", "GuildBankClassic_Comment", GuildBankClassic);
		GuildBankClassic.Comment:SetWidth(100);
		GuildBankClassic.Comment:SetHeight(24);
		GuildBankClassic.Comment:SetPoint("RIGHT", GuildBankClassicButton1, "RIGHT", -35, 0);
		GuildBankClassic.Comment:SetFontObject("GameTooltipTextSmall");
		GuildBankClassic.Comment:SetText("CTRL+C to copy");
		GuildBankClassic.Comment:SetAutoFocus(false);
		GuildBankClassic.Comment:SetMultiLine(false);
		GuildBankClassic.Comment:EnableMouse(false);
		

	end);

	GuildBankClassic = CreateFrame("Frame", "GuildBankClassic", UIParent, "BackdropTemplate");
	GuildBankClassic:SetFrameStrata("HIGH");
	GuildBankClassic:SetPoint("RIGHT", GuildBankClassicButton1, "RIGHT", 0, -42);
	GuildBankClassic:SetWidth(150);
	GuildBankClassic:SetHeight(60);
	GuildBankClassic:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	});
	GuildBankClassic:SetMovable(false);
	GuildBankClassic:SetClampedToScreen(true);
	GuildBankClassic:SetResizable(false);
	GuildBankClassic:EnableMouse(true);
	GuildBankClassic:RegisterForDrag("LeftButton");
	GuildBankClassic:SetScript("OnUpdate", function()
		GuildBankClassic.EditBox:SetWidth(GuildBankClassic:GetWidth() - 13);
		GuildBankClassic.EditBox:SetHeight(GuildBankClassic:GetHeight() - 13);
		GuildBankClassic.ScrollFrame:UpdateScrollChildRect();
	end);
	GuildBankClassic:Hide();

	GuildBankClassic.EditBox = CreateFrame("EditBox", "GuildBankClassic_EditBox", GuildBankClassic);
	GuildBankClassic.EditBox:SetAutoFocus(true);
	GuildBankClassic.EditBox:SetMultiLine(true);
	GuildBankClassic.EditBox:EnableMouse(true);
	GuildBankClassic.EditBox:SetPoint("CENTER", GuildBankClassic, "CENTER");
	GuildBankClassic.EditBox:SetFontObject("GameTooltipTextSmall");
	GuildBankClassic.EditBox:SetScript("OnEscapePressed", function() GuildBankClassic:Hide() end);

	GuildBankClassic.ScrollFrame = CreateFrame("ScrollFrame", "GuildBankClassic_ScrollFrame", GuildBankClassic, "UIPanelScrollFrameTemplate");
	GuildBankClassic.ScrollFrame:SetPoint("TOPLEFT", GuildBankClassic, "TOPLEFT", 6, -6);
	GuildBankClassic.ScrollFrame:SetPoint("BOTTOMRIGHT", GuildBankClassic, "BOTTOMRIGHT", -6, 6);
	GuildBankClassic.ScrollFrame:SetScrollChild(GuildBankClassic.EditBox);
end);