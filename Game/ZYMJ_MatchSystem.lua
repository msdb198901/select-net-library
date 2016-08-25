local ASMJ_MatchControl = class("ASMJ_MatchControl", function() return cc.Node:create() end)

local SID_MatchTimeElapse = nil
local SID_ReLeftElapse = nil

IDB_BT_RELEFT_316 = 1
IDB_BT_OUT_ENABLE_316 = 2
IDB_BT_EXIT_316 = 3  
IDB_BT_AWARD_316 = 4
IDI_BT_CLOSE_316 = 10
IDI_BT_PLEASE_CHOICE_316 = 11
IDI_BT_SHARED_316 = 12

--create( ... )
function ASMJ_MatchControl_create()
    print("ASMJ_MatchControl_create")
    local Node = ASMJ_MatchControl.new()
    return Node
end

--ctor()
function ASMJ_MatchControl:ctor()
    print("ASMJ_MatchControl:ctor")
    self.m_fMinScaleX = 1
    self.m_fMinScaleY = 1
    self.m_bShowMatch = false
    self.m_ptAction = cc.p(0,0)
    self.m_wMatchTime = 0

    local function onNodeEvent(event)
      if event == "enter" then
          self:onEnter()
      elseif event == "exit" then
          self:onExit()
      end
    end

    self:registerScriptHandler(onNodeEvent)
end


function ASMJ_MatchControl:onEnter()
end

--onExit()
function ASMJ_MatchControl:onExit()
    print("ASMJ_MatchControl:onExit")
    if SID_MatchTimeElapse ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(SID_MatchTimeElapse)
        SID_MatchTimeElapse = nil
    end
end

----------------------------------
function ASMJ_MatchControl:SetScaleMin(iMinScaleX, iMinScaleY)
    self.m_fMinScaleX = iMinScaleX 
    self.m_fMinScaleY = iMinScaleY
end


function ASMJ_MatchControl:SetMatchTime(wMatchTime)
    self.m_wMatchTime = wMatchTime
end

function ASMJ_MatchControl:GetMatchTime(wMatchTime)
    return self.m_wMatchTime
end

function ASMJ_MatchControl:DrawMatchRank(iTurnIndex)
    
    if not self.m_bShowMatch then
        return
    end

    local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()
    
    if iTurnIndex == 0 then

        self.m_pTurnL1:setString(string.format("%d", pMatchAttribute.dwPromtCount))
        self.m_pTurnL2:setString(string.format("%d", pMatchAttribute.dwEndCount))
        self.m_pTurnR1:setString(string.format("%d.%d", pMatchAttribute.dwCurRank, pMatchAttribute.dwTotalCount))

    elseif iTurnIndex == 1 or iTurnIndex == 2 then

        self.m_pTurnR1:setString(string.format("%d.%d", pMatchAttribute.wGameCount, pMatchAttribute.wContiunePlayCount))
        self.m_pTurnR2:setString(string.format("%d.%d", pMatchAttribute.dwTableRank, GAME_PLAYER_316))

    elseif iTurnIndex == 3 then

        self.m_pTurnR1:setString(string.format("%d.%d", pMatchAttribute.wGameCount, pMatchAttribute.wContiunePlayCount))
        self.m_pTurnR2:setString(string.format("%d.%d", pMatchAttribute.dwCurRank, pMatchAttribute.dwTotalCount))
    
    end
end

function ASMJ_MatchControl:ShowMatch(ptBenchmark)

    local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()
    local iTurnIndex = pMatchAttribute.wMatchSenceIndex

    self.m_pMatchBackL = cc.Sprite:create(string.format("316_match_turn_%d.png", iTurnIndex))
    self.m_pMatchBackL:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    self.m_pMatchBackL:setPosition(ptBenchmark.x - 70 * self.m_fMinScaleX - self.m_pMatchBackL:getContentSize().width * self.m_fMinScaleX / 2, ptBenchmark.y)
    self:addChild(self.m_pMatchBackL, -1)

    self.m_pMatchBackR = cc.Sprite:create(string.format("316_match_sence_info%d.png", iTurnIndex))
    self.m_pMatchBackR:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    self.m_pMatchBackR:setPosition(ptBenchmark.x + 70 * self.m_fMinScaleX + self.m_pMatchBackR:getContentSize().width * self.m_fMinScaleX / 2, ptBenchmark.y)
    if self.m_pMatchBackR == 0 then
        self.m_pMatchBackR:setPosition(ptBenchmark.x + 20 * self.m_fMinScaleX+ self.m_pMatchBackR:getContentSize().width * self.m_fMinScaleX / 2, ptBenchmark.y)
    end
    self:addChild(self.m_pMatchBackR, -1)

    if iTurnIndex == 0 then
        local iXPos = self.m_pMatchBackL:getPositionX() - self.m_pMatchBackL:getBoundingBox().width / 2
        local iYPos = self.m_pMatchBackL:getPositionY() + self.m_pMatchBackL:getBoundingBox().height / 2
        
        self.m_pTurnL1 = cc.LabelAtlas:_create(string.format("%d", pMatchAttribute.dwPromtCount), "316_match_rank_number_0.png", 12, 20, string.byte("."))
        self.m_pTurnL1:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pTurnL1:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_pTurnL1:setPosition(iXPos + 60 * self.m_fMinScaleX, iYPos - 30 * self.m_fMinScaleY)
        self:addChild(self.m_pTurnL1, 1)

        self.m_pTurnL2 = cc.LabelAtlas:_create(string.format("%d", pMatchAttribute.dwEndCount), "316_match_rank_number_1.png", 12, 20, string.byte("."))
        self.m_pTurnL2:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pTurnL2:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_pTurnL2:setPosition(iXPos + 57 * self.m_fMinScaleX, iYPos - 54 * self.m_fMinScaleY)
        self:addChild(self.m_pTurnL2, 1)

        iXPos = self.m_pMatchBackR:getPositionX() - self.m_pMatchBackR:getBoundingBox().width / 2
        iYPos = self.m_pMatchBackR:getPositionY() + self.m_pMatchBackR:getBoundingBox().height / 2

        self.m_pTurnR1 = cc.LabelAtlas:_create(string.format("%d.%d", pMatchAttribute.dwCurRank, pMatchAttribute.dwTotalCount), "316_match_rank_number_0.png", 12, 20, string.byte("."))
        self.m_pTurnR1:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pTurnR1:setAnchorPoint(cc.p(0., 0.5))
        self.m_pTurnR1:setPosition(iXPos + 65 * self.m_fMinScaleX, iYPos - 10 * self.m_fMinScaleY)
        self:addChild(self.m_pTurnR1, 1)

        local strMatchTime = ""
        if self.m_wMatchTime == 0 then
            strMatchTime = string.format("%02d/%02d", 0, 0)
        else
            local wMatchTime = self.m_wMatchTime - os.time()
            if wMatchTime <= 0 then
                wMatchTime = 0
            end
            local tmMatchTime = os.date("*t", wMatchTime)
            strMatchTime = string.format("%02d/%02d",  tmMatchTime.min, tmMatchTime.sec)

            local scheduler = cc.Director:getInstance():getScheduler()
            SID_MatchTimeElapse = scheduler:scheduleScriptFunc(handler(self, self.MatchTimeElapse), 1, false)
        end

        self.m_pTurnR2 = cc.LabelAtlas:_create(strMatchTime, "316_match_rank_number_0.png", 12, 20, string.byte("."))
        self.m_pTurnR2:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pTurnR2:setAnchorPoint(cc.p(0, 0.5))
        self.m_pTurnR2:setPosition(iXPos + 65 * self.m_fMinScaleX, iYPos - 53 * self.m_fMinScaleY)
        self:addChild(self.m_pTurnR2, 1)

    elseif iTurnIndex == 1 or iTurnIndex == 2 then
        local iXPos = self.m_pMatchBackR:getPositionX() - self.m_pMatchBackR:getBoundingBox().width / 2
        local iYPos = self.m_pMatchBackR:getPositionY() + self.m_pMatchBackR:getBoundingBox().height / 2

        self.m_pTurnR1 = cc.LabelAtlas:_create(string.format("%d.%d", pMatchAttribute.wGameCount, pMatchAttribute.wContiunePlayCount), "316_match_rank_number_0.png", 12, 20, string.byte("."))
        self.m_pTurnR1:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pTurnR1:setAnchorPoint(cc.p(0, 0.5))
        self.m_pTurnR1:setPosition(iXPos + 95 * self.m_fMinScaleX, iYPos - 8 * self.m_fMinScaleY)
        self:addChild(self.m_pTurnR1, 1)
  
        self.m_pTurnR2 = cc.LabelAtlas:_create(string.format("%d.%d", pMatchAttribute.dwTableRank, GAME_PLAYER_316), "316_match_rank_number_0.png", 12, 20, string.byte("."))
        self.m_pTurnR2:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pTurnR2:setAnchorPoint(cc.p(0, 0.5))
        self.m_pTurnR2:setPosition(iXPos + 95 * self.m_fMinScaleX, iYPos - 50 * self.m_fMinScaleY)
        self:addChild(self.m_pTurnR2, 1)

    elseif iTurnIndex == 3 then
        local iXPos = self.m_pMatchBackR:getPositionX() - self.m_pMatchBackR:getBoundingBox().width / 2
        local iYPos = self.m_pMatchBackR:getPositionY() + self.m_pMatchBackR:getBoundingBox().height / 2

        self.m_pTurnR1 = cc.LabelAtlas:_create(string.format("%d.%d", pMatchAttribute.wGameCount, pMatchAttribute.wContiunePlayCount), "316_match_rank_number_0.png", 12, 20, string.byte("."))
        self.m_pTurnR1:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pTurnR1:setAnchorPoint(cc.p(0, 0.5))
        self.m_pTurnR1:setPosition(iXPos + 95 * self.m_fMinScaleX, iYPos - 9 * self.m_fMinScaleY)
        self:addChild(self.m_pTurnR1, 1)

        self.m_pTurnR2 = cc.LabelAtlas:_create(string.format("%d.%d", pMatchAttribute.dwCurRank, pMatchAttribute.dwTotalCount), "316_match_rank_number_0.png", 12, 20, string.byte("."))
        self.m_pTurnR2:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pTurnR2:setAnchorPoint(cc.p(0, 0.5))
        self.m_pTurnR2:setPosition(iXPos + 85 * self.m_fMinScaleX, iYPos - 35 * self.m_fMinScaleY)
        self:addChild(self.m_pTurnR2, 1)
    end

    self.m_bShowMatch = true
end

function ASMJ_MatchControl:MatchTimeElapse(fTime)
    local wMatchTime = self.m_wMatchTime - os.time()
    if wMatchTime <= 0 then
        wMatchTime = 0
        if SID_MatchTimeElapse ~= nil then
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(SID_MatchTimeElapse)
            SID_MatchTimeElapse = nil
        end
    end
    local tmMatchTime = os.date("*t", wMatchTime)
    strMatchTime = string.format("%02d/%02d",  tmMatchTime.min, tmMatchTime.sec)
    self.m_pTurnR2:setString(strMatchTime)
end


function ASMJ_MatchControl:ClearMatch() 
    if SID_MatchTimeElapse ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(SID_MatchTimeElapse)
        SID_MatchTimeElapse = nil
    end

    self.m_bShowMatch = false
    self:removeAllChildren()

    self.m_pMatchBackL = nil
    self.m_pMatchBackR = nil

    self.m_pTurnL1 = nil
    self.m_pTurnL2 = nil

    self.m_pTurnR1 = nil
    self.m_pTurnR2 = nil
end


-----------------------------------------------------------------------------

local ASMJ_MatchNotifyStatus = class("ASMJ_MatchNotifyStatus", function() return cc.Node:create() end)

--create( ... )
function ASMJ_MatchNotifyStatus_create()
    print("ASMJ_MatchNotifyStatus_create")
    local Node = ASMJ_MatchNotifyStatus.new()
    return Node
end

--ctor()
function ASMJ_MatchNotifyStatus:ctor()
    print("ASMJ_MatchNotifyStatus:ctor")
    self.m_fMinScaleX = 1
    self.m_fMinScaleY = 1
    self.m_ptBack = cc.p(0,0)

    self:ClearNotifyStatus()
end

function ASMJ_MatchNotifyStatus:OnClickEvent(clickcmd)
    print("ASMJ_MatchNotifyStatus:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDB_BT_OUT_ENABLE_316  then
        self:ClearNotifyStatus()

        CClientKernel:GetInstance():CloseRoomThread()
        local reScene = ASMJ_LobbyListScene_createScene(ERT_FL_316) 
        if reScene then
            cc.Director:getInstance():replaceScene( cc.TransitionSlideInL:create(TIME_SCENE_CHANGE, reScene) )
        end
    end
end

function ASMJ_MatchNotifyStatus:SetScaleMin(iMinScaleX, iMinScaleY)
    self.m_fMinScaleX = iMinScaleX 
    self.m_fMinScaleY = iMinScaleY
end

function ASMJ_MatchNotifyStatus:InitPosition(ptBack)
    self.m_ptBack = ptBack
end

function ASMJ_MatchNotifyStatus:ShowNotifyStatus(iSenceIndex, iStatus, iReason)
    self.m_bShowNotifyStatus = true

    if iSenceIndex == 0 then
        self:ShowTurnOne(iStatus, iReason)
    elseif iSenceIndex <= 2 then
        self:ShowTurnOther(iStatus, iReason)
    elseif iSenceIndex == 3 then
        self:ShowTurnLast(iStatus, iReason)
    end

end

function ASMJ_MatchNotifyStatus:ShowTurnOne(iStatus, iReason)
    local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()

    if iStatus == User_Out then
        self.m_pNotifyBack = cc.Sprite:create("316_match_out_bg.png")
        self.m_pNotifyBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pNotifyBack:setPosition(self.m_ptBack.x, self.m_ptBack.y)
        self:addChild(self.m_pNotifyBack, 0)

        local iXPos = 0
        local iYPos = self.m_pNotifyBack:getContentSize().height
        self.m_pCurrentRank = cc.LabelAtlas:_create("-0123456789", "316_match_info_number.png", 26, 28, string.byte("/"))
        self.m_pCurrentRank:setScale(0.8)
        self.m_pCurrentRank:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_pCurrentRank:setPosition(iXPos + 305, iYPos - 62)
        self.m_pNotifyBack:addChild(self.m_pCurrentRank, 1)
        self:SetCurrentRank(pMatchAttribute.dwCurRank)

        self.m_pPromtCount = cc.LabelAtlas:_create("0123456789", "316_match_info_number2.png", 26, 28, string.byte("0"))
        self.m_pPromtCount:setScale(0.8)
        self.m_pPromtCount:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_pPromtCount:setPosition(iXPos + 220, iYPos - 100)
        self.m_pNotifyBack:addChild(self.m_pPromtCount, 1)
        self:SetPromtCount(pMatchAttribute.dwPromtCount)

        self.m_btOutEnable = CImageButton:Create("316_match_out_exit0.png", "316_match_out_exit1.png", IDB_BT_OUT_ENABLE_316)
        self.m_btOutEnable:setPosition(self.m_pNotifyBack:getContentSize().width/2, iYPos - 230)
        self.m_pNotifyBack:addChild(self.m_btOutEnable, 1)

        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btOutEnable, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)

    elseif iStatus == User_Wait then
        
        self.m_pNotifyBack = cc.Sprite:create("316_match_wait_next_turn.png")
        self.m_pNotifyBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pNotifyBack:setPosition(self.m_ptBack)
        self:addChild(self.m_pNotifyBack, 0)

        local iXPos = 0
        local iYPos = self.m_pNotifyBack:getContentSize().height

        local pCurrentScore = cc.LabelAtlas:_create("-0123456789", "316_match_info_number.png", 26, 28, string.byte("/"))
        pCurrentScore:setScale(0.8)
        pCurrentScore:setAnchorPoint(cc.p(0, 0.5))
        pCurrentScore:setPosition(iXPos + 195, iYPos - 107)
        self.m_pNotifyBack:addChild(pCurrentScore, 1)
        
        local strScore = ""
        local pIClientUserItem = ASMJ_MyUserItem:GetInstance():GetClientUserItem(MYSELF_VIEW_ID_316)
        local lScore = pIClientUserItem.lScore
        if lScore < 0 then
            strScore = string.format("/%d", -lScore)
        else  
            strScore = string.format("%d", lScore)
        end
        pCurrentScore:setString(strScore)

        self.m_pCurrentRank = cc.LabelAtlas:_create("-0123456789", "316_match_info_number.png", 26, 28, string.byte("/"))
        self.m_pCurrentRank:setScale(0.8)
        self.m_pCurrentRank:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_pCurrentRank:setPosition(iXPos + 160, iYPos - 145)
        self.m_pNotifyBack:addChild(self.m_pCurrentRank, 1)
        self:SetCurrentRank(pMatchAttribute.dwCurRank)
        
        self.m_pPromtCount = cc.LabelAtlas:_create("0123456789", "316_match_info_number2.png", 26, 28, string.byte("0"))
        self.m_pPromtCount:setScale(0.8)
        self.m_pPromtCount:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_pPromtCount:setPosition(iXPos + 295, iYPos - 145)
        self.m_pNotifyBack:addChild(self.m_pPromtCount, 1)
        self:SetPromtCount(pMatchAttribute.dwPromtCount)
        
        self.m_PlayTableCount = cc.LabelAtlas:_create("0123456789", "316_match_info_number2.png", 26, 28, string.byte("0"))
        self.m_PlayTableCount:setScale(0.8)
        self.m_PlayTableCount:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_PlayTableCount:setPosition(iXPos + 175, iYPos - 190)
        self.m_pNotifyBack:addChild(self.m_PlayTableCount, 1)
        self:SetPlayTableCount(pMatchAttribute.dwPlayTableCount)
    elseif iStatus == User_Promt then
        --todo
    end

end

function ASMJ_MatchNotifyStatus:ShowTurnOther(iStatus, iReason)
    local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()

    if iStatus == User_Out then
       
        if iReason == 0 then
            self.m_pNotifyBack = cc.Sprite:create("316_match_table_rank3.png")
        else
            self.m_pNotifyBack = cc.Sprite:create("316_match_out_back2.png")
        end
        self.m_pNotifyBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pNotifyBack:setPosition(self.m_ptBack.x, self.m_ptBack.y)
        self:addChild(self.m_pNotifyBack, 0)

        local iXPos = 0
        local iYPos = self.m_pNotifyBack:getContentSize().height
        if iReason == 0 then
            self.m_pTableRank = cc.LabelAtlas:_create("-0123456789", "316_match_info_number.png", 26, 28, string.byte("/"))
            self.m_pTableRank:setScale(0.8)
            self.m_pTableRank:setAnchorPoint(cc.p(0.5, 0.5))
            self.m_pTableRank:setPosition(iXPos + 370, iYPos - 40)
            self.m_pNotifyBack:addChild(self.m_pTableRank, 1)
            self:SetTableRank(pMatchAttribute.dwTableRank)
        end

        self.m_btOutEnable = CImageButton:Create("316_match_out_exit0.png", "316_match_out_exit1.png", IDB_BT_OUT_ENABLE_316)
        self.m_btOutEnable:setPosition(self.m_pNotifyBack:getContentSize().width/2, iYPos - 150 * self.m_fMinScaleY - (iReason ~= 0 and 75 or 0) * self.m_fMinScaleY)
        self.m_pNotifyBack:addChild(self.m_btOutEnable, 1)
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btOutEnable, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)

    elseif iStatus == User_Wait then

        self.m_pNotifyBack = cc.Sprite:create("316_match_table_rank2.png")
        self.m_pNotifyBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pNotifyBack:setPosition(self.m_ptBack.x, self.m_ptBack.y)
        self:addChild(self.m_pNotifyBack, 0)
        
        local iXPos = 0
        local iYPos = self.m_pNotifyBack:getContentSize().height
        self.m_PlayTableCount = cc.LabelAtlas:_create("-0123456789", "316_match_info_number.png", 26, 28, string.byte("/"))
        self.m_PlayTableCount:setAnchorPoint(Vec2(0.5, 0.5))
        self.m_PlayTableCount:setScale(0.8)
        self.m_PlayTableCount:setPosition(iXPos + 200, 35)
        self.m_pNotifyBack:addChild(self.m_PlayTableCount, 1)
        self:SetPlayTableCount(pMatchAttribute.dwPlayTableCount)

    elseif iStatus == User_Promt then
        
        self.m_pNotifyBack = cc.Sprite:create("316_match_table_rank1.png")
        self.m_pNotifyBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pNotifyBack:setPosition(self.m_ptBack.x, self.m_ptBack.y)
        self:addChild(self.m_pNotifyBack, 0)

        local iXPos = 0
        local iYPos = self.m_pNotifyBack:getContentSize().height
        self.m_PlayTableCount = cc.LabelAtlas:_create("-0123456789", "316_match_info_number.png", 26, 28, string.byte("/"))
        self.m_PlayTableCount:setScale(0.8)
        self.m_PlayTableCount:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_PlayTableCount:setPosition(iXPos + 200, 35)
        self.m_pNotifyBack:addChild(self.m_PlayTableCount, 1)
        self:SetPlayTableCount(pMatchAttribute.dwPlayTableCount)
    end
end

function ASMJ_MatchNotifyStatus:ShowTurnLast(iStatus, iReason)
    
    local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()

    self.m_pNotifyBack = cc.Sprite:create("316_match_finish_bg.png")
    self.m_pNotifyBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    self.m_pNotifyBack:setPosition(self.m_ptBack.x, self.m_ptBack.y)
    self:addChild(self.m_pNotifyBack, 0)

    local iXPos = 0
    local iYPos = self.m_pNotifyBack:getContentSize().height
    self.m_pCurrentRank = cc.LabelAtlas:_create("-0123456789", "316_match_info_number.png", 26, 28, string.byte("/"))
    self.m_pCurrentRank:setScale(0.8)
    self.m_pCurrentRank:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_pCurrentRank:setPosition(iXPos + 320, iYPos - 105)
    self.m_pNotifyBack:addChild(self.m_pCurrentRank, 1)
    self:SetCurrentRank(pMatchAttribute.dwCurRank)

    self.m_PlayTableCount = cc.LabelAtlas:_create("-0123456789", "316_match_info_number.png", 26, 28, string.byte("/"))
    self.m_PlayTableCount:setScale(0.8)
    self.m_PlayTableCount:setPosition(iXPos + 200, iYPos - 215)
    self.m_PlayTableCount:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_pNotifyBack:addChild(self.m_PlayTableCount, 1)
    self:SetPlayTableCount(pMatchAttribute.dwPlayTableCount)
end



function ASMJ_MatchNotifyStatus:SetTableRank(iRank)

    if not self.m_bShowNotifyStatus then
        return
    end

    if self.m_pTableRank == nil then
        return
    end

    self.m_pTableRank:setString(string.format("%d", iRank))
end


function ASMJ_MatchNotifyStatus:SetCurrentRank(iRank)

    if not self.m_bShowNotifyStatus then
        return
    end

    if self.m_pCurrentRank == nil then
        return
    end

    self.m_pCurrentRank:setString(string.format("%d", iRank))
end


function ASMJ_MatchNotifyStatus:SetPromtCount(PromtCount)

    if not self.m_bShowNotifyStatus then
        return
    end

    if self.m_pPromtCount == nil then
        return
    end

    self.m_pPromtCount:setString(string.format("%d", PromtCount))
end


function ASMJ_MatchNotifyStatus:SetPlayTableCount(iPlayTableCount)

    if not self.m_bShowNotifyStatus then
        return
    end

    if self.m_PlayTableCount == nil then
        return
    end

    self.m_PlayTableCount:setString(string.format("%d", iPlayTableCount))
end

function ASMJ_MatchNotifyStatus:ClearNotifyStatus()

    self.m_bShowNotifyStatus = false
    self:removeAllChildren()

    self.m_pNotifyBack = nil
    self.m_pCurrentRank = nil
    self.m_pPromtCount = nil
    self.m_PlayTableCount = nil
    self.m_pTableRank = nil
end

---------------------------------------------------------

local ASMJ_MatchNotifyOut = class("ASMJ_MatchNotifyOut", function() return cc.Node:create() end)

--create( ... )
function ASMJ_MatchNotifyOut_create()
    print("ASMJ_MatchNotifyOut_create")
    local Node = ASMJ_MatchNotifyOut.new()
    return Node
end

--ctor()
function ASMJ_MatchNotifyOut:ctor()
    print("ASMJ_MatchNotifyOut:ctor")
    self.m_fMinScaleX = 1
    self.m_fMinScaleY = 1

    self.m_bShowNotifyOut = false
    self.m_wTipTime = 0
    self.m_ptBack = cc.p(0, 0)
    self.m_pNotifyBack = nil
    
    local function onNodeEvent(event)
      if event == "enter" then
          self:onEnter()
      elseif event == "exit" then
          self:onExit()
      end
    end

    self:registerScriptHandler(onNodeEvent)
end


function ASMJ_MatchNotifyOut:onEnter()
end

--onExit()
function ASMJ_MatchNotifyOut:onExit()
    print("ASMJ_MatchNotifyOut:onExit")
    if SID_ReLeftElapse ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(SID_ReLeftElapse)
        SID_ReLeftElapse = nil
    end
end


function ASMJ_MatchNotifyOut:OnClickEvent(clickcmd)
    print("ASMJ_MatchNotifyOut:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDB_BT_RELEFT_316  then
        self.m_btReLeft:SetClickable(false)
        self.m_btReLeft:SetImg("316_match_bt_releft_gray.png", "316_match_bt_releft_gray.png")

        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():SendSocketToGameServer(MDM_GR_MATCH, SUB_GR_USER_RESURRECTION)

    elseif clickcmd:getnTag() == IDB_BT_EXIT_316 then
        --todo
        self:ClearNotifyOut()
        CClientKernel:GetInstance():CloseRoomThread()
        local reScene = ASMJ_LobbyListScene_createScene(ERT_FL_316)
        if reScene then
            cc.Director:getInstance():replaceScene( cc.TransitionSlideInL:create(TIME_SCENE_CHANGE, reScene) )
        end
    end
end

function ASMJ_MatchNotifyOut:ClearNotifyOut()
    
    self.m_bShowNotifyOut = false
    self:removeAllChildren(true)
    self.m_pNotifyBack = nil
    self.m_btReLeft = nil
    self.m_pCountDown = nil

    if SID_ReLeftElapse ~= nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(SID_ReLeftElapse)
        SID_ReLeftElapse = nil
    end
end

function ASMJ_MatchNotifyOut:ReLeftElapse(fTime)

    self.m_wTipTime = self.m_wTipTime - 1
    self.m_pCountDown:setString(string.format("%d", self.m_wTipTime))

    if self.m_wTipTime <= 0 then

        self.m_btReLeft:SetClickable(false)
        self.m_btReLeft:SetImg("316_match_bt_releft_gray.png", "316_match_bt_releft_gray.png")

        if SID_ReLeftElapse ~= nil then
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(SID_ReLeftElapse)
            SID_ReLeftElapse = nil
        end
    end
end

function ASMJ_MatchNotifyOut:SetScaleMin(iMinScaleX, iMinScaleY)
    self.m_fMinScaleX = iMinScaleX 
    self.m_fMinScaleY = iMinScaleY
end

function ASMJ_MatchNotifyOut:InitPosition(ptBack)
    self.m_ptBack = ptBack
end

function ASMJ_MatchNotifyOut:ShowNotifyOut(bTimeLimit, wTipTime, lCostGold, cbReason)

    if cbReason == 0 then
       
        self.m_pNotifyBack = cc.Sprite:create("316_match_resurrect_back.png")
        self.m_pNotifyBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pNotifyBack:setPosition(self.m_ptBack.x, self.m_ptBack.y)
        self:addChild(self.m_pNotifyBack, 0)

        local iXPos = 0
        local iYPos = self.m_pNotifyBack:getContentSize().height

        self.m_btReLeft = CImageButton:Create("316_match_bt_releft0.png", "316_match_bt_releft1.png", IDB_BT_RELEFT_316)
        self.m_btReLeft:setPosition(iXPos + 155, iYPos - 225)
        self.m_pNotifyBack:addChild(self.m_btReLeft, 1)
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btReLeft, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)


        if not bTimeLimit then
            self.m_btReLeft:SetClickable(false)
            self.m_btReLeft:SetImg("316_match_bt_releft_gray.png", "316_match_bt_releft_gray.png")
        end

        local strReleftGold = string.format(CUtilEx:getString("0_releft_tip"), lCostGold)
        local pCostGold = cc.LabelTTF:create(strReleftGold, "Arial", 20)
        pCostGold._eHorizAlign = cc.TEXT_ALIGNMENT_CENTER
        pCostGold:setPosition(self.m_pNotifyBack:getContentSize().width/2, iYPos - 115)
        self.m_pNotifyBack:addChild(pCostGold, 1)

        self.m_btExit = CImageButton:Create("316_match_out_exit0.png", "316_match_out_exit1.png", IDB_BT_EXIT_316)
        self.m_btExit:setPosition(self.m_btReLeft:getPositionX() + 255, self.m_btReLeft:getPositionY())
        self.m_pNotifyBack:addChild(self.m_btExit, 1)
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btExit, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)

        self.m_wTipTime = wTipTime
        self.m_pCountDown = cc.LabelAtlas:_create("0123456789", "316_match_promt_number.png", 20, 27, string.byte("0"))
        self.m_pCountDown:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_pCountDown:setPosition(iXPos + 265, iYPos - 220)
        self.m_pNotifyBack:addChild(self.m_pCountDown, 1)
        self.m_pCountDown:setString(string.format("%d", self.m_wTipTime))

        local scheduler = cc.Director:getInstance():getScheduler()
        SID_ReLeftElapse = scheduler:scheduleScriptFunc(handler(self, self.ReLeftElapse), 1, false)

        local pReleftInfo = cc.LabelTTF:create(CUtilEx:getString("316_releft_info"), "Arial", 20)
        pReleftInfo:setAnchorPoint(cc.p(0.5, 0.5))
        pReleftInfo:setColor(cc.c3b(200, 10, 10))
        pReleftInfo:setPosition(self.m_pNotifyBack:getContentSize().width/2, iYPos - 265)
        self.m_pNotifyBack:addChild(pReleftInfo, 1)

    elseif cbReason == 1 then

        local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()

        self.m_pNotifyBack = cc.Sprite:create("316_match_out_back.png")
        self.m_pNotifyBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_pNotifyBack:setPosition(cc.p(self.m_ptBack))
        self:addChild(self.m_pNotifyBack, 0)

        local iXPos = 0
        local iYPos = self.m_pNotifyBack:getContentSize().height
        local pCurrentRank = cc.LabelAtlas:_create(string.format("%d", pMatchAttribute.dwCurRank), "316_match_info_number.png", 26, 28, string.byte("/"))
        pCurrentRank:setScale(0.8)
        pCurrentRank:setAnchorPoint(cc.p(0.5, 0.5))
        pCurrentRank:setPosition(iXPos + 300, iYPos - 60)
        self.m_pNotifyBack:addChild(pCurrentRank, 0 + 1)

        local pPromtCount = cc.LabelAtlas:_create(string.format("%d", pMatchAttribute.dwPromtCount), "316_match_info_number2.png", 26, 28, string.byte("0"))
        pPromtCount:setScale(0.8)
        pPromtCount:setAnchorPoint(cc.p(0.5, 0.5))
        pPromtCount:setPosition(iXPos + 215, iYPos - 98)
        self.m_pNotifyBack:addChild(pPromtCount, 0 + 1)

        self.m_btExit = CImageButton:Create("316_match_out_exit0.png", "316_match_out_exit1.png", IDB_BT_EXIT_316)
        self.m_btExit:setPosition(self.m_pNotifyBack:getContentSize().width/2, iYPos - 230)
        self.m_pNotifyBack:addChild(self.m_btExit, 1)
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btExit, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    end
end

-------------------------------------------------
local ASMJ_MatchResult = class("ASMJ_MatchResult", function() return cc.Node:create() end)

--create( ... )
function ASMJ_MatchResult_create()
    print("ASMJ_MatchResult_create")
    local Node = ASMJ_MatchResult.new()
    return Node
end

--ctor()
function ASMJ_MatchResult:ctor()
    print("ASMJ_MatchResult:ctor")
    self.m_fMinScaleX = 1
    self.m_fMinScaleY = 1

    self.m_bShowNotifyOut = false
    self.m_wTipTime = 0
    self.m_ptBack = cc.p(0, 0)
    self.m_pNotifyBack = nil
end

function ASMJ_MatchResult:OnClickEvent(clickcmd)
    print("ASMJ_MatchResult:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDI_BT_SHARED_316 then
        --todo
    elseif clickcmd:getnTag() == IDB_BT_EXIT_316  then
        CClientKernel:GetInstance():CloseRoomThread()
        local reScene = ASMJ_LobbyListScene_createScene(ERT_FL_316)--ASMJ_RoomFLListScene_createScene()
        if reScene then
            cc.Director:getInstance():replaceScene( cc.TransitionSlideInL:create(TIME_SCENE_CHANGE, reScene) )
        end
    end
end

function ASMJ_MatchResult:SetScaleMin(iMinScaleX, iMinScaleY)
    self.m_fMinScaleX = iMinScaleX 
    self.m_fMinScaleY = iMinScaleY
end

function ASMJ_MatchResult:InitPosition(ptBack)
    self.m_ptBack = ptBack
end

function ASMJ_MatchResult:ShowMatchResult(msgcmd)

    local szMatchName           = CMCipher:g2u_forlua(msgcmd:readChars(32), 32)         
    local szNickName            = CMCipher:g2u_forlua(msgcmd:readChars(32), 32) 
    local wAwardMode            = msgcmd:readWORD()
    local wRank                 = msgcmd:readWORD()
    local dwGold                = msgcmd:readDWORD()
    local dwMedal               = msgcmd:readDWORD()
    local dwMatchTiket          = msgcmd:readDWORD()
    local dwEntityKind          = msgcmd:readDWORD()
    local dwEntityCount         = msgcmd:readDWORD()

    local cbMustWardGold        = msgcmd:readBYTE()
    local cbMustWardMedal       = msgcmd:readBYTE()
    local cbMustWardMatchTiket  = msgcmd:readBYTE()
    local cbMustWardEntity      = msgcmd:readBYTE()

    local m_Reward = {}
    if dwMedal > 0 then
        m_Reward.iCount = dwMedal
        m_Reward.iRewardType = 1
    elseif dwGold > 0 then
        m_Reward.iCount = dwGold
        m_Reward.iRewardType = 0
    elseif dwEntityKind > 0 then
        m_Reward.iCount = dwEntityCount
        m_Reward.iRewardType = 2
    else
        m_Reward.iCount = 0
        m_Reward.iRewardType = 0
    end

    local iRewardCount = #m_Reward
    local pResultBack = cc.Sprite:create("316_match_award_back.png")
    pResultBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    pResultBack:setPosition(cc.p(self.m_ptBack))
    self:addChild(pResultBack, 0)

    local iXPos = 0
    local iYPos = pResultBack:getContentSize().height

    self.m_pBtShare = CImageButton:Create("316_match_bt_shared0.png", "316_match_bt_shared1.png", IDI_BT_SHARED_316)
    self.m_pBtShare:setPosition(iXPos + pResultBack:getContentSize().width - self.m_pBtShare:getContentSize().width/2, iYPos - self.m_pBtShare:getContentSize().height/2 )
    pResultBack:addChild(self.m_pBtShare, 1)

    local sp_info1 = cc.LabelTTF:create(CUtilEx:getString("0_match_result0"), "Arial", 27)
    sp_info1:setPosition(65, 260)
    sp_info1:setColor(cc.c3b(90, 35, 5))
    sp_info1:setAnchorPoint(cc.p(0, 0.5))
    pResultBack:addChild(sp_info1)

    local sp_info2 = cc.LabelTTF:create(szMatchName, "Arial", 27)
    sp_info2:setPosition(282, sp_info1:getPositionY())
    sp_info2:setColor(cc.c3b(220, 0, 0))
    sp_info2:setAnchorPoint(cc.p(0.5, 0.5))
    pResultBack:addChild(sp_info2)

    local sp_info3 = cc.LabelTTF:create(CUtilEx:getString("0_match_result1"), "Arial", 27)
    sp_info3:setPosition(385, sp_info1:getPositionY())
    sp_info3:setColor(cc.c3b(90, 35, 5))
    sp_info3:setAnchorPoint(cc.p(0, 0.5))
    pResultBack:addChild(sp_info3)
   
    local sp_info4 = cc.LabelTTF:create(string.format("%d", wRank), "Arial", 27)
    sp_info4:setPosition(517, sp_info1:getPositionY())
    sp_info4:setColor(cc.c3b(220, 0, 0))
    sp_info4:setAnchorPoint(cc.p(0.5, 0.5))
    pResultBack:addChild(sp_info4)
    
    local sp_info5 = cc.LabelTTF:create(CUtilEx:getString("0_match_result2"), "Arial", 27)
    sp_info5:setPosition(535, sp_info1:getPositionY())
    sp_info5:setColor(cc.c3b(90, 35, 5))
    sp_info5:setAnchorPoint(cc.p(0, 0.5))
    pResultBack:addChild(sp_info5)
    
    local sp_info6 = cc.LabelTTF:create(CUtilEx:getString("0_match_result3"), "Arial", 27)
    sp_info6:setPosition(65, sp_info1:getPositionY() - 53)
    sp_info6:setColor(cc.c3b(90, 35, 5))
    sp_info6:setAnchorPoint(cc.p(0, 0.5))
    pResultBack:addChild(sp_info6)

    local sp_info7 = cc.LabelTTF:create(CUtilEx:getString("0_match_result4"), "Arial", 22)
    sp_info7:setPosition(150, 60)
    sp_info7:setColor(cc.c3b(220, 0, 0))
    sp_info7:setAnchorPoint(cc.p(0, 0.5))
    pResultBack:addChild(sp_info7)

    local reward_type = m_Reward.iRewardType
    local reward_count = m_Reward.iCount
    local strReward = string.format(CUtilEx:getString(string.format("0_match_award_name_%d", reward_type)), reward_count)
    local lab_reward = cc.LabelTTF:create(strReward, "Arial", 35)
    lab_reward:setPosition(150, 140)
    lab_reward:setColor(cc.c3b(130, 50, 10))
    lab_reward:setAnchorPoint(cc.p(0, 0.5))
    pResultBack:addChild(lab_reward)
    
    local tmAawardTime = os.date("*t",os.time())
    local strAawardTime = string.format("%04d-%02d-%02d", tmAawardTime.year, tmAawardTime.month, tmAawardTime.day)

    local pAawardTime = cc.LabelTTF:create(strAawardTime, "Arial", 18)
    pAawardTime:setColor(cc.c3b(0, 0, 0))
    pAawardTime._eHorizAlign = cc.TEXT_ALIGNMENT_CENTER
    pAawardTime:setPosition(540, 67)
    pResultBack:addChild(pAawardTime, 1)
    
    local pBtClose = CImageButton:CreateWithSpriteFrameName("316_bt_detail_close.png", "316_bt_detail_close.png", IDB_BT_EXIT_316)
    pBtClose:setPosition(48, pResultBack:getContentSize().height - 48)
    pResultBack:addChild(pBtClose, 1)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(pBtClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
   
    self.m_strShared = string.format(CUtilEx:getString("0_match_result_share"), CUtilEx:getString("316_app_name"), szMatchName, wRank)
end

function ASMJ_MatchResult:ClearResult()
    self:removeAllChildren()
    self.m_pCountDown = nil
end