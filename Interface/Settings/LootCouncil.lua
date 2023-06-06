---@type GL
local _, GL = ...;

local Overview = GL.Interface.Settings.Overview; ---@type SettingsOverview

---@class SoftResSettings
GL.Interface.Settings.SoftRes = {
    description = "Importez simplement votre fichier de priorités et gargul se chargera du reste !",
};
local SoftRes = GL.Interface.Settings.SoftRes; ---@type SoftResSettings

---@return void
function SoftRes:draw(Parent)
    GL:debug("SoftResSettings:draw");

    local HorizontalSpacer = GL.AceGUI:Create("SimpleGroup");
    HorizontalSpacer:SetLayout("FILL");
    HorizontalSpacer:SetFullWidth(true);
    HorizontalSpacer:SetHeight(20);
    Parent:AddChild(HorizontalSpacer);

    local OpenSoftRes = GL.AceGUI:Create("Button");
    OpenSoftRes:SetText("Loot Council");
    OpenSoftRes:SetCallback("OnClick", function()
        GL.Settings:close();
        GL.Commands:call("softreserves");
    end);
    Parent:AddChild(OpenSoftRes);
end

GL:debug("Interface/Settings/SoftRes.lua");