local function UnlockInventory()
    panorama.RunScript([[

	LoadoutAPI.IsLoadoutAllowed = () => {

		return true;

	};

]])
end

local function LockInventory()
    panorama.RunScript([[

	LoadoutAPI.IsLoadoutAllowed = () => {

		return false;

	};

]])
end

local UnlockInventorybutton = gui.Button(gui.Reference("Misc", "General", "Bypass"), "🌟解锁库存", UnlockInventory)

local LockInventorybutton = gui.Button(gui.Reference("Misc", "General", "Bypass"), "🌟锁定库存", LockInventory)


UnlockInventorybutton:SetPosX(0)
LockInventorybutton:SetPosX(0)
UnlockInventorybutton:SetWidth(265)
LockInventorybutton:SetWidth(265)