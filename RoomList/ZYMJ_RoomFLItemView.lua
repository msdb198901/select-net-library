local ASMJ_RoomFLItemView = class("ASMJ_RoomFLItemView", function() return cc.Layer:create() end)

--init()
function ASMJ_RoomFLItemView:init(iType)

    print("ASMJ_RoomFLItemView:init", iType)
    local m_visibleSize = cc.Director:getInstance():getVisibleSize()
    self.m_scalex = display.scalex_landscape
    self.m_scaley = display.scaley_landscape

    -- online count
    local iRoomFLIndex = 0
    local pFLDataItem =  ASMJ_CServerManager:GetInstance():GetRoomFLItem(iType)
    if pFLDataItem then
        for i=1,CS_MATCH_ROOM_COUNT_316 do
            if pFLDataItem.szServerName == CUtilEx:getString(string.format("316_room_match_name_%d", i)) then
                iRoomFLIndex = i
                break
            end
        end
    end

    -- room fl
    if iRoomFLIndex > 0 then

        local strRoomItem = string.format("316_roomlist_match_%d.png", iRoomFLIndex)
        self.m_roomFLBg = cc.Sprite:create(strRoomItem)
        
        local w = self.m_roomFLBg:getContentSize().width
        local h = self.m_roomFLBg:getContentSize().height

        self:setContentSize(cc.size(w, h))
        self.m_roomFLBg:setPosition(w / 2, h - self.m_roomFLBg:getContentSize().height / 2)
        self.m_roomFLBg:setScale(0.9)
        self:addChild(self.m_roomFLBg, 0)

        -- obtain time
        local wMatchTime = self:GetMatchTime(iType)
        local tmMatchTime = os.date("*t",wMatchTime)
        local pFLTimeStr = string.format("%02d/%02d %02d:%02d:%02d", tmMatchTime.month, tmMatchTime.day, tmMatchTime.hour, tmMatchTime.min, tmMatchTime.sec)

        -- timelab
        local ttfConfig = {}
        ttfConfig.fontFilePath = "default.ttf"
        ttfConfig.fontSize     = 20
        self.m_pFLTimeLabA = cc.Label:createWithTTF(ttfConfig, pFLTimeStr)
        self.m_pFLTimeLabA:setPosition(170, 82)
        self.m_pFLTimeLabA:setColor(cc.c3b(255, 255, 255))
        self.m_pFLTimeLabA:enableOutline(cc.c4b(0,0,0,255), 2)
        self.m_roomFLBg:addChild(self.m_pFLTimeLabA, 3)

        -- match online
        ttfConfig.fontSize     = 22
        self.m_pFLOnLineLabA = cc.Label:createWithTTF(ttfConfig, string.format("%d", pFLDataItem.dwOnLineCount))
        self.m_pFLOnLineLabA:setAnchorPoint(cc.p(0, 0.5))
        self.m_pFLOnLineLabA:setColor(cc.c3b(255, 255, 255))
        self.m_pFLOnLineLabA:enableOutline(cc.c4b(255,0,0,255), 2)
        self.m_pFLOnLineLabA:setPosition(145, 47)
        self.m_roomFLBg:addChild(self.m_pFLOnLineLabA, 1)
    end

    return true
end


--settype()
function ASMJ_RoomFLItemView:SetType(iIndex)
    print("ASMJ_RoomFLItemView:SetType", iIndex)

    -- online count
    local iRoomFLIndex = 0
    local pFLDataItem =  ASMJ_CServerManager:GetInstance():GetRoomFLItem(iIndex)
    if pFLDataItem then
        for i=1,CS_MATCH_ROOM_COUNT_316 do
            if pFLDataItem.szServerName == CUtilEx:getString(string.format("316_room_match_name_%d", i)) then
                iRoomFLIndex = i
                break
            end
        end
    end

    self.m_roomFLBg:setTexture(string.format("316_roomlist_match_%d.png", iRoomFLIndex))
    local w = self.m_roomFLBg:getContentSize().width
    local h = self.m_roomFLBg:getContentSize().height
    self:setContentSize(cc.size(w, h))

    -- obtain time
    local wMatchTime = self:GetMatchTime(iIndex)
    local tmMatchTime = os.date("*t",wMatchTime)
    local pFLTimeStr = string.format("%02d.%02d %02d/%02d/%02d", tmMatchTime.month, tmMatchTime.day, tmMatchTime.hour, tmMatchTime.min, tmMatchTime.sec)

    -- timelab
    self.m_pFLTimeLabA:setString(pFLTimeStr)

    -- online count
    local iOnlineCountFL = 0
    if pFLDataItem then
        iOnlineCountFL = pFLDataItem.dwOnLineCount
    end

    self.m_pFLOnLineLabA:setString(string.format("%d",iOnlineCountFL))
end

-- match time()
function ASMJ_RoomFLItemView:GetMatchTime(iType)
    print("ASMJ_RoomFLItemView:GetMatchTime")
    
    local pFLDataItem =  ASMJ_CServerManager:GetInstance():GetRoomFLItem(iType)
    if not pFLDataItem then
        return 0
    end

    local wMatchTime = 0
    
    if pFLDataItem.cbLoopServiceMode == 1 then
            
        local tServerStart = pFLDataItem.dwServiceTimeStart  
        local tmServerTimeDay = os.date("*t", tServerStart) 

        tmServerTimeDay.sec = 0
        tmServerTimeDay.min = 0
        tmServerTimeDay.hour = 0
        local tServiceTimeDay = os.time(tmServerTimeDay)

        local tCurrentTime = os.time()
        local tmCurrentTime = os.date("*t",tCurrentTime)
        tmCurrentTime.sec = 0
        tmCurrentTime.min = 0
        tmCurrentTime.hour = 0
        local tCurMatchClock = os.time(tmCurrentTime)

        local bCurDay = false
        if tCurrentTime >= tServiceTimeDay and  pFLDataItem.cbServiceDay[tmCurrentTime.wday] == 1 then
            
            local iMatchTimeCount = 20
            local tmCurMatchClock = os.date("*t",tCurrentTime)
           
            for i=1,iMatchTimeCount do
                if pFLDataItem.dwMatchClock[i] == 0 then
                    break
                end

                local tmMatchClock = os.date("*t",pFLDataItem.dwMatchClock[i])

                local tmHMS = {tmMatchClock.hour, tmMatchClock.min, tmMatchClock.sec}

                local tmCurMatchClock = os.date("*t", tCurMatchClock)
                tmCurMatchClock.sec = tmHMS[3]
                tmCurMatchClock.min = tmHMS[2]
                tmCurMatchClock.hour = tmHMS[1]
                tCurMatchClock = os.time(tmCurMatchClock)

                if tCurrentTime < tCurMatchClock then
                    bCurDay = true
                    wMatchTime = tCurMatchClock
                    break
                end
            end
        end

        if not bCurDay then
            local iMatchTimeCount = 20
            local tmCurMatchClock = os.date("*t",tCurrentTime)

            for i=1,iMatchTimeCount do
                if pFLDataItem.dwMatchClock[i] == 0 then
                    break
                end

                local tMatchClock = pFLDataItem.dwMatchClock[i]
                local tmMatchClock = os.date("*t",tMatchClock)

                local tmHMS = {tmMatchClock.hour, tmMatchClock.min, tmMatchClock.sec}
                local tmCurMatchClock = os.date("*t", tCurMatchClock)
                tmCurMatchClock.sec = tmHMS[3]
                tmCurMatchClock.min = tmHMS[2]
                tmCurMatchClock.hour = tmHMS[1]
               
                local tCurMatchClock = os.time(tmCurMatchClock)
                tCurMatchClock = tCurMatchClock + 3600 * 24

                while true do
                    if tCurMatchClock >= tServerStart then
                        break
                    else
                        tCurMatchClock = tCurMatchClock + 3600 * 24
                    end
                end

                for i=1,7 do
                    tmMatchClock = os.date("*t",tCurMatchClock)
                    if pFLDataItem.cbServiceDay[tmMatchClock.wday] == 0 then
                        tCurMatchClock = tCurMatchClock + 3600 * 24
                    else
                        break
                    end
                end

                wMatchTime = tCurMatchClock
                break
            end
        end
    end
   
    return wMatchTime
end

--ctor()
function ASMJ_RoomFLItemView:ctor(iType)
    print("ASMJ_RoomFLItemView:ctor")
    self:init(iType)
    self:setIgnoreAnchorPointForPosition(false)
end

--create( ... )
function ASMJ_RoomFLItemView_create(iType)
    print("ASMJ_RoomFLItemView_create")
    local layer = ASMJ_RoomFLItemView.new(iType)
    return layer
end