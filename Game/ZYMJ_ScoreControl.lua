local ASMJ_ScoreControl = class("ASMJ_ScoreControl", function() return cc.Layer:create() end)

function ASMJ_ScoreControl:OnClickEvent(clickcmd)
    print("ASMJ_ScoreControl:OnClickEvent " .. clickcmd:getnTag())

    if clickcmd:getnTag() == TAG_BT_LOOKSCORE_316  then
        
        if self:getChildByTag(1000) then
            return
        end

        local m_DetailControl = ASMJ_DetailControl_create(self.m_ScoreData)
        self:addChild(m_DetailControl, 1000, 1000)

    elseif clickcmd:getnTag() == TAG_BT_STARTGAME_316 then

        if self:getChildByTag(1000) then
            return
        end
        
        -- sit down
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

        self:removeFromParent()
    else
        print("click tag unknow")
    end
end

--ctor()
function ASMJ_ScoreControl:ctor(ScoreData)
    print("ASMJ_ScoreControl:ctor")
    self.m_ScoreData = ScoreData
    self:init()
end

--create( ... )
function ASMJ_ScoreControl_create(ScoreData)
    print("ASMJ_ScoreControl_create")
    local layer = ASMJ_ScoreControl.new(ScoreData)
    return layer
end


--init()
function ASMJ_ScoreControl:init()

    local Visible = cc.Director:getInstance():getVisibleSize()
    local scalex = display.scalex_landscape
    local scaley = display.scaley_landscape

    local pEasyScore = cc.Node:create()
    self:addChild(pEasyScore, ZORDER_ACTION_316 + 50)

    local pWinLostBack = nil
    local pWinLostFont = nil
    local wMeChairID = ASMJ_MyUserItem:GetInstance():GetChairID()
    
    if self.m_ScoreData.bFlowBureau == 1 then
        pWinLostBack = cc.Sprite:createWithSpriteFrameName("316_end_win_bg.png")
        pWinLostFont = cc.Sprite:createWithSpriteFrameName("316_end_LJ.png")
    elseif self.m_ScoreData.lGameScore[wMeChairID] > 0 then
        pWinLostBack = cc.Sprite:createWithSpriteFrameName("316_end_win_bg.png")
        pWinLostFont = cc.Sprite:createWithSpriteFrameName("316_end_SL.png")
    else
        pWinLostBack = cc.Sprite:createWithSpriteFrameName("316_end_lost_bg.png")
        pWinLostFont = cc.Sprite:createWithSpriteFrameName("316_end_SB.png")
    end

    local iPosY = 400 * scaley
    pWinLostBack:setScale(scalex, scaley)
    pWinLostBack:setPosition(Visible.width / 2, iPosY)
    pEasyScore:addChild(pWinLostBack, 0)
    pWinLostBack:runAction(cc.FadeIn:create(0.2))

    pWinLostFont:setScale(scalex, scaley)
    pWinLostFont:setPosition(Visible.width / 2, iPosY + 100 * scaley)
    pEasyScore:addChild(pWinLostFont, 1)

    local moveAction = cc.MoveTo:create(0.8, cc.p(pWinLostFont:getPositionX(), iPosY + 25 * scaley))
    local easeAction = cc.EaseBounceOut:create(moveAction:clone())
    local seqAction = cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.2), cc.Show:create(), easeAction)
    pWinLostFont:runAction(seqAction)

    ---------------------------------
    local pRing = nil
    if self.m_ScoreData.lGameScore[wMeChairID] > 0 then
        
        pRing = cc.Sprite:createWithSpriteFrameName("316_end_ring.png")
        local iRandStar = 0
        for i=1,math.random(5,8) do
            local pWinStar = cc.Sprite:createWithSpriteFrameName("316_end_star.png")
            pWinStar:setScale(scalex, scaley)

            iRandStar = math.random(0,3)
            if iRandStar == 0 then
                pWinStar:setPosition(
                    Visible.width / 2 + (math.random(0,50) + 10) * scalex,
                    iPosY + 50 * scaley + (math.random(0,50) + 20) * scaley)
            elseif iRandStar == 1 then
                pWinStar:setPosition(
                    Visible.width / 2 - (math.random(0,50) + 10) * scalex,
                    iPosY + 50 * scaley - (math.random(0,50) + 20) * scaley)
            elseif iRandStar == 2 then
                pWinStar:setPosition(
                    Visible.width / 2 + (math.random(0,50) + 10) * scalex,
                    iPosY + 50 * scaley - (math.random(0,50) + 20) * scaley)
            elseif iRandStar == 3 then
                pWinStar:setPosition(
                    Visible.width / 2 - (math.random(0,50) + 10) * scalex,
                    iPosY + 50 * scaley + (math.random(0,50) + 20) * scaley)
            end

            pEasyScore:addChild(pWinStar, 2)
            local pSeq = cc.Sequence:create(
                cc.Hide:create(),
                cc.DelayTime:create(math.random()), 
                cc.Show:create(),
                cc.FadeOut:create(1.0), 
                cc.FadeIn:create(1.0))
            pWinStar:runAction(cc.RepeatForever:create(pSeq))
        end
  
        local pHat = cc.Sprite:createWithSpriteFrameName("316_end_hat.png")
        pHat:setScale(scalex, scaley)
        pHat:setPosition(Visible.width / 2, Visible.height - 50 * scaley)
        pEasyScore:addChild(pHat, 1)
        pHat:runAction(
                cc.Sequence:create(
                    cc.Hide:create(), 
                    cc.DelayTime:create(1),
                    cc.Show:create(),
                    cc.Spawn:create(
                        cc.FadeIn:create(0.3),
                        cc.MoveTo:create(0.3,cc.p(Visible.width / 2, iPosY + 135 * scaley)))))
    
    elseif self.m_ScoreData.bFlowBureau == 1 then
        pRing = cc.Sprite:createWithSpriteFrameName("316_end_ring.png")
    else
        pRing = cc.Sprite:createWithSpriteFrameName("316_end_lost_ring.png")
    end

    pRing:setScale(scalex, scaley)
    pRing:setPosition(Visible.width / 2, iPosY + 20 * scaley)
    pEasyScore:addChild(pRing, -1)
    pRing:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.8, 30)))
    -----------

    for i=1,GAME_PLAYER_316 do
        local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(i)
        local pAddNumber = nil
        local iTmpScore = 0
        if self.m_ScoreData.lGameScore[i] >= 0 then
            iTmpScore = self.m_ScoreData.lGameScore[i]
            pAddNumber = cc.LabelAtlas:_create("+0123456789", "316_end_show_add_score.png", 52, 56, string.byte("/"))
        else
            iTmpScore = -self.m_ScoreData.lGameScore[i]
            pAddNumber = cc.LabelAtlas:_create("-0123456789", "316_end_show_lost_score.png", 52, 56, string.byte("/"))
        end

        local pt = cc.p(0,0)
        if wViewChairID == 1 then
            pt.x = 300 * scalex
            pt.y = Visible.height - 120 * scaley
            pAddNumber:setAnchorPoint(cc.p(0, 0.5))
        elseif wViewChairID == 2 then
            pt.x = 110 * scalex
            pt.y = Visible.height / 2 + 50 * scaley
            pAddNumber:setAnchorPoint(cc.p(0, 0.5))
        elseif wViewChairID == 3 then
            pt.x = Visible.width / 2
            pt.y = 280 * scaley
            pAddNumber:setAnchorPoint(cc.p(0.5, 0.5))
        elseif wViewChairID == 4 then
            pt.x = Visible.width - 110 * scalex
            pt.y = Visible.height / 2 + 50 * scaley
            pAddNumber:setAnchorPoint(cc.p(1, 0.5))
        end

        pAddNumber:setScale(0.5 * scalex, 0.5 * scaley)
        pAddNumber:setOpacity(0)
        pAddNumber:setPosition(pt)
        self:addChild(pAddNumber, ZORDER_ACTION_316 + 1)

        pAddNumber:setString(string.format("/%d", iTmpScore))

        pAddNumber:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.3),
            cc.Spawn:create(
                cc.FadeIn:create(0.3),
                cc.ScaleTo:create(0.3, scalex, scaley))))

        if wViewChairID ~= MYSELF_VIEW_ID_316 and self.m_ScoreData.dwChiHuKind[i] ~= WIK_NULL_316 then
            local pEasyHu = cc.Sprite:createWithSpriteFrameName("316_end_DH_hu0.png")
            pEasyHu:setScale(scalex, scaley)

            if wViewChairID == 1 then
                pEasyHu:setPosition(pAddNumber:getPositionX() - pEasyHu:getContentSize().width * scalex, pAddNumber:getPositionY())
            elseif wViewChairID == 2 then
                pEasyHu:setPosition(pAddNumber:getPositionX() + pAddNumber:getContentSize().width * scalex + pEasyHu:getContentSize().width * scalex, pAddNumber:getPositionY())
            elseif wViewChairID == 4 then
                pEasyHu:setPosition(pAddNumber:getPositionX() - pAddNumber:getContentSize().width * scalex - pEasyHu:getContentSize().width * scalex, pAddNumber:getPositionY())
            end

            self:addChild(pEasyHu, ZORDER_ACTION_316 + 1)

            local animation =cc.Animation:create()
            for i=0,6 do
                local szName =string.format("316_end_DH_hu%d.png",i)
                local pSpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(szName)
                animation:addSpriteFrame(pSpriteFrame)
            end  

            local fActionTime = 0.3
            animation:setDelayPerUnit(fActionTime)
            animation:setRestoreOriginalFrame(true)    --

            local action =cc.Animate:create(animation) 
            pEasyHu:runAction(cc.RepeatForever:create(action))
        end
    end

    local iButtonPosX = Visible.width / 2 - 150 * scalex
    local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
    if iRoomType == ERT_FL_316 then
        iButtonPosX = iButtonPosX + 150 * scalex
    end

    local pBtLookScore = CImageButton:CreateWithSpriteFrameName("316_bt_detail0.png", "316_bt_detail1.png", TAG_BT_LOOKSCORE_316)
    pBtLookScore:setScale(scalex, scaley)
    pBtLookScore:setPosition(iButtonPosX, 200 * scaley)
    self:addChild(pBtLookScore, ZORDER_BUTTON_316)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(pBtLookScore, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)

    if iRoomType == ERT_FL_316 then
        return
    end

    local pBtStartGame = CImageButton:CreateWithSpriteFrameName("316_bt_again0.png", "316_bt_again1.png", TAG_BT_STARTGAME_316)
    pBtStartGame:setScale(scalex, scaley)
    pBtStartGame:setPosition(Visible.width / 2 + 150 * scalex, 200 * scaley)
    self:addChild(pBtStartGame, ZORDER_BUTTON_316)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(pBtStartGame, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end


-----------------------------
local ASMJ_DetailControl = class("ASMJ_DetailControl", function() return cc.Layer:create() end)

function ASMJ_DetailControl:OnClickEvent(clickcmd)
    print("ASMJ_DetailControl:OnClickEvent " .. clickcmd:getnTag())

    if clickcmd:getnTag() == TAG_BT_CLOSE_SCORE_316 then
        self:onAcitonEnd()
    end
end

--ctor()
function ASMJ_DetailControl:ctor(ScoreData)
    print("ASMJ_DetailControl:ctor")
    self.m_ScoreData = ScoreData
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

--create( ... )
function ASMJ_DetailControl_create(ScoreData)
    print("ASMJ_DetailControl_create")
    local layer = ASMJ_DetailControl.new(ScoreData)
    return layer
end

--onEnter()
function ASMJ_DetailControl:onEnter()
    
    print("ASMJ_DetailControl:onEnter")
    -- touch
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--onExit()
function ASMJ_DetailControl:onExit()
    print("ASMJ_DetailControl:onExit")
end

--touch begin
function ASMJ_DetailControl:onTouchBegan(touch, event)

    if self.m_pScoreBack ~= nil and self.m_pScoreBack:isVisible() then
        local Visible = cc.Director:getInstance():getVisibleSize()
        local rtTouch = cc.rect(
            Visible.width / 2 - self.m_pScoreBack:getBoundingBox().width/2,
            Visible.height / 2 - self.m_pScoreBack:getBoundingBox().height/2,
            self.m_pScoreBack:getBoundingBox().width,
            self.m_pScoreBack:getBoundingBox().height)
        if cc.rectContainsPoint(rtTouch, cc.p(touch:getLocation().x, touch:getLocation().y)) then
            return false
        end
    end
    return true
end

--touch end
function ASMJ_DetailControl:onTouchEnded(touch, event)
    self:onAcitonEnd()
    --self.m_pScoreBack:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25, 0), cc.CallFunc:create(self:removeFromParent()))) 
end

function ASMJ_DetailControl:onAcitonEnd()
    self.m_pScoreBack:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25, 0), cc.CallFunc:create(function () self:removeFromParent() end))) 
end

--init()
function ASMJ_DetailControl:init()

    if self.m_pScoreBack ~= nil and self.m_pScoreBack:isVisible() then
        return
    end

    local wMeChairID = self.m_ScoreData.m_wMeChairID
    local Visible = cc.Director:getInstance():getVisibleSize()
    local scalex = display.scalex_landscape
    local scaley = display.scaley_landscape

    self.m_pScoreBack = cc.Sprite:createWithSpriteFrameName("316_detail_bg.png")
    self.m_pScoreBack:setScale(0)
    self.m_pScoreBack:setPosition(Visible.width/2, Visible.height/2)
    self.m_pScoreBack:setScale(scalex, scaley)
    self:addChild(self.m_pScoreBack, -1)

    local scaleTo = cc.ScaleTo:create(0.15, 1.25)
    local scaleTo2 = cc.ScaleTo:create(0.1, 1)
    self.m_pScoreBack:runAction(cc.Sequence:create(scaleTo, scaleTo2))

    local iTopLeftX = self.m_pScoreBack:getBoundingBox().width
    local iTopLeftY =  self.m_pScoreBack:getBoundingBox().height
    local pBtClose = CImageButton:CreateWithSpriteFrameName("316_bt_detail_close.png", "316_bt_detail_close.png", TAG_BT_CLOSE_SCORE_316)
    pBtClose:setScale(scalex, scaley)
    pBtClose:setPosition(iTopLeftX - pBtClose:getContentSize().width * scalex, iTopLeftY - pBtClose:getContentSize().height * scaley + 5 * scaley)
    self.m_pScoreBack:addChild(pBtClose, 1)

    local pDetailTitleBg = nil
    local pDetailTitle = nil
    if self.m_ScoreData.bFlowBureau == 1 then
        pDetailTitleBg = cc.Sprite:createWithSpriteFrameName("316_end_win_bg.png")
        pDetailTitle = cc.Sprite:createWithSpriteFrameName("316_end_LJ.png")
    elseif self.m_ScoreData.lGameScore[wMeChairID] > 0 then
        pDetailTitleBg = cc.Sprite:createWithSpriteFrameName("316_end_win_bg.png")
        pDetailTitle = cc.Sprite:createWithSpriteFrameName("316_end_SL.png")
    else
        pDetailTitleBg = cc.Sprite:createWithSpriteFrameName("316_end_lost_bg.png")
        pDetailTitle = cc.Sprite:createWithSpriteFrameName("316_end_SB.png")
    end

    pDetailTitleBg:setScale(scalex, scaley)
    pDetailTitleBg:setPosition(iTopLeftX/2, iTopLeftY)
    self.m_pScoreBack:addChild(pDetailTitleBg, 1)

    pDetailTitle:setScale(scalex, scaley)
    pDetailTitle:setPosition(iTopLeftX/2, iTopLeftY + 20 * scaley)
    self.m_pScoreBack:addChild(pDetailTitle, 2)

    for i=1,GAME_PLAYER_316 do
        local colorText = nil
        if i == self.m_ScoreData.wChiHuUser then
            colorText = cc.c3b(0, 255, 246)
        else
            colorText = cc.c3b(255, 255, 255)
        end

        local wViewChairID = ASMJ_MyUserItem:GetInstance():SwitchViewChairID(i)
        local pPlayerNameLab = cc.LabelTTF:create(self.m_ScoreData.m_szAccount[wViewChairID], "Arial", 30)
        pPlayerNameLab:setScale(scalex, scaley)
        pPlayerNameLab:setDimensions(cc.size(145, 40))
        pPlayerNameLab:setColor(colorText)
        pPlayerNameLab:setPosition((i * 160 - 10) * scalex, iTopLeftY - 95 * scaley)
        self.m_pScoreBack:addChild(pPlayerNameLab, 1)

        local iGameScore = 0
        local pScoreLabA = nil
        if self.m_ScoreData.lGameScore[i] >= 0 then
            iGameScore = self.m_ScoreData.lGameScore[i]
            pScoreLabA = cc.LabelAtlas:_create("+0123456789", "316_detail_add_score.png", 18, 24, string.byte("/"))
        else
            iGameScore = -self.m_ScoreData.lGameScore[i]
            pScoreLabA = cc.LabelAtlas:_create("-0123456789", "316_detail_lost_score.png", 18, 24, string.byte("/"))    
        end
        pScoreLabA:setAnchorPoint(cc.p(0.5, 0.5))
        pScoreLabA:setScale(scalex, scaley)
        pScoreLabA:setPosition((i * 160 - 10) * scalex, iTopLeftY - 325 * scaley)
        self.m_pScoreBack:addChild(pScoreLabA, 1)
        pScoreLabA:setString(string.format("/%d", iGameScore))

        if self.m_ScoreData.nXiaJiao[i] > 0 then
            local pYesJiao = cc.Sprite:createWithSpriteFrameName("316_detail_ting.png")
            pYesJiao:setScale(scalex, scaley)
            pYesJiao:setPosition(( i * 160 - 10) * scalex, iTopLeftY - 140 * scaley)
            self.m_pScoreBack:addChild(pYesJiao, 1)
        end

        if self.m_ScoreData.nHuFanShu[i] ~= 0 then
            local pHuType = nil
            local pFanNumber = nil
            local strHuType = ""
            local iHuFanShuPosX = 0

            if self.m_ScoreData.wChiHuUser == self.m_ScoreData.wProvideUser then

                if self.m_ScoreData.nHuFanShu[i] >= 0 then
                    iGameScore = self.m_ScoreData.nHuFanShu[i]
                    pFanNumber = cc.LabelAtlas:_create("+0123456789", "316_detail_chicken_add_score.png", 19, 27, string.byte("/"))
                    pHuType = cc.Sprite:createWithSpriteFrameName("316_detail_hutype_zm.png")
                    pHuType:setScale(scalex, scaley)
                    pHuType:setPosition((i * 160 - 30) * scalex, iTopLeftY - 185 * scaley)
                    self.m_pScoreBack:addChild(pHuType, 1)
                    iHuFanShuPosX = pHuType:getPositionX() + pHuType:getBoundingBox().width / 2 + 10 * scalex
                else
                    iGameScore = -self.m_ScoreData.nHuFanShu[i]
                    pFanNumber = cc.LabelAtlas:_create("-0123456789", "316_detail_lost_add_score.png", 19, 27, string.byte("/"))
                    iHuFanShuPosX = (130 + i * 160) * scalex
                end

            else

                if self.m_ScoreData.nHuFanShu[i] >= 0 then

                    iGameScore = self.m_ScoreData.nHuFanShu[i]
                    pFanNumber = cc.LabelAtlas:_create("+0123456789", "316_detail_chicken_add_score.png", 19, 27, string.byte("/"))
                    pHuType = cc.Sprite:createWithSpriteFrameName("316_detail_hutype_hp.png")
                    pHuType:setScale(scalex, scaley)
                    pHuType:setPosition((i * 160 - 30) * scalex, iTopLeftY - 185 * scaley)
                    self.m_pScoreBack:addChild(pHuType, 1)

                else
                    iGameScore = -self.m_ScoreData.nHuFanShu[i]
                    pFanNumber = cc.LabelAtlas:_create("-0123456789", "316_detail_chicken_lost_score.png", 19, 27, string.byte("/"))
                    pHuType = cc.Sprite:createWithSpriteFrameName("316_detail_hutype_dp.png")
                    pHuType:setScale(scalex, scaley)
                    pHuType:setPosition((i * 160 - 30) * scalex, iTopLeftY - 185 * scaley)
                    self.m_pScoreBack:addChild(pHuType, 1)
                end
                iHuFanShuPosX = pHuType:getPositionX() + pHuType:getBoundingBox().width / 2 + 10 * scalex
            end
            pFanNumber:setAnchorPoint(cc.p(0, 0.5))
            pFanNumber:setScale(scalex, scaley)
            pFanNumber:setPosition(iHuFanShuPosX, iTopLeftY - 185 * scaley)
            self.m_pScoreBack:addChild(pFanNumber, 1)
            pFanNumber:setString(string.format("/%d", iGameScore))
        end

        local pJiFenNumber = nil
        if self.m_ScoreData.nJiFan[i] * 3 + self.m_ScoreData.nJiFanLost[i] >= 0 then

            iGameScore = self.m_ScoreData.nJiFan[i] * 3 + self.m_ScoreData.nJiFanLost[i]
            if i == self.m_ScoreData.wChiHuUser then
                pJiFenNumber = cc.LabelAtlas:_create("+0123456789","316_detail_chicken_add_score.png", 19, 27, string.byte("/"))
            else
                pJiFenNumber = cc.LabelAtlas:_create("+0123456789", "316_detail_chicken_add_score.png", 19, 27, string.byte("/"))
            end
        else
            iGameScore = -(self.m_ScoreData.nJiFan[i] * 3 + self.m_ScoreData.nJiFanLost[i])
            if i == self.m_ScoreData.wChiHuUser then
                pJiFenNumber = cc.LabelAtlas:_create("-0123456789", "316_detail_chicken_lost_score.png", 19, 27, string.byte("/"))
            else
                pJiFenNumber = cc.LabelAtlas:_create("-0123456789", "316_detail_chicken_lost_score.png", 19, 27, string.byte("/"))
            end
        end

        pJiFenNumber:setAnchorPoint(cc.p(0.5, 0.5))
        pJiFenNumber:setScale(scalex, scaley)
        pJiFenNumber:setPosition((i * 160 - 10) * scalex, iTopLeftY - 230 * scaley)
        self.m_pScoreBack:addChild(pJiFenNumber, 1)
        pJiFenNumber:setString(string.format("/%d", iGameScore))

        if self.m_ScoreData.nMenDou[i] + self.m_ScoreData.nZhuanWanDou[i] + self.m_ScoreData.nDianDou[i] ~= 0 then
            local pDouNumber = nil
            if self.m_ScoreData.nMenDou[i] + self.m_ScoreData.nZhuanWanDou[i] + self.m_ScoreData.nDianDou[i] >= 0 then
                iGameScore = self.m_ScoreData.nMenDou[i] + self.m_ScoreData.nZhuanWanDou[i] + self.m_ScoreData.nDianDou[i]
                if i == self.m_ScoreData.wChiHuUser then
                    pDouNumber = cc.LabelAtlas:_create("+0123456789", "316_detail_chicken_add_score.png", 19, 27, string.byte("/"))
                else
                    pDouNumber = cc.LabelAtlas:_create("+0123456789", "316_detail_chicken_add_score.png", 19, 27, string.byte("/"))
                end
            else
                iGameScore = -(self.m_ScoreData.nMenDou[i] + self.m_ScoreData.nZhuanWanDou[i] + self.m_ScoreData.nDianDou[i])
                if i == self.m_ScoreData.wChiHuUser then
                    pDouNumber = cc.LabelAtlas:_create("-0123456789", "316_detail_chicken_lost_score.png", 19, 27, string.byte("/"))
                else
                    pDouNumber = cc.LabelAtlas:_create("-0123456789", "316_detail_chicken_lost_score.png", 19, 27, string.byte("/"))
                end
            end

            pDouNumber:setAnchorPoint(cc.p(0.5, 0.5))
            pDouNumber:setScale(scalex, scaley)
            pDouNumber:setPosition((i * 160 - 10) * scalex, iTopLeftY - 280 * scaley)
            self.m_pScoreBack:addChild(pDouNumber, 1)
            pDouNumber:setString(string.format("/%d", iGameScore))
        end
    end

    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(pBtClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end