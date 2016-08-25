local ASMJ_RoomXSItemView = class("ASMJ_RoomXSItemView", function() return cc.Layer:create() end)

--init()
function ASMJ_RoomXSItemView:init(iIndex)
    print("ASMJ_RoomXSItemView:init")

    local m_visibleSize = cc.Director:getInstance():getVisibleSize()
    self.m_scalex = display.scalex_landscape
    self.m_scaley = display.scaley_landscape

    -- room xs bg
    self.m_roomXSBg = CImageButton:CreateWithSwallow("316_roomlist_xs_bg0.png", "316_roomlist_xs_bg1.png", false, iIndex)
    local w = self.m_roomXSBg:getContentSize().width
    local h = self.m_roomXSBg:getContentSize().height
    self:setContentSize(cc.size(w, h))
    self.m_roomXSBg:setPosition(w / 2, h - self.m_roomXSBg:getContentSize().height / 2)
    self:addChild(self.m_roomXSBg)

    self.m_roomXSImg = cc.Sprite:create(string.format("316_roomlist_xs_img_%d.png", iIndex))
    self.m_roomXSImg:setPosition(w / 2, h - self.m_roomXSBg:getContentSize().height / 2)
    self:addChild(self.m_roomXSImg, 1)

    self.m_roomXSNameImg = cc.Sprite:create(string.format("316_roomlist_xs_name_%d.png", iIndex))
    self.m_roomXSNameImg:setPosition(w / 2, h - 70)
    self:addChild(self.m_roomXSNameImg, 1)

    -- online count
    local iOnlineCountXS = 0
    local pXSDataItem =  ASMJ_CServerManager:GetInstance():GetRoomXSItem(iIndex)
    if pXSDataItem then
        iOnlineCountXS = pXSDataItem.dwOnLineCount
    end

    local ttfConfig = {}
    ttfConfig.fontFilePath = "default.ttf"
    ttfConfig.fontSize     = 27
    self.m_pOnlineCountLabA = cc.Label:createWithTTF(ttfConfig, string.format("%d", iOnlineCountXS))
    self.m_pOnlineCountLabA:setAnchorPoint(cc.p(0, 0.5))
    self.m_pOnlineCountLabA:setPosition(150, 65)
    self.m_pOnlineCountLabA:setColor(cc.c3b(40, 37, 54))
    self:addChild(self.m_pOnlineCountLabA, 2)

    return true
end

--settype()
function ASMJ_RoomXSItemView:SetType(iIndex)
    print("ASMJ_RoomItemlView:SetType", iIndex)

    local pXSRoomItem = ASMJ_CServerManager:GetInstance():GetRoomXSItem(iIndex)

    self.m_roomXSBg:SetImg("316_roomlist_xs_bg0.png", "316_roomlist_xs_bg1.png")
    local w = self.m_roomXSBg:getContentSize().width
    local h = self.m_roomXSBg:getContentSize().height
    self:setContentSize(cc.size(w, h))

    self.m_roomXSImg:setTexture(string.format("316_roomlist_xs_img_%d.png", iIndex))

    self.m_roomXSNameImg:setTexture(string.format("316_roomlist_xs_name_%d.png", iIndex))

    -- online count
    local iOnlineCountXS = 0
    local pXSDataItem =  ASMJ_CServerManager:GetInstance():GetRoomXSItem(iIndex)
    if pXSDataItem then
        iOnlineCountXS = pXSDataItem.dwOnLineCount
    end

    self.m_pOnlineCountLabA:setString(string.format("%d",iOnlineCountXS))
end

--ctor()
function ASMJ_RoomXSItemView:ctor(iIndex)
    cclog("ASMJ_RoomXSItemView:ctor")
    self:init(iIndex)
    self:setIgnoreAnchorPointForPosition(false)
end

--create( ... )
function ASMJ_RoomXSItemView_create(iIndex)
    cclog("ASMJ_RoomXSItemView_create")
    local layer = ASMJ_RoomXSItemView.new(iIndex)
    return layer
end


