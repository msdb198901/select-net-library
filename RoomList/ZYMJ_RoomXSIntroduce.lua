local ASMJ_RoomXSIntroduce = class("ASMJ_RoomXSIntroduce", function() return cc.Layer:create() end)

-----------------------------------------function OnClickEvent-------------------
function ASMJ_RoomXSIntroduce:OnClickEvent(clickcmd)
    print("ASMJ_RoomXSIntroduce:OnClickEvent " .. clickcmd:getnTag())

    if clickcmd:getnTag() == IDI_BT_ROOM_ENTER_316 then
        local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()--CClientKernel:GetInstance():GetMyUserData()
        if MyUserData and MyUserData:GetUserStatus() ~= US_PLAYING then
            -- ready
            CClientKernel:GetInstance():ResetBuffers()
            CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_FRAME, SUB_GF_USER_READY)

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
            --self:removeFromParent()
        end
    elseif clickcmd:getnTag() == IDI_BT_ROOM_RETURN_316 then
        local ani1 = cc.MoveBy:create(0.1, cc.p(0, -20))
        local ani2 = cc.MoveBy:create(0.1, cc.p(0, 20))
        local cal1 = cc.CallFunc:create(handler(self, self.OnKeyBackEvent))
        self.m_btReturn:runAction(cc.Sequence:create(ani1, ani2, cal1))
    end
end

--init()
function ASMJ_RoomXSIntroduce:init()
    print("ASMJ_RoomXSIntroduce:init")
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
    
    -- room indrouce bg
    self.m_roomIntroduceBg = cc.Sprite:create("316_room_information_1.png")
    self.m_roomIntroduceBg:setPosition(285, 209)
    self.m_pBoard:addChild(self.m_roomIntroduceBg)

    self.m_roomTitle = cc.Sprite:create("316_room_title_name_1.png")
    self.m_roomTitle:setPosition(281, 344)
    self.m_pBoard:addChild(self.m_roomTitle, 1)

    -- bt enter
    local m_btEnter = CImageButton:Create("316_room_btn_enter_0.png", "316_room_btn_enter_1.png", IDI_BT_ROOM_ENTER_316)
    m_btEnter:setPosition(293, 93)
    self.m_pBoard:addChild(m_btEnter, 1)
    
    self.m_btReturn = CImageButton:Create("316_room_return.png", "316_room_return.png", IDI_BT_ROOM_RETURN_316)
    self.m_btReturn:setPosition(538, 275)
    self.m_pBoard:addChild(self.m_btReturn, -1)

    -- setscale
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
function ASMJ_RoomXSIntroduce:ctor()
    print("ASMJ_RoomXSIntroduce:ctor")
    self:init()
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
function ASMJ_RoomXSIntroduce_create()
    print("ASMJ_RoomXSIntroduce_create")
    local layer = ASMJ_RoomXSIntroduce.new()
    return layer
end

--onEnter()
function ASMJ_RoomXSIntroduce:onEnter()
    cclog("ASMJ_RoomXSIntroduce:onEnter")
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--onExit()
function ASMJ_RoomXSIntroduce:onExit()
    cclog("ASMJ_RoomXSIntroduce:onExit")
end

--touch begin
function ASMJ_RoomXSIntroduce:onTouchBegan(touch, event)
    local size = self.m_pBoard:getBoundingBox()
    local m_bTouched = cc.rectContainsPoint(size, touch:getLocation())
    if not m_bTouched then
       self:OnKeyBackEvent()
    end
    return true
end

--touch end
function ASMJ_RoomXSIntroduce:onTouchEnded(touch, event)

end

--OnKeyBackEvent
function ASMJ_RoomXSIntroduce:OnKeyBackEvent()
    local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()
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
