local L = Gargul_L;

---@type GL
local _, GL = ...;

---@type Interface
local Interface = GL.Interface;

---@type GDKPSession
local GDKPSession = GL.GDKP.Session;

---@class GDKPGoldTradesCreateInterface
GL:tableSet(GL, "Interface.GDKP.GoldTrades.Create", {
    playerGUID = nil,
    sessionID = nil,
    windowName = "Gargul.Interface.GDKP.GoldTrades.Create.Window",
});

---@type GDKPGoldTradesOverviewInterface
local Create = GL.Interface.GDKP.GoldTrades.Create;

--[[ CONSTANTS ]]
local WINDOW_WIDTH = 350;
local WINDOW_HEIGHT = 220;
local FONT;

---@param sessionID string
---@param playerGUID string
---@return Frame|nil
function Create:open(sessionID, playerGUID)
    FONT = GL.FONT;
    self.sessionID = sessionID;
    self.playerGUID = playerGUID;

    local Window = _G[self.windowName] or self:build();

    self:refresh();

    return Window:Show() and Window;
end

---@return Frame
function Create:build()
    if (_G[self.windowName]) then
        return _G[self.windowName];
    end

    ---@type Frame
    local Window = Interface:createWindow(self.windowName, {
        width = WINDOW_WIDTH,
        height = WINDOW_HEIGHT,
        hideResizeButton = true,
        hideMinimizeButton = true,
    });

    --[[ THE SETTINGS MENU IN THE TOP LEFT OF THE WINDOW ]]
    Interface:addWindowOptions(Window, {
        { text = L.CHANGE_SCALE, notCheckable = true, func = function ()
            Interface:openScaler(Window);
            CloseMenus();
        end }
    }, 100);

    --[[ TITLE ]]
    ---@type FontString
    local Title = Interface:createFontString(Window, "");
    Title:SetFont(GL.FONT, 14, "OUTLINE");
    Title:SetPoint("TOPLEFT", Window, "TOPLEFT", 20, -30);
    Window.Title = Title;

    --[[ CURRENT BALANCE ]]
    ---@type FontString
    local Balance = Interface:createFontString(Window, "");
    Balance:SetPoint("TOPLEFT", Title, "BOTTOMLEFT", 0, -4);
    Window.Balance = Balance;

    --[[ GOLD GIVEN ]]
    ---@type FontString
    local GivenLabel = Interface:createFontString(Window, "");
    GivenLabel:SetFont(GL.FONT, 14, "OUTLINE");
    GivenLabel:SetPoint("TOPLEFT", Balance, "BOTTOMLEFT", 0, -30);
    Window.GivenLabel = GivenLabel;

    ---@type EditBox
    local ReceivedInput;
    local GivenInput = Interface:inputBox(Window);
    GivenInput:SetWidth(100);
    GivenInput:SetPoint("CENTER", GivenLabel, "CENTER");
    GivenInput:SetPoint("RIGHT", Window, "RIGHT", -30, 0);
    GivenInput:SetScript("OnTextChanged", function ()
        local text = GivenInput:GetText();
        text = text and text:gsub("[^%d]", "") or "";
        if (not GL:empty(text)) then
            ReceivedInput:SetText("");
        end
        GivenInput:SetText(text);
    end);
    Window.GivenInput = GivenInput;

    --[[ GOLD RECEIVED ]]
    ---@type FontString
    local ReceivedLabel = Interface:createFontString(Window, "");
    ReceivedLabel:SetFont(GL.FONT, 14, "OUTLINE");
    ReceivedLabel:SetPoint("TOPLEFT", GivenLabel, "BOTTOMLEFT", 0, -12);
    Window.ReceivedLabel = ReceivedLabel;

    ---@type EditBox
    ReceivedInput = Interface:inputBox(Window);
    ReceivedInput:SetWidth(100);
    ReceivedInput:SetPoint("CENTER", ReceivedLabel, "CENTER");
    ReceivedInput:SetPoint("RIGHT", Window, "RIGHT", -30, 0);
    ReceivedInput:SetScript("OnTextChanged", function ()
        local text = ReceivedInput:GetText();
        text = text and text:gsub("[^%d]", "") or "";
        if (not GL:empty(text)) then
            GivenInput:SetText("");
        end
        ReceivedInput:SetText(text);
    end);
    Window.ReceivedInput = ReceivedInput;

    --[[ SAVE ]]
    ---@type Button
    local SaveButton = Interface:dynamicPanelButton(Window, "Save");
    SaveButton:SetPoint("TOPLEFT", ReceivedLabel, "BOTTOMLEFT", 0, -20);

    --[[ SET THE SAVE BUTTON ACTION ]]
    SaveButton:SetScript("OnClick", function ()
        local received = tonumber(Window.ReceivedInput:GetText()) or 0;
        local given = tonumber(Window.GivenInput:GetText()) or 0;

        if (received > 0 and given > 0) then
            GL:error("You can't give AND receive gold from the same player at the same time");
            return false;
        end

        if (received <= 0 and given <= 0) then
            GL:error("Set a numeric (positive) amount in gold traded or gold received");
            return false;
        end

        if (not GDKPSession:addGoldTrade(self.sessionID, self.playerGUID, given * 10000, received * 10000)) then
            GL:error("Something went wrong, check your input and try again!");
            return false;
        end

        self:close();
    end);

    return Window;
end

---@return void
function Create:refresh()
    local sessionID = self.sessionID;
    local playerGUID = self.playerGUID;

    local Instance = GDKPSession:byID(sessionID);
    if (not Instance) then
        self.sessionID = nil;
        self.playerGUID = nil;
        return;
    end

    ---@type Frame
    local Window = _G[self.windowName] or self:build();

    --[[ SET THE WINDOW TITLE ]]
    local playerName = GL:disambiguateName(playerGUID, { colorize = true });
    Window.Title:SetText(([[GDKP Session: |c00967FD2%s|r
Player: %s
]]):format(Instance.title, playerName));

    --[[ SHOW THE PLAYER BALANCE ]]
    local balance = "";
    local copperOwedToPLayer = GDKPSession:copperOwedToPlayer(playerGUID, sessionID);
    if (copperOwedToPLayer == 0) then
        balance = playerName;
    elseif (copperOwedToPLayer > 0) then
        balance = ("You owe %s %s"):format(playerName, GL:copperToMoney(copperOwedToPLayer));
    else
        balance = ("%s owes you %s"):format(playerName, GL:copperToMoney(copperOwedToPLayer * -1));
    end
    Window.Balance:SetText(balance);

    --[[ UPDATE THE INPUT LABELS ]]
    Window.GivenLabel:SetText(("Gold |c00967FD2given to|r %s"):format(playerName));
    Window.ReceivedLabel:SetText(("Gold |c00967FD2received from|r %s"):format(playerName));

    --[[ REFRESH INPUTS ]]
    Window.GivenInput:SetText("");
    Window.ReceivedInput:SetText("");
end

---@return void
function Create:close()
    if (self.sessionID) then
        GL.Interface.GDKP.GoldTrades.Overview:open(self.sessionID, self.playerGUID);
    end

    self.sessionID = nil;
    self.playerGUID = nil;
    return _G[self.windowName] and _G[self.windowName]:Hide();
end

---@return Frame
function Create:getWindow()
    return _G[self.windowName];
end