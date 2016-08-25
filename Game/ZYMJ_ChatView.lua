
local ASMJ_ChatView = class("ASMJ_ChatView", function() return cc.Layer:create() end)

function ASMJ_ChatView:OnClickEvent(clickcmd)
    print("ASMJ_ChatView:OnClickEvent " .. clickcmd:getnTag())

    if not self.m_bEnable then
        return
    end
    self.m_bEnable = false

    if clickcmd:getnTag() == TAG_BT_IRR_ID_CANCEL_316 then
        self:onAcitonEnd()
        return
    end

    if clickcmd:getnTag() < TAG_BT_IRR_ID_0_316 or clickcmd:getnTag() > TAG_BT_IRR_ID_0_316 + GAME_PLAYER_316 - 1 then
        return 
    end

    local iTag = clickcmd:getnTag() - TAG_BT_IRR_ID_0_316 + 1
    local szChatFile = string.format("PY00%d.png", iTag)
   
    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteWORDToBuffers(32)
    CClientKernel:GetInstance():WriteDWORDToBuffers(0)
    CClientKernel:GetInstance():WriteDWORDToBuffers(0)
    CClientKernel:GetInstance():WritecharToBuffers(szChatFile,32,false)
    CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_FRAME, SUB_GF_USER_CHAT)
    
    self:onAcitonEnd()
end

--ctor()
function ASMJ_ChatView:ctor()
    print("ASMJ_ChatView:ctor")

    self.m_bEnable = false
    self:init()

end

--create( ... )
function ASMJ_ChatView_create()
    print("ASMJ_ChatView_create")
    local layer = ASMJ_ChatView.new()
    return layer
end

--onEnter()
function ASMJ_ChatView:onEnter()
    
    print("ASMJ_ChatView:onEnter")
    -- touch
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--onExit()
function ASMJ_ChatView:onExit()
    print("ASMJ_ChatView:onExit")
end

--touch begin
function ASMJ_ChatView:onTouchBegan(touch, event)
    local bIrrRegular = {}

    local pIrrRegular = nil
    for i=1,4 do
        pIrrRegular = self:getChildByTag(TAG_BT_IRR_ID_0_316+i-1)
        bIrrRegular[i] = not pIrrRegular:onTouchBegan(touch, event)
    end

    return bIrrRegular[1] and bIrrRegular[2] and bIrrRegular[3] and bIrrRegular[4] 
end

--touch end
function ASMJ_ChatView:onTouchEnded(touch, event)
    self:onAcitonEnd()
end

function ASMJ_ChatView:onAcitonEnd()

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    m_scalex = display.scalex_landscape
    m_scaley = display.scaley_landscape

    local pIrrRegular = nil
    for i=0,3 do
        pIrrRegular = self:getChildByTag(TAG_BT_IRR_ID_0_316+i)
        if pIrrRegular ~= nil then
            pIrrRegular:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.5,cc.p(visibleSize.width/2, 355 * m_scaley)),
                cc.FadeOut:create(0.3)
                )
            )
        end
    end

    local pIrrRegularCancel = self:getChildByTag(TAG_BT_IRR_ID_CANCEL_316)
    if pIrrRegularCancel ~= nil then
        pIrrRegularCancel:runAction(cc.Sequence:create(
            cc.FadeOut:create(0.9), 
            cc.CallFunc:create(function () self:removeFromParent() end)
            )
        )
    end
end

--init()
function ASMJ_ChatView:init()
    print("ASMJ_ChatView:init")

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    m_scalex = display.scalex_landscape
    m_scaley = display.scaley_landscape

    local tmpMove = cc.p(0,0)
    local szIrrFile0 = ""
    local szIrrFile1 = ""

    for i=0,3 do
        szIrrFile0 = string.format("316_chat_bt_%d_0.png", i)
        szIrrFile1 = string.format("316_chat_bt_%d_1.png", i)
        local pIrrRegular = IrrRegularButton:Create(szIrrFile0, szIrrFile1, TAG_BT_IRR_ID_0_316 + i)
        pIrrRegular:SetImageFile(szIrrFile0)
        pIrrRegular:setScale(m_scalex, m_scaley)

        if i == 0 then
            tmpMove = cc.p(0, 20*m_scaley)
            pIrrRegular:setAnchorPoint(cc.p(0.5, 0))
        elseif i == 1 then
            tmpMove = cc.p(-20*m_scalex, 0)
            pIrrRegular:setAnchorPoint(cc.p(1, 0.5))
        elseif i == 2 then
            tmpMove = cc.p(0, -20*m_scaley)
            pIrrRegular:setAnchorPoint(cc.p(0.5, 1))
        elseif i == 3 then
            tmpMove = cc.p(20*m_scalex, 0)
            pIrrRegular:setAnchorPoint(cc.p(0, 0.5))
        end

        pIrrRegular:setPosition(visibleSize.width/2, 355 * m_scaley)
        pIrrRegular:setOpacity(0)
        self:addChild(pIrrRegular, 1)
        pIrrRegular:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.MoveBy:create(0.5,tmpMove)))

        -- ScriptHandlerMgr
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(pIrrRegular, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    end

    local pIrrRegularCancel = IrrRegularButton:Create("316_chat_bt_cancel0.png", "316_chat_bt_cancel1.png", TAG_BT_IRR_ID_CANCEL_316)
    pIrrRegularCancel:setScale(m_scalex, m_scaley)
    pIrrRegularCancel:SetImageFile("316_chat_bt_cancel0.png")
    pIrrRegularCancel:setPosition(visibleSize.width/2, 355 * m_scaley)
    pIrrRegularCancel:setOpacity(0)
    self:addChild(pIrrRegularCancel, 2)
    pIrrRegularCancel:runAction(cc.Sequence:create(cc.FadeIn:create(0.8), cc.CallFunc:create(function () self.m_bEnable = true end)))

    -- ScriptHandlerMgr
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(pIrrRegularCancel, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end
