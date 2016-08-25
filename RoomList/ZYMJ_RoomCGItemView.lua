local ASMJ_RoomCGItemView = class("ASMJ_RoomCGItemView", function() return cc.Layer:create() end)

--init()
function ASMJ_RoomCGItemView:init(iIndex)
    print("ASMJ_RoomCGItemView:init")

    local m_RoomItem = ASMJ_CServerManager:GetInstance():GetRoomCGItem(iIndex)
    self.m_iType = m_RoomItem.m_iType

    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    self.m_scalex = display.scalex_landscape
    self.m_scaley = display.scaley_landscape
   
    local strRoomItem = string.format("316_room_item_%d.png", self.m_iType)
    self.m_itemBg = cc.Sprite:create(strRoomItem)
    local w = self.m_itemBg:getContentSize().width
    local h = self.m_itemBg:getContentSize().height
    self:setContentSize(cc.size(w, h))

    self.m_itemBg:setPosition(w / 2, h / 2)
    self:addChild(self.m_itemBg)

    if self.m_iType < ERT_FL_316 then
        --online count
        local iPeopleCount = 0
        local pDataItem = nil
        if self.m_iType == ERT_XS_316 then
            local iXSPeopleCount = 0
            local iXSRoomCount = ASMJ_CServerManager:GetInstance():GetRoomXSCount()
            for i=1,iXSRoomCount do
                pDataItem =  ASMJ_CServerManager:GetInstance():GetRoomXSItem(i)
                if pDataItem then
                    iXSPeopleCount = iXSPeopleCount + pDataItem.dwOnLineCount
                end
            end
            iPeopleCount = iXSPeopleCount
        else
            pDataItem = ASMJ_CServerManager:GetInstance():GetRoomCGItem(iIndex)
            if pDataItem then
                iPeopleCount = pDataItem.dwOnLineCount
            end
        end

        --laba
        local ttfConfig = {}
        ttfConfig.fontFilePath = "default.ttf"
        ttfConfig.fontSize     = 25
        self.m_pOnlineCountLabA = cc.Label:createWithTTF(ttfConfig, string.format("%d", iPeopleCount))
        self.m_pOnlineCountLabA:setPosition(120, 69)
        self.m_pOnlineCountLabA:setColor(cc.c3b(240, 240, 255))
        self.m_pOnlineCountLabA:setTag(TAG_ID_ONLINE_COUNT)
        self.m_pOnlineCountLabA:setAnchorPoint(cc.p(0, 0.5))
        self:addChild(self.m_pOnlineCountLabA, 3)
    else

    end

    return true
end

--settype()
function ASMJ_RoomCGItemView:SetType(iIndex)
    print("ASMJ_RoomItemlView:SetType", iIndex)

    local m_RoomItem = ASMJ_CServerManager:GetInstance():GetRoomCGItem(iIndex)
    self.m_iType = m_RoomItem.m_iType

    local strRoomItem = string.format("316_room_item_%d.png", self.m_iType)
    if self.m_itemBg == nil then
        self.m_itemBg = cc.Sprite:create(strRoomItem)
        self:addChild(self.m_itemBg)
    end
    local w = self.m_itemBg:getContentSize().width
    local h = self.m_itemBg:getContentSize().height
    self:setContentSize(cc.size(w, h))

    self.m_itemBg:setTexture(strRoomItem)
    self.m_itemBg:setPosition(w / 2, h / 2)

    if self.m_iType < ERT_FL_316 then
     
        if not self.m_pOnlineCountLabA then
            --online count
            local iPeopleCount = 0
            local pDataItem = nil
            if self.m_iType == ERT_XS_316 then
                local iXSPeopleCount = 0
                local iXSRoomCount = ASMJ_CServerManager:GetInstance():GetRoomXSCount()
                for i=1,iXSRoomCount do
                    pDataItem =  ASMJ_CServerManager:GetInstance():GetRoomXSItem(i)
                    if pDataItem then
                        iXSPeopleCount = iXSPeopleCount + pDataItem.dwOnLineCount
                    end
                end
                iPeopleCount = iXSPeopleCount
            else
                pDataItem = ASMJ_CServerManager:GetInstance():GetRoomCGItem(self.m_iType)
                if pDataItem then
                    iPeopleCount = pDataItem.dwOnLineCount
                end
            end

            self.m_pOnlineCountLabA = cc.Label:createWithTTF(ttfConfig, string.format("%d", iPeopleCount))
            self.m_pOnlineCountLabA:setPosition(120, 69)
            self.m_pOnlineCountLabA:setColor(cc.c3b(240, 240, 255))
            self.m_pOnlineCountLabA:setTag(TAG_ID_ONLINE_COUNT)
            self.m_pOnlineCountLabA:setActionPoint(cc.p(0, 0.5))
            self:addChild(self.m_pOnlineCountLabA, 3)
        end

    else
            
        if self.m_pOnlineCountLabA then
            self.m_pOnlineCountLabA:removeFromParent()
        end
    end
end

--ctor()
function ASMJ_RoomCGItemView:ctor(iIndex)
    cclog("ASMJ_RoomCGItemView:ctor")
    self:init(iIndex)
    self:setIgnoreAnchorPointForPosition(false)
end

--create( ... )
function ASMJ_RoomCGItemView_create(iIndex)
    cclog("ASMJ_RoomCGItemView_create")
    local layer = ASMJ_RoomCGItemView.new(iIndex)
    return layer
end

