local ASMJ_FaceChoice = class("ASMJ_FaceChoice", function() return cc.Layer:create() end)

--function OnClickEvent
function ASMJ_FaceChoice:OnClickEvent(clickcmd)
    cclog("ASMJ_FaceChoice:OnClickEvent " .. clickcmd:getnTag())
    local iTag = clickcmd:getnTag()
    local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    local isVip = MyUserData.isVip

    if iTag >= 100 and (not isVip) then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_face_choice_not_member"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    if iTag >= 100 and isVip then
        if MyUserData ~= nil then
            local tmMember = {year=MyUserData:GetMemberOverDate().wYear, month=MyUserData:GetMemberOverDate().wMonth, day=MyUserData:GetMemberOverDate().wDay, hour=0, min=0, sec=0, isdst=false}
            local sMemeber = os.time(tmMember)
            local sTM = os.time()
            if sMemeber < sTM then
                local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_face_choice_member_timelimit"), "316_popup_ok", nil, self, nil, true)    
                dialog:setTag(IDI_POPUP_OK_316)
                return 
            end
        end
    end

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteWORDToBuffers(iTag)
    CClientKernel:GetInstance():WriteDWORDToBuffers(MyUserData:GetUserID())
    CClientKernel:GetInstance():WritecharToBuffers(ASMJ_MyUserItem:GetInstance():GetPassword(),33,true)
    CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)
    CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_SYSTEM_FACE_INFO)
end

--init()
function ASMJ_FaceChoice:init()
    cclog("ASMJ_FaceChoice:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape
    self:setPosition(m_visibleSize.width / 2, m_visibleSize.height / 2)

    --layer color 
    self.m_layerColor = cc.LayerColor:create(cc.c4b(0,0,0,100),m_visibleSize.width,m_visibleSize.height)
    self:addChild(self.m_layerColor, -1)

    --choice bg
    self.m_choiceBg = CSpriteEx:Create("316_GRZX_FACE_CHOICE_BG.png")
    self.m_choiceBg:setPosition(m_visibleSize.width/2 + 125*m_scalex,m_visibleSize.height/2)
    self:addChild(self.m_choiceBg, 0)

    --mftx sprite
    local m_mftxImg = cc.Sprite:create("316_GRZX_FACE_CHOICE_MFTX.png")
    m_mftxImg:setPosition(m_mftxImg:getContentSize().width/2 + 30,self.m_choiceBg:getContentSize().height - m_mftxImg:getContentSize().height/2 - 20)
    self.m_choiceBg:addChild(m_mftxImg,1)
    
    --hytx sprite
    local m_hytxImg = cc.Sprite:create("316_GRZX_FACE_CHOICE_HYTX.png")
    m_hytxImg:setPosition(m_hytxImg:getContentSize().width / 2 + 30,self.m_choiceBg:getContentSize().height - m_hytxImg:getContentSize().height / 2 - 160)
    self.m_choiceBg:addChild(m_hytxImg,1)

    --user face
    local iFaceNormalCount = 3
    local iFaceMemberCount = 13
    local iFaceID = 0
    local m_choiceFaceNormal = {}
    local m_choiceFaceMember = {}

    local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData() --CClientKernel:GetInstance():GetMyUserData()
    if MyUserData:GetGender() == 1 then
        for i=0,iFaceNormalCount do
            local choiceFaceNormal = CSpriteEx:CreateWithSpriteFrameName(string.format("0_head_%d.png", i), i)
            local posx = choiceFaceNormal:getContentSize().width / 2 + 40 + (i % 6) * choiceFaceNormal:getContentSize().width + (i % 6) * 10
            local posy = self.m_choiceBg:getContentSize().height - 50 - choiceFaceNormal:getContentSize().height / 2
            choiceFaceNormal:setPosition(cc.p(posx, posy))
            self.m_choiceBg:addChild(choiceFaceNormal, 2)

            table.insert(m_choiceFaceNormal, choiceFaceNormal) 
        end

        for i=0,iFaceMemberCount do
            local choiceFaceMember = CSpriteEx:CreateWithSpriteFrameName(string.format("0_head_%d.png", i+100), i+100)
            local posx = choiceFaceMember:getContentSize().width / 2 + 40 + (i % 6) * choiceFaceMember:getContentSize().width + (i % 6) * 10
            local posy = self.m_choiceBg:getContentSize().height - 190 - choiceFaceMember:getContentSize().height / 2 - math.floor(i / 6) * (choiceFaceMember:getContentSize().height + 5)
            choiceFaceMember:setPosition(cc.p(posx, posy))
            self.m_choiceBg:addChild(choiceFaceMember, 2)

            table.insert(m_choiceFaceMember, choiceFaceMember) 
        end

    elseif MyUserData:GetGender() == 0 then
        for i=0,iFaceNormalCount do
            local choiceFaceNormal = CSpriteEx:CreateWithSpriteFrameName(string.format("0_head_%d.png", i+50), i+50)
            local posx = choiceFaceNormal:getContentSize().width / 2 + 40 + (i % 6) * choiceFaceNormal:getContentSize().width + (i % 6) * 10
            local posy = self.m_choiceBg:getContentSize().height - 50 - choiceFaceNormal:getContentSize().height / 2
            choiceFaceNormal:setPosition(cc.p(posx, posy))
            self.m_choiceBg:addChild(choiceFaceNormal, 2)

            table.insert(m_choiceFaceNormal, choiceFaceNormal) 
        end

        for i=0,iFaceMemberCount do
            local choiceFaceMember = CSpriteEx:CreateWithSpriteFrameName(string.format("0_head_%d.png", i+150), i+150)
            local posx = choiceFaceMember:getContentSize().width / 2 + 40 + (i % 6) * choiceFaceMember:getContentSize().width + (i % 6) * 10
            local posy = self.m_choiceBg:getContentSize().height - 190 - choiceFaceMember:getContentSize().height / 2 - math.floor(i / 6) * (choiceFaceMember:getContentSize().height + 5)
            choiceFaceMember:setPosition(cc.p(posx, posy))
            self.m_choiceBg:addChild(choiceFaceMember, 2)

            table.insert(m_choiceFaceMember, choiceFaceMember) 
        end
    else
        cclog("%d", MyUserData:GetGender())
    end

    --runing bg
    self.m_choiceBg:setScale(0.1)
    self.m_choiceBg:runAction(cc.ScaleTo:create(0.25, m_scalex, m_scaley))

    --ScriptHandlerMgr
    for i = 1, #m_choiceFaceNormal do     
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_choiceFaceNormal[i] , "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    end 

    for i = 1, #m_choiceFaceMember do     
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_choiceFaceMember[i] , "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    end 
end

--ctor()
function ASMJ_FaceChoice:ctor()
    cclog("ASMJ_FaceChoice:ctor")

    self:setIgnoreAnchorPointForPosition(false)

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

--touch begin
function ASMJ_FaceChoice:onTouchBegan(touch, event)
    print("ASMJ_FaceChoice:onTouchBegan")
    return self.m_choiceBg:onTouchBegan(touch, event)
end

--touch end
function ASMJ_FaceChoice:onTouchEnded(touch, event)
    print("ASMJ_FaceChoice:onTouchEnded")
    self:OnKeyBackEvent()
    return self.m_choiceBg:onTouchEnded(touch, event)
end


--onEnter()
function ASMJ_FaceChoice:onEnter()
    cclog("ASMJ_FaceChoice:onEnter")

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--onExit()
function ASMJ_FaceChoice:onExit()
    cclog("ASMJ_FaceChoice:onExit")
end

--keyback event
function ASMJ_FaceChoice:OnKeyBackEvent() 
    local visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape
    self.m_choiceBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25, 0), cc.CallFunc:create(function () self:removeFromParent() end)))
end

--create( ... )
function ASMJ_FaceChoice_createLayer( ... )
    cclog("ASMJ_FaceChoice_createLayer")
    local layer = ASMJ_FaceChoice.new()
    return layer
end
