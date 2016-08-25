local ASMJ_RoomFLIntroduce = class("ASMJ_RoomFLIntroduce", function() return cc.Layer:create() end)

-----------------------------------------function OnClickEvent-------------------
function ASMJ_RoomFLIntroduce:OnClickEvent(clickcmd)
    print("ASMJ_RoomFLIntroduce:OnClickEvent " .. clickcmd:getnTag())

    if clickcmd:getnTag() == IDI_BT_ROOM_ENTER_316 then

        assert(self.m_iRoomFLIndex <= CS_MATCH_ROOM_COUNT_316, "error match index")
    
        local strSignUp = ""
        local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    
        if MyUserData.isVip then
            strSignUp = CUtilEx:getString("0_match_signup_prompt10")
        else
            strSignUp = CUtilEx:getString(string.format("0_match_signup_prompt0%d",self.m_iRoomFLIndex))
        end

        if MyUserData then
            local tmMember = {year=MyUserData:GetMemberOverDate().wYear, month=MyUserData:GetMemberOverDate().wMonth, day=MyUserData:GetMemberOverDate().wDay, hour=0, min=0, sec=0, isdst=false}
            local sMemeber = os.time(tmMember)
            local sTM = os.time()
            if sMemeber < sTM then
                strSignUp = CUtilEx:getString("0_match_signup_prompt10")
            end
        end

        local dialog = ASMJ_PopupBox_ShowDialog(strSignUp, "316_popup_ok", "316_popup_cancel", self, self, true)  
        dialog:setTag(IDI_POPUP_MATCH_PROMPT_316)

    elseif clickcmd:getnTag() == IDI_BT_ROOM_RETURN_316 then
        local ani1 = cc.MoveBy:create(0.1, cc.p(0, -20))
        local ani2 = cc.MoveBy:create(0.1, cc.p(0, 20))
        local cal1 = cc.CallFunc:create(handler(self, self.OnKeyBackEvent))
        self.m_btReturn:runAction(cc.Sequence:create(ani1, ani2, cal1))
    end
end

--init()
function ASMJ_RoomFLIntroduce:init(iIndex)
    print("ASMJ_RoomFLIntroduce:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape

    -- content size
    local size = self:getContentSize()
    self:setPosition(size.width / 2, size.height / 2)

    self.m_ptOrigin = cc.p(m_visibleSize.width/2, m_visibleSize.height*3/2)
    self.m_ptFinal = cc.p(m_visibleSize.width/2, m_visibleSize.height/2)

    -- layer color 
    local m_layerColor = cc.LayerColor:create(cc.c4b(0,0,0,100),m_visibleSize.width,m_visibleSize.height)
    self:addChild(m_layerColor)

    -- room indrouce bg
    self.m_pBoard = cc.Sprite:create()
    self.m_pBoard:setContentSize(569, 418)
    self.m_pBoard:setScale(m_scalex, m_scaley)
    self.m_pBoard:setPosition(self.m_ptOrigin)
    self:addChild(self.m_pBoard)

    self.m_iRoomFLIndex = 0
    local pFLDataItem =  ASMJ_CServerManager:GetInstance():GetRoomFLItem(iIndex)
    if pFLDataItem then
        for i=1,CS_MATCH_ROOM_COUNT_316 do
            if pFLDataItem.szServerName == CUtilEx:getString(string.format("316_room_match_name_%d", i)) then
                self.m_iRoomFLIndex = i
                break
            end
        end
    end

    self.m_roomIntroduceBg = cc.Sprite:create(string.format("316_room_information_match%d.png", self.m_iRoomFLIndex))
    assert(self.m_roomIntroduceBg, "error Index for FLRoom Introduce")
    self.m_roomIntroduceBg:setPosition(285, 209)
    self.m_pBoard:addChild(self.m_roomIntroduceBg)

    self.m_roomTitle = cc.Sprite:create(string.format("316_room_match_name_%d.png", self.m_iRoomFLIndex))
    self.m_roomTitle:setPosition(281, 344)
    self.m_pBoard:addChild(self.m_roomTitle, 1)

    -- obtain time
    self.m_dwMatchCurrentServerTime = ASMJ_MyUserItem:GetInstance():GetMatchCurrentServerTime()
    self.m_dwMatchCurrentLocalTime = ASMJ_MyUserItem:GetInstance():GetMatchCurrentLocalTime()
    
    self.m_wStartTime = self:GetMatchTime(iIndex)
    local wRemainTime = self.m_wStartTime - self.m_dwMatchCurrentServerTime - (os.time() - self.m_dwMatchCurrentLocalTime)
    if wRemainTime <= 0 then
        wRemainTime = 0
    end

    local tmMatchTime = os.date("*t",wRemainTime)
    local pFLTimeStr = string.format("%02d:%02d:%02d", (tmMatchTime.hour - 8 + 24)%24, tmMatchTime.min, tmMatchTime.sec)

    local ttfConfig = {}
    ttfConfig.fontFilePath = "default.ttf"
    ttfConfig.fontSize     = 22
    self.m_pTimeLab = cc.Label:createWithTTF(ttfConfig, pFLTimeStr)
    self.m_pTimeLab:setPosition(435, 160)
    self.m_pTimeLab:setColor(cc.c3b(255, 255, 255))
    self.m_pTimeLab:enableOutline(cc.c4b(0,0,0,255), 2)
    self.m_pBoard:addChild(self.m_pTimeLab, 1)

    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.CallFunc:create(handler(self, self.MatchRemainTimeElapse)),
            cc.DelayTime:create(1)
            )
        ))

    local m_btEnter = CImageButton:Create(string.format("316_match_bt_signup_%d.png", self.m_iRoomFLIndex), string.format("316_match_bt_signup_%d.png", self.m_iRoomFLIndex), IDI_BT_ROOM_ENTER_316)
    m_btEnter:setPosition(330, 100)
    m_btEnter:SetEffect(true, BE_SCALE, m_scalex, m_scaley)
    self.m_pBoard:addChild(m_btEnter, 1)

    self.m_btReturn = CImageButton:Create("316_room_return.png", "316_room_return.png", IDI_BT_ROOM_RETURN_316)
    self.m_btReturn:setPosition(538, 275)
    self.m_pBoard:addChild(self.m_btReturn, -1)

    local ani1 = cc.MoveTo:create(0.2, cc.p(self.m_ptFinal.x, self.m_ptFinal.y - 30))
    local ani2 = cc.MoveTo:create(0.05, cc.p(self.m_ptFinal.x, self.m_ptFinal.y + 25))
    local ani3 = cc.MoveTo:create(0.05, cc.p(self.m_ptFinal.x, self.m_ptFinal.y))
    self.m_pBoard:setPosition(self.m_ptOrigin)
    self.m_pBoard:runAction(cc.Sequence:create(ani1, ani2, ani3))

    -- ScriptHandlerMgr
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_btEnter, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btReturn, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    return true
end

--ctor()
function ASMJ_RoomFLIntroduce:ctor(iIndex)
    print("ASMJ_RoomFLIntroduce:ctor")
    self:init(iIndex)
    self:setIgnoreAnchorPointForPosition(false)

    --onEnter
    local function onNodeEvent(event)
      if event == "enter" then
          self:onEnter()
      elseif event == "exit" then
          self:onExit()
      end
    end

    self:registerScriptHandler(onNodeEvent)
end

--create( ... )
function ASMJ_RoomFLIntroduce_create(iIndex)
    print("ASMJ_RoomFLIntroduce_create")
    local layer = ASMJ_RoomFLIntroduce.new(iIndex)
    return layer
end

--onEnter()
function ASMJ_RoomFLIntroduce:onEnter()
    print("ASMJ_RoomFLIntroduce:onEnter")
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--onExit()
function ASMJ_RoomFLIntroduce:onExit()
    print("ASMJ_RoomFLIntroduce:onExit")
end

--touch begin
function ASMJ_RoomFLIntroduce:onTouchBegan(touch, event)
    local size = self.m_pBoard:getBoundingBox()
    local m_bTouched = cc.rectContainsPoint(size, touch:getLocation())
    if not m_bTouched then
       self:OnKeyBackEvent()
    end
    return true
end

--touch end
function ASMJ_RoomFLIntroduce:onTouchEnded(touch, event)

end

--OnKeyBackEvent
function ASMJ_RoomFLIntroduce:OnKeyBackEvent()
    local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()--CClientKernel:GetInstance():GetMyUserData()
    if MyUserData and MyUserData:GetUserStatus() == US_PLAYING then
        return true
    end
 
    CClientKernel:GetInstance():CloseRoomThread()
    
    local ani1 = cc.MoveTo:create(0.2, cc.p(self.m_ptFinal.x, self.m_ptFinal.y - 25))
    local ani2 = cc.MoveTo:create(0.05, cc.p(self.m_ptFinal.x, self.m_ptFinal.y + 30))
    local ani3 = cc.MoveTo:create(0.05, cc.p(self.m_ptOrigin.x, self.m_ptOrigin.y))
    self.m_pBoard:setPosition(self.m_ptFinal)

    self.m_pBoard:runAction(
        cc.Sequence:create(
            ani1,ani2, ani3,
            cc.CallFunc:create(
                function () 
                    local pParentLayer = self:getParent()
                    if pParentLayer == nil then
                        return
                    end
                    pParentLayer:onShowBottom()  
                    self:removeFromParent() 
                end)))
    return true
end


-- match time()
function ASMJ_RoomFLIntroduce:GetMatchTime(iIndex)
    print("ASMJ_RoomFLIntroduce:GetMatchTime")
    
    local pFLDataItem =  ASMJ_CServerManager:GetInstance():GetRoomFLItem(iIndex)
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

function ASMJ_RoomFLIntroduce:MatchRemainTimeElapse()
    local wRemainTime = self.m_wStartTime - self.m_dwMatchCurrentServerTime - (os.time() - self.m_dwMatchCurrentLocalTime)
    if wRemainTime <= 0 then
        wRemainTime = 0
        self:stopAllActions()
    end

    print("wRemainTime", wRemainTime)
    local tmMatchTime = os.date("*t",wRemainTime)
    local pFLTimeStr = string.format("%02d:%02d:%02d", (tmMatchTime.hour - 8 + 24)%24, tmMatchTime.min, tmMatchTime.sec)
    self.m_pTimeLab:setString(pFLTimeStr)
end