require "src/app/Game/AnShunMaJiang/Game/ASMJ_ExperienceControl"
require "src/app/Game/AnShunMaJiang/Game/ASMJ_ReportDialog"


local ASMJ_AvatarView = class("ASMJ_AvatarView", function() return cc.Layer:create() end)

function ASMJ_AvatarView:OnClickEvent(clickcmd)
    print("ASMJ_AvatarView:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() > TAG_BT_REPORT_CHAT_316 and clickcmd:getnTag() <= TAG_BT_REPORT_CHAT_316 + 4 then
        
        local dialog = ASMJ_ReportDialog_ShowDialog(nil, nil, "316_dialog_bt_report_ok", "316_dialog_bt_report_cancle", self, self, true)    
        dialog:setTag(TAG_DIALOG_REPORT_RESULT_316 + clickcmd:getnTag() - TAG_BT_REPORT_CHAT_316) 

    else
        print("click tag unknow")
    end
end

--ctor()
function ASMJ_AvatarView:ctor(ViewChairID)
    print("ASMJ_AvatarView:ctor")
    self:setIgnoreAnchorPointForPosition(false)

    self:init(ViewChairID)
   
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
function ASMJ_AvatarView_create(ViewChairID)
    print("ASMJ_AvatarView_create")
    local layer = ASMJ_AvatarView.new(ViewChairID)
    return layer
end

--onEnter()
function ASMJ_AvatarView:onEnter()
    
    print("ASMJ_AvatarView:onEnter")
    -- touch
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--onExit()
function ASMJ_AvatarView:onExit()
    print("ASMJ_AvatarView:onExit")
end

--touch begin
function ASMJ_AvatarView:onTouchBegan(touch, event)
    return not self.m_AvatarBg:onTouchBegan(touch, event)
end

--touch end
function ASMJ_AvatarView:onTouchEnded(touch, event)
    self:onAcitonEnd()
end

function ASMJ_AvatarView:onAcitonEnd()
    self.m_AvatarBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 0), cc.CallFunc:create(function  ()
        self:removeFromParent()
    end)))
end

--init()
function ASMJ_AvatarView:init(ViewChairID)
    print("ASMJ_AvatarView:init")

    local scalex = display.scalex_landscape
    local scaley = display.scaley_landscape

    local Visible = cc.Director:getInstance():getVisibleSize()
    self.m_AvatarBg = CSpriteEx:CreateWithSpriteFrameName("316_detail_avatar_bg.png")
    self.m_AvatarBg:setScale(0)

    local size = self.m_AvatarBg:getContentSize()
    self:setContentSize(size)
    self:setPosition(size.width/2, size.height/2)
    
    if ViewChairID == 1 then
        self:setPosition((320 + self.m_AvatarBg:getContentSize().width / 2)*scalex, Visible.height - (80 + self.m_AvatarBg:getContentSize().height / 2)*scaley)
    elseif ViewChairID == 2 then
        self:setPosition((115 + self.m_AvatarBg:getContentSize().width / 2)*scalex, Visible.height / 2)
    elseif ViewChairID == 3 then
        self:setPosition((150 + self.m_AvatarBg:getContentSize().width / 2)*scalex, (150 + self.m_AvatarBg:getContentSize().height / 2) * scaley)
    elseif ViewChairID == 4 then
        self:setPosition(Visible.width - (115 + self.m_AvatarBg:getContentSize().width / 2) * scalex, Visible.height / 2)
    end
    self.m_AvatarBg:setPosition(size.width/2, size.height/2)
    self:addChild(self.m_AvatarBg, -1)

    local iTopX = 0
    local iTopY = size.height - 35 * scaley

    local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
    if iRoomType == ERT_GJ_316 then
        local pBtReport = CImageButton:Create("316_report_bt0.png", "316_report_bt1.png", TAG_BT_REPORT_CHAT_316 + ViewChairID)
        pBtReport:setPosition(70, 30)
        self.m_AvatarBg:addChild(pBtReport, 5)
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(pBtReport, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    end
   
    local pIClientUserItem = ASMJ_MyUserItem:GetInstance():GetClientUserItem(ViewChairID)
    if pIClientUserItem ~= nil then
        
        local szInfo = ""
        if pIClientUserItem.cbGender == GENDER_MANKIND then
            local iFaceID = pIClientUserItem.wFaceID
            if (iFaceID >= 0 and iFaceID <= 3) or (iFaceID >= 100 and iFaceID <= 113) then
                szInfo = string.format("316_detail_face_%d.png", iFaceID)
            else
                szInfo = string.format("316_detail_face_%d.png", 0)
            end
        else
            local iFaceID = pIClientUserItem.wFaceID
            if (iFaceID >= 50 and iFaceID <= 53) or (iFaceID >= 150 and iFaceID <= 163) then
                szInfo = string.format("316_detail_face_%d.png", iFaceID)
            else
                szInfo = string.format("316_detail_face_%d.png", 50)
            end
        end

        local pFace = cc.Sprite:createWithSpriteFrameName(szInfo)
        pFace:setScale(scalex, scaley)
        pFace:setPosition(iTopX + 70 * scalex, iTopY - 50 * scaley)
        self.m_AvatarBg:addChild(pFace, 1)

        local pAvaterName = cc.Sprite:createWithSpriteFrameName("316_detail_avatar_name.png")
        pAvaterName:setScale(scalex, scaley)
        pAvaterName:setAnchorPoint(cc.p(0, 0.5))
        pAvaterName:setPosition(iTopX + 135 * scalex, iTopY)
        self.m_AvatarBg:addChild(pAvaterName, 1)

        local ttfConfig = {}
        ttfConfig.fontFilePath = "default.ttf"
        ttfConfig.fontSize     = 20
        pNickNameLabe = cc.Label:createWithTTF(ttfConfig, CUtilEx:subStringWithFormatStrWidth(pIClientUserItem ~= nil and pIClientUserItem.szNickName or "", 150, 20, scalex, scaley))
        pNickNameLabe:setScale(scalex, scaley)
        pNickNameLabe:setAnchorPoint(cc.p(0, 0.5))
        pNickNameLabe._eHorizAlign = cc.TEXT_ALIGNMENT_LEFT
        pNickNameLabe._eVertAlign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
        pNickNameLabe:setPosition(pAvaterName:getPositionX() + pAvaterName:getBoundingBox().width + 10 * scalex, iTopY) 
        pNickNameLabe:setColor(cc.c3b(10, 10, 10))
        self.m_AvatarBg:addChild(pNickNameLabe, 1) 

        iTopY = iTopY - 35 * scaley
        local pScoreIcon = nil
        local pTexture2D = cc.Director:getInstance():getTextureCache():addImage("316_icon.png")
        local w = pTexture2D:getContentSize().width / 5
        local h = pTexture2D:getContentSize().height

        if iRoomType < ERT_FL_316  then
            pScoreIcon = cc.Sprite:createWithTexture(pTexture2D, cc.rect(0 * w, 0, w, h))
            pScoreIcon:setScale(scalex, scaley)
            pScoreIcon:setAnchorPoint(cc.p(0, 0.5))
            pScoreIcon:setPosition(iTopX + 135 * scalex, iTopY)
            self.m_AvatarBg:addChild(pScoreIcon, 1)
        else
            pScoreIcon = cc.Sprite:createWithTexture(pTexture2D, cc.rect(2 * w, 0, w, h))
            pScoreIcon:setScale(scalex, scaley)
            pScoreIcon:setAnchorPoint(cc.p(0, 0.5))
            pScoreIcon:setPosition(iTopX + 135 * scalex, iTopY)
            self.m_AvatarBg:addChild(pScoreIcon, 1)
        end

        local pScoreLabe =  cc.Label:createWithTTF(ttfConfig, CUtilEx:subStringWithFormatNumCount(pIClientUserItem.lScore, 8, "...")) 
        pScoreLabe:setScale(scalex, scaley)
        pScoreLabe:setAnchorPoint(cc.p(0, 0.5))
        pScoreLabe:setColor(cc.c3b(10, 10, 10))
        pScoreLabe:setPosition(pScoreIcon:getPositionX() + pScoreIcon:getBoundingBox().width + 10 * scalex, iTopY)
        pScoreLabe._eHorizAlign = cc.TEXT_ALIGNMENT_LEFT
        pScoreLabe._eVertAlign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
        self.m_AvatarBg:addChild(pScoreLabe, 1)

        
        iTopY = iTopY - 35 * scaley
        if iRoomType < ERT_FL_316 then
            local pAvaterExp = cc.Sprite:createWithSpriteFrameName("316_detail_avatar_lv.png")
            pAvaterExp:setScale(scalex, scaley)
            pAvaterExp:setAnchorPoint(cc.p(0, 0.5))
            pAvaterExp:setPosition(iTopX + 135 * scalex, iTopY)
            self.m_AvatarBg:addChild(pAvaterExp, 1)

            szInfo = string.format("%d%s", ASMJ_ExperienceLogic:GetInstance():ExpToLevel(pIClientUserItem.dwExperience), CUtilEx:getString("316_exp_Ji"))

            local pExprienceLabe = cc.Label:createWithTTF(ttfConfig, szInfo)  --cc.LabelTTF:create(szInfo, "Arial", 20)
            pExprienceLabe:setScale(scalex, scaley)
            pExprienceLabe:setAnchorPoint(cc.p(0, 0.5))
            pExprienceLabe:setPosition(pAvaterExp:getPositionX() + pAvaterExp:getBoundingBox().width + 10 * scalex, iTopY)
            pExprienceLabe:setColor(cc.c3b(4, 122, 151))
            pExprienceLabe._eHorizAlign = cc.TEXT_ALIGNMENT_LEFT
            pExprienceLabe._eVertAlign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
            self.m_AvatarBg:addChild(pExprienceLabe, 1)

        else
            local pAvaterRank = cc.Sprite:createWithTexture(pTexture2D, cc.rect(4 * w, 0, w, h))
            pAvaterRank:setScale(scalex, scaley)
            pAvaterRank:setAnchorPoint(cc.p(0, 0.5))
            pAvaterRank:setPosition(iTopX + 135 * scalex, iTopY)
            self.m_AvatarBg:addChild(pAvaterRank, 1)

            local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()
            if pMatchAttribute ~= nil then

                local dwUserID = pIClientUserItem.dwUserID
                if dwUserID == ASMJ_MyUserItem:GetInstance():GetChairID() then
                    szInfo = string.format("%d/%d", pMatchAttribute.dwCurRank, pMatchAttribute.dwTotalCount)
                else
                    for i=1,GAME_PLAYER_316 do
                        if pMatchAttribute.dwUserIDArry[i] == dwUserID then
                            szInfo = string.format("%d/%d", pMatchAttribute.dwOtherCurRank[i], pMatchAttribute.dwTotalCount)
                        end
                    end
                end

                local pExprience = cc.Label:createWithTTF(ttfConfig, szInfo) --cc.LabelTTF:create(szInfo, "Arial", 20)
                pExprience:setScale(scalex, scaley)
                pExprience:setPosition(iTopX + 115 * scalex, iTopY - 5 * scaley)
                pExprience:setDimensions(cc.size(150, 30))
                pExprience._eHorizAlign = cc.TEXT_ALIGNMENT_LEFT
                pExprience._eVertAlign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
                pExprience:setColor(cc.c3b(4, 122, 151))
                pExprience:setAnchorPoint(cc.p(0, 0.5))
                self.m_AvatarBg:addChild(pExprience, 1)
            end
        end

        if pIClientUserItem.cbMemberOrder > 0 then

            iTopY = iTopY - 35 * scaley

            local pAvaterVip = cc.Sprite:createWithSpriteFrameName("316_detail_avatar_vip.png")
            pAvaterVip:setScale(scalex, scaley)
            pAvaterVip:setAnchorPoint(cc.p(0, 0.5))
            pAvaterVip:setPosition(iTopX + 135 * scalex, iTopY)
            self.m_AvatarBg:addChild(pAvaterVip, 1)

            local pVIPLab = cc.LabelAtlas:_create(string.format("%d", pIClientUserItem.cbMemberOrder), "316_avatar_vip_number.png", 16, 22, string.byte("0"))
            pVIPLab:setScale(scalex, scaley)
            pVIPLab:setAnchorPoint(cc.p(0, 0.5))
            pVIPLab:setPosition(pAvaterVip:getPositionX() + pAvaterVip:getBoundingBox().width / 2 + 20 * scalex, iTopY)
            self.m_AvatarBg:addChild(pVIPLab, 1)
        end
    end

    self.m_AvatarBg:runAction(cc.ScaleTo:create(0.3, scalex, scaley))
end
