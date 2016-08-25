require "src/app/Game/AnShunMaJiang/Game/ASMJ_HandMJControl"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_OtherHandMJControl"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_TableOutMJControl"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_HuMJControl"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_ActionControl"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_OperateControl"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_ScoreControl"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_GameLogic"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_MoveCardItem"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_MatchSystem"

require "src/app/Game/AnShunMaJiang/Game/ASMJ_AvatarView"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_OptionSet"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_ChatView"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_OffLineLayer"

local SID_CurrentUserTimeElapse = {}
local SID_OperateUserTimeElapse = nil
local SID_GameFastRestTimeElapse = nil

local SID_MatchStartTimeElapse = nil
local SID_MatchStatusWaitTimeElapse = nil

local ASMJ_GameClientView = class("ASMJ_GameClientView", function() return cc.Layer:create() end)

-----------------------------------------virtual function-----------------------------
-- OnDialogClickEvent
function ASMJ_GameClientView:OnDialogClickEvent(event)
    print("ASMJ_GameClientView OnDialogClickEvent: tag = " .. event.node:getTag())
   
    if event.node:getTag() == IDI_POPUP_GAME_EXIT_316 then

        if event.clickevent == "ok" then 
            local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()

            if iRoomType <= ERT_GJ_316 then

                CClientKernel:GetInstance():CloseRoomThread()
                
            elseif iRoomType == ERT_FL_316 then
                
                local iRoomStatus = ASMJ_CServerManager:GetInstance():GetEntryRoomStatus()
                if iRoomStatus == ES_FL_Free_316 then
                    CClientKernel:GetInstance():ResetBuffers()
                    CClientKernel:GetInstance():SendSocketToGameServer(MDM_GR_MATCH, SUB_GR_MATCH_QUIT)
                else
                    
                end

                CClientKernel:GetInstance():CloseRoomThread() -- TODO...这里可以优化下（放在上面可以收到消息，放在这里防止bug）
            end

            local reScene = ASMJ_LobbyListScene_createScene(iRoomType)
            if reScene then
                cc.Director:getInstance():replaceScene( cc.TransitionSlideInR:create(TIME_SCENE_CHANGE, reScene) )
            end
        end

    elseif event.node:getTag() == IDI_DIALOG_OK_316 then
        if event.clickevent == "ok" then
            self:BackRoom()
        end
    elseif event.node:getTag() > TAG_DIALOG_REPORT_RESULT_316 and event.node:getTag() <= TAG_DIALOG_REPORT_RESULT_316 + GAME_PLAYER_316 then
        
        local iTagID = event.node:getTag()
        event.node:removeFromParent()

        if event.clickevent == "ok" then

            local pMyItem               = ASMJ_MyUserItem:GetInstance():GetMyUserData()
            local wViewReportID = iTagID - TAG_DIALOG_REPORT_RESULT_316
            local pIClientUserItem = ASMJ_MyUserItem:GetInstance():GetClientUserItem(wViewReportID)
            
            for i=1,#self.m_ReportData do
                if self.m_ReportData[i].dwCheatUserID[1] == pIClientUserItem.dwUserID then
                    local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_report_aleady"), "316_popup_ok", nil, self, nil, true)    
                    dialog:setTag(IDI_POPUP_OK_316)
                    return
                end
            end

            local pReportData           = {}
            local pGameServer           = ASMJ_CServerManager:GetInstance():GetRoomCGItem(ASMJ_CServerManager:GetInstance():GetOnClickRoomIndex())
            pReportData.wKindID         = KIND_ID_316
            pReportData.wServerID       = pGameServer.wServerID
            pReportData.wTableID        = pMyItem:GetTableID()
            pReportData.wChairID        = pMyItem:GetChairID()
            pReportData.dwConcludeTime  = os.time()
            pReportData.dwUserID        = pMyItem:GetUserID() 
            pReportData.lDeposit        = 0

            pReportData.dwCheatUserID   = {}
            pReportData.cbCheatFlags    = {}
            pReportData.cbOnhookFlags   = {}
            pReportData.cbSpiteFlags    = {}
            pReportData.szDescribeString= ""

            for i=1,8 do
                pReportData.dwCheatUserID[i] = 0
                pReportData.cbCheatFlags[i] = 0
                pReportData.cbOnhookFlags[i] = 0
                pReportData.cbSpiteFlags[i] = 0
            end

            
            if pIClientUserItem ~= nil then
                pReportData.dwCheatUserID[1] = pIClientUserItem.dwUserID
                pReportData.cbCheatFlags[1] = 1
            end

            table.insert(self.m_ReportData, pReportData)
        end
    end
end

-----------------------------------------function OnClickEvent-------------------
function ASMJ_GameClientView:OnClickEvent(clickcmd)
    print("ASMJ_GameClientView:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == TAG_BT_GAME_EXIT_316  then
        self:BackRoom()
    elseif clickcmd:getnTag() == TAG_BT_OPTION_SET_316 then
        local ani1 = cc.RotateBy:create(0.5, 270)
        local ani2 = cc.Spawn:create(cc.DelayTime:create(0.2), cc.CallFunc:create(handler(self, self.OptionSet)))
        local ani3 = cc.Sequence:create(ani1, ani2)
        self.m_btSet:runAction(ani3)
    elseif clickcmd:getnTag() > TAG_BT_PLAY_INFO_316 and clickcmd:getnTag() <= TAG_BT_PLAY_INFO_316 + GAME_PLAYER_316 then
        self:PlayInfo(clickcmd:getnTag())
    elseif clickcmd:getnTag() == TAG_BT_STARTGAME_316 then
        self:GameAgain()
    elseif clickcmd:getnTag() == TAG_BT_TING_ALTER_316 then
        self:TingAlter()
    elseif clickcmd:getnTag() == TAG_BT_CHAT_316 then
        self:ChatShow()
    else
        print("click tag unknow")
    end
end

function ASMJ_GameClientView:BackRoom()

    ccexp.AudioEngine:stopAll()
    self:StopViewAllScheduler()

    local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()

    if iRoomType <= ERT_GJ_316 then

        CClientKernel:GetInstance():CloseRoomThread()
        local reScene = ASMJ_LobbyListScene_createScene(iRoomType)
        if reScene then
            cc.Director:getInstance():replaceScene( cc.TransitionSlideInR:create(TIME_SCENE_CHANGE, reScene) )
        end

    elseif iRoomType == ERT_FL_316 then

        self:onQueryKeyBack()

    end
end

function ASMJ_GameClientView:OptionSet()
    local optionSetLayer = ASMJ_OptionSet_create()    
    self:addChild(optionSetLayer, 800)
end

function ASMJ_GameClientView:PlayInfo(iTag)
    if  iTag == TAG_BT_PLAY_INFO_316 + MYSELF_VIEW_ID_316 then
        self:OnStustee()
    else
        local wViewChairID = iTag - TAG_BT_PLAY_INFO_316
        local pIClientUserItem = ASMJ_MyUserItem:GetInstance():GetClientUserItem(wViewChairID)
        if pIClientUserItem == nil then
            return
        end
        local pAvatarView = ASMJ_AvatarView_create(wViewChairID)
        self:addChild(pAvatarView, 1000)
    end
end

function ASMJ_GameClientView:TingAlter()
    self.m_bTingAlter = not self.m_bTingAlter
    self.m_pTingAlter:setVisible(self.m_bTingAlter)
    self.m_pTingCancle:setVisible(not self.m_bTingAlter)
    self.m_cbListenStatus = 3
    if self.m_bTingAlter then
        self.m_cbListenStatus = 2
    end
end

function ASMJ_GameClientView:ChatShow()
    local chatViewLayer = self:getChildByTag(TAG_ID_CHAT_SHOW_316)
    if chatViewLayer == nil then
        chatViewLayer = ASMJ_ChatView_create()
        self:addChild(chatViewLayer, 1000, TAG_ID_CHAT_SHOW_316)
    end
end

function ASMJ_GameClientView:onQueryKeyBack()

    local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_room_exit"), "316_popup_ok", "316_popup_cancel", self, self, true)    
    dialog:setTag(IDI_POPUP_GAME_EXIT_316)

end

--init()
function ASMJ_GameClientView:init()
    print("ASMJ_GameClientView:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    self.m_scalex = display.scalex_landscape
    self.m_scaley = display.scaley_landscape

    local iRoomType = ASMJ_CServerManager:GetInstance():GetEntryRoomStatus()
    if iRoomType == ES_CG_Free_316 or iRoomType == ES_XS_Free_316 or iRoomType == ES_FL_Free_316 or iRoomType == ES_FL_Play_Free_316 then
        
        local pGameBg = cc.Sprite:create("316_table_bg.png")
        pGameBg:setPosition(m_visibleSize.width / 2, m_visibleSize.height / 2)
        pGameBg:setScale(self.m_scalex, self.m_scaley)
        self:addChild(pGameBg, ZORDER_BACK_VIEW_316)

        if iRoomType ~= ES_FL_Play_Free_316 then

            local btBack = CImageButton:Create("316_room_return1.png", "316_room_return0.png", TAG_BT_GAME_EXIT_316)
            btBack:setScale(self.m_scalex, self.m_scaley)
            btBack:setPosition( cc.p(100 * self.m_scalex, m_visibleSize.height - 80 * self.m_scaley))
            self:addChild(btBack, ZORDER_BACK_VIEW_316 + 3)
            -- ScriptHandlerMgr
            ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btBack, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
        end

        if iRoomType == ES_XS_Free_316 or iRoomType == ES_CG_Free_316 or iRoomType == ES_FL_Play_Free_316 then
            
            local pWaitTitle = cc.Sprite:create("316_wait_title.png")
            pWaitTitle:setPosition(m_visibleSize.width / 2, m_visibleSize.height / 2)
            pWaitTitle:setScale(self.m_scalex, self.m_scaley)
            self:addChild(pWaitTitle, ZORDER_BACK_VIEW_316 + 1)

        end

        if iRoomType == ES_FL_Free_316 then
            self:GameStartTime()
        end
    else
        self:Reset()
        self:OnEventSceneMessage()
    end

    return true
end

-- match time()
function ASMJ_GameClientView:GetMatchTime(iType)
    print("ASMJ_GameClientView:GetMatchTime")
    
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

-- match time()
function ASMJ_GameClientView:GameStartTime()
    print("ASMJ_GameClientView:GetMatchTime")
    
    local visible = cc.Director:getInstance():getVisibleSize()

    local iXPos = visible.width / 2 - 175 * self.m_scalex
    local iYPos = visible.height / 2 + 100 * self.m_scaley

    --obtain match time
    self.m_dwMatchCurrentServerTime = ASMJ_MyUserItem:GetInstance():GetMatchCurrentServerTime()
    self.m_dwMatchCurrentLocalTime = ASMJ_MyUserItem:GetInstance():GetMatchCurrentLocalTime()
    
    local iIndex = ASMJ_CServerManager:GetInstance():GetOnClickRoomIndex()
    self.m_wMatchStartTime = self:GetMatchTime(iIndex)

    local wRemainTime = self.m_wMatchStartTime - self.m_dwMatchCurrentServerTime - (os.time() - self.m_dwMatchCurrentLocalTime)
    if wRemainTime <= 0 then
        wRemainTime = 0
    end

    local tmMatchTime = os.date("*t",wRemainTime)
    local strRemainTime = string.format("%s%02d:%02d:%02d", CUtilEx:getString("0_match_start_info1"), (tmMatchTime.hour - 8 + 24)%24, tmMatchTime.min, tmMatchTime.sec)

    self.m_pMatchStartTime = cc.LabelTTF:create(strRemainTime, "Arial", 40)
    self.m_pMatchStartTime:setColor(cc.c3b(255, 183, 70))
    self.m_pMatchStartTime:setScale(self.m_scalex, self.m_scaley)
    self.m_pMatchStartTime._eHorizAlign = cc.TEXT_ALIGNMENT_CENTER
    self.m_pMatchStartTime:setPosition(visible.width / 2, iYPos)
    self:addChild(self.m_pMatchStartTime, ZORDER_FACE_316)
    
    iYPos = iYPos - 150 * self.m_scaley
    local pGameTitle = cc.LabelTTF:create(CUtilEx:getString("316_app_name"), "Arial", 30)
    pGameTitle:setScale(self.m_scalex, self.m_scaley)
    pGameTitle:setColor(cc.c3b(255, 183, 70))
    pGameTitle:setAnchorPoint(cc.p(0.5, 0.5))
    pGameTitle:setPosition(visible.width / 2, iYPos)
    self:addChild(pGameTitle, ZORDER_FACE_316)

    iYPos = iYPos - 50 * self.m_scaley
    local pLunInfo = cc.LabelTTF:create(CUtilEx:getString("0_match_start_info2"), "Arial", 30)
    pLunInfo:setScale(self.m_scalex, self.m_scaley)
    pLunInfo:setColor(cc.c3b(255, 183, 70))
    pLunInfo:setAnchorPoint(cc.p(0.5, 0.5))
    pLunInfo:setPosition(visible.width / 2, iYPos)
    self:addChild(pLunInfo, ZORDER_FACE_316)

    local scheduler = cc.Director:getInstance():getScheduler()
    SID_MatchStartTimeElapse = scheduler:scheduleScriptFunc(handler(self, self.MatchStartTimeElapse), 1, false)
end

function ASMJ_GameClientView:MatchStartTimeElapse(dt)
    local wRemainTime = self.m_wMatchStartTime - self.m_dwMatchCurrentServerTime - (os.time() - self.m_dwMatchCurrentLocalTime)
    if wRemainTime <= 0 and SID_MatchStartTimeElapse ~= nil then
        wRemainTime = 0
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(SID_MatchStartTimeElapse)
        SID_MatchStartTimeElapse = nil
    end

    local tmMatchTime = os.date("*t",wRemainTime)
    local strRemainTime = string.format("%s%02d:%02d:%02d", CUtilEx:getString("0_match_start_info1"), (tmMatchTime.hour - 8 + 24)%24, tmMatchTime.min, tmMatchTime.sec)
    self.m_pMatchStartTime:setString(strRemainTime)
end

--ctor()
function ASMJ_GameClientView:ctor()
    print("ASMJ_GameClientView:ctor")

    self:init()
  
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

--[====[   ASMJ_GameClientView_createScene()  ]====]
function ASMJ_GameClientView_createScene()
    cclog("ASMJ_GameClientView_createScene")
    local scene = cc.Scene:create()
    scene:addChild(ASMJ_GameClientView.new(), 0)
    return scene
end

--onEnter()
function ASMJ_GameClientView:onEnter()
    
    cclog("ASMJ_GameClientView:onEnter")
    -- touch
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    -- ondialog
    local eventDispatcher = self:getEventDispatcher()
    local listenerDialog = nil
    listenerDialog = cc.EventListenerCustom:create("OnDialogClickEvent", handler(self, self.OnDialogClickEvent))
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenerDialog, self)

    -- handermessage
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(CClientKernel:GetInstance(), "cc.Ref"), handler(self, self.HanderMessage), cc.Handler.EVENT_CUSTOMCMD)
end

--onExit()
function ASMJ_GameClientView:onExit()
    print("ASMJ_GameClientView:onExit")
    self:StopViewAllScheduler()
end

--touch begin
function ASMJ_GameClientView:onTouchBegan(touch, event)
    if self.gameStatus ~= Game_PlayGame_316 then
        return false
    end

    if self.m_bStustee then
        self:OnStustee() 
    end

    if not self.m_HandCardControl.m_bPositive then
        return false
    end

    local iMJWidth = 0
    local iMJHeight = 0

    for i=1,#self.m_HandCardControl.m_HandMJData do

        if self.m_HandCardControl.m_HandMJData[i].m_bGray then
        else
            iMJWidth = self.m_HandCardControl.m_HandMJData[i].m_pSpriteMJBack:getBoundingBox().width
            iMJHeight = self.m_HandCardControl.m_HandMJData[i].m_pSpriteMJBack:getBoundingBox().height

            local rtTouch = cc.rect(self.m_HandCardControl.m_HandMJData[i].m_pSpriteMJBack:getPositionX(), self.m_HandCardControl.m_HandMJData[i].m_pSpriteMJBack:getPositionY() - iMJHeight / 2, iMJWidth, iMJHeight)
            
            if cc.rectContainsPoint(rtTouch, cc.p(touch:getLocation().x, touch:getLocation().y)) then
                
                if self.m_HandCardControl.m_HandMJData[i].m_bSelect and self.m_wCurrentUser == ASMJ_MyUserItem:GetInstance():GetChairID() then
                    if not(self.m_cbListenStatus > 0 and (not self.m_bWillHearStatus)) then
                        assert(#self.m_HandCardControl.m_HandMJData, "error mj data is empty")
                        local cbCardData = self.m_HandCardControl.m_HandMJData[i].m_cbHandMJData
                        assert(self.m_cbCardIndex[ASMJ_GameLogic:GetInstance():SwitchToCardIndex(cbCardData)] > 0, "error mj index is nil")
                        self:OnHandOutMJ(cbCardData, i, 1)
                        break
                    end
                end

                self.m_iMJIndex_down = i
                self.m_HandCardControl:SetMJShoot(i, true)
                
            elseif self.m_HandCardControl.m_HandMJData[i].m_bSelect then
                self.m_HandCardControl:SetMJShoot(i, false)
            end
        end
    end

    return true
end

--touch move
function ASMJ_GameClientView:onTouchMoved(touch, event)
    if self.gameStatus ~= Game_PlayGame_316 then
        return
    end
    
    if self.m_bStustee then
        return
    end

    if not self.m_HandCardControl.m_bPositive then
        return
    end

    local iMJWidth = 0
    local iMJHeight = 0

    for i=1,#self.m_HandCardControl.m_HandMJData do
        
        if self.m_HandCardControl.m_HandMJData[i].m_bGray then
        else
            iMJWidth = self.m_HandCardControl.m_HandMJData[i].m_pSpriteMJBack:getBoundingBox().width
            iMJHeight = self.m_HandCardControl.m_HandMJData[i].m_pSpriteMJBack:getBoundingBox().height

            local rtTouch = cc.rect(self.m_HandCardControl.m_HandMJData[i].m_pSpriteMJBack:getPositionX(), self.m_HandCardControl.m_HandMJData[i].m_pSpriteMJBack:getPositionY() - iMJHeight / 2, iMJWidth, iMJHeight)
            if cc.rectContainsPoint(rtTouch, cc.p(touch:getLocation().x, touch:getLocation().y)) then   
                self.m_iMJIndex_down = i
                self.m_HandCardControl:SetMJShoot(i, true)
                break
            end
        end
    end

    for i=1,#self.m_HandCardControl.m_HandMJData do
        if self.m_HandCardControl.m_HandMJData[i].m_bGray then
        elseif self.m_HandCardControl.m_HandMJData[i].m_bSelect then
            if self.m_iMJIndex_down ~= i then
                self.m_HandCardControl:SetMJShoot(i, false)
            end
        end
    end
end

--touch end
function ASMJ_GameClientView:onTouchEnded(touch, event)
    if self.gameStatus == Game_PlayGame_316 then

        if self.m_iMJIndex_down <= #self.m_HandCardControl.m_HandMJData then

            if self.m_HandCardControl.m_HandMJData[self.m_iMJIndex_down].m_bSelect and self.m_wCurrentUser == ASMJ_MyUserItem:GetInstance():GetChairID() then 

                if touch:getLocation().y  > self.m_HandCardControl.m_HandMJData[self.m_iMJIndex_down].m_pSpriteMJBack:getPositionY() + 40 * self.m_scaley then
                   
                    --assert(#self.m_HandCardControl.m_HandMJData)
                    local cbCardData = m_HandCardControl.m_HandMJData[self.m_iMJIndex_down].m_cbHandMJData
                    assert(self.m_cbCardIndex[ASMJ_GameLogic:GetInstance():SwitchToCardIndex(cbCardData)] > 0, "error mj index is nil")
                    self:OnHandOutMJ(cbCardData, self.m_iMJIndex_down, 1)
                end
            end
            self.m_iMJIndex_down = INVALID_ITEM_316
        end
    end
end

----------------------------------------------------------------------------------
-----------------------------------------function HanderMessage-------------------
function ASMJ_GameClientView:HanderMessage(msgcmd)
    print("ASMJ_RoomCGListScene:HanderMessage main:%d, sub=%d, len=%d", msgcmd:getMainCmdID(), msgcmd:getSubCmdID(), msgcmd:getLen())
    if msgcmd:getMainCmdID() == MDM_GF_TASK then
        self:OnTaskEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GF_FRAME then
        self:OnFrameEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GF_GAME  then
        self:OnGameEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GR_HEART_BEAT then
        self:OnHeartEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GR_MATCH then
        self:OnMatchEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GR_FAST_MODE then
        self:OnFastEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GR_USER then
        self:OnUserEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GR_LOGON then
        self:OnLoginEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_IPHONE_MESSAGE then
        self:OnIphoneEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_SOCKET_ERROR then
        self:OnSocketError(msgcmd)
    end
end

-- OnTaskEvent
function ASMJ_GameClientView:OnTaskEvent(msgcmd)

end

-- OnFrameEvent
function ASMJ_GameClientView:OnFrameEvent(msgcmd)
    print("OnFrameEvent========================", msgcmd:getSubCmdID())
    if msgcmd:getSubCmdID() == SUB_GF_GAME_STATUS then

        local pOffLine = ASMJ_MyUserItem:GetInstance():GetOffLine()
        pOffLine.cbGameStatus = msgcmd:readBYTE()
        print("cbGameStatus", pOffLine.cbGameStatus)

    elseif msgcmd:getSubCmdID() == SUB_GF_GAME_SCENE then 

        local pOffLine = ASMJ_MyUserItem:GetInstance():GetOffLine()  
        if pOffLine.cbGameStatus == GS_MJ_FREE_316 then

        elseif pOffLine.cbGameStatus == GS_MJ_PLAY_316 then
            ASMJ_MyUserItem:GetInstance():SetOffLine(msgcmd)
            self:Reset()
            self:OnEventSceneMessage()
        end

    elseif msgcmd:getSubCmdID() == SUB_GF_USER_CHAT then
        
        -- read data
        local wChatLength       = msgcmd:readWORD()
        local dwChatColor       = msgcmd:readDWORD()
        local dwSendUserID      = msgcmd:readDWORD()
        local dwTargetUserID    = msgcmd:readDWORD()
        local szChatString      = CMCipher:g2u_forlua(msgcmd:readChars(32), 32)
        -------

        local pUserInfo = ASMJ_ClientUserManager:GetInstance():SeachByUserID(dwSendUserID)
        local wChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(pUserInfo.wChairID)
        self:TranslateInsertString(wChairID, szChatString)

    elseif msgcmd:getSubCmdID() == SUB_GF_USER_REPORT_RESULT then

        local lResultCode = msgcmd:readLONG()
        if lResultCode == 0 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_report_success"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
        end
    end
end

function ASMJ_GameClientView:TranslateInsertString(wChairID, szChatString)
    
    local pNode = self:getChildByTag(TAG_ID_CHAT_MESSAGE_316 + wChairID)
    if pNode ~= nil then
        pNode:removeFromParent()
    end

    local szChatString1, gsubCount = string.gsub(szChatString, "PY00", "316_chat_face_0")
    if Direction_West_316 == wChairID then
        szChatString1, gsubCount = string.gsub(szChatString, ".", "b.")
    end

    if szChatString1 == nil or szChatString1 == "" then
        return 
    end

    local nXCurrentPos, nYCurrentPos = 0, 0
    local pFaceName = cc.Sprite:create(szChatString1)

    if wChairID == Direction_North_316 then
        nXCurrentPos = self.m_ptAvatar[wChairID].x + 80 * self.m_scalex
        nYCurrentPos = self.m_ptAvatar[wChairID].y - 50 * self.m_scaley
        pFaceName:setAnchorPoint(cc.p(0, 0))
    elseif wChairID == Direction_East_316 or wChairID == Direction_South_316 then
        nXCurrentPos = self.m_ptAvatar[wChairID].x + 90 * self.m_scalex
        nYCurrentPos = self.m_ptAvatar[wChairID].y
        pFaceName:setAnchorPoint(cc.p(0, 0.5))
    elseif wChairID == Direction_West_316 then
        nXCurrentPos = self.m_ptAvatar[wChairID].x - 90*self.m_scalex
        nYCurrentPos = self.m_ptAvatar[wChairID].y
        pFaceName:setAnchorPoint(cc.p(1, 0.5))
    end
    
    pFaceName:setScale(self.m_scalex, self.m_scaley)
    pFaceName:setTag(TAG_ID_CHAT_MESSAGE_316 + wChairID)
    pFaceName:setPosition(nXCurrentPos, nYCurrentPos)
    self:addChild(pFaceName, ZORDER_ACTION_316)

    pFaceName:runAction(cc.Sequence:create(cc.FadeIn:create(0.1), cc.DelayTime:create(3), cc.FadeOut:create(1), cc.CallFunc:create(function () pFaceName:removeFromParent() end)))
end

-- OnEventSceneMessage
function ASMJ_GameClientView:OnEventSceneMessage()

    local pOffLine = ASMJ_MyUserItem:GetInstance():GetOffLine()
    --------------------------------------------------------
    -- set operate status
    self.gameStatus = Game_PlayGame_316
    local Visible = cc.Director:getInstance():getVisibleSize()
   
    -- read scene data
    self.m_lCellScore           =  pOffLine.lCellScore
    self.m_wBankerUser          =  pOffLine.wBankerUser      
    self.m_wCurrentUser         =  pOffLine.wCurrentUser
    self.m_wTimeCount           =  pOffLine.wTimeCount

    local wFirstChickenUser     =  pOffLine.wFirstChickenUser
    self.m_cbFirstChicken       =  pOffLine.cbFirstChicken

    self.m_cbActionCard         =  pOffLine.cbActionCard
    self.m_cbActionMask         =  pOffLine.cbActionMask
    
    local cbHearStatus          = {}
    for i=1,GAME_PLAYER_316 do
        cbHearStatus[i]         =  pOffLine.cbHearStatus[i]
    end

    self.m_cbLeftCardCount      =  pOffLine.cbLeftCardCount

    local bTrustee              = {}
    for i=1,GAME_PLAYER_316 do
        bTrustee[i]             =  pOffLine.bTrustee[i]
    end

    local wOutCardUser          =  pOffLine.wOutCardUser
    local cbOutCardData         =  pOffLine.cbOutCardData
    local cbDiscardCount        = {}
    for i=1,GAME_PLAYER_316 do
        cbDiscardCount[i]       =  pOffLine.cbDiscardCount[i]
    end

    local cbDiscardCard         = {}
    for i=1,GAME_PLAYER_316 do
        cbDiscardCard[i]        = {}
        for j=1,60 do
            cbDiscardCard[i][j] =  pOffLine.cbDiscardCard[i][j]
        end
    end

    local cbCardCount           =  pOffLine.cbCardCount
    local cbCardData            = {}
    for i=1,MAX_COUNT_316 do
        cbCardData[i]           =  pOffLine.cbCardData[i]
    end

    local cbSendCardData        =  pOffLine.cbSendCardData
    self.m_cbWeaveCount         = {}
    for i=1,GAME_PLAYER_316 do
        self.m_cbWeaveCount[i]  =  pOffLine.cbWeaveCount[i]
    end

    self.m_WeaveItemArray       = {}
    for i=1,GAME_PLAYER_316 do
        self.m_WeaveItemArray[i]    = {}
        for j=1,MAX_WEAVE_316 do
            self.m_WeaveItemArray[i][j] = {}
            self.m_WeaveItemArray[i][j].cbWeaveKind     = pOffLine.WeaveItemArray[i][j].cbWeaveKind
            self.m_WeaveItemArray[i][j].cbCenterCard    = pOffLine.WeaveItemArray[i][j].cbCenterCard
            self.m_WeaveItemArray[i][j].cbPublicCard    = pOffLine.WeaveItemArray[i][j].cbPublicCard
            self.m_WeaveItemArray[i][j].wProvideUser    = pOffLine.WeaveItemArray[i][j].wProvideUser
            self.m_WeaveItemArray[i][j].cbCardData      = {}
            for z=1,GAME_PLAYER_316 do
                self.m_WeaveItemArray[i][j].cbCardData[z] = pOffLine.WeaveItemArray[i][j].cbCardData[z]
            end
        end
    end
    --------------------------------------------
    self.m_scalex = display.scalex_landscape
    self.m_scaley = display.scaley_landscape

    local m_TableMJBack = cc.Sprite:create("316_table_bg.png")
    m_TableMJBack:setScale(self.m_scalex, self.m_scaley)
    m_TableMJBack:setPosition(Visible.width / 2, Visible.height / 2)
    self:addChild(m_TableMJBack, ZORDER_BACK_VIEW_316)

    self:RectifyControl(Visible.width, Visible.height)
    self:DrawUserView()
    self:CellBanker()

    self.m_pTimeBack:setVisible(true)
    self.m_pTimerNumber:setVisible(true)

    local iType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
    if iType == ERT_FL_316 then
        local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()
        self.m_MatchControl = ASMJ_MatchControl_create()

        self.m_MatchControl:SetScaleMin(self.m_scalex, self.m_scaley)
        self.m_wMatchTime = pMatchAttribute.dwMatchTime
        if self.m_MatchControl:GetMatchTime() > 0 then
            self.m_wMatchTime = self.m_MatchControl:GetMatchTime()
        end

        self.m_MatchControl:SetMatchTime(self.m_wMatchTime)
        self.m_MatchControl:setTag(TAG_ID_MATCH_CONTROL_316)
        self.m_MatchControl:ShowMatch(cc.p(Visible.width / 2, 355 * self.m_scaley))
        self:addChild(self.m_MatchControl, 0)
    end
    ------------------------------------------------------
    if self:getChildByTag(TAG_ID_START_MJ_316) ~= nil then
        self.m_pStartMJBack:removeFromParent()
    end
    self.m_HandCardControl.m_bPositive = true

    local pOffLayer = self:getChildByTag(TAG_ID_OFFLINE_LAYER_316)
    if pOffLayer ~= nil then
        pOffLayer:removeFromParent()
    end

    self.m_pLeftMJNumber:setString(string.format("%d", self.m_cbLeftCardCount))
    ASMJ_GameLogic:GetInstance():SwitchTableToCardIndex(cbCardData, cbCardCount, self.m_cbCardIndex)

    for i=1,GAME_PLAYER_316 do
        local wOperateViewID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(i)
        self.m_HuMJControl[wOperateViewID]:HuMJClear()

        for j=1,self.m_cbWeaveCount[i] do
            local cbWeaveKind = self.m_WeaveItemArray[i][j].cbWeaveKind
            local cbCenterCard = self.m_WeaveItemArray[i][j].cbCenterCard
            local cbWeaveCardCount = bit:_and(cbWeaveKind, WIK_PENG_316) ~= 0 and 3 or 4
            
            local iHuType = (self.m_WeaveItemArray[i][j].cbPublicCard == 1 and 1 or 3) + 3
            
            if cbWeaveCardCount == 3 then
                iHuType = HT_PENG_316
            end
            if cbWeaveCardCount == 4 and self.m_WeaveItemArray[i][j].wProvideUser == i then
                iHuType = HT_ZIMO_GANG_316
            end

            if self.m_WeaveItemArray[i][j].cbCenterCard ~= 0 then
               self.m_HuMJControl[wOperateViewID]:DrawHuControl(
                    self.m_WeaveItemArray[i][j].cbCenterCard, 
                    iHuType, 
                    cc.p(0, 0),
                    ASMJ_MyUserItem:GetInstance():SwitchViewChairID(self.m_WeaveItemArray[i][j].wProvideUser),
                    false, false)
            end
        end
    end

    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    for i=1,GAME_PLAYER_316 do
        if i ~= wMeChairID then
            
            local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(i)
            local wViewChairIndex = wViewChairID > 3 and 3 or wViewChairID
            self.m_OtherPlayerHandMJ[wViewChairIndex]:OtherHandMJClear()

            local cbCardCount = MAX_COUNT_316 - self.m_cbWeaveCount[i] * 3 - 1 + (self.m_wCurrentUser == i and 1 or 0)

            if wViewChairIndex == 2 then
                self.m_OtherPlayerHandMJ[2]:SetOriginControlPoint(145 * self.m_scalex, Visible.height - 130 * self.m_scaley)
            end
            if wViewChairIndex == 3 then
                self.m_OtherPlayerHandMJ[3]:SetOriginControlPoint(Visible.width - 145 * self.m_scalex, 215 * self.m_scaley)
            end

            self.m_OtherPlayerHandMJ[wViewChairIndex].m_CurrentMJPoint = self.m_HuMJControl[wViewChairID]:GetLastHuMJPoint()
            self.m_OtherPlayerHandMJ[wViewChairIndex]:DrawUserHandMJ(cbCardCount, cbCardCount % 3 == 2)
        end
    end
    
    self.m_HandCardControl:HandMJClear()
    
    if #self.m_HuMJControl[MYSELF_VIEW_ID_316].m_HuMJSprite > 0 then
        self.m_HandCardControl.m_CurrentMJPoint.x = self.m_HuMJControl[MYSELF_VIEW_ID_316]:GetLastHuMJPoint().x
    end

    self.m_HandCardControl:DrawHandMJ(cbCardData, cbCardCount, cbCardCount % 3 == 2)

    local cbFirstChicked = 1
    for i=1,GAME_PLAYER_316 do
        self.m_pTimeXYZ[i]:setVisible(false)

        local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(i)
        self.m_TableOutMJControl[wViewChairID]:TableOutMJClear()
        self.m_TableOutMJControl[wViewChairID]:SetRoundSprite()

        for j=1,cbDiscardCount[i] do
            if wFirstChickenUser == i and cbDiscardCard[i][j] == 17 then
                self.m_TableOutMJControl[wViewChairID]:DrawOutMJControl(cbDiscardCard[i][j], cbFirstChicked, cc.p(Visible.width / 2, Visible.height / 2))
                cbFirstChicked = 0
            else
                self.m_TableOutMJControl[wViewChairID]:DrawOutMJControl(cbDiscardCard[i][j], 0, cc.p(Visible.width / 2, Visible.height / 2))
            end
        end
    end
    
    if wOutCardUser ~= INVALID_CHAIR_316 then
       
        local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wOutCardUser)
        local ptDisc = cc.p(self.m_TableOutMJControl[wViewChairID]:GetOutMJPoint())
        self.m_pDiscUser:setPosition(ptDisc.x, ptDisc.y + 30 * self.m_scaley)
        self.m_pDiscUser:stopAllActions()

        local seqDisc = cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.8), cc.Show:create(),
                cc.CallFunc:create(
                    function ()
                        local pMove1 = cc.MoveTo:create(0.8, cc.p(self.m_pDiscUser:getPositionX(), self.m_pDiscUser:getPositionY()))
                        local pMove2 = cc.MoveTo:create(0.8, cc.p(self.m_pDiscUser:getPositionX(), self.m_pDiscUser:getPositionY() + 15 * self.m_scaley))
                        local seqMove = cc.Sequence:create(pMove2, pMove1)
                        local pRepeat = cc.RepeatForever:create(seqMove)
                        self.m_pDiscUser:runAction(pRepeat)
                    end))
        self.m_pDiscUser:runAction(seqDisc)
        self.m_TableOutMJControl[wViewChairID]:DrawOutMJControl(cbOutCardData, 0, cc.p(Visible.width / 2, Visible.height / 2))
    end

    if self.m_cbActionMask ~= WIK_NULL_316 then

        self.m_wOperateUser[wMeChairID] = 1
        local GangCardResult = {}
        GangCardResult.cbCardData = {}
        GangCardResult.cbCardCount = 0

        if bit:_and(self.m_cbActionMask, WIK_GANG_316) ~= 0 then
            
            if self.m_cbListenStatus == 0 then
                if self.m_bStustee then
                    self:OnStustee()
                end
            end

            if self.m_wCurrentUser == INVALID_CHAIR_316 and self.m_cbActionCard ~= 0 then
                GangCardResult.cbCardCount = 1
                GangCardResult.cbCardData[1] = self.m_cbActionCard
            end

            if self.m_wCurrentUser == wMeChairID or self.m_cbActionCard == 0 then
                ASMJ_GameLogic:GetInstance():AnalyseGangCard(self.m_cbCardIndex, self.m_WeaveItemArray[wMeChairID], self.m_cbWeaveCount[wMeChairID], self.m_cbEnjoinGangCard, GangCardResult)
            end
        end
        if self.m_cbListenStatus == 0 then
            self.m_OperateControl:SetOperateControl(self.m_cbActionCard, self.m_cbActionMask, GangCardResult)
        end
        
        if self.m_wCurrentUser == INVALID_CHAIR_316 then
            local scheduler = cc.Director:getInstance():getScheduler()
            SID_OperateUserTimeElapse = scheduler:scheduleScriptFunc(handler(self, self.OperateUserTimeElapse), 1, false)
        end
    end

    if self.m_wCurrentUser ~= INVALID_CHAIR_316 then
        self.m_pTimeXYZ[ASMJ_MyUserItem:GetInstance():SwitchViewChairID(self.m_wCurrentUser)]:setVisible(true)
        local scheduler = cc.Director:getInstance():getScheduler()
        SID_CurrentUserTimeElapse[#SID_CurrentUserTimeElapse+1] = scheduler:scheduleScriptFunc(handler(self, self.CurrentUserTimeElapse), 1, false)
    end
    
    self.m_wTimeOutCount = 0
    for i=1,GAME_PLAYER_316 do
    
        local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(i)
        local pBtAvatar = self:getChildByTag(TAG_BT_PLAY_INFO_316 + wViewChairID)

        if pBtAvatar ~= 0 then

            if bTrustee[i] == 1 then

                pBtAvatar:setPosition(self.m_ptTrusteeAvatar[wViewChairID])
                pBtAvatar:setSpriteFrame("316_Trustee_Head0.png")

                local animation =cc.Animation:create()
                for i=0,2 do
                    local szName =string.format("316_Trustee_Head%d.png",i)
                    local pSpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(szName)
                    animation:addSpriteFrame(pSpriteFrame)
                end  
           
                animation:setDelayPerUnit(2.0/7.0)
                animation:setRestoreOriginalFrame(true)    --

                local action =cc.Animate:create(animation) 
                local seqShowHand = cc.Sequence:create(cc.DelayTime:create(0.5), action)
                pBtAvatar:runAction(cc.RepeatForever:create(seqShowHand))

            else
                pBtAvatar:stopAllActions()
                pBtAvatar:setPosition(self.m_ptNormalAvatar[wViewChairID])
                pBtAvatar:setSpriteFrame(self.m_strFaceID[wViewChairID])
            end
        end
    end

    -- if bReEnter then
        for i=1,GAME_PLAYER_316 do
            if cbHearStatus[i] > 0 then
                self:OnSubListen(i)
            end
        end
    -- end

    if bTrustee[wMeChairID] == 1 then
        self.m_bStustee = true
        self:OnStustee()
    end
end

-- OnGameEvent
function ASMJ_GameClientView:OnGameEvent(msgcmd)
    if msgcmd:getSubCmdID() == SUB_S_GAME_START then
        self:Reset()
        self:GameStart(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_S_OUT_CARD then   
        self:OnSubOutCard(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_S_SEND_CARD then
        self:OnSubSendCard(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_S_OPERATE_NOTIFY then
        self:OnSubOperateNotify(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_S_OPERATE_RESULT then
        self:OnSubOperateResult(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_S_GAME_END then
        self:OnSubGameEnd(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_S_TRUSTEE then
        self:OnSubTrustee(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_S_LISTEN then
        self:OnSubListen(msgcmd:readWORD()+1)
    end
end

-- OnHeartEvent
function ASMJ_GameClientView:OnHeartEvent(msgcmd)
    if msgcmd:getSubCmdID() == SUB_GR_HEART_SERVER then

        local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
        local pOffLayer = self:getChildByTag(TAG_ID_OFFLINE_LAYER_316)
        if pOffLayer ~= nil and myItem.cbUserStatus == US_FREE then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_offline_gameover"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)

            self:runAction(cc.Sequence:create(cc.DelayTime:create(3),
             cc.CallFunc:create(
                function ()
                    ccexp.AudioEngine:stopAll()

                    self:StopViewAllScheduler()
                    CClientKernel:GetInstance():CloseRoomThread()

                    local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
                    local reScene = ASMJ_LobbyListScene_createScene(iRoomType)
                    if reScene then
                        cc.Director:getInstance():replaceScene( cc.TransitionSlideInL:create(TIME_SCENE_CHANGE, reScene) )
                    end
                end )))
        end

        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():SendSocketToGameServer(MDM_GR_HEART_BEAT, SUB_GR_HEART_CLIENT)
    end
end

-- OnMatchEvent
function ASMJ_GameClientView:OnMatchEvent(msgcmd)
    if msgcmd:getSubCmdID() == SUB_GR_MATCH_JIONQUUIT_RESULT then
        ASMJ_Toast_Dismiss()

        local cbResult          = msgcmd:readBYTE()
                                  msgcmd:readBYTE()
        local cbMatchStatus     = msgcmd:readBYTE()
                                  msgcmd:readLONGLONG()  
                                  msgcmd:readDWORD()
                                  msgcmd:readWORD()  
        local szDescribeString  = CMCipher:g2u_forlua(msgcmd:readChars(32), 32)                   

        if not (cbResult == 0 and cbMatchStatus == MS_SIGNUP) then
            local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", "316_popup_cancel", self, self, true)    
            dialog:setTag(IDI_POPUP_GAME_EXIT_316)
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_MATCH_USER_FLAGS then
        local dwUserID          = msgcmd:readDWORD()
        local dwMatchID         = msgcmd:readDWORD()
        local dwMatchNo         = msgcmd:readDWORD()
        local wMatchSceneIndex  = msgcmd:readBYTE()

        if dwUserID == ASMJ_MyUserItem:GetInstance():GetUserID() then
            local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()
            pMatchAttribute.dwMatchID = dwMatchID
            pMatchAttribute.dwMatchNo = dwMatchNo
            pMatchAttribute.wMatchSceneIndex = wMatchSceneIndex
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_NEW_MATCH_SENCE_INFO then

        --read data
        local dwMatchID     = msgcmd:readDWORD()
        local dwMatchNo     = msgcmd:readDWORD()
        local dwStartTime   = msgcmd:readDWORD()
        local wSenceIndex   = msgcmd:readBYTE()
        local wTableRank    = msgcmd:readBYTE()
        local dwBaseScore   = msgcmd:readDWORD()
        local dwTotalCount  = msgcmd:readWORD()
        local dwRank        = msgcmd:readWORD()
        local dwPlayCount   = msgcmd:readWORD()
        local dwGameCount   = msgcmd:readWORD()
        local dwMatchTime   = msgcmd:readWORD()
        local dwEndCount    = msgcmd:readWORD()
        local dwPromtCount  = msgcmd:readWORD()
        --------

        local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()
        pMatchAttribute.dwMatchID = dwMatchID
        pMatchAttribute.dwMatchNo = dwMatchNo
        pMatchAttribute.wMatchSenceIndex = wSenceIndex
        pMatchAttribute.dwNowBaseScore = dwBaseScore
        pMatchAttribute.dwMatchTime = dwMatchTime + os.time()
        pMatchAttribute.dwMatchStartTime = dwStartTime
        pMatchAttribute.dwTotalCount = dwTotalCount
        pMatchAttribute.dwCurRank = dwRank
        pMatchAttribute.dwEndCount = dwEndCount
        pMatchAttribute.dwPromtCount = dwPromtCount
        pMatchAttribute.dwTableRank = wTableRank
        pMatchAttribute.wContiunePlayCount = dwGameCount
        pMatchAttribute.wGameCount = dwPlayCount

        self.m_wMatchTime = pMatchAttribute.dwMatchTime

        --redo 
        local m_pRankMedalScore = self:getChildByTag(TAG_ID_MEDAL_RANK_316)
        if m_pRankMedalScore ~= nil then
            m_pRankMedalScore:setString(string.format("%d.%d", pMatchAttribute.dwCurRank, pMatchAttribute.dwTotalCount))
        end
        --------
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        self.m_scalex = display.scalex_landscape
        self.m_scaley = display.scaley_landscape

        local pMatchControl = self:getChildByTag(TAG_ID_MATCH_CONTROL_316)
        if pMatchControl ~= nil and pMatchControl ~= 0 then
            self.m_MatchControl:ClearMatch()
        else
            self.m_MatchControl = ASMJ_MatchControl_create()
            self:addChild(self.m_MatchControl, 0)
        end

        self.m_MatchControl:SetScaleMin(self.m_scalex, self.m_scaley)
        if self.m_MatchControl:GetMatchTime() > 0 then
            self. m_wMatchTime = self.m_MatchControl:GetMatchTime()
        end

        self.m_MatchControl:SetMatchTime(self.m_wMatchTime)
        self.m_MatchControl:setTag(TAG_ID_MATCH_CONTROL_316)
        self.m_MatchControl:ShowMatch(cc.p(visibleSize.width / 2, 355 * self.m_scaley))
        self.m_MatchControl:SetMatchTime(self.m_wMatchTime)
        self.m_MatchControl:DrawMatchRank(pMatchAttribute.wMatchSenceIndex)
        
        if self.m_MatchNotifyStatus ~= nil then
            self.m_MatchNotifyStatus:SetCurrentRank(pMatchAttribute.dwCurRank)
            self.m_MatchNotifyStatus:SetPlayTableCount(pMatchAttribute.dwPlayTableCount)
            self.m_MatchNotifyStatus:SetPromtCount(pMatchAttribute.dwPromtCount)
            self.m_MatchNotifyStatus:SetTableRank(pMatchAttribute.dwTableRank)
        end
    elseif msgcmd:getSubCmdID() == SUB_GR_MATCH_SENCE_BEGIN then
        
        -- read data
        local dwMatchID         = msgcmd:readDWORD()
        local dwMatchNo         = msgcmd:readDWORD()
        local wMatchSenceIndex  = msgcmd:readBYTE()
                                  msgcmd:SetPos(4+4+1+120)
        local lNormalBaseScore  = msgcmd:readDWORD()
        local dwCurRank         = msgcmd:readWORD()
        local dwTotal           = msgcmd:readWORD()
        local dwMatchStartTime  = msgcmd:readDWORD()
        local dwMatchTime       = msgcmd:readDWORD()
        local dwStartTime       = msgcmd:readDWORD()
        local dwEndCount        = msgcmd:readWORD()
        local dwPromtCount      = msgcmd:readWORD()
        local wContiunePlayCount= msgcmd:readWORD()
        -----

        local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()
        pMatchAttribute.dwMatchID = dwMatchID
        pMatchAttribute.dwMatchNo = dwMatchNO
        pMatchAttribute.wMatchSenceIndex = wMatchSenceIndex
        pMatchAttribute.dwNowBaseScore = lNormalBaseScore
        pMatchAttribute.dwMatchTime = dwMatchTime * 60
        pMatchAttribute.dwMatchTime = pMatchAttribute.dwMatchTime + os.time()
        pMatchAttribute.dwMatchStartTime = dwMatchStartTime
        pMatchAttribute.dwTotalCount = dwTotal
        pMatchAttribute.dwCurRank = dwCurRank
        pMatchAttribute.dwEndCount = dwEndCount
        pMatchAttribute.dwPromtCount = dwPromtCount
        pMatchAttribute.dwCurStartTime = dwStartTime
        pMatchAttribute.wContiunePlayCount = wContiunePlayCount

        self.m_wMatchTime = pMatchAttribute.dwMatchTime

        if wMatchSenceIndex == 0 then
            if SID_MatchStartTimeElapse ~= nil then
                local scheduler = cc.Director:getInstance():getScheduler()
                scheduler:unscheduleScriptEntry(SID_MatchStartTimeElapse)
                SID_MatchStartTimeElapse = nil
            end
            self:removeAllChildren()
        elseif wMatchSenceIndex == 1 then

        elseif wMatchSenceIndex == 2 then

        elseif wMatchSenceIndex == 3 then
            self:Reset()
        end

        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local pGameBack = cc.Sprite:create("316_table_bg.png")
        pGameBack:setPosition(visibleSize.width / 2, visibleSize.height / 2)
        pGameBack:setScale(self.m_scalex, self.m_scaley)
        self:addChild(pGameBack, ZORDER_BACK_VIEW_316)

        local pWaitTitle = cc.Sprite:create("316_wait_title.png")
        pWaitTitle:setPosition(visibleSize.width / 2, visibleSize.height / 2)
        pWaitTitle:setScale(self.m_scalex, self.m_scaley)
        self:addChild(pWaitTitle, ZORDER_BACK_VIEW_316 + 1)

    elseif msgcmd:getSubCmdID() == SUB_GR_MATCH_GAMECOUNT then

        -- read data
        local wGameCount        = msgcmd:readWORD()
        local lBaseScore        = msgcmd:readDWORD()
        local wTableRank        = msgcmd:readBYTE()
        local wCurSenceIndex    = msgcmd:readBYTE()
        local dwUserIDArry      = {}
        for i=1,4 do
            dwUserIDArry[i]     = msgcmd:readDWORD()
        end

        local wRankArry         = {}
        for i=1,4 do
            wRankArry[i]        = msgcmd:readBYTE()
        end
        ----------
        local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()

        pMatchAttribute.wGameCount = wGameCount
        pMatchAttribute.dwNowBaseScore = lBaseScore
        pMatchAttribute.dwTableRank = wTableRank
        pMatchAttribute.wMatchSenceIndex = wCurSenceIndex

        for i=1,4 do
            pMatchAttribute.dwUserIDArry[i] = dwUserIDArry[i]
            pMatchAttribute.wRankArry[i] = wRankArry[i]
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_NEW_MATCH_RANK then

        -- read data
        local dwUserID              = msgcmd:readDWORD()
        local dwRank                = msgcmd:readWORD()
        local dwTotal               = msgcmd:readWORD()
        local dwPlayingTableCount   = msgcmd:readWORD()
        ---------

        local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()

        if dwUserID == ASMJ_MyUserItem:GetInstance():GetUserID() then

            pMatchAttribute.dwCurRank = dwRank
            pMatchAttribute.dwTotalCount = dwTotal
            pMatchAttribute.dwPlayTableCount = dwPlayingTableCount
            ------------------ 

            if self:getChildByTag(TAG_ID_MATCH_CONTROL_316) ~= nil then
                self.m_MatchControl:DrawMatchRank(pMatchAttribute.wMatchSenceIndex)
            end

            if self:getChildByTag(TAG_ID_MATCH_STATUS_316) ~= nil then
                self.m_MatchNotifyStatus:SetCurrentRank(pMatchAttribute.dwCurRank)
                self.m_MatchNotifyStatus:SetPlayTableCount(pMatchAttribute.dwPlayTableCount)
                self.m_MatchNotifyStatus:SetPromtCount(pMatchAttribute.dwPromtCount)
                self.m_MatchNotifyStatus:SetTableRank(pMatchAttribute.dwTableRank)
            end

            local pRankScore = self:getChildByTag(TAG_ID_MEDAL_RANK_316)
            if pRankScore ~= nil and pRankScore ~= 0 then
                pRankScore:setString(string.format("%d.%d", pMatchAttribute.dwCurRank, pMatchAttribute.dwTotalCount))
            end
        else
            for i=1,4 do
                if pMatchAttribute.dwUserIDArry[i] == dwUserID then
                    pMatchAttribute.dwOtherCurRank[i] = dwRank
                end
            end
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_MATCH_RESULT then

        self:Reset()

        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local m_TableMJBack = cc.Sprite:create("316_table_bg.png")
        m_TableMJBack:setScale(self.m_scalex, self.m_scaley)
        m_TableMJBack:setPosition(visibleSize.width / 2, visibleSize.height / 2)
        self:addChild(m_TableMJBack, ZORDER_BACK_VIEW_316)

        self.m_MatchResult = ASMJ_MatchResult_create()
        self.m_MatchResult:SetScaleMin(self.m_scalex, self.m_scaley)
        self.m_MatchResult:InitPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
        self.m_MatchResult:setTag(TAG_ID_MATCH_RESULT_316)
        self.m_MatchResult:ShowMatchResult(msgcmd)
        self:addChild(self.m_MatchResult, 0)

    elseif msgcmd:getSubCmdID() == SUB_GR_NOTIFY_USEROUT then
        --read data
        local dwUserID          = msgcmd:readDWORD()
        local wTipTime          = msgcmd:readWORD()
        local lCostGold         = {}
              lCostGold[1]      = msgcmd:readDWORD()
              lCostGold[2]      = msgcmd:readDWORD()
        local bTimeLimit        = msgcmd:readBYTE()  -- bool
        local wSenceIndex       = msgcmd:readBYTE()
        local wCurRank          = msgcmd:readWORD()
        local cbReason          = msgcmd:readBYTE()
        local dwAfterScore      = msgcmd:readDWORD()
        ------------------
        local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData() 
        if dwUserID == myItem:GetUserID() then
            self:Reset()

            local visibleSize = cc.Director:getInstance():getVisibleSize()
            local m_TableMJBack = cc.Sprite:create("316_table_bg.png")
            m_TableMJBack:setScale(self.m_scalex, self.m_scaley)
            m_TableMJBack:setPosition(visibleSize.width / 2, visibleSize.height / 2)
            self:addChild(m_TableMJBack, ZORDER_BACK_VIEW_316)

            self.m_MatchNotifyOut = ASMJ_MatchNotifyOut_create()
            self.m_MatchNotifyOut:setTag(TAG_ID_MATCH_OUT_316)
            self.m_MatchNotifyOut:SetScaleMin(self.m_scalex, self.m_scalex)
            self.m_MatchNotifyOut:InitPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
            self:addChild(self.m_MatchNotifyOut, 500)
            self.m_MatchNotifyOut:ShowNotifyOut(bTimeLimit, wTipTime, lCostGold[1], cbReason)
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_RESURRECTION_RESULT then
        --read data
        local dwUserID = msgcmd:readDWORD()
        local wRetCode = msgcmd:readBYTE()
        local lCostGold = msgcmd:readDWORD()
        local szErrStr = CUtilEx:getString("0_match_releft_fail")
        -------
        if wRetCode == 0 then

            self:Reset()

            local visibleSize = cc.Director:getInstance():getVisibleSize()
            local m_TableMJBack = cc.Sprite:create("316_table_bg.png")
            m_TableMJBack:setScale(self.m_scalex, self.m_scaley)
            m_TableMJBack:setPosition(visibleSize.width / 2, visibleSize.height / 2)
            self:addChild(m_TableMJBack, ZORDER_BACK_VIEW_316)

            local pWaitTitle = cc.Sprite:create("316_wait_title.png")
            pWaitTitle:setPosition(visibleSize.width / 2, visibleSize.height / 2)
            pWaitTitle:setScale(self.m_scalex, self.m_scaley)
            self:addChild(pWaitTitle, ZORDER_BACK_VIEW_316 + 1)

            szErrStr = CUtilEx:getString("0_match_releft_success") 
        end

        local dialog = ASMJ_PopupBox_ShowDialog(szErrStr, "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)

    elseif msgcmd:getSubCmdID() == SUB_GR_NOTIFY_USER_PROMT_STATUS then
        -- read data
        local dwUserID      = msgcmd:readDWORD()
        local wPromtStatus  = msgcmd:readBYTE()
        local wTableRank    = msgcmd:readBYTE()
        local wCurrentSence = msgcmd:readBYTE()
        local wMatchRank    = msgcmd:readWORD()
        local cbReason      = msgcmd:readBYTE()
        ----
        if wPromtStatus == User_Promt and wCurrentSence == 0 then
            return
        end

        if dwUserID == ASMJ_MyUserItem:GetInstance():GetUserID() then
            
            self:Reset()

            local visibleSize = cc.Director:getInstance():getVisibleSize()
            local m_TableMJBack = cc.Sprite:create("316_table_bg.png")
            m_TableMJBack:setScale(self.m_scalex, self.m_scaley)
            m_TableMJBack:setPosition(visibleSize.width / 2, visibleSize.height / 2)
            self:addChild(m_TableMJBack, ZORDER_BACK_VIEW_316)

            self.m_MatchNotifyStatus = ASMJ_MatchNotifyStatus_create()
            self.m_MatchNotifyStatus:setTag(TAG_ID_MATCH_STATUS_316)
            self.m_MatchNotifyStatus:SetScaleMin(self.m_scalex, self.m_scalex)
            self.m_MatchNotifyStatus:InitPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
            self:addChild(self.m_MatchNotifyStatus, 500)
            self.m_MatchNotifyStatus:ShowNotifyStatus(wCurrentSence, wPromtStatus, cbReason)

            local pWaitBg = self:getChildByTag(TAG_ID_MATCH_WAIT_316)
            if pWaitBg ~= nil and pWaitBg ~= 0 then
                pWaitBg:removeFromParent()
            end
        end
    end
end

-- OnFastEvent
function ASMJ_GameClientView:OnFastEvent(msgcmd)

    if msgcmd:getSubCmdID() == SUB_GR_FAST_SIGNUP_RESULT then
        ASMJ_Toast_Dismiss()

        local cbResultCode = msgcmd:readBYTE()
        local wLastTime = msgcmd:readWORD()
        local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)

        if cbResultCode == 1 then

            self:Reset()

            local visibleSize = cc.Director:getInstance():getVisibleSize()
            self.m_scalex = display.scalex_landscape
            self.m_scaley = display.scaley_landscape

            local m_TableMJBack = cc.Sprite:create("316_table_bg.png")
            m_TableMJBack:setScale(self.m_scalex, self.m_scaley)
            m_TableMJBack:setPosition(visibleSize.width / 2, visibleSize.height / 2)
            self:addChild(m_TableMJBack, ZORDER_BACK_VIEW_316)

            local pWaitTitle = cc.Sprite:create("316_wait_title.png")
            pWaitTitle:setPosition(visibleSize.width / 2, visibleSize.height / 2)
            pWaitTitle:setScale(self.m_scalex, self.m_scaley)
            self:addChild(pWaitTitle, ZORDER_BACK_VIEW_316 + 1)

            local btBack = CImageButton:Create("316_room_return1.png", "316_room_return0.png", TAG_BT_GAME_EXIT_316)
            btBack:setScale(self.m_scalex, self.m_scaley)
            btBack:setPosition( cc.p(100 * self.m_scalex, visibleSize.height - 80 * self.m_scaley))
            self:addChild(btBack, ZORDER_BACK_VIEW_316 + 3)
            -- ScriptHandlerMgr
            ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btBack, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)

            ccexp.AudioEngine:stopAll()

        else
            local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()--CClientKernel:GetInstance():GetMyUserData()
            if not MyUserData then
                return
            end

            local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_GAME_OK_316)
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_FAST_NOTIFY then
                              msgcmd:readDWORD()
        local dwStatus      = msgcmd:readDWORD()
        local bExitNotify   = msgcmd:readBYTE()

        if dwStatus == FAST_MODE_STATUS_FREE and bExitNotify == 1 then
            self:BackRoom()
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_FAST_REST_NOTIFY then

                            msgcmd:readWORD()
                            msgcmd:readWORD()
        local dwGameCount = msgcmd:readWORD()
        local lGoldGrade  = msgcmd:readLONGLONG()
        local lMedalsGrade= msgcmd:readLONGLONG()

        ASMJ_MyUserItem:GetInstance():SetFastGameCount(dwGameCount)
        ASMJ_MyUserItem:GetInstance():SetFastGoldCount(lGoldGrade)
        ASMJ_MyUserItem:GetInstance():SetFastMedalCount(lMedalsGrade)

        local scheduler = cc.Director:getInstance():getScheduler()
        SID_GameFastRestTimeElapse = scheduler:scheduleScriptFunc(handler(self, self.GameFastRest), 15, false)
    end
end

-- OnUserEvent
function ASMJ_GameClientView:OnUserEvent(msgcmd)
    if msgcmd:getSubCmdID() == SUB_GR_USER_ENTER then
        
        ASMJ_ClientUserManager:GetInstance():UpdataItem_Cmd(msgcmd)
        -- restart 
        msgcmd:SetPos(4)
        local dwUserID = msgcmd:readDWORD()
        if dwUserID == ASMJ_MyUserItem:GetInstance():GetUserID() then
            msgcmd:SetPos(0)
            ASMJ_MyUserItem:GetInstance():UpdataItem_Cmd(msgcmd)
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_USER_SELF_STANDUP then
        
        local dwUserID = ASMJ_MyUserItem:GetInstance():GetUserID()
        ASMJ_ClientUserManager:GetInstance():ResetOtherList(dwUserID)

    elseif msgcmd:getSubCmdID() == SUB_GR_REQUEST_FAILURE then
        
        local lErrorCode = msgcmd:readLONG()
        local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(256), 256)
        local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)

    elseif msgcmd:getSubCmdID() == SUB_GR_USER_STATUS then
        
        local dwUserID = msgcmd:readDWORD()
        local dwTableID = msgcmd:readWORD()
        local dwChairID = msgcmd:readWORD() + 1
        local cbUserStatus = msgcmd:readBYTE()

        local UserItem = ASMJ_ClientUserManager:GetInstance():SeachByUserID(dwUserID)
        if UserItem ~= nil then
            UserItem.wTableID = dwTableID
            UserItem.wChairID = dwChairID
            UserItem.cbUserStatus = cbUserStatus
        end

        if dwUserID == ASMJ_MyUserItem:GetInstance():GetUserID() then
            local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
            if (cbUserStatus == US_SIT) and (myItem.cbUserStatus ~= US_PLAYING) then
                -- offline ReEntry game option
                local cbAllowLookon = 0
                local dwFrameVersion = 101056515
                local dwClientVersion = 102301699
                CClientKernel:GetInstance():ResetBuffers()
                CClientKernel:GetInstance():WriteBYTEToBuffers(cbAllowLookon)
                CClientKernel:GetInstance():WriteDWORDToBuffers(dwFrameVersion)
                CClientKernel:GetInstance():WriteDWORDToBuffers(dwClientVersion)
                CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_FRAME, SUB_GF_GAME_OPTION)
            end
            if dwChairID ~= INVALID_CHAIR_316 then
                myItem.wChairID = dwChairID
            end
            myItem.wTableID     = dwTableID
            myItem.cbUserStatus = cbUserStatus
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_USER_SCORE then

        local dwUserID = msgcmd:readDWORD()
        local lScore = msgcmd:readLONGLONG()         
        local lGrade = msgcmd:readLONGLONG()        
        local lInsure = msgcmd:readLONGLONG()     
        local lGoldA = msgcmd:readLONGLONG()   
        local dwRankScore = msgcmd:readDWORD()  
        local dwWinCount = msgcmd:readDWORD()   
        local dwLostCount = msgcmd:readDWORD()  
        local dwDrawCount = msgcmd:readDWORD()  
        local dwFleeCount = msgcmd:readDWORD()   
        local dwUserMedal = msgcmd:readDWORD()   
        local dwExperience = msgcmd:readDWORD()  
        local dwMatchTiket = msgcmd:readDWORD() 
        local lLoveLiness = msgcmd:readLONG()   

        local UserItem = ASMJ_ClientUserManager:GetInstance():SeachByUserID(dwUserID)
        if UserItem ~= nil then
            UserItem.dwWinCount = dwWinCount
            UserItem.dwLostCount = dwLostCount
            UserItem.dwDrawCount = dwDrawCount
            UserItem.dwFleeCount = dwFleeCount
            UserItem.dwUserMedal = dwUserMedal
            UserItem.dwExperience = dwExperience
            UserItem.dwMatchTiket = dwMatchTiket

            UserItem.lGrade = lGrade
            UserItem.lInsure = lInsure

            UserItem.lScore = lScore
            UserItem.lGoldA = lGoldA
        end

        local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
        if myItem ~= nil and myItem.dwUserID == dwUserID then
            
            myItem.dwWinCount = dwWinCount
            myItem.dwLostCount = dwLostCount
            myItem.dwDrawCount = dwDrawCount
            myItem.dwFleeCount = dwFleeCount
            myItem.dwUserMedal = dwUserMedal
            myItem.dwExperience = dwExperience
            myItem.dwMatchTiket = dwMatchTiket

            myItem.lGrade = lGrade
            myItem.lInsure = lInsure

            myItem.lScore = lScore
            myItem.lGoldA = lGoldA

            local pUserScore = self:getChildByTag(TAG_ID_USER_SCORE_316)
            if pUserScore and pUserScore ~= 0 then
                if myItem.lScore < 0 then
                    pUserScore:setString(string.format(";%d", -myItem.lScore))
                else
                    pUserScore:setString(string.format("%d", myItem.lScore))
                end
            end
                
            local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
            if iRoomType < ERT_FL_316 then
                local pUserMedal = self:getChildByTag(TAG_ID_MEDAL_RANK_316)
                if pUserMedal and  pUserMedal ~= 0 then
                    pUserMedal:setString(string.format("%d", myItem.dwUserMedal))
                end
            end
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_USER_GROW_WELFARE then

        local pMyItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
        if pMyItem ~= nil then
            local pExpLayer = ASMJ_ExperienceLayer_create(pMyItem:GetExperience())
            self:addChild(pExpLayer, 2000)
        end

    end
end

-- OnLoginEvent
function ASMJ_GameClientView:OnLoginEvent(msgcmd)
    if msgcmd:getSubCmdID() ==  SUB_GR_LOGON_FINISH then
        local cbAllowLookon = 0
        local dwFrameVersion = 101056515
        local dwClientVersion = 102301699
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteBYTEToBuffers(cbAllowLookon)
        CClientKernel:GetInstance():WriteDWORDToBuffers(dwFrameVersion)
        CClientKernel:GetInstance():WriteDWORDToBuffers(dwClientVersion)
        CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_FRAME, SUB_GF_GAME_OPTION)
    end
end

-- OnLoginEvent
function ASMJ_GameClientView:OnIphoneEvent(msgcmd)
    if msgcmd:getSubCmdID() == SUB_IM_OPERATE then
        self:OnUserAction(msgcmd:readBYTE(), msgcmd:readBYTE())
    end
end

-- OnSocketError
function ASMJ_GameClientView:OnSocketError(msgcmd)

    local pGrayLayer = self:getChildByTag(TAG_ID_LAYER_COLOR_316)
    if pGrayLayer ~= nil then
        pGrayLayer:removeFromParent()
    end

    local pOffLayer = self:getChildByTag(TAG_ID_OFFLINE_LAYER_316)
    if pOffLayer == nil then
        local pOffLineLayer = ASMJ_OffLineLayer_create()
        self:addChild(pOffLineLayer, 2000, TAG_ID_OFFLINE_LAYER_316)
    end

    self:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(5),
            cc.CallFunc:create(
                function ()
                    local password = ASMJ_MyUserItem:GetInstance():GetPassword()
                    local moduleid = KIND_ID_316
                    local devicetype = display.DeviceType
                    local wBehaviorFlags = 0
                    local wPageTableCount = 60
                    local dwSiteID = 1000
                    local plazaversion = 0

                    if (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
                        plazaversion = 102367235 --101842947
                    else
                        plazaversion = 101056515
                    end

                    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
                    assert(myItem, "MyUserData is error")

                    local cbLogonMode = 0

                    CClientKernel:GetInstance():ResetBuffers()
                    CClientKernel:GetInstance():WriteWORDToBuffers(moduleid)
                    CClientKernel:GetInstance():WriteDWORDToBuffers(plazaversion)
                    CClientKernel:GetInstance():WriteBYTEToBuffers(devicetype)
                    CClientKernel:GetInstance():WriteWORDToBuffers(wBehaviorFlags)
                    CClientKernel:GetInstance():WriteWORDToBuffers(wPageTableCount)
                    CClientKernel:GetInstance():WriteDWORDToBuffers(dwSiteID)
                    CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
                    CClientKernel:GetInstance():WritecharToBuffers(password,33,true)
                    CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)
                    CClientKernel:GetInstance():WriteBYTEToBuffers(cbLogonMode)

                    -- online count
                    local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
                    local iRoomIndex = ASMJ_CServerManager:GetInstance():GetOnClickRoomIndex()
                    local pRoomDataItem =  nil
                    if iRoomType == ERT_XS_316 then
                        pRoomDataItem = ASMJ_CServerManager:GetInstance():GetRoomXSItem(iRoomIndex)
                    elseif iRoomType <= ERT_GJ_316 then
                        pRoomDataItem = ASMJ_CServerManager:GetInstance():GetRoomCGItem(iRoomIndex)
                    elseif iRoomType == ERT_FL_316 then
                        pRoomDataItem = ASMJ_CServerManager:GetInstance():GetRoomFLItem(iRoomIndex)
                    end

                    if pRoomDataItem then
                        CClientKernel:GetInstance():SendLoginToGameServer(pRoomDataItem.dwServerAddr, pRoomDataItem.wServerPort, MDM_GR_LOGON, SUB_GR_LOGON_MOBILE)
                    end
                end
            )
        )
    )
end

function ASMJ_GameClientView:GameFastRest()
    self:Reset()

    local visibleSize = cc.Director:getInstance():getVisibleSize()

    local m_TableMJBack = cc.Sprite:create("316_table_bg.png")
    m_TableMJBack:setScale(self.m_scalex, self.m_scaley)
    m_TableMJBack:setPosition(visibleSize.width / 2, visibleSize.height / 2)
    self:addChild(m_TableMJBack, ZORDER_BACK_VIEW_316)

    local pBackUpper = cc.Sprite:createWithSpriteFrameName("316_fast_rest_bg.png")
    pBackUpper:setScale(self.m_scalex, self.m_scaley)
    pBackUpper:setPosition(visibleSize.width / 2, visibleSize.height / 2 + 40 * self.m_scaley)
    self:addChild(pBackUpper, ZORDER_BACK_VIEW_316 + 1)

    local pGirl = cc.Sprite:createWithSpriteFrameName("316_fast_rest_girl.png")
    pGirl:setScale(self.m_scalex, self.m_scaley)
    pGirl:setPosition(pGirl:getContentSize().width / 2 * self.m_scalex, visibleSize.height / 2)
    self:addChild(pGirl, ZORDER_BACK_VIEW_316 + 2)

    local pJiZhan = cc.Sprite:createWithSpriteFrameName("316_fast_rest_jz.png")
    pJiZhan:setScale(self.m_scalex, self.m_scaley)
    pJiZhan:setPosition(455 * self.m_scalex, pBackUpper:getPositionY() + pBackUpper:getBoundingBox().height / 2 - pJiZhan:getBoundingBox().height / 2 - 20 * self.m_scaley)
    self:addChild(pJiZhan, ZORDER_BACK_VIEW_316 + 2)

    local pGameCountLabA = cc.LabelAtlas:_create(string.format("%d", ASMJ_MyUserItem:GetInstance():GetFastGameCount()) , "316_fast_rest_number.png", 22, 31, string.byte("."))
    pGameCountLabA:setScale(self.m_scalex, self.m_scaley)
    pGameCountLabA:setAnchorPoint(cc.p(0.5, 0.5))
    pGameCountLabA:setPosition(pJiZhan:getPositionX() + pJiZhan:getBoundingBox().width / 2 + pGameCountLabA:getBoundingBox().width / 2, pJiZhan:getPositionY())
    self:addChild(pGameCountLabA, ZORDER_BACK_VIEW_316 + 2)

    local pZhanJiRuXia = cc.Sprite:createWithSpriteFrameName("316_fast_rest_rx.png")
    pZhanJiRuXia:setScale(self.m_scalex, self.m_scaley)
    pZhanJiRuXia:setPosition(pGameCountLabA:getPositionX() + pGameCountLabA:getBoundingBox().width / 2 + pZhanJiRuXia:getBoundingBox().width / 2, pGameCountLabA:getPositionY())
    self:addChild(pZhanJiRuXia, ZORDER_BACK_VIEW_316 + 2)

    local pJinDou = cc.Sprite:createWithSpriteFrameName("316_fast_rest_jd.png")
    pJinDou:setScale(self.m_scalex, self.m_scaley)
    pJinDou:setPosition(visibleSize.width / 2, pJiZhan:getPositionY() - pJiZhan:getBoundingBox().height / 2 - pJinDou:getBoundingBox().height / 2 - 10 * self.m_scaley)
    self:addChild(pJinDou, ZORDER_BACK_VIEW_316 + 2)

    local pJiangPai = cc.Sprite:createWithSpriteFrameName("316_fast_rest_jp.png")
    pJiangPai:setScale(self.m_scalex, self.m_scaley)
    pJiangPai:setPosition(visibleSize.width / 2, pJinDou:getPositionY() - pJinDou:getBoundingBox().height / 2 - pJiangPai:getBoundingBox().height / 2 - 10 * self.m_scaley)
    self:addChild(pJiangPai, ZORDER_BACK_VIEW_316 + 2)

    local pJinDouCountLabA = nil
    if ASMJ_MyUserItem:GetInstance():GetFastGoldCount() >= 0 then
        pJinDouCountLabA = cc.LabelAtlas:_create(string.format("/%d", ASMJ_MyUserItem:GetInstance():GetFastGoldCount()) , "316_fast_rest_number.png", 22, 31, string.byte("."))
    else
        pJinDouCountLabA = cc.LabelAtlas:_create(string.format(".%d", math.abs(ASMJ_MyUserItem:GetInstance():GetFastGoldCount())) , "316_fast_rest_number.png", 22, 31, string.byte("."))
    end
    pJinDouCountLabA:setScale(self.m_scalex, self.m_scaley)
    pJinDouCountLabA:setAnchorPoint(cc.p(0.5, 0.5))
    pJinDouCountLabA:setPosition(pJinDou:getPositionX() + pJinDou:getBoundingBox().width / 2 + pJinDouCountLabA:getBoundingBox().width / 2, pJinDou:getPositionY())
    self:addChild(pJinDouCountLabA, ZORDER_BACK_VIEW_316 + 2)

    local pJiangPaiCountLabA = cc.LabelAtlas:_create(string.format("/%d", ASMJ_MyUserItem:GetInstance():GetFastMedalCount()), "316_fast_rest_number.png", 22, 31, string.byte("."))
    pJiangPaiCountLabA:setScale(self.m_scalex, self.m_scaley)
    pJiangPaiCountLabA:setAnchorPoint(cc.p(0.5, 0.5))
    pJiangPaiCountLabA:setPosition(pJiangPai:getPositionX() + pJiangPai:getBoundingBox().width / 2 + pJiangPaiCountLabA:getBoundingBox().width / 2, pJiangPai:getPositionY())
    self:addChild(pJiangPaiCountLabA, ZORDER_BACK_VIEW_316 + 2)

    local pBtRest = CImageButton:CreateWithSpriteFrameName("316_bt_exit0.png", "316_bt_exit1.png", TAG_BT_GAME_EXIT_316)
    pBtRest:setScale(self.m_scalex, self.m_scaley)
    pBtRest:setPosition(visibleSize.width / 2 - pBtRest:getContentSize().width / 2 * self.m_scalex - 50 * self.m_scalex, visibleSize.height / 4)
    self:addChild(pBtRest, ZORDER_BACK_VIEW_316 + 1)

    local pBtAgain = CImageButton:CreateWithSpriteFrameName("316_bt_again0.png", "316_bt_again1.png", TAG_BT_STARTGAME_316)
    pBtAgain:setScale(self.m_scalex, self.m_scaley)
    pBtAgain:setPosition(visibleSize.width / 2 + pBtRest:getContentSize().width / 2 * self.m_scalex + 50 * self.m_scalex, visibleSize.height / 4)
    self:addChild(pBtAgain, ZORDER_BACK_VIEW_316 + 1)

    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(pBtRest, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(pBtAgain, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ccexp.AudioEngine:stopAll()

    local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
    if iRoomType > ERT_GJ_316 then 
        assert(false, "error is iRoomType")
        return
    end

    local pTitle = cc.Sprite:createWithSpriteFrameName(string.format("316_fast_rest_title_%d.png", iRoomType))
    pTitle:setScale(self.m_scalex, self.m_scaley)
    pTitle:setPosition(visibleSize.width / 2, pBackUpper:getPositionY() + pBackUpper:getBoundingBox().height / 2 + pTitle:getContentSize().height * self.m_scaley)
    self:addChild(pTitle, ZORDER_BACK_VIEW_316 + 1)
end

function ASMJ_GameClientView:StopViewAllScheduler()
    local scheduler = cc.Director:getInstance():getScheduler()
    if SID_MatchStatusWaitTimeElapse ~= nil then
        scheduler:unscheduleScriptEntry(SID_MatchStatusWaitTimeElapse)
        SID_MatchStatusWaitTimeElapse = nil
    end
    if SID_MatchStartTimeElapse ~= nil then
        scheduler:unscheduleScriptEntry(SID_MatchStartTimeElapse)
        SID_MatchStartTimeElapse = nil
    end
    
    for i = 1, #SID_CurrentUserTimeElapse do
        if SID_CurrentUserTimeElapse[i] ~= nil then
            scheduler:unscheduleScriptEntry(SID_CurrentUserTimeElapse[i])
            SID_CurrentUserTimeElapse[i] = nil
        end
    end
    
    if SID_OperateUserTimeElapse ~= nil then
        scheduler:unscheduleScriptEntry(SID_OperateUserTimeElapse)
        SID_OperateUserTimeElapse = nil
    end
    if SID_GameFastRestTimeElapse ~= nil then
        scheduler:unscheduleScriptEntry(SID_GameFastRestTimeElapse)
        SID_GameFastRestTimeElapse = nil
    end
end

------------------------
function ASMJ_GameClientView:Reset()
    -------scheduler close------
    self:StopViewAllScheduler()
    
    if self.m_MatchControl ~= nil then
        self.m_MatchControl:ClearMatch()
        self.m_MatchControl = nil
    end
    if self.m_MatchNotifyOut ~= nil then
        self.m_MatchNotifyOut:ClearNotifyOut()
        self.m_MatchNotifyOut = nil
    end
    if self.m_MatchNotifyStatus ~= nil then
        self.m_MatchNotifyStatus:ClearNotifyStatus()
        self.m_MatchNotifyStatus = nil
    end
    ------control clear-----
    if self.m_HandCardControl ~= nil then
        self.m_HandCardControl:HandMJClear()
        self.m_HandCardControl = nil
    end

    for i=1,3 do
        if self.m_OtherPlayerHandMJ ~= nil and self.m_OtherPlayerHandMJ[i] ~= nil then
            self.m_OtherPlayerHandMJ[i]:OtherHandMJClear()
            self.m_OtherPlayerHandMJ[i] = nil
        end
    end

    for i=1,GAME_PLAYER_316 do
        if self.m_TableOutMJControl ~= nil and self.m_TableOutMJControl[i] ~= nil then
            self.m_TableOutMJControl[i]:TableOutMJClear()
            self.m_TableOutMJControl[i] = nil
        end
    end
    -----------------
    self:stopAllActions()
    self:removeAllChildren()
    self.m_MoveCardItemArray        = {}

    self.m_strFaceID                = {}
    self.m_ptNormalAvatar           = {}--cc.p(0,0)
    self.m_ptTrusteeAvatar          = {}--cc.p(0,0)

    self.m_wSpendTime               = 0
    self.m_wTimeOutCount            = 0
    self.gameStatus                 = Game_Free_316
    self.m_wCurrentUser             = INVALID_CHAIR_316
    self.m_wBankerUser              = INVALID_CHAIR_316
    self.m_iMJIndex_down            = INVALID_ITEM_316

    self.m_cbCardIndex = {}
    self.m_cbActionMask             = 0
    self.m_cbActionCard             = 0

    self.m_bStustee                 = false
    self.m_bTingAlter               = false
    self.m_cbListenStatus           = 0
    self.m_bWillHearStatus          = false
    
    self.m_cbFirstChicken           = 0

    self.m_wTimeCount               = 0
    self.m_cbEnjoinGangCount        = 0
    self.m_cbEnjoinGangCard         = {}

    self.m_wOperateUser             = {}
    self.m_cbWeaveCount             = {}
    for i=1,GAME_PLAYER_316 do
        self.m_cbWeaveCount[i] = 0
    end

    self.m_WeaveItemArray           = {}
    for i=1,GAME_PLAYER_316 do
        self.m_WeaveItemArray[i]    = {}
        for j=1,MAX_WEAVE_316 do
            self.m_WeaveItemArray[i][j] = {}
            self.m_WeaveItemArray[i][j].cbWeaveKind     = 0
            self.m_WeaveItemArray[i][j].cbCenterCard   = 0
            self.m_WeaveItemArray[i][j].cbPublicCard    = 0
            self.m_WeaveItemArray[i][j].wProvideUser    = 0
            self.m_WeaveItemArray[i][j].cbCardData      = {}
            for z=1,GAME_PLAYER_316 do
                self.m_WeaveItemArray[i][j].cbCardData[z] = 0
            end
        end
    end

    self.m_ScoreData        ={}
    self.m_ReportData       ={}
end

function ASMJ_GameClientView:RectifyControl(nWidth, nHeight)
    -- trustee
    self.m_pTrusteeBack = cc.Sprite:createWithSpriteFrameName("316_trustee_bg.png")
    self.m_pTrusteeBack:setPosition(nWidth / 2, 28 * self.m_scaley + self.m_pTrusteeBack:getContentSize().height / 2 * self.m_scaley)
    self.m_pTrusteeBack:setVisible(false)
    self.m_pTrusteeBack:setScale(self.m_scalex, self.m_scaley)
    self:addChild(self.m_pTrusteeBack, ZORDER_BUTTON_316 - 1)
 
    -- chat 
    self.m_btChat = CImageButton:CreateWithSpriteFrameName("316_bt_chat1.png", "316_bt_chat0.png", TAG_BT_CHAT_316)
    self.m_btChat:setScale(self.m_scalex, self.m_scaley)
    self.m_btChat:setPosition(nWidth - 60 * self.m_scalex, 250 * self.m_scaley)
    self:addChild(self.m_btChat, ZORDER_BUTTON_316)

    -- set option
    
    local m_pSetBg = cc.Sprite:createWithSpriteFrameName("316_bt_set0.png")
    m_pSetBg:setScale(self.m_scalex, self.m_scaley)
    m_pSetBg:setPosition(nWidth - 60 * self.m_scalex, nHeight - 50 * self.m_scaley)
    self:addChild(m_pSetBg, ZORDER_BUTTON_316)

    self.m_btSet = CSpriteEx:CreateWithSpriteFrameName("316_bt_set1.png", TAG_BT_OPTION_SET_316)
    self.m_btSet:setScale(self.m_scalex, self.m_scaley)
    self.m_btSet:setPosition(nWidth - 60 * self.m_scalex, nHeight - 50 * self.m_scaley)
    self:addChild(self.m_btSet, ZORDER_BUTTON_316)

    -- point avatar
    self.m_ptAvatar = {}
    self.m_ptAvatar[1] = cc.p(255 * self.m_scalex, nHeight - 50 * self.m_scaley)
    self.m_ptAvatar[2] = cc.p(60 * self.m_scalex, 410 * self.m_scaley)
    self.m_ptAvatar[3] = cc.p(60 * self.m_scalex, 195 * self.m_scaley)
    self.m_ptAvatar[4] = cc.p(nWidth - 60 * self.m_scalex, 410 * self.m_scaley)
  
    -- left bg
    self.m_pLeftMJBack = cc.Sprite:createWithSpriteFrameName("316_left_back.png")
    self.m_pLeftMJBack:setPosition(nWidth / 2, 290 * self.m_scaley)
    self.m_pLeftMJBack:setScale(self.m_scalex, self.m_scaley)
    self:addChild(self.m_pLeftMJBack, ZORDER_BACK_VIEW_316 + 1)

    -- left lab
    self.m_cbLeftCardCount = MAX_REPERTORY_316
    self.m_pLeftMJNumber = cc.LabelAtlas:_create(string.format("%d", self.m_cbLeftCardCount), "316_mj_left_number.png", 20, 30, string.byte("0"))
    self.m_pLeftMJNumber:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_pLeftMJNumber:setPosition(self.m_pLeftMJBack:getPositionX() - self.m_pLeftMJBack:getContentSize().width / 2 * self.m_scalex + 77 * self.m_scalex, self.m_pLeftMJBack:getPositionY())
    self.m_pLeftMJNumber:setScale(self.m_scalex, self.m_scaley)
    self:addChild(self.m_pLeftMJNumber, ZORDER_BACK_VIEW_316 + 1)

    -- start mj bg
    self.m_pStartMJBack = cc.Sprite:createWithSpriteFrameName("316_mj_send_back.png")
    self.m_pStartMJBack:setTag(TAG_ID_START_MJ_316)
    self.m_pStartMJBack:setPosition(38 * self.m_scalex, nHeight - 45 * self.m_scaley)
    self.m_pStartMJBack:setScale(self.m_scalex, self.m_scaley)
    self:addChild(self.m_pStartMJBack, ZORDER_BACK_VIEW_316 + 1)

    -- time 
    self.m_pTimeBack = cc.Sprite:createWithSpriteFrameName("316_Timer_blackBack.png")
    self.m_pTimeBack:setTag(TAG_ID_TIME_BACK_316)
    self.m_pTimeXYZ = {}
    self.m_pTimeXYZ[1] = cc.Sprite:createWithSpriteFrameName("316_Timer_wind2.png")
    self.m_pTimeXYZ[2] = cc.Sprite:createWithSpriteFrameName("316_Timer_wind1.png")
    self.m_pTimeXYZ[3] = cc.Sprite:createWithSpriteFrameName("316_Timer_wind0.png")
    self.m_pTimeXYZ[4] = cc.Sprite:createWithSpriteFrameName("316_Timer_wind3.png")
    self.m_pTimerNumber = cc.LabelAtlas:_create("0123456789", "316_timer_number.png", 22, 36, string.byte("0"))
    
    self.m_pTimeBack:setScale(self.m_scalex, self.m_scaley)
    self.m_pTimerNumber:setScale(self.m_scalex, self.m_scaley)
    for i=1,4 do
        self.m_pTimeXYZ[i]:setScale(self.m_scalex, self.m_scaley)
    end

    self.m_pTimeBack:setPosition(nWidth / 2, 355 * self.m_scaley)
    self.m_pTimerNumber:setPosition(self.m_pTimeBack:getPositionX() - 23 * self.m_scalex, self.m_pTimeBack:getPositionY() - 19 * self.m_scaley)
    local iTimeBackPosX, iTimeBackPosY = self.m_pTimeBack:getPosition()
    self.m_pTimeXYZ[1]:setPosition(iTimeBackPosX, iTimeBackPosY + 31 * self.m_scaley)
    self.m_pTimeXYZ[2]:setPosition(iTimeBackPosX - 41 * self.m_scalex, iTimeBackPosY)
    self.m_pTimeXYZ[3]:setPosition(iTimeBackPosX, iTimeBackPosY - 32 * self.m_scaley) 
    self.m_pTimeXYZ[4]:setPosition(iTimeBackPosX + 40 * self.m_scalex, iTimeBackPosY)

    self:addChild(self.m_pTimeBack, ZORDER_TIME_316)
    self:addChild(self.m_pTimerNumber, ZORDER_TIME_316 + 2)
    for i=1,4 do
        self:addChild(self.m_pTimeXYZ[i], ZORDER_TIME_316 + 3 + i)
    end

    --self.m_pTimeBack:setOpacity(0)
    --self.m_pTimerNumber:setOpacity(0)
    self.m_pTimerNumber:setString("00")
    for i=1,4 do
        self.m_pTimeXYZ[i]:setVisible(false)
        self.m_pTimeXYZ[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1.0), cc.FadeIn:create(1.0))))
    end

    -- disc 
    self.m_pDiscUser = cc.Sprite:createWithSpriteFrameName("316_tile_pointer.png")
    self.m_pDiscUser:setVisible(false)
    self.m_pDiscUser:setScale(self.m_scalex, self.m_scaley)
    self:addChild(self.m_pDiscUser, 2 * ZORDER_DISC_316)

    -------------------other handmj control---------------------
    self.m_OtherPlayerHandMJ = {}
    self.m_OtherPlayerHandMJ[1] = ASMJ_OtherHandMJControl_create()
    self.m_OtherPlayerHandMJ[2] = ASMJ_OtherHandMJControl_create()
    self.m_OtherPlayerHandMJ[3] = ASMJ_OtherHandMJControl_create()

    self.m_OtherPlayerHandMJ[1].m_HandMJDirection = Direction_North_316
    self.m_OtherPlayerHandMJ[2].m_HandMJDirection = Direction_East_316
    self.m_OtherPlayerHandMJ[3].m_HandMJDirection = Direction_West_316

    self.m_OtherPlayerHandMJ[1]:SetOriginControlPoint(nWidth - 290 * self.m_scalex, nHeight - 55 * self.m_scaley)
    self.m_OtherPlayerHandMJ[2]:SetOriginControlPoint(145 * self.m_scalex, nHeight - 140 * self.m_scaley)
    self.m_OtherPlayerHandMJ[3]:SetOriginControlPoint(nWidth - 145 * self.m_scalex, 250 * self.m_scaley)
    
    for i=1,3 do
        if i > 1 then
            self.m_OtherPlayerHandMJ[i]:SetScaleMin(0.8 * self.m_scalex, 0.8 * self.m_scaley)
        else
            self.m_OtherPlayerHandMJ[i]:SetScaleMin(self.m_scalex, self.m_scaley)
        end
        self:addChild(self.m_OtherPlayerHandMJ[i], ZORDER_OTHER_HAND_316)
    end

    ----------------------handmj control------------------------------
    self.m_HandCardControl = ASMJ_HandMJControl_create()
    self.m_HandCardControl:SetScaleMin(self.m_scalex, self.m_scaley)
    self.m_HandCardControl:SetOriginControlPoint(45 * self.m_scalex, 92 * self.m_scaley)
    self:addChild(self.m_HandCardControl, ZORDER_MY_HAND_316)

    ----------------------outmj control-------------------------------
    self.m_TableOutMJControl = {}
    
    for i=1,GAME_PLAYER_316 do
        self.m_TableOutMJControl[i] = ASMJ_TableOutMJControl_create()
        self.m_TableOutMJControl[i]:SetScaleMin(self.m_scalex, self.m_scaley)
        self.m_TableOutMJControl[i]:SetDirection(i)
        self.m_TableOutMJControl[i]:SetRoundSprite()
        self:addChild(self.m_TableOutMJControl[i], ZORDER_OUTMJ_316 + (i == MYSELF_VIEW_ID and ZORDER_DISC_316 or 0))
    end

    self.m_TableOutMJControl[1]:SetOriginControlPoint(nWidth / 2 + 145 * self.m_scalex, nHeight / 2 + 140 * self.m_scaley)
    self.m_TableOutMJControl[2]:SetOriginControlPoint(nWidth / 2 - 275 * self.m_scalex, nHeight / 2 + 150 * self.m_scaley)
    self.m_TableOutMJControl[3]:SetOriginControlPoint(nWidth / 2 - 145 * self.m_scalex, nHeight / 2 - 85 * self.m_scaley)
    self.m_TableOutMJControl[4]:SetOriginControlPoint(nWidth / 2 + 275 * self.m_scalex, nHeight / 2 - 90 * self.m_scaley)
    
    ------------------------HuMJControl control------------------------------
    self.m_HuMJControl = {}
    for i=1,GAME_PLAYER_316 do
        self.m_HuMJControl[i] = ASMJ_HuControl_create()
        
        self.m_HuMJControl[i].m_HuMJDirection = i

        if i == 3 then
            self.m_HuMJControl[i]:SetScaleMin(0.8 * self.m_scalex, 0.8 * self.m_scaley)
            self:addChild(self.m_HuMJControl[i], 2 * ZORDER_DISC_316)
        elseif i == 2 or i == 4 then
            self.m_HuMJControl[i]:SetScaleMin(0.8 * self.m_scalex, 0.8 * self.m_scaley)
            self:addChild(self.m_HuMJControl[i], (i == 4 and 2 * ZORDER_DISC_316 or ZORDER_DISC_316))
        else 
            self.m_HuMJControl[i]:SetScaleMin(self.m_scalex, self.m_scaley)
            self:addChild(self.m_HuMJControl[i], ZORDER_DISC_316)
        end 
    end

    self.m_HuMJControl[1]:SetOriginHuPoint(nWidth - 230 * self.m_scalex, nHeight - 55 * self.m_scaley)
    self.m_HuMJControl[2]:SetOriginHuPoint(145 * self.m_scalex, nHeight - 80 * self.m_scaley)
    self.m_HuMJControl[3]:SetOriginHuPoint(70 * self.m_scalex, 80 * self.m_scaley)
    self.m_HuMJControl[4]:SetOriginHuPoint(nWidth - 145 * self.m_scalex, 210 * self.m_scaley)

    ------------------------action control------------------------------
    self.m_ActionControl = {}

    for i=1,GAME_PLAYER_316 do
        self.m_ActionControl[i] = ASMJ_ActionControl_create()
        self.m_ActionControl[i]:SetScaleMin(self.m_scalex, self.m_scaley)
        self:addChild(self.m_ActionControl[i], ZORDER_ACTION_316)
    end

    self.m_ActionControl[1]:SetActionPoint(nWidth / 2, nHeight - 120 * self.m_scaley)
    self.m_ActionControl[2]:SetActionPoint(200 * self.m_scalex, self.m_ptAvatar[2].y)
    self.m_ActionControl[3]:SetActionPoint(nWidth / 2, 120 * self.m_scaley)
    self.m_ActionControl[4]:SetActionPoint(nWidth - 200 * self.m_scalex, self.m_ptAvatar[4].y)
    ------------------------operate control-----------------------------
    self.m_OperateControl = ASMJ_OperateControl_create()
    self.m_OperateControl:SetScaleMin(self.m_scalex, self.m_scaley)
    self.m_OperateControl:SetOriginPoint(nWidth - 70 * self.m_scalex, 180 * self.m_scaley)
    self.m_OperateControl:InitOperateButton()
    self:addChild(self.m_OperateControl, ZORDER_BUTTON_316)

    --ScriptHandlerMgr
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btChat, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btSet, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end

function ASMJ_GameClientView:DrawUserView()

    local iUpdataFlag = ASMJ_MyUserItem:GetInstance():UpdataDeskUserItem()
    if iUpdataFlag ~= GAME_PLAYER_316 then
        assert (false, "error useritem data")
        return
    end

    self.m_szAccount = {}
    self.m_btAvatar = {}
    self.m_btAvatarTrustee = {}
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    for i=1, GAME_PLAYER_316 do

        local pIClientUserItem = ASMJ_MyUserItem:GetInstance():GetClientUserItem(i)
        if not pIClientUserItem then
            return
        end

        self.m_szAccount[i] = pIClientUserItem.szNickName

        if i == MYSELF_VIEW_ID_316 then
            local pUserBack = cc.Sprite:createWithSpriteFrameName("316_head_back_me.png")
            pUserBack:setScale(self.m_scalex, self.m_scaley)
            pUserBack:setPosition(self.m_ptAvatar[i].x, self.m_ptAvatar[i].y)
            self:addChild(pUserBack, ZORDER_FACE_316 - 1)

            local iFaceID = pIClientUserItem.wFaceID
            if pIClientUserItem.cbGender == GENDER_MANKIND then
                if (iFaceID >= 0 and iFaceID <= 3) or (iFaceID >= 100 and iFaceID <= 113) then
                else
                    iFaceID = 0              
                end
            else
                if (iFaceID >= 50 and iFaceID <= 53) or (iFaceID >= 150 and iFaceID <= 163) then
                else
                    iFaceID = 50              
                end
            end 

            self.m_strFaceID[i] = string.format("316_Head_Face%d.png", iFaceID)
            self.m_btAvatar[i] = CSpriteEx:CreateWithSpriteFrameName(self.m_strFaceID[i], TAG_BT_PLAY_INFO_316 + i)
            local iOffPosY = self.m_btAvatar[i]:getContentSize().height > 65 and 7 or 0
            self.m_btAvatar[i]:setScale(self.m_scalex, self.m_scaley)
            self.m_btAvatar[i]:setPosition(pUserBack:getPositionX(), pUserBack:getPositionY() + iOffPosY * self.m_scaley)            
            self:addChild(self.m_btAvatar[i], ZORDER_FACE_316)

            self.m_ptNormalAvatar[i] = cc.p(self.m_btAvatar[i]:getPosition())
            self.m_ptTrusteeAvatar[i] = cc.p(pUserBack:getPosition())

            local iUserInfoPosX = 37 * self.m_scalex
            local iUserInfoPosY = 24 * self.m_scaley

            local ttfConfig = {}
            ttfConfig.fontFilePath = "default.ttf"
            ttfConfig.fontSize     = 27
            local myNameLabe= cc.Label:createWithTTF(ttfConfig, pIClientUserItem.szNickName)
            myNameLabe:setAnchorPoint(cc.p(0, 0.5))
            myNameLabe:setScale(m_scalex, m_scaley)
            myNameLabe:setPosition(iUserInfoPosX, iUserInfoPosY)
            myNameLabe:setColor(cc.c4b(240, 240, 180, 255))
            self:addChild(myNameLabe, ZORDER_FACE_316)

            iUserInfoPosX = iUserInfoPosX + myNameLabe:getBoundingBox().width + 150 *  self.m_scalex

            local pTexture2D = cc.Director:getInstance():getTextureCache():addImage("316_icon.png")
            local w = pTexture2D:getContentSize().width / 5
            local h = pTexture2D:getContentSize().height

            local pScoreIcon = nil
            local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
            if iRoomType <= ERT_GJ_316 then
                pScoreIcon = cc.Sprite:createWithTexture(pTexture2D, cc.rect(0 * w, 0, w, h))
            elseif iRoomType == ERT_FL_316 then
                pScoreIcon = cc.Sprite:createWithTexture(pTexture2D, cc.rect(2 * w, 0, w, h))
            end
            pScoreIcon:setScale(self.m_scalex, self.m_scaley)
            pScoreIcon:setPosition(iUserInfoPosX, iUserInfoPosY)
            self:addChild(pScoreIcon, ZORDER_FACE_316)

            iUserInfoPosX = iUserInfoPosX + pScoreIcon:getBoundingBox().width / 2 + 20 * self.m_scalex
            
            local m_pUserScore = cc.LabelAtlas:_create("/:0123456789+-", "316_mj_user_score.png", 16, 21, string.byte("."))
            m_pUserScore:setAnchorPoint(cc.p(0, 0.5))
            m_pUserScore:setTag(TAG_ID_USER_SCORE_316)
            m_pUserScore:setPosition(iUserInfoPosX, iUserInfoPosY)
            m_pUserScore:setScale(self.m_scalex, self.m_scaley)
            self:addChild(m_pUserScore, ZORDER_FACE_316)

            local szName = nil
            if pIClientUserItem.lScore < 0  then
                szName = string.format(";%d", -pIClientUserItem.lScore) 
            else 
                szName = string.format("%d", pIClientUserItem.lScore) 
            end
            m_pUserScore:setString(szName)

            iUserInfoPosX = iUserInfoPosX + m_pUserScore:getBoundingBox().width + 150 * self.m_scalex
            local iRandMedalIndex = iRoomType <= ERT_GJ_316 and 3 or 4
            local pRandOrMedalIcon = cc.Sprite:createWithTexture(pTexture2D, cc.rect(iRandMedalIndex * w, 0, w, h))
            pRandOrMedalIcon:setScale(self.m_scalex, self.m_scaley)
            pRandOrMedalIcon:setPosition(iUserInfoPosX, iUserInfoPosY)
            self:addChild(pRandOrMedalIcon, ZORDER_FACE_316)

            iUserInfoPosX = iUserInfoPosX + pRandOrMedalIcon:getBoundingBox().width / 2 + 20 * self.m_scalex
            local m_pRankMedalScore = cc.LabelAtlas:_create("/:0123456789+-", "316_mj_user_score.png", 16, 21, string.byte("."))
            m_pRankMedalScore:setAnchorPoint(cc.p(0, 0.5))
            m_pRankMedalScore:setTag(TAG_ID_MEDAL_RANK_316)
            m_pRankMedalScore:setScale(self.m_scalex, self.m_scaley)
            m_pRankMedalScore:setPosition(iUserInfoPosX, iUserInfoPosY)
            self:addChild(m_pRankMedalScore, ZORDER_FACE_316)

            if iRoomType <= ERT_GJ_316 then
                szName = string.format("%d", pIClientUserItem.dwUserMedal)
            else
                local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()
                if pMatchAttribute ~= nil then
                    szName = string.format("%d.%d", pMatchAttribute.dwCurRank, pMatchAttribute.dwTotalCount)
                end
            end
            m_pRankMedalScore:setString(szName)   

        else

            local pUserBack = cc.Sprite:createWithSpriteFrameName("316_head_back_me.png")
            pUserBack:setScale(self.m_scalex, self.m_scaley)
            pUserBack:setPosition(self.m_ptAvatar[i].x, self.m_ptAvatar[i].y)
            self:addChild(pUserBack, ZORDER_FACE_316 - 1)

            local strFaceID = nil
            local iFaceID = pIClientUserItem.wFaceID
            if pIClientUserItem.cbGender == GENDER_MANKIND then
                if (iFaceID >= 0 and iFaceID <= 3) or (iFaceID >= 100 and iFaceID <= 113) then
                else
                    iFaceID = 0              
                end
            else
                if (iFaceID >= 50 and iFaceID <= 53) or (iFaceID >= 150 and iFaceID <= 163) then
                else
                    iFaceID = 50              
                end
            end 

            self.m_strFaceID[i] = string.format("316_Head_Face%d.png", iFaceID)
            self.m_btAvatar[i] = CSpriteEx:CreateWithSpriteFrameName(self.m_strFaceID[i], TAG_BT_PLAY_INFO_316 + i)
            local iOffPosY = self.m_btAvatar[i]:getContentSize().height > 65 and 7 or 0
            local iPosX = pUserBack:getPositionX()
            local iPosY = pUserBack:getPositionY() + pUserBack:getBoundingBox().height / 2 - 40 * self.m_scaley
            self.m_btAvatar[i]:setScale(self.m_scalex, self.m_scaley)
            self.m_btAvatar[i]:setPosition(iPosX, iPosY + iOffPosY * self.m_scaley)            
            self:addChild(self.m_btAvatar[i], ZORDER_FACE_316) 

            self.m_ptNormalAvatar[i] = cc.p(self.m_btAvatar[i]:getPosition())
            self.m_ptTrusteeAvatar[i] = cc.p(pUserBack:getPosition())
        end

        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btAvatar[i], "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    end
end

function ASMJ_GameClientView:CellBanker()

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    ---------------------------------------------
    local pUserBack = cc.Sprite:createWithSpriteFrameName("316_head_back_me.png")
    local iUserBackWidth = (pUserBack:getContentSize().width - 5) * self.m_scalex
    local iUserBackHeight = (pUserBack:getContentSize().height - 5) * self.m_scaley
    
    local iBankerView = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(self.m_wBankerUser)
    local pBanker = cc.Sprite:createWithSpriteFrameName("316_bank_flag.png")
    pBanker:setScale(self.m_scalex, self.m_scaley)
    pBanker:setPosition(self.m_ptAvatar[iBankerView].x - iUserBackWidth / 2, self.m_ptAvatar[iBankerView].y + iUserBackHeight / 2)
    self:addChild(pBanker, ZORDER_FACE_316)

    local iCellCount = 0
    local iTmpCellScore = self.m_lCellScore
    repeat
        iCellCount = iCellCount + 1
        iTmpCellScore = math.floor(iTmpCellScore/10)
    until iTmpCellScore == 0 

    local pCellBack = cc.Sprite:createWithSpriteFrameName("316_cell_bg.png")
    local iCellInfoX = pCellBack:getContentSize().width * self.m_scalex + iCellCount * 16 * self.m_scalex
    local iCellInfoY = 420 * self.m_scaley
    pCellBack:setAnchorPoint(cc.p(0, 0.5))
    pCellBack:setPosition(visibleSize.width / 2 - iCellInfoX / 2, iCellInfoY)
    pCellBack:setScale(self.m_scalex, self.m_scaley)
    self:addChild(pCellBack, ZORDER_BACK_VIEW_316 + 1)

    iCellInfoX = pCellBack:getPositionX() + pCellBack:getBoundingBox().width + 2 * self.m_scalex
    
    local pBaseNumber = cc.LabelAtlas:_create(string.format("%d", self.m_lCellScore), "316_mj_cell_num.png", 19, 27, string.byte("0"))
    pBaseNumber:setPosition(iCellInfoX, iCellInfoY)
    pBaseNumber:setAnchorPoint(cc.p(0, 0.5))
    pBaseNumber:setScale(self.m_scalex, self.m_scaley)
    self:addChild(pBaseNumber, ZORDER_BACK_VIEW_316 + 1)
    ---------------------------------------
end

function ASMJ_GameClientView:GameStart(msgcmd)

    self.gameStatus = Game_PlayGame_316

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    self.m_scalex = display.scalex_landscape
    self.m_scaley = display.scaley_landscape

    local m_TableMJBack = cc.Sprite:create("316_table_bg.png")
    m_TableMJBack:setScale(self.m_scalex, self.m_scaley)
    m_TableMJBack:setPosition(visibleSize.width / 2, visibleSize.height / 2)
    self:addChild(m_TableMJBack, ZORDER_BACK_VIEW_316)

    self:RectifyControl(visibleSize.width, visibleSize.height)

    self:DrawUserView()

    -- read start data
    self.m_lCellScore       =   msgcmd:readLONGLONG()
                                msgcmd:readWORD()
    self.m_wBankerUser      =   msgcmd:readWORD() + 1
    self.m_wCurrentUser     =   msgcmd:readWORD() + 1
    self.m_wTimeCount       =   msgcmd:readWORD()
    self.m_cbActionMask     =   msgcmd:readBYTE()

    local wChairID          =   ASMJ_MyUserItem:GetInstance():GetChairID()
    local cbCardCount       =   wChairID == self.m_wBankerUser and MAX_COUNT_316 or MAX_COUNT_316 - 1
    local cbCardData        =   {}
    for i=1,cbCardCount do
        cbCardData[i]       =   msgcmd:readBYTE()            
    end
    
    self:CellBanker()

    -- show send mj
    ASMJ_GameLogic:GetInstance():SwitchTableToCardIndex(cbCardData, cbCardCount, self.m_cbCardIndex)

    local cbHandCardData = {}
    ASMJ_GameLogic:GetInstance():SwitchTableToCardData(self.m_cbCardIndex, cbHandCardData)

    self:ShowSiceFinish()

    local iType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
    if iType == ERT_FL_316 then
        local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()
        self.m_MatchControl = ASMJ_MatchControl_create()

        self.m_MatchControl:SetScaleMin(self.m_scalex, self.m_scaley)
        self.m_wMatchTime = pMatchAttribute.dwMatchTime
        if self.m_MatchControl:GetMatchTime() > 0 then
            self.m_wMatchTime = self.m_MatchControl:GetMatchTime()
        end

        self.m_MatchControl:SetMatchTime(self.m_wMatchTime)
        self.m_MatchControl:setTag(TAG_ID_MATCH_CONTROL_316)
        self.m_MatchControl:ShowMatch(cc.p(visibleSize.width / 2, 355 * self.m_scaley))
        self:addChild(self.m_MatchControl, 0)
    end

    if cc.UserDefault:getInstance():getBoolForKey("316_BackMusic", true) then
        ccexp.AudioEngine:play2d("316_background.MP3", true, 0.3)
    else
        ccexp.AudioEngine:stopAll()
    end

    if cc.UserDefault:getInstance():getBoolForKey("316_GameMusic", true) then
        ccexp.AudioEngine:play2d("316_game_start.MP3", false, 1)
    end
end

function ASMJ_GameClientView:ShowSiceFinish()

    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()

    local cbHandCardData = {}
    ASMJ_GameLogic:GetInstance():SwitchTableToCardData(self.m_cbCardIndex, cbHandCardData)

    local iCardCount = ASMJ_GameLogic:GetInstance():GetCardCount(self.m_cbCardIndex)
    ASMJ_GameLogic:GetInstance():RandCardData(cbHandCardData, iCardCount)

    for i=1,4 do
        for j=1,GAME_PLAYER_316 do

            local wChairID = (self.m_wBankerUser + GAME_PLAYER_316 - j) % GAME_PLAYER_316 + 1
            local pStartCardItem = ASMJ_CStartCardItem_create()
            pStartCardItem.m_cbCardCount = i <= 3 and 4 or 1

            if wChairID == wMeChairID then
                if i <= 3 then
                    for z=1,4 do
                        pStartCardItem.m_cbCardData[z] = cbHandCardData[(i-1)*4 + z]
                    end
                else
                   pStartCardItem.m_cbCardData[1] = cbHandCardData[(i-1)*4 + 1] 
                end
            end

            pStartCardItem.m_wChairID = wChairID
            table.insert(self.m_MoveCardItemArray, pStartCardItem)
        end
    end

    local pStartCardItem = ASMJ_CStartCardItem_create()
    pStartCardItem.m_cbCardCount = 1
    if iCardCount == MAX_COUNT_316 then
        pStartCardItem.m_cbCardData[1] = cbHandCardData[MAX_COUNT_316]
    end
    pStartCardItem.m_wChairID = self.m_wBankerUser
    pStartCardItem.m_bLastItem = true
    table.insert(self.m_MoveCardItemArray, pStartCardItem)
    self:BeginMoveCard()
end

function ASMJ_GameClientView:BeginMoveCard()

    if self.m_bMovingMJ then
        return false
    end

    if #self.m_MoveCardItemArray <= 0 then
        return false
    end

    local enMoveKind = self.m_MoveCardItemArray[1]:GetMoveKind()
    if enMoveKind == MK_StartCard_316 then
        return self:BeginMoveStartCard(self.m_MoveCardItemArray[1])
    elseif enMoveKind == MK_OutCard_316 then
        return self:BeginMoveOutCard(self.m_MoveCardItemArray[1])
    elseif enMoveKind == MK_SendCard_316 then
        return self:BeginMoveSendCard(self.m_MoveCardItemArray[1])
    elseif enMoveKind == MK_ShowCard_316 then
        return self:BeginMoveShowCard(self.m_MoveCardItemArray[1])
    elseif enMoveKind == MK_OrbitCard_316 then
        return self:BeginMoveOrbitCard(self.m_MoveCardItemArray[1])
    end

    return false
end

function ASMJ_GameClientView:BeginMoveStartCard(pStartCardItem)

    local visibleSize = cc.Director:getInstance():getVisibleSize()

    local ptTo
    local wChairID = pStartCardItem.m_wChairID

    local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wChairID)
    if wViewChairID == MYSELF_VIEW_ID_316 then
        ptTo = self.m_HandCardControl:GetSendMJPoint()
    else
        local wUserIndex = wViewChairID > 3 and 3 or wViewChairID
        ptTo = self.m_OtherPlayerHandMJ[wUserIndex]:GetSendMJPoint()
    end

    self.m_cbLeftCardCount = self.m_cbLeftCardCount - pStartCardItem.m_cbCardCount
    self.m_pLeftMJNumber:setString(string.format("%d", self.m_cbLeftCardCount))

    if self.m_bMovingMJ then
        return true
    end
    self.m_bMovingMJ = true


    local callMoveFinish = cc.CallFunc:create(handler(self, self.ActionCallMoveMJFinish))

    if pStartCardItem.m_cbCardCount == 1 then
       
        local pDealMJ = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_Up_0.png")
        pDealMJ:setPosition(self.m_pStartMJBack:getPosition())
        pDealMJ:setScale(self.m_scalex, self.m_scaley)
        self:addChild(pDealMJ, ZORDER_ACTION_316)

        local callfunc = cc.CallFunc:create(function () pDealMJ:removeFromParent() end)
        local pDealSeq = cc.Sequence:create(cc.MoveTo:create(0.4, ptTo), callfunc, callMoveFinish, NULL)
        pDealMJ:runAction(pDealSeq)

    elseif pStartCardItem.m_cbCardCount == 2 then
       
        local pDealMJ = cc.Sprite:createWithSpriteFrameName("316_prepare_wall_w_item_0.png")
        pDealMJ:setPosition(self.m_pStartMJBack:getPosition())
        pDealMJ:setScale(self.m_scalex, self.m_scaley)
        self:addChild(pDealMJ, ZORDER_ACTION_316)

        local callfunc = cc.CallFunc:create(function () pDealMJ:removeFromParent() end)
        local pDealSeq = cc.Sequence:create(cc.MoveTo:create(0.4, ptTo), callfunc, callMoveFinish, NULL)
        pDealMJ:runAction(pDealSeq)

    elseif pStartCardItem.m_cbCardCount == 4 then

        local pDealMJ = cc.Sprite:createWithSpriteFrameName("316_tile_wall.png")
        pDealMJ:setPosition(self.m_pStartMJBack:getPosition())
        pDealMJ:setScale(self.m_scalex, self.m_scaley)
        self:addChild(pDealMJ, ZORDER_ACTION_316)

        local pDealMJ1 = cc.Sprite:createWithSpriteFrame(pDealMJ:getSpriteFrame())
        pDealMJ1:setPosition(self.m_pStartMJBack:getPositionX() + pDealMJ:getBoundingBox().width, self.m_pStartMJBack:getPositionY())
        pDealMJ1:setScale(self.m_scalex, self.m_scaley)
        self:addChild(pDealMJ1, ZORDER_ACTION_316)

        local callfunc = cc.CallFunc:create(function () pDealMJ:removeFromParent() end)
        local pDealSeq = cc.Sequence:create(cc.MoveTo:create(0.4, ptTo), callfunc)
        pDealMJ:runAction(pDealSeq)

        ptTo.x = ptTo.x + pDealMJ:getBoundingBox().width
        local callfunc1 = cc.CallFunc:create(function () pDealMJ1:removeFromParent() end)
        local pDealSeq1 = cc.Sequence:create(cc.MoveTo:create(0.4, ptTo), callfunc1, callMoveFinish)
        pDealMJ1:runAction(pDealSeq1)

    end

    if cc.UserDefault:getInstance():getBoolForKey("316_GameMusic", true) then
        --AudioEngine.playEffect("316_game_send.MP3", false)
        ccexp.AudioEngine:play2d("316_game_send.MP3", false, 1)
    end
end

function ASMJ_GameClientView:BeginMoveOutCard(pMoveCardItem)
    
    local pOutCardItem = pMoveCardItem

    local wMeChairID =  ASMJ_MyUserItem:GetInstance():GetChairID()
    local wOutCardUser = pOutCardItem.m_wOutCardUser
    local wViewOutCardUser = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wOutCardUser)
    
    local cbOutCardData = pOutCardItem.m_cbOutCardData

    if wOutCardUser ~= wMeChairID then

        self.m_OtherPlayerHandMJ[wViewOutCardUser > 3 and 3 or wViewOutCardUser]:DeleteUserHandMJ(1)
        self.m_wCurrentUser = INVALID_CHAIR_316
        self:PlayMJSound(wOutCardUser, cbOutCardData)
    end

    self:ActionCallMoveMJFinish()
end

function ASMJ_GameClientView:BeginMoveSendCard(pMoveCardItem)
    
    local pSendCardItem = pMoveCardItem
    local wSendCardUser = pSendCardItem.m_wSendCardUser
    local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wSendCardUser)

    self.m_wCurrentUser = pSendCardItem.m_wCurrentUser

    self.m_cbLeftCardCount = self.m_cbLeftCardCount - 1
    self.m_pLeftMJNumber:setString(string.format("%d", self.m_cbLeftCardCount))

    self:ActionCallMoveMJFinish()

    if cc.UserDefault:getInstance():getBoolForKey("316_GameMusic", true) then
        --AudioEngine.playEffect("316_game_send.MP3", false)
        ccexp.AudioEngine:play2d("316_game_send.MP3", false, 1)
    end

    return true
end

function ASMJ_GameClientView:BeginMoveShowCard(pMoveCardItem)

    if #self.m_ReportData > 0 then
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteWORDToBuffers(self.m_ReportData[1].wKindID)
        CClientKernel:GetInstance():WriteWORDToBuffers(self.m_ReportData[1].wServerID)
        CClientKernel:GetInstance():WriteWORDToBuffers(self.m_ReportData[1].wTableID)
        CClientKernel:GetInstance():WriteWORDToBuffers(self.m_ReportData[1].wChairID)
        CClientKernel:GetInstance():WriteDWORDToBuffers(self.m_ReportData[1].dwConcludeTime)
        CClientKernel:GetInstance():WriteDWORDToBuffers(self.m_ReportData[1].dwUserID)
        CClientKernel:GetInstance():WriteLONGLONGToBuffers(self.m_ReportData[1].lDeposit)

        for i=1,8 do
            CClientKernel:GetInstance():WriteDWORDToBuffers(self.m_ReportData[1].dwCheatUserID[i])
        end
        for i=1,8 do
            CClientKernel:GetInstance():WriteBYTEToBuffers(self.m_ReportData[1].dwCheatUserID[i])
        end
        for i=1,8 do
            CClientKernel:GetInstance():WriteBYTEToBuffers(self.m_ReportData[1].dwCheatUserID[i])
        end
        for i=1,8 do
            CClientKernel:GetInstance():WriteBYTEToBuffers(self.m_ReportData[1].dwCheatUserID[i])
        end
        CClientKernel:GetInstance():WritecharToBuffers(self.m_ReportData[1].szDescribeString, 128)
        CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_FRAME, SUB_GF_USER_REPORT_CHEAT)
    end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function () self:ActionCallMoveMJFinish() end)))
end

function ASMJ_GameClientView:BeginMoveOrbitCard(pOrbitCardItem)
    self:ActionCallMoveMJFinish()
end

function ASMJ_GameClientView:ActionCallMoveMJFinish()

    if #self.m_MoveCardItemArray <= 0 then
        return
    end

    self.m_bMovingMJ = false   

    local enMoveKind = self.m_MoveCardItemArray[1]:GetMoveKind()

    if enMoveKind == MK_StartCard_316 then
       
        local StartCardItem = self.m_MoveCardItemArray[1]
        self:OnMoveStartCardFinish(StartCardItem)
        table.remove(self.m_MoveCardItemArray, 1)

    elseif enMoveKind == MK_OutCard_316 then

        local OutCardItem = self.m_MoveCardItemArray[1]
        self:OnMoveOutCardFinish(OutCardItem)
        table.remove(self.m_MoveCardItemArray, 1)

    elseif enMoveKind == MK_SendCard_316 then

        local SendCardItem = self.m_MoveCardItemArray[1]
        self:OnMoveSendCardFinish(SendCardItem)
        table.remove(self.m_MoveCardItemArray, 1)

    elseif enMoveKind == MK_ShowCard_316 then
        local ShowCardItem = self.m_MoveCardItemArray[1]
        self:OnMoveShowCardFinish(ShowCardItem)
        table.remove(self.m_MoveCardItemArray, 1)

    elseif enMoveKind == MK_OrbitCard_316 then
        local OrbitCardItem = self.m_MoveCardItemArray[1]
        self:OnMoveOrbitCardFinish(OrbitCardItem)
        table.remove(self.m_MoveCardItemArray, 1)
    end

    self:BeginMoveCard()
end

function ASMJ_GameClientView:OnMoveStartCardFinish(pStartCardItem)
    
    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    local wChairID = pStartCardItem.m_wChairID
    local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wChairID)

    if wViewChairID == MYSELF_VIEW_ID_316 then
        self.m_HandCardControl:DrawHandMJ(pStartCardItem.m_cbCardData, pStartCardItem.m_cbCardCount, pStartCardItem.m_bLastItem, pStartCardItem.m_bLastItem and true or false)
    else
        local wUserIndex = wViewChairID > 3 and 3 or wViewChairID
        self.m_OtherPlayerHandMJ[wUserIndex]:DrawUserHandMJ(pStartCardItem.m_cbCardCount, pStartCardItem.m_bLastItem)
    end

    if pStartCardItem.m_bLastItem then

        self.m_pStartMJBack:removeFromParent()

        self.m_HandCardControl:OrbitHandMJ()
        self.m_HandCardControl:SetPositive(true)
        for i=1,3 do
            self.m_OtherPlayerHandMJ[i]:OrbitUserHandMJ()
        end

        if self.m_wCurrentUser == wMeChairID then

            if self.m_cbActionMask ~= WIK_NULL_316 then

                local GangCardResult = {}
                GangCardResult.cbCardData = {}
                GangCardResult.cbCardCount = 0

                if bit:_and(self.m_cbActionMask, WIK_GANG_316) ~= 0 then
                    
                    if self.m_wCurrentUser == INVALID_CHAIR_316 and self.m_cbActionCard ~= 0 then
                        GangCardResult.cbCardCount = 1
                        GangCardResult.cbCardData[1] = self.m_cbActionCard
                    end

                    if self.m_wCurrentUser == wMeChairID or self.m_cbActionCard == 0 then
                        ASMJ_GameLogic:GetInstance():AnalyseGangCard(self.m_cbCardIndex, self.m_WeaveItemArray[wMeChairID], self.m_cbWeaveCount[wMeChairID], self.m_cbEnjoinGangCard, GangCardResult)
                    end
                end
                self.m_OperateControl:SetOperateControl(self.m_cbActionCard, self.m_cbActionMask, GangCardResult)
            end
        end

        if self.m_wCurrentUser ~= INVALID_CHAIR_316 then

            assert(self.m_wCurrentUser <= GAME_PLAYER_316, "error m_wCurrentUser")

            local wTimeUserView = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(self.m_wCurrentUser) 
            self.m_pTimeXYZ[wTimeUserView]:setVisible(true)

            self.m_pTimerNumber:setString(string.format("%d%d", math.floor(self.m_wTimeCount/10), self.m_wTimeCount%10))

            local scheduler = cc.Director:getInstance():getScheduler()
            SID_CurrentUserTimeElapse[#SID_CurrentUserTimeElapse + 1] = scheduler:scheduleScriptFunc(handler(self, self.CurrentUserTimeElapse), 1, false)
        end
    end

    return true
end

function ASMJ_GameClientView:OnMoveOutCardFinish(pOutCardItem)
    
    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    local cbOutCardData = pOutCardItem.m_cbOutCardData
    local cbFirstChicken = pOutCardItem.m_cbFirstChicken
    local wOutUserView = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(pOutCardItem.m_wOutCardUser)
    
    self.m_TableOutMJControl[wOutUserView]:DrawOutMJControl(cbOutCardData, cbFirstChicken, pOutCardItem.m_ptOrigin, true)

    local ptDisc = cc.p(self.m_TableOutMJControl[wOutUserView]:GetOutMJPoint())
    self.m_pDiscUser:setPosition(ptDisc.x, ptDisc.y + 30 * self.m_scaley)
    self.m_pDiscUser:stopAllActions()

    local seqDisc = cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.8), cc.Show:create(),
            cc.CallFunc:create(
                function ()
                    local pMove1 = cc.MoveTo:create(0.8, cc.p(self.m_pDiscUser:getPositionX(), self.m_pDiscUser:getPositionY()))
                    local pMove2 = cc.MoveTo:create(0.8, cc.p(self.m_pDiscUser:getPositionX(), self.m_pDiscUser:getPositionY() + 15 * self.m_scaley))
                    local seqMove = cc.Sequence:create(pMove2, pMove1)
                    local pRepeat = cc.RepeatForever:create(seqMove)
                    self.m_pDiscUser:runAction(pRepeat)
                end))
    self.m_pDiscUser:runAction(seqDisc)

    return true
end

function ASMJ_GameClientView:OnMoveSendCardFinish(pSendCardItem)
    
    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(pSendCardItem.m_wSendCardUser)
    
    local wChairID = pSendCardItem.m_wSendCardUser
    local cbSendCardData = pSendCardItem.m_cbCardData

    if wViewChairID ~= MYSELF_VIEW_ID_316 then
        local wUserIndex = (wViewChairID > 3) and 3 or wViewChairID
        self.m_OtherPlayerHandMJ[wUserIndex]:DrawUserHandMJ(1, true, true)
    else
        local cbCardIndex = ASMJ_GameLogic:GetInstance():SwitchToCardIndex(cbSendCardData)
        self.m_cbCardIndex[cbCardIndex] = self.m_cbCardIndex[cbCardIndex] + 1
        
        local cbSendCardDataTable = {}
        cbSendCardDataTable[1] = cbSendCardData
        self.m_HandCardControl:DrawHandMJ(cbSendCardDataTable, 1, true, true, true)
    end

    self.m_wCurrentUser = pSendCardItem.m_wCurrentUser

   
    if self.m_wCurrentUser == wMeChairID then

        self.m_cbActionMask = pSendCardItem.m_cbActionMask
        self.m_cbActionCard = pSendCardItem.m_cbCardData

        if self.m_cbActionMask ~= WIK_NULL_316 then

            local GangCardResult = {}
            GangCardResult.cbCardData = {}
            GangCardResult.cbCardCount = 0

            if bit:_and(self.m_cbActionMask, WIK_GANG_316) ~= 0 then
                
                if self.m_cbListenStatus == 0 then
                    if self.m_bStustee then
                        self:OnStustee()
                    end
                end

                if self.m_wCurrentUser == INVALID_CHAIR_316 and self.m_cbActionCard ~= 0 then
                    GangCardResult.cbCardCount = 1
                    GangCardResult.cbCardData[1] = self.m_cbActionCard
                end

                if self.m_wCurrentUser == wMeChairID or self.m_cbActionCard == 0 then
                    ASMJ_GameLogic:GetInstance():AnalyseGangCard(self.m_cbCardIndex, self.m_WeaveItemArray[wMeChairID], self.m_cbWeaveCount[wMeChairID], self.m_cbEnjoinGangCard, GangCardResult)
                end
            end
            self.m_OperateControl:SetOperateControl(self.m_cbActionCard, self.m_cbActionMask, GangCardResult)
        end
    end

    if self.m_wCurrentUser ~= INVALID_CHAIR_316 then
       
        self.m_wSpendTime = 0

        local wTimeUserView = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(self.m_wCurrentUser)
        self.m_pTimeXYZ[wTimeUserView]:setVisible(true)

        self.m_pTimerNumber:setString(string.format("%d%d", math.floor(self.m_wTimeCount / 10), self.m_wTimeCount % 10))
  
        local scheduler = cc.Director:getInstance():getScheduler()
        SID_CurrentUserTimeElapse[#SID_CurrentUserTimeElapse + 1] = scheduler:scheduleScriptFunc(handler(self, self.CurrentUserTimeElapse), 1, false)
    end

    return true
end

function ASMJ_GameClientView:OnMoveShowCardFinish(pShowCardItem)
    local cbSendCardData = pShowCardItem.m_cbCardData

    self.m_cbLeftCardCount = self.m_cbLeftCardCount - 1
    self.m_pLeftMJNumber:setString(string.format("%d", self.m_cbLeftCardCount))

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local pAllNode = cc.Node:create()
    self:addChild(pAllNode, ZORDER_ACTION_316)

    local pScale = cc.ScaleTo:create(0.5, 1.2)
    local pScaleOrigin = cc.ScaleTo:create(0.5, 1)
    local pSeqBack = cc.Sequence:create(
        cc.ScaleTo:create(0.5, 1.2), 
        cc.DelayTime:create(3.0),
        cc.ScaleTo:create(0.5, 1), 
        cc.DelayTime:create(0.5), 
        cc.CallFunc:create(function () pAllNode:removeFromParent() end),
        cc.CallFunc:create(handler(self,self.ShowGameScore)))     
    
    self:runAction(pSeqBack)

    local pShowControl = cc.Sprite:createWithSpriteFrameName("316_chicken_back.png")
    pShowControl:setScale(self.m_scalex, self.m_scaley)
    pShowControl:setPosition(visibleSize.width / 2, visibleSize.height / 2)
    pAllNode:addChild(pShowControl, 0)

    local iTopShowX = visibleSize.width / 2 - pShowControl:getBoundingBox().width / 2
    local iTopShowY = visibleSize.height / 2 + pShowControl:getBoundingBox().height / 2

    
    local iShowMJPoint = { 
            cc.p(iTopShowX + 140 * self.m_scalex, iTopShowY - 80 * self.m_scaley),
            cc.p(iTopShowX + 75 * self.m_scalex, iTopShowY - 155 * self.m_scaley),
            cc.p(iTopShowX + 205 * self.m_scalex, iTopShowY - 155 * self.m_scaley), }

    local pShowMJBack1 = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_Up_0.png")
    pShowMJBack1:setScale(self.m_scalex, self.m_scaley)
    pShowMJBack1:setPosition(iShowMJPoint[1])
    pAllNode:addChild(pShowMJBack1, 1)

    pShowMJBack1:runAction(
            cc.Sequence:create(cc.DelayTime:create(1.5), 
            cc.CallFunc:create(function () pShowMJBack1:removeFromParent() end)))

    local pShowMJBack2 = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_Up_0.png")
    pShowMJBack2:setScale(self.m_scalex, self.m_scaley)
    pShowMJBack2:setPosition(iShowMJPoint[2])
    pAllNode:addChild(pShowMJBack2, 1)

    pShowMJBack1:runAction(
            cc.Sequence:create(cc.DelayTime:create(1.8), 
            cc.CallFunc:create(function () pShowMJBack1:removeFromParent() end)))

    local pShowMJBack3 = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_Up_0.png")
    pShowMJBack3:setScale(self.m_scalex, self.m_scaley)
    pShowMJBack3:setPosition(iShowMJPoint[3])
    pAllNode:addChild(pShowMJBack3, 1)

    pShowMJBack1:runAction(
            cc.Sequence:create(cc.DelayTime:create(2.1), 
            cc.CallFunc:create(function () pShowMJBack3:removeFromParent() end)))
  
    local pShowHand = cc.Sprite:createWithSpriteFrameName("316_chicken_action_1.png")
    pShowHand:setScale(self.m_scalex, self.m_scaley)
    pShowHand:setPosition(visibleSize.width / 2, visibleSize.height / 2 + 60 * self.m_scaley)
    pAllNode:addChild(pShowHand, 10)

    local animation =cc.Animation:create()
    for i=1,10 do
        local szName =string.format("316_chicken_action_%d.png",i)
        local pSpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(szName)
        animation:addSpriteFrame(pSpriteFrame)
    end  

    local fActionTime = 2.8/14.0
    animation:setDelayPerUnit(fActionTime)
    animation:setRestoreOriginalFrame(true)    --

    local action =cc.Animate:create(animation) 
    local seqShowHand = cc.Sequence:create(cc.DelayTime:create(0.5), action, cc.CallFunc:create(function () pShowHand:removeFromParent() end))
    pShowHand:runAction(cc.RepeatForever:create(seqShowHand))

    for i=1,3 do
        str = string.format("316_tile_meUp_%d%d.png", bit:_rshift(self.m_ScoreData.cbChickenCard[i], 4), bit:_and(self.m_ScoreData.cbChickenCard[i], 15))
        local pMJData = cc.Sprite:createWithSpriteFrameName(str)
        local pMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_meUp_0.png")

        pMJData:setColor(cc.c3b(243,170,175))
        pMJBack:setColor(cc.c3b(243,170,175))

        pMJData:setScale(self.m_scalex, self.m_scaley)
        pMJData:setPosition(iShowMJPoint[i].x, iShowMJPoint[i].y + DATA_MJ_EDGE_LRT_316 * self.m_scaley)

        pMJBack:setScale(self.m_scalex, self.m_scaley)
        pMJBack:setPosition(iShowMJPoint[i])

        pAllNode:addChild(pMJBack, 1)
        pAllNode:addChild(pMJData, 2)

        local fMJDelayTime = fActionTime * 10 + 0.5 + (i - 1)*0.3
        pMJData:runAction(
                cc.Sequence:create(cc.Hide:create(), 
                cc.DelayTime:create(fMJDelayTime), 
                cc.Show:create()))

        pMJBack:runAction(
                cc.Sequence:create(cc.Hide:create(), 
                cc.DelayTime:create(fMJDelayTime),
                cc.Show:create()))
    end
end

function ASMJ_GameClientView:OnMoveOrbitCardFinish(pOrbitCardItem)
    self.m_HandCardControl:OrbitShowHandMJ(pOrbitCardItem.m_cbCardData, pOrbitCardItem.m_cbCardCount, pOrbitCardItem.m_cbProvideMJ)
end

function ASMJ_GameClientView:CurrentUserTimeElapse(considerTime)

    assert(self.gameStatus == Game_PlayGame_316, "error game status")

    if self.gameStatus ~= Game_PlayGame_316 then
        return
    end

    self.m_wSpendTime = self.m_wSpendTime + 1 

    local iRemainTime = self.m_wTimeCount - self.m_wSpendTime
    if iRemainTime <= 0 then
        iRemainTime = 0
    end

    self.m_pTimerNumber:setString(string.format("%d%d", math.floor(iRemainTime/10), iRemainTime%10))

    if iRemainTime <= 0 then
        local scheduler = cc.Director:getInstance():getScheduler()

        for i = 1, #SID_CurrentUserTimeElapse do
            if SID_CurrentUserTimeElapse[i] ~= nil then
                scheduler:unscheduleScriptEntry(SID_CurrentUserTimeElapse[i])
                SID_CurrentUserTimeElapse[i] = nil
            end
        end
    end

    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    if self.m_wCurrentUser ~= wMeChairID then
        return
    end


    if self.m_bStustee or iRemainTime <= 0 or
        (self.m_cbListenStatus ~= 0 and (not self.m_bWillHearStatus) and iRemainTime < self.m_wTimeCount) then

        self.m_wTimeOutCount = self.m_wTimeOutCount + 1
        if self.m_cbListenStatus == 0 and (not self.m_bStustee) and (self.m_wTimeOutCount >= 1) then
           self.m_wTimeOutCount = 0
           self:OnStustee()
        end

        local iHandMJCount = #self.m_HandCardControl.m_HandMJData
        assert(iHandMJCount > 0, "error m_HandMJData is empty")
        local cbCardData = self.m_HandCardControl.m_HandMJData[iHandMJCount].m_cbHandMJData

        if (self.m_bStustee or self.m_cbListenStatus > 0) and (bit:_and(self.m_cbActionMask,WIK_CHI_HU_316)) ~= 0 then
            self:OnUserAction(WIK_CHI_HU_316, 0)
        end

        if self.m_cbActionMask ~= WIK_NULL_316 then
            self.m_OperateControl:ClearAllOperate()
        end
       
        local iHandMJIndex = iHandMJCount


        if not self:VerdictOutCard(cbCardData) then

            for i=1,MAX_INDEX_316 do
                if self.m_cbCardIndex[i] == 0 or (not self:VerdictOutCard(ASMJ_GameLogic:GetInstance():SwitchToCardData(i))) then
                else
                   cbCardData = ASMJ_GameLogic:GetInstance():SwitchToCardData(i)
                end
            end

            iHandMJIndex = iHandMJCount
            for i=iHandMJCount,1,-1 do
                if self.m_HandCardControl.m_HandMJData[i].m_cbHandMJData == cbCardData then
                    break
                end
            end
        end

        assert(iHandMJIndex >= 1, "error outmj index")
        assert(self.m_cbCardIndex[ASMJ_GameLogic:GetInstance():SwitchToCardIndex(cbCardData)] > 0, "error mjdata is nil")
        self:OnHandOutMJ(cbCardData, iHandMJIndex, 1)
    end

    return
end 

function ASMJ_GameClientView:OperateUserTimeElapse(considerTime)
    assert(self.gameStatus == Game_PlayGame_316, "error gameStatus")
   
    if self.gameStatus ~= Game_PlayGame_316 then
        return
    end

    self.m_wSpendTime = self.m_wSpendTime + 1
    local iRemainTime = self.m_wTimeCount - self.m_wSpendTime

    if iRemainTime <= 0 then
        iRemainTime = 0
    end

    self.m_pTimerNumber:setString(string.format("%d%d", math.floor(iRemainTime / 10), iRemainTime % 10))

    if iRemainTime <= 0 then
        if SID_OperateUserTimeElapse ~= nil then
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(SID_OperateUserTimeElapse)
            SID_OperateUserTimeElapse = nil
        end
    end

    local wOperateUser = ASMJ_MyUserItem:GetInstance():GetChairID()
    if self.m_cbActionMask == 0 or self.m_wOperateUser[wOperateUser] == 0 then
        return
    end

    if self.m_cbListenStatus > 0 or self.m_bStustee or iRemainTime <= 0 then
        
        self.m_wOperateUser[wOperateUser] = 0

        if self.m_cbListenStatus ~= 2 then
            if  bit:_and(self.m_cbActionMask, WIK_CHI_HU_316) ~= 0 then
                self:OnUserAction(WIK_CHI_HU_316, 0)
                return
            end
        end

        self:OnUserAction(WIK_NULL_316, 0)
    end
end

function ASMJ_GameClientView:VerdictOutCard(cbCardData)
    if self.m_cbListenStatus > 0 or self.m_bWillHearStatus then
        local chr = {}
        local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
        local cbWeaveCount = self.m_cbWeaveCount[wMeChairID]

        local cbCardIndexTemp = {}
        for i=1,MAX_INDEX_316 do
            cbCardIndexTemp[i] = self.m_cbCardIndex[i]
        end

        if not ASMJ_GameLogic:GetInstance():RemoveCard(cbCardIndexTemp, cbCardData) then
            assert(false, "error remove mj")
            return false
        end

        local i = 0
        for i=1,MAX_INDEX_316 do
            local cbCurrentCard = ASMJ_GameLogic:GetInstance():SwitchToCardData(i)
            local cbHuCardKind = ASMJ_GameLogic:GetInstance():AnalyseChiHuCard(cbCardIndexTemp,self.m_WeaveItemArray[wMeChairID], cbWeaveCount, cbCurrentCard,chr, true, true)

            if cbHuCardKind ~= WIK_NULL_316 then
                break
            end
        end
        return (i ~= MAX_INDEX_316)
    end

    return false
end

function ASMJ_GameClientView:OnHandOutMJ(cbMJData, cbMJIndex, cbOutType) 
    if self.m_wCurrentUser ~= ASMJ_MyUserItem:GetInstance():GetChairID() then
        return
    end

    local wTimeUserView = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(self.m_wCurrentUser)
    self.m_pTimeXYZ[wTimeUserView]:setVisible(false)

    self.m_wCurrentUser = INVALID_CHAIR_316
    self.m_cbActionMask = 0
    self.m_cbActionCard = 0

    local cbOutCardData = cbMJData

    if self.m_bWillHearStatus then
        self.m_bWillHearStatus = false
    end

    if not ASMJ_GameLogic:GetInstance():RemoveCard(self.m_cbCardIndex, cbOutCardData) then
        assert(false, "error removemj")
        return
    end

    self.m_OperateControl:ClearAllOperate()

    local cbCardData = {}
    local cbCardCount = ASMJ_GameLogic:GetInstance():SwitchTableToCardData(self.m_cbCardIndex, cbCardData)

    assert((cbCardCount - 1) % 3 == 0)

    local pOutCardItem = ASMJ_COutCardItem_create()
    pOutCardItem.m_ptOrigin = cc.p(self.m_HandCardControl.m_HandMJData[cbMJIndex].m_pSpriteMJBack:getPosition())
    pOutCardItem.m_cbOutCardData = cbOutCardData
    pOutCardItem.m_wOutCardUser = ASMJ_MyUserItem:GetInstance():GetChairID()
    
    self.m_HandCardControl:DeleteMJData(cbMJData, cbMJIndex)

    if cbOutCardData == 17 and self.m_cbFirstChicken == 0 then
        pOutCardItem.m_cbFirstChicken = 1
    else 
        pOutCardItem.m_cbFirstChicken = 0
    end

    table.insert(self.m_MoveCardItemArray, pOutCardItem)

    self:BeginMoveCard()

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteBYTEToBuffers(cbOutType)
    CClientKernel:GetInstance():WriteBYTEToBuffers(cbOutCardData)
    CClientKernel:GetInstance():WriteWORDToBuffers(self.m_wSpendTime)
    CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_GAME, SUB_C_OUT_CARD)

    self:PlayMJSound(ASMJ_MyUserItem:GetInstance():GetChairID(), cbOutCardData)

    return
end

function ASMJ_GameClientView:OnStustee()

    local pIClientUserItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    if not pIClientUserItem then
        return
    end

    self.m_pTrusteeBack:setVisible(not self.m_bStustee)
    self.m_wTimeOutCount = 0
    self.m_bStustee = not self.m_bStustee

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteboolToBuffers(self.m_bStustee)
    CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_GAME, SUB_C_TRUSTEE)

    local pBtAvatar = self:getChildByTag(TAG_BT_PLAY_INFO_316 + MYSELF_VIEW_ID_316)
    if pBtAvatar ~= 0 then

        if self.m_bStustee then

            pBtAvatar:setPosition(self.m_ptTrusteeAvatar[MYSELF_VIEW_ID_316])
            pBtAvatar:setSpriteFrame("316_Trustee_Head0.png")

            local animation =cc.Animation:create()
            for i=0,2 do
                local szName =string.format("316_Trustee_Head%d.png",i)
                local pSpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(szName)
                animation:addSpriteFrame(pSpriteFrame)
            end  
       
            animation:setDelayPerUnit(2.0/7.0)
            animation:setRestoreOriginalFrame(true)    --

            local action =cc.Animate:create(animation) 
            local seqShowHand = cc.Sequence:create(cc.DelayTime:create(0.5), action)
            pBtAvatar:runAction(cc.RepeatForever:create(seqShowHand))

        else
            pBtAvatar:stopAllActions()
            pBtAvatar:setPosition(self.m_ptNormalAvatar[MYSELF_VIEW_ID_316])
            pBtAvatar:setSpriteFrame(self.m_strFaceID[MYSELF_VIEW_ID_316])
        end
    end

    return 0
end

function ASMJ_GameClientView:GameAgain()
    local wTableID = 65535
    local wChairID = 65535
    local szPassword = ""
    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteWORDToBuffers(wTableID)
    CClientKernel:GetInstance():WriteWORDToBuffers(wChairID)
    CClientKernel:GetInstance():WritecharToBuffers(szPassword,33)
   
    if CClientKernel:GetInstance():SendSocketToGameServer(MDM_GR_USER, SUB_GR_USER_SITDOWN) then
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end



function ASMJ_GameClientView:OnSubTrustee(msgcmd)
    
    if self.gameStatus ~= Game_PlayGame_316 then
        return 
    end

    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    local bTrustee = msgcmd:readBYTE()
    local wChairID = msgcmd:readWORD() + 1

    if wChairID ~= wMeChairID then

        local wViewChairID = (wChairID + GAME_PLAYER_316 + 2 - wMeChairID)%GAME_PLAYER_316 + 1
        local pBtAvatar = self:getChildByTag(TAG_BT_PLAY_INFO_316 + wViewChairID)

        if pBtAvatar ~= 0 then
            if bTrustee == 1 then

                pBtAvatar:setPosition(self.m_ptTrusteeAvatar[wViewChairID])
                pBtAvatar:setSpriteFrame("316_Trustee_Head0.png")

                local animation = cc.Animation:create()
                for i=0,2 do
                    local szName =string.format("316_Trustee_Head%d.png",i)
                    local pSpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(szName)
                    animation:addSpriteFrame(pSpriteFrame)
                end  
           
                animation:setDelayPerUnit(2.0/7.0)
                animation:setRestoreOriginalFrame(true)    --

                local action =cc.Animate:create(animation) 
                local seqShowHand = cc.Sequence:create(cc.DelayTime:create(0.5), action)
                pBtAvatar:runAction(cc.RepeatForever:create(seqShowHand))

            else
                pBtAvatar:stopAllActions()
                pBtAvatar:setPosition(self.m_ptNormalAvatar[wViewChairID])
                pBtAvatar:setSpriteFrame(self.m_strFaceID[wViewChairID])
            end
        end
    end

    return 0
end

function ASMJ_GameClientView:OnSubListen(wListenUser)

    local Visible = cc.Director:getInstance():getVisibleSize()
    local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wListenUser) 

    if wViewChairID ~= MYSELF_VIEW_ID_316 then
        self.m_ActionControl[wViewChairID]:DrawHuAction(HT_TING_316)

        local pListenFlags = cc.Sprite:createWithSpriteFrameName("316_tile_ting_h.png")
        pListenFlags:setScale(self.m_scalex, self.m_scaley)
        pListenFlags:setPosition(self.m_ptAvatar[wViewChairID].x, self.m_ptAvatar[wViewChairID].y - 50 * self.m_scaley - pListenFlags:getContentSize().height / 2 * self.m_scaley)
        self:addChild(pListenFlags, ZORDER_FACE_316)
    else
        local pListen = cc.Sprite:createWithSpriteFrameName("316_tile_ting_v.png")
        local pListenOrigin = cc.Sprite:createWithSpriteFrameName("316_tile_ting_v.png")
        pListen:setScale(self.m_scalex, self.m_scaley)
        pListenOrigin:setScale(self.m_scalex * 0.6, self.m_scaley * 0.6)

        pListen:setPosition(Visible.width / 2, 155 * self.m_scaley)
        pListenOrigin:setPosition(cc.p(pListen:getPosition()))

        self:addChild(pListen, ZORDER_ACTION_316 + 2)
        self:addChild(pListenOrigin, ZORDER_ACTION_316 + 1)

        local pScaleSamll = cc.ScaleTo:create(0.3, 0.6 * self.m_scaley)
        local pFade = cc.FadeOut:create(0.3)
        local pScaleBig = cc.ScaleTo:create(0.3, 1.2 * self.m_scaley)
        local pSpawn = cc.Spawn:create(pScaleBig, pFade)
        local pSeqType = cc.Sequence:create(pScaleSamll, pSpawn, cc.CallFunc:create(function () pListen:removeFromParent() end ))
        pListen:runAction(pSeqType)
        pListenOrigin:runAction(cc.FadeIn:create(0.2))

        self.m_pTingCancle = CSpriteEx:CreateWithSpriteFrameName("316_tile_ting_bt_alter0.png", TAG_BT_TING_ALTER_316)
        self.m_pTingCancle:setScale(self.m_scalex, self.m_scaley)
        self.m_pTingCancle:setPosition(pListen:getPositionX() + pListen:getBoundingBox().width, pListen:getPositionY() + 20 * self.m_scaley)
        self:addChild(self.m_pTingCancle, ZORDER_OUTMJ_316 + 2)

        self.m_pTingAlter = CSpriteEx:CreateWithSpriteFrameName("316_tile_ting_bt_alter1.png", TAG_BT_TING_ALTER_316)
        self.m_pTingAlter:setScale(self.m_scalex, self.m_scaley)
        self.m_pTingAlter:setVisible(false)
        self.m_pTingAlter:setPosition(cc.p(self.m_pTingCancle:getPosition()))
        self:addChild(self.m_pTingAlter, ZORDER_OUTMJ_316 + 1)

        self.m_bTingAlter = false
    end
end

function ASMJ_GameClientView:OnSubOutCard(msgcmd)

    local scheduler = cc.Director:getInstance():getScheduler()
    for i = 1, #SID_CurrentUserTimeElapse do
        if SID_CurrentUserTimeElapse[i] ~= nil then
            scheduler:unscheduleScriptEntry(SID_CurrentUserTimeElapse[i])
            SID_CurrentUserTimeElapse[i] = nil
        end
    end

    local wOutCardUser = msgcmd:readWORD() + 1
    local cbOutCardData = msgcmd:readBYTE()
    local cbFirstChicken = msgcmd:readBYTE()
    local cbChickenCount = msgcmd:readBYTE()
 
    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wOutCardUser)

    if self.m_cbFirstChicken == 0 and cbOutCardData == 17 then
        self.m_cbFirstChicken = cbFirstChicken
    end

    if wOutCardUser ~= wMeChairID then
         
        for i=1,GAME_PLAYER_316 do
            self.m_pTimeXYZ[i]:setVisible(false)
        end

        local wOutUserIndex = wViewChairID > 3 and 3 or wViewChairID
        
        local pOutCardItem = ASMJ_COutCardItem_create()
        
        local iMJCount = #self.m_OtherPlayerHandMJ[wOutUserIndex].m_OtherHandMJData
        local pOutCard = {}
        pOutCard.wOutCardUser = wOutCardUser
        pOutCard.cbOutCardData = cbOutCardData
        pOutCard.cbFirstChicken = cbFirstChicken
        pOutCard.ptOrigin =  iMJCount ~= 0 and cc.p(self.m_OtherPlayerHandMJ[wOutUserIndex].m_OtherHandMJData[iMJCount]:getPosition()) or cc.p(0,0)
        pOutCardItem:SetOutCardItem(pOutCard)

        table.insert(self.m_MoveCardItemArray, pOutCardItem)

        self:BeginMoveCard()
    end

    return true
end

function ASMJ_GameClientView:OnSubSendCard(msgcmd)
    
    local scheduler = cc.Director:getInstance():getScheduler()
    for i = 1, #SID_CurrentUserTimeElapse do
        if SID_CurrentUserTimeElapse[i] ~= nil then
            scheduler:unscheduleScriptEntry(SID_CurrentUserTimeElapse[i])
            SID_CurrentUserTimeElapse[i] = nil
        end
    end

    if SID_OperateUserTimeElapse ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(SID_OperateUserTimeElapse)
        SID_OperateUserTimeElapse = nil
    end
    
    ----read data
    local pSendMJ = {}
    pSendMJ.cbCardData      = msgcmd:readBYTE()
    pSendMJ.cbActionMask    = msgcmd:readBYTE()
    pSendMJ.wCurrentUser    = msgcmd:readWORD() + 1
    self.m_wTimeCount       = msgcmd:readWORD()
    pSendMJ.wSendCardUser   = msgcmd:readWORD() + 1                     
                              msgcmd:readWORD() 
                              msgcmd:readBYTE()
    pSendMJ.bTail           = msgcmd:readBYTE()
    self.m_cbEnjoinGangCount= msgcmd:readBYTE()
    self.m_cbEnjoinGangCard = {}
    for i=1,MAX_COUNT_316 do
        self.m_cbEnjoinGangCard[i] = msgcmd:readBYTE()
    end
    --------------------
    local pSendCardItem = ASMJ_CSendCardItem_create()
    pSendCardItem:SetSendCardItem(pSendMJ)
    table.insert(self.m_MoveCardItemArray, pSendCardItem)
  
    self:BeginMoveCard()
end

function ASMJ_GameClientView:OnSubOperateNotify(msgcmd)

                          msgcmd:readWORD()
    local wTimeCount    = msgcmd:readWORD()
    local cbActionMask  = msgcmd:readBYTE()
    local cbActionCard  = msgcmd:readBYTE()
    local cbAutoChiHu   = msgcmd:readBYTE()
    ------------------
    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    
    self.m_wTimeCount = wTimeCount
    self.m_wOperateUser[wMeChairID] = 0

    
    if cbActionMask ~= WIK_NULL_316 then
        self.m_wOperateUser[wMeChairID] = 1
        self.m_cbActionMask = cbActionMask
        self.m_cbActionCard = cbActionCard

        local GangCardResult = {}
        GangCardResult.cbCardData = {}
        GangCardResult.cbCardCount = 0

        if bit:_and(self.m_cbActionMask, WIK_GANG_316) ~= 0 then
            
            if self.m_cbListenStatus == 0 and self.m_bStustee then
                self:OnStustee()
            end

            if self.m_wCurrentUser == INVALID_CHAIR_316 and self.m_cbActionCard ~= 0 then
                GangCardResult.cbCardCount = 1
                GangCardResult.cbCardData[1] = self.m_cbActionCard
            end

            if self.m_wCurrentUser == wMeChairID then
                ASMJ_GameLogic:GetInstance():AnalyseGangCard(self.m_cbCardIndex, self.m_WeaveItemArray[wMeChairID], self.m_cbWeaveCount[wMeChairID], self.m_cbEnjoinGangCard, GangCardResult)
            end

        end


        if self.m_cbListenStatus == 0 then
            self.m_OperateControl:SetOperateControl(self.m_cbActionCard, self.m_cbActionMask, GangCardResult)
        end

        if cbAutoChiHu == 1 and bit:_and(self.m_cbActionMask, WIK_CHI_HU_316) ~= 0 then
            self:OnUserAction(WIK_CHI_HU_316, 0)
        end
    end

    local scheduler = cc.Director:getInstance():getScheduler()
    for i = 1, #SID_CurrentUserTimeElapse do
        if SID_CurrentUserTimeElapse[i] ~= nil then
            scheduler:unscheduleScriptEntry(SID_CurrentUserTimeElapse[i])
            SID_CurrentUserTimeElapse[i] = nil
        end
    end

    self.m_pTimerNumber:setString(string.format("%d%d", math.floor(self.m_wTimeCount/10), self.m_wTimeCount % 10))

    self.m_wSpendTime = 0

    local scheduler = cc.Director:getInstance():getScheduler()
    SID_OperateUserTimeElapse = scheduler:scheduleScriptFunc(handler(self, self.OperateUserTimeElapse), 1, false)
end

function ASMJ_GameClientView:OnSubOperateResult(msgcmd)

    self.m_wOperateUser[ASMJ_MyUserItem:GetInstance():GetChairID()] = 0
    if SID_OperateUserTimeElapse ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(SID_OperateUserTimeElapse)
        SID_OperateUserTimeElapse = nil
    end

    ------------------read data----------------
    local wOperateUser = msgcmd:readWORD() + 1              
    self.m_wTimeCount  = msgcmd:readWORD()
    local wProvideUser = msgcmd:readWORD() + 1
    local cbOperateCode = msgcmd:readBYTE()
    local cbOperateCard = {}
          cbOperateCard[1] = msgcmd:readBYTE()
          cbOperateCard[2] = msgcmd:readBYTE()
          cbOperateCard[3] = msgcmd:readBYTE()
    -------------------------------------------

    local cbIndex = 0
    local cbPublicCard = 1
    local wOperateViewID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wOperateUser)
    local wProviderViewID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wProvideUser)
    self.m_wCurrentUser = wOperateUser

    if bit:_and(cbOperateCode, WIK_GANG_316) ~= 0 then

        self.m_wCurrentUser = INVALID_CHAIR_316
        local cbWeaveIndex = 255

        for i=1,self.m_cbWeaveCount[wOperateUser] do
            local cbWeaveKind = self.m_WeaveItemArray[wOperateUser][i].cbWeaveKind
            local cbCenterCard = self.m_WeaveItemArray[wOperateUser][i].cbCenterCard
            if cbCenterCard == cbOperateCard[1] and bit:_and(cbWeaveKind, WIK_PENG_316) then
                cbIndex = 2
                cbWeaveIndex = i
                self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicCard = 1
                self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind = cbOperateCode
                self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCardData[4] = cbCenterCard
                break
            end
        end

        if cbWeaveIndex == 255 then
            cbIndex = wProvideUser == wOperateUser and 3 or 1
            cbPublicCard = wProvideUser == wOperateUser and 0 or 1

            self.m_cbWeaveCount[wOperateUser] = self.m_cbWeaveCount[wOperateUser]  + 1
            cbWeaveIndex = self.m_cbWeaveCount[wOperateUser] 
            
            self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicCard = cbPublicCard
            self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCenterCard = cbOperateCard[1]
            self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind = cbOperateCode
            self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser = wProvideUser

            for i=1,4 do
                self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCardData[i] = cbOperateCard[1]
            end
        end

        local ptOutMJ = cc.p(self.m_TableOutMJControl[wProviderViewID]:GetOutMJPoint())
        local ptHandMJ = cc.p(self.m_HandCardControl.m_HandMJData[#self.m_HandCardControl.m_HandMJData].m_pSpriteMJBack:getPosition())

        local ptGangMJOrigin = cc.p(0, 0)
        if cbIndex == 1 then
            ptGangMJOrigin = ptOutMJ
        elseif cbIndex == 2 then
            ptGangMJOrigin = ptHandMJ
        end

        self.m_HuMJControl[wOperateViewID]:DrawHuControl(cbOperateCard[1], cbIndex + 3, ptGangMJOrigin, wProviderViewID)

        if wOperateViewID ~= MYSELF_VIEW_ID_316 then
            self.m_ActionControl[wOperateViewID]:DrawHuAction(cbIndex + 3)
        end

        if cbIndex == 1 then
            self.m_pDiscUser:stopAllActions()
            self.m_pDiscUser:setVisible(false)
            self.m_TableOutMJControl[wProviderViewID]:DeleteTableOutMJ()
        end

        if ASMJ_MyUserItem:GetInstance():GetChairID() == wOperateUser then
            self.m_cbCardIndex[ASMJ_GameLogic:GetInstance():SwitchToCardIndex(cbOperateCard[1])] = 0
        end

        if ASMJ_MyUserItem:GetInstance():GetChairID() == wOperateUser then
            local cbCardCount = MAX_COUNT_316 -  self.m_cbWeaveCount[wOperateUser] * 3
            self.m_HandCardControl:DeleteMJData1(cbOperateCard[1], cbIndex + 3, self.m_HuMJControl[3]:GetLastHuMJPoint())
        else
            local wUserIndex = wOperateViewID > 3 and 3 or wOperateViewID

            local Visible = cc.Director:getInstance():getVisibleSize()

            if wUserIndex == 2 then
                self.m_OtherPlayerHandMJ[2]:SetOriginControlPoint(145 * self.m_scalex, Visible.height - 130 * self.m_scaley)
            end

            if wUserIndex == 3 then
                self.m_OtherPlayerHandMJ[3]:SetOriginControlPoint(Visible.width - 145 * self.m_scalex, 215 * self.m_scaley)
            end

            local cbCardCount = MAX_COUNT_316 - self.m_cbWeaveCount[wOperateUser] * 3 - 1
            local iOtherPlayerHandMJCount = #self.m_OtherPlayerHandMJ[wUserIndex].m_OtherHandMJData
            assert(iOtherPlayerHandMJCount >= cbCardCount, "error iOtherPlayerHandMJCount")
            self.m_OtherPlayerHandMJ[wUserIndex].m_CurrentMJPoint = self.m_HuMJControl[wOperateViewID]:GetLastHuMJPoint()

            if cbIndex == 2 then
                self.m_OtherPlayerHandMJ[wUserIndex]:DeleteUserHandMJ(iOtherPlayerHandMJCount - cbCardCount, 0)
            else
                self.m_OtherPlayerHandMJ[wUserIndex]:DeleteUserHandMJ(iOtherPlayerHandMJCount - cbCardCount, 1)
            end
        end

    elseif cbOperateCode ~= WIK_NULL_316 then
        
        self.m_cbWeaveCount[wOperateUser] = self.m_cbWeaveCount[wOperateUser] + 1
        local cbWeaveIndex = self.m_cbWeaveCount[wOperateUser]

        self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicCard = 1
        self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCenterCard = cbOperateCard[1]
        self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind = cbOperateCode
        self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser = wProvideUser

        for i=1,3 do
            self.m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCardData[i] = cbOperateCard[i]
        end

        local cbWeaveCard = {}
        local cbWeaveKind = cbOperateCode
        local cbWeaveCardCount = 3

        for i=1,3 do
            cbWeaveCard[i] = cbOperateCard[i]
        end

        if ASMJ_MyUserItem:GetInstance():GetChairID() == wOperateUser then
            if not ASMJ_GameLogic:GetInstance():RemoveCard1(self.m_cbCardIndex, cbWeaveCard, cbWeaveCardCount - 1) then
                assert(0, "error RemoveCard")
                return false
            end
        end

        local ptOutMJ = cc.p(self.m_TableOutMJControl[wProviderViewID]:GetOutMJPoint())
        self.m_HuMJControl[wOperateViewID]:DrawHuControl(cbOperateCard[1], HT_PENG_316, ptOutMJ, wProviderViewID)
        
        if wOperateViewID ~= MYSELF_VIEW_ID_316 then
            self.m_ActionControl[wOperateViewID]:DrawHuAction(HT_PENG_316)
        end
        
        self.m_pDiscUser:stopAllActions()
        self.m_pDiscUser:setVisible(false)
        self.m_TableOutMJControl[wProviderViewID]:DeleteTableOutMJ()

        if ASMJ_MyUserItem:GetInstance():GetChairID() == wOperateUser then
            local cbCardCount = MAX_COUNT_316 - self.m_cbWeaveCount[wOperateUser] * 3
            self.m_HandCardControl:DeleteMJData1(cbOperateCard[1], cbIndex + 3, self.m_HuMJControl[3]:GetLastHuMJPoint())
        else
            local wUserIndex = wOperateViewID > 3 and 3 or wOperateViewID

            local Visible = cc.Director:getInstance():getVisibleSize()
            if wUserIndex == 2 then
                self.m_OtherPlayerHandMJ[2]:SetOriginControlPoint(145 * self.m_scalex, Visible.height - 130 * self.m_scaley)
            end

            if wUserIndex == 3 then
                self.m_OtherPlayerHandMJ[3]:SetOriginControlPoint(Visible.width - 145 * self.m_scalex, 215 * self.m_scaley)
            end

            local cbCardCount = MAX_COUNT_316 - self.m_cbWeaveCount[wOperateUser] * 3
            local iOtherPlayerHandMJCount = #self.m_OtherPlayerHandMJ[wUserIndex].m_OtherHandMJData
            assert(iOtherPlayerHandMJCount >= cbCardCount, "error iOtherPlayerHandMJCount")
            self.m_OtherPlayerHandMJ[wUserIndex].m_CurrentMJPoint = self.m_HuMJControl[wOperateViewID]:GetLastHuMJPoint()
            self.m_OtherPlayerHandMJ[wUserIndex]:DeleteUserHandMJ(iOtherPlayerHandMJCount - cbCardCount, 1)
        end
    end

    self:PlayActionSound(wOperateUser, cbOperateCode, cbIndex)

    if self.m_wCurrentUser ~= INVALID_CHAIR_316 then

        assert(self.m_wCurrentUser <= GAME_PLAYER_316, "error m_wCurrentUser")
        local wTimeUserView = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(self.m_wCurrentUser)
        self.m_pTimeXYZ[wTimeUserView]:setVisible(true)
        self.m_pTimerNumber:setString(string.format("%d%d", math.floor(self.m_wTimeCount/10), self.m_wTimeCount % 10))

        self.m_wSpendTime = 0
        local scheduler = cc.Director:getInstance():getScheduler()
        SID_CurrentUserTimeElapse[#SID_CurrentUserTimeElapse + 1] = scheduler:scheduleScriptFunc(handler(self, self.CurrentUserTimeElapse), 1, false)
    end

    return true

end

function ASMJ_GameClientView:OnSubGameEnd(msgcmd)

    self.gameStatus = Game_Free_316
    self.m_HandCardControl.m_bPositive = false

    local scheduler = cc.Director:getInstance():getScheduler()
    for i = 1, #SID_CurrentUserTimeElapse do
        if SID_CurrentUserTimeElapse[i] ~= nil then
            scheduler:unscheduleScriptEntry(SID_CurrentUserTimeElapse[i])
            SID_CurrentUserTimeElapse[i] = nil
        end
    end

    if SID_OperateUserTimeElapse ~= nil then
        scheduler:unscheduleScriptEntry(SID_OperateUserTimeElapse)
        SID_OperateUserTimeElapse = nil
    end

    self.m_OperateControl:ClearAllOperate()

    self.m_pTimeBack:removeFromParent()
    self.m_pTimerNumber:removeFromParent()
    for i=1,GAME_PLAYER_316 do
        self.m_pTimeXYZ[i]:removeFromParent()
    end

    if self.m_bStustee then
        self:OnStustee()
    end

   
    ---------------------read data---------------------
    self.m_ScoreData.wProvideUser               = msgcmd:readWORD() + 1
    self.m_ScoreData.cbProvideCard              = msgcmd:readBYTE()
    
    self.m_ScoreData.dwChiHuKind                = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.dwChiHuKind[i]         = msgcmd:readDWORD()
    end
    
    self.m_ScoreData.dwChiHuRight               = {}
    for i=1,3 do
        self.m_ScoreData.dwChiHuRight[i]        = msgcmd:readDWORD()
    end

    self.m_ScoreData.cbChickenCard              = {}
    for i=1,3 do
        self.m_ScoreData.cbChickenCard[i]       = msgcmd:readBYTE()
    end

    self.m_ScoreData.bFlowBureau                = msgcmd:readint() -- BOOL

    self.m_ScoreData.nPackHuFanShu              = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.nPackHuFanShu[i]       = msgcmd:readint()
    end
    
    self.m_ScoreData.nHuFanShu                  = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.nHuFanShu[i]           = msgcmd:readint()
    end   

    self.m_ScoreData.cbHuCount                  = msgcmd:readBYTE()
    self.m_ScoreData.cbReQiangHu                = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.cbReQiangHu[i]         = msgcmd:readBYTE()
    end
    
    self.m_ScoreData.lGameScore                 = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.lGameScore[i]          = msgcmd:readLONGLONG()
    end

    self.m_ScoreData.cbCardCount                = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.cbCardCount[i]         = msgcmd:readBYTE()
    end

    self.m_ScoreData.cbCardData                 = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.cbCardData[i]          = {}
        for j=1,MAX_COUNT_316 do
            self.m_ScoreData.cbCardData[i][j]   = msgcmd:readBYTE()
        end
    end

    self.m_ScoreData.bZiMo                      = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.bZiMo[i]               = msgcmd:readBYTE() --bool
    end

    self.m_ScoreData.wWinnerSite                = {}
    for i=1,3 do
        self.m_ScoreData.wWinnerSite[i]         = msgcmd:readWORD()
    end

    self.m_ScoreData.nJiFan                     = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.nJiFan[i]              = msgcmd:readint()
    end

    self.m_ScoreData.nJiFanLost                 = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.nJiFanLost[i]          = msgcmd:readint()
    end    

    self.m_ScoreData.wFirstChickenUser          = msgcmd:readWORD() + 1
    self.m_ScoreData.cbChickenCountEx           = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.cbChickenCountEx[i]    = msgcmd:readBYTE()
    end

    self.m_ScoreData.nMenDou                    = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.nMenDou[i]             = msgcmd:readint()
    end
   
    self.m_ScoreData.nZhuanWanDou               = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.nZhuanWanDou[i]        = msgcmd:readint()
    end

    self.m_ScoreData.nDianDou                   = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.nDianDou[i]            = msgcmd:readint()
    end

    self.m_ScoreData.nXiaJiao                   = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.nXiaJiao[i]            = msgcmd:readint()
    end
    ------------------------------------------------------     
    self.m_ScoreData.m_wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    self.m_ScoreData.m_szAccount = {}
    for i=1,GAME_PLAYER_316 do
        self.m_ScoreData.m_szAccount[i] = self.m_szAccount[i]

        if self.m_ScoreData.cbCardCount == 0 and self.m_ScoreData.dwChiHuKind[i] ~= WIK_NULL_316 then
            self.m_ScoreInfo.wChiHuUser = i
        end
    end

    --- show user mj data
    for i=1,GAME_PLAYER_316 do
        local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(i)
        local cbProvideMJ = self.m_ScoreData.dwChiHuKind[i] ~= WIK_NULL_316 and self.m_ScoreData.cbProvideCard or 0
        if cbProvideMJ ~= 0 then
            local cbRemoveMJ = {}
            cbRemoveMJ[1] = cbProvideMJ
            ASMJ_GameLogic:GetInstance():DeleteCard(self.m_ScoreData.cbCardData[i], self.m_ScoreData.cbCardCount[i], cbRemoveMJ, 1)
            -- self.m_ScoreData.cbCardCount[i] = self.m_ScoreData.cbCardCount[i] + 1
            -- table 函数传递 是引用 数值 是拷贝
            self.m_ScoreData.cbCardData[i][self.m_ScoreData.cbCardCount[i]] = cbProvideMJ
        end

        if wViewChairID == MYSELF_VIEW_ID_316 then
            self.m_HandCardControl:OrbitShowHandMJ(self.m_ScoreData.cbCardData[i], self.m_ScoreData.cbCardCount[i], cbProvideMJ)
        else
            self.m_OtherPlayerHandMJ[wViewChairID > 3 and 3 or wViewChairID]:OrbitShowUserHandMJ(self.m_ScoreData.cbCardData[i], self.m_ScoreData.cbCardCount[i], cbProvideMJ)
        end
    end

    ------score
    local bChiHuRight = true
    for i=1,3 do
        if self.m_ScoreData.dwChiHuRight[i] ~= 0 then
            bChiHuRight = false
            break
        end
    end

    if not bChiHuRight then
        for i=1,GAME_PLAYER_316 do
            if self.m_ScoreData.dwChiHuKind[i] ~= WIK_NULL_316 then
                local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(i)
                self.m_ActionControl[wViewChairID]:DrawHuAction(HT_HU_316)
                break
            end
        end

        if self.m_cbLeftCardCount > 0 then
            local pShowCardItem = ASMJ_CShowCardItem_create()
            pShowCardItem:SetShowCardItem(self.m_ScoreData.cbChickenCard[1])
            table.insert(self.m_MoveCardItemArray, pShowCardItem)
            self:BeginMoveCard()
        else
            self:ShowGameScore()
        end

    else
        self:ShowGameScore()
    end

    if cc.UserDefault:getInstance():getBoolForKey("316_GameMusic", true) then
        ccexp.AudioEngine:play2d("316_game_end.MP3", false, 1)
    end
end

function ASMJ_GameClientView:MatchStatusWaitTimeElapse(fTime)
    if SID_MatchStatusWaitTimeElapse ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(SID_MatchStatusWaitTimeElapse)
        SID_MatchStatusWaitTimeElapse = nil
    end

    self:Reset()

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local m_TableMJBack = cc.Sprite:create("316_table_bg.png")
    m_TableMJBack:setScale(self.m_scalex, self.m_scaley)
    m_TableMJBack:setPosition(visibleSize.width / 2, visibleSize.height / 2)
    self:addChild(m_TableMJBack, ZORDER_BACK_VIEW_316)

    local pWaitTitle = cc.Sprite:create("316_wait_title.png")
    pWaitTitle:setPosition(visibleSize.width / 2, visibleSize.height / 2)
    pWaitTitle:setScale(self.m_scalex, self.m_scaley)
    pWaitTitle:setTag(TAG_ID_MATCH_WAIT_316)
    self:addChild(pWaitTitle, ZORDER_BACK_VIEW_316 + 1)
end

function ASMJ_GameClientView:ShowGameScore()
    
    local iType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
    if iType == ERT_FL_316 then
        local pMatchNode = nil
        for i=1,3 do
            pMatchNode = self:getChildByTag(TAG_ID_MATCH_CONTROL_316 + i)
            if pMatchNode ~= nil and pMatchNode ~= 0 then
                return
            end
        end

        local scheduler = cc.Director:getInstance():getScheduler()
        SID_MatchStatusWaitTimeElapse = scheduler:scheduleScriptFunc(handler(self, self.MatchStatusWaitTimeElapse), 5, false)
    end

    local Visible = cc.Director:getInstance():getVisibleSize()
    local pLayerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 128), Visible.width, Visible.height)
    self:addChild(pLayerColor, 500, TAG_ID_LAYER_COLOR_316)

    for i=1,GAME_PLAYER_316 do
        if self.m_ScoreData.bFlowBureau == 1 then
            for j=1,GAME_PLAYER_316 do
                self.m_HuMJControl[j]:ChickenColorClear()
                self.m_TableOutMJControl[j]:CancelSwayChichenColor()
            end
            break
        end

        local iViewID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(i)

        if self.m_ScoreData.nXiaJiao[i] > 0 and self.m_ScoreData.cbReQiangHu[i] == 0 then
            if iViewID == MYSELF_VIEW_ID_316 then
                self.m_HandCardControl:SetSwayChichenColor(self.m_ScoreData.cbChickenCard, 3)
            else
                self.m_OtherPlayerHandMJ[iViewID > 3 and 3 or iViewID]:SetSwayChichenColor(self.m_ScoreData.cbChickenCard, 3)
            end
            self.m_HuMJControl[iViewID]:SetSwayChichenColor(self.m_ScoreData.cbChickenCard, 3)
        else
            self.m_HuMJControl[iViewID]:ChickenColorClear()
            self.m_TableOutMJControl[iViewID]:CancelSwayChichenColor()
        end
    end
    ------------------------------------
    self.m_ScoreCotrol = ASMJ_ScoreControl_create(self.m_ScoreData)
    self:addChild(self.m_ScoreCotrol, ZORDER_ACTION_316)
end

function ASMJ_GameClientView:OnUserAction(cbOperateCode, cbOperateData)
    
    local cbOperateCard = {}

    if cbOperateCode == WIK_NULL_316 then
        
        if m_cbActionMask ~= WIK_NULL_316 then

            self.m_OperateControl:ClearAllOperate()
            self.m_cbActionMask = WIK_NULL_316
            self.m_cbActionCard = 0

            if self.m_wCurrentUser == INVALID_CHAIR_316 then
                
                if SID_OperateUserTimeElapse ~= nil then
                    local scheduler = cc.Director:getInstance():getScheduler()
                    scheduler:unscheduleScriptEntry(SID_OperateUserTimeElapse)
                    SID_OperateUserTimeElapse = nil
                end

                CClientKernel:GetInstance():ResetBuffers()
                CClientKernel:GetInstance():WriteBYTEToBuffers(1)
                CClientKernel:GetInstance():WriteBYTEToBuffers(WIK_NULL_316)
                CClientKernel:GetInstance():WriteBYTEToBuffers(0)
                CClientKernel:GetInstance():WriteBYTEToBuffers(0)
                CClientKernel:GetInstance():WriteBYTEToBuffers(0)
                CClientKernel:GetInstance():WriteWORDToBuffers(self.m_wSpendTime)
                CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_GAME, SUB_C_OPERATE_CARD)
            end
        end

        return
    end

    if bit:_and(cbOperateCode, WIK_PENG_316) ~= 0 or bit:_and(self.m_cbActionMask, WIK_GANG_316) ~= 0 then

        cbOperateCard[1] = cbOperateData
        cbOperateCard[2] = cbOperateData
        cbOperateCard[3] = cbOperateData
        
        if self.m_wCurrentUser == ASMJ_MyUserItem:GetInstance():GetChairID() and cbOperateCode == WIK_NULL_316 and cbOperateCard[1] == 0 then
            return
        end

        if bit:_and(cbOperateCode, WIK_PENG_316) ~= 0 and bit:_and(self.m_cbActionMask, WIK_GANG_316) ~= 0 then
            self.m_cbEnjoinGangCount = self.m_cbEnjoinGangCount + 1
            self.m_cbEnjoinGangCard[self.m_cbEnjoinGangCount] = cbOperateCard[1]
        end

        self.m_cbActionMask = 0
        self.m_cbActionCard = 0
        self.m_wCurrentUser = INVALID_CHAIR_316

        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteBYTEToBuffers(0)
        CClientKernel:GetInstance():WriteBYTEToBuffers(cbOperateCode)
        CClientKernel:GetInstance():WriteBYTEToBuffers(cbOperateCard[1])
        CClientKernel:GetInstance():WriteBYTEToBuffers(cbOperateCard[2])
        CClientKernel:GetInstance():WriteBYTEToBuffers(cbOperateCard[3])
        CClientKernel:GetInstance():WriteWORDToBuffers(self.m_wSpendTime)
        CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_GAME, SUB_C_OPERATE_CARD)
    end

    if bit:_and(cbOperateCode, WIK_LISTEN_316) ~= 0 then
        
        assert(self.m_cbListenStatus == 0, "error is listen")
        if self.m_cbListenStatus ~= 0 then
            return
        end

        self.m_cbListenStatus = 3
        self.m_bWillHearStatus = true

        self.m_cbActionMask = WIK_NULL_316
        self.m_cbActionCard = 0

        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteBYTEToBuffers(self.m_cbListenStatus)
        CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_GAME, SUB_C_LISTEN)

        local sci = {}
        local cbInfoCount = self:ListenAlterMJ(sci)

        if cbInfoCount == 1 then
            self.m_bWillHearStatus = false
            self:OnHandOutMJ(sci[1].cbActionCard, self.m_HandCardControl:GetHandMJIndex(sci[1].cbActionCard), 3)
        else 
            local iListenCount = cbInfoCount
            local gListen = {}
            for i=1,#sci do
                gListen[i] = {}
                gListen[i].cbActionCard = sci[i].cbActionCard
                gListen[i].wActionMask = sci[i].wActionMask
                gListen[i].cbCardCount = sci[i].cbCardCount
                gListen[i].cbCardData = sci[i].cbCardData
            end

            for i=1,#self.m_HandCardControl.m_HandMJData do
                self.m_HandCardControl.m_HandMJData[i].m_bGray = true

                for j=1,iListenCount do
                    if gListen[j].cbActionCard == self.m_HandCardControl.m_HandMJData[i].m_cbHandMJData then
                        self.m_HandCardControl.m_HandMJData[i].m_bGray = false
                    end
                end

                if self.m_HandCardControl.m_HandMJData[i].m_bGray then
                    self.m_HandCardControl.m_HandMJData[i].m_pSpriteMJBack:setColor(cc.c3b(122, 122, 122))
                    self.m_HandCardControl.m_HandMJData[i].m_pSpriteMJData:setColor(cc.c3b(122, 122, 122))
                end
            end
        end
        return
    end

    if bit:_and(cbOperateCode, WIK_CHI_HU_316) ~= 0 then
        
        if SID_OperateUserTimeElapse ~= nil then
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(SID_OperateUserTimeElapse)
            SID_OperateUserTimeElapse = nil
        end

        self.m_wCurrentUser = INVALID_CHAIR_316
        self.m_cbActionMask = WIK_NULL_316
        self.m_cbActionCard = 0

        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteBYTEToBuffers(2)
        CClientKernel:GetInstance():WriteBYTEToBuffers(cbOperateCode)
        CClientKernel:GetInstance():WriteBYTEToBuffers(cbOperateCard[1] or 0)
        CClientKernel:GetInstance():WriteBYTEToBuffers(cbOperateCard[2] or 0)
        CClientKernel:GetInstance():WriteBYTEToBuffers(cbOperateCard[3] or 0)
        CClientKernel:GetInstance():WriteWORDToBuffers(self.m_wSpendTime)
        CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_GAME, SUB_C_OPERATE_CARD)
    end

    return
end

function ASMJ_GameClientView:ListenAlterMJ(selectMJ)
    local cbSelectCount = 0
    local cbCardCount = 0
    local cbCardData = {}
    local cbCardIndex = {}

    for i=1,MAX_INDEX_316 do
        cbCardIndex[i] = self.m_cbCardIndex[i]
    end

    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    
    local chr = {}

    for i=1,MAX_INDEX_316 do

        if i % 10 ~= 0 then

            if cbCardIndex[i] == 0 then

            else
                cbCardIndex[i] = cbCardIndex[i] - 1

                for j=1,MAX_INDEX_316 do
                    if j % 10 ~= 0 then
                        local cbCurrentCard = ASMJ_GameLogic:GetInstance():SwitchToCardData(j)
                        if WIK_CHI_HU_316 == ASMJ_GameLogic:GetInstance():AnalyseChiHuCard(cbCardIndex, self.m_WeaveItemArray[wMeChairID], self.m_cbWeaveCount[wMeChairID], cbCurrentCard, chr, true, true) then
                            cbCardCount = cbCardCount + 1
                            cbCardData[cbCardCount] = ASMJ_GameLogic:GetInstance():SwitchToCardData(i)
                            break
                        end
                    end
                end

                cbCardIndex[i] = cbCardIndex[i] + 1
            end
        end
    end

    for i=1,cbCardCount do
        cbSelectCount = cbSelectCount + 1
        selectMJ[cbSelectCount] = {}
        selectMJ[cbSelectCount].cbActionCard = cbCardData[i]
        selectMJ[cbSelectCount].wActionMask = WIK_LISTEN_316
        selectMJ[cbSelectCount].cbCardCount = 1
        selectMJ[cbSelectCount].cbCardData = cbCardData[i]
    end
   
    return cbSelectCount
end

function ASMJ_GameClientView:PlayMJSound(wChairID, cbCardData)
    -- body
    if wChairID < 1 or wChairID > GAME_PLAYER_316 then
        return
    end

    if not ASMJ_GameLogic:GetInstance():IsValidCard(cbCardData) then
        return 
    end

    local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wChairID)
    local pIClientUserItem = ASMJ_MyUserItem:GetInstance():GetClientUserItem(wViewChairID)
    if pIClientUserItem == nil then
        return
    end

    local bBoy = pIClientUserItem.cbGender ~= GENDER_FEMALE and true or false
    local cbType = bit:_rshift(bit:_and(cbCardData, MASK_COLOR_316), 4)
    local cbValue = bit:_and(cbCardData, MASK_VALUE_316)

    local szSoundName = string.format("316_%d_%d.MP3", cbType, cbValue)
    if bBoy then
        strSoundName = string.format("316_BOY/316_%d_%d.MP3", cbType, cbValue)
    else
        strSoundName = string.format("316_GIRL/316_%d_%d.MP3", cbType, cbValue)
    end

    if cc.UserDefault:getInstance():getBoolForKey("316_GameMusic", true) then
        --AudioEngine.playEffect(strSoundName, false)
        ccexp.AudioEngine:play2d(strSoundName, false, 1)
    end
end


function ASMJ_GameClientView:PlayActionSound(wChairID, cbAction, cbIndex)

    local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(wChairID)
    local pIClientUserItem = ASMJ_MyUserItem:GetInstance():GetClientUserItem(wViewChairID)
    if pIClientUserItem == nil then
        return
    end

    if wChairID < 0 or wChairID > GAME_PLAYER_316 then
        return
    end

    local bBoy = pIClientUserItem.cbGender ~= GENDER_FEMALE and true or false
    local strSoundName = ""
    if cbAction == WIK_PENG_316 then
        strSoundName = "316_PENG.MP3"
    elseif cbAction == WIK_GANG_316 then
        strSoundName = string.format("316_GANG_%d.MP3", cbIndex)
    elseif cbAction == WIK_CHI_HU_316 then
        strSoundName = "316_CHI_HU.MP3"
    end

    if bBoy then
        strSoundName = "316_BOY/" .. strSoundName
    else
        strSoundName = "316_GIRL/" .. strSoundName
    end

    if cc.UserDefault:getInstance():getBoolForKey("316_GameMusic", true) then
        --AudioEngine.playEffect(strSoundName, false)
        ccexp.AudioEngine:play2d(strSoundName, false, 1)
    end

    return 
end