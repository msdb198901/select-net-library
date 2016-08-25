ASMJ_SlipBaseView = class("ASMJ_SlipBaseView", function() return cc.Layer:create() end)

--keyback event
function ASMJ_SlipBaseView:OnKeyBackEvent() 
    local visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape
    self.m_functionBg:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(visibleSize.width / 2, -110*m_scaley)), cc.CallFunc:create(function () self:removeFromParent() end))) 
end

--init()
function ASMJ_SlipBaseView:init(tex_bg, file_board)
    print("ASMJ_SlipBaseView:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape
    
    self.m_ptOrigin = cc.p(m_visibleSize.width/2, m_visibleSize.height*3/2)
    self.m_ptFinal = cc.p(m_visibleSize.width/2, m_visibleSize.height/2)

    local sp_bg = cc.Sprite:createWithTexture(tex_bg)
    sp_bg:setPosition(m_visibleSize.width/2, m_visibleSize.height/2)
    sp_bg:setFlippedY(true)
    self:addChild(sp_bg, -5)

    --layer color 
    local m_layerColor = cc.LayerColor:create(cc.c4b(0,0,0,150),m_visibleSize.width,m_visibleSize.height)
    self:addChild(m_layerColor, -4)

    --background
    self.m_functionBg = CSpriteEx:Create(file_board)
    self.m_functionBg:setScale(m_scalex,m_scaley)
    self.m_functionBg:setPosition(self.m_ptOrigin)
    self:addChild(self.m_functionBg, 1)

    --bg runing
    self:onShow()
end

--onShow()
function ASMJ_SlipBaseView:onShow()
    self.m_functionBg:setPosition(self.m_ptOrigin)
    local ani1 = cc.MoveTo:create(0.2, cc.p(self.m_ptFinal.x, self.m_ptFinal.y - 30))
    local ani2 = cc.MoveTo:create(0.07, cc.p(self.m_ptFinal.x, self.m_ptFinal.y + 20))
    local ani3 = cc.MoveTo:create(0.07, self.m_ptFinal)
    local seq = cc.Sequence:create(ani1, ani2, ani3)
    self.m_functionBg:runAction(seq)
end

--onHide()
function ASMJ_SlipBaseView:onHide()
    self.m_functionBg:setPosition(self.m_ptFinal)
    local ani1 = cc.MoveTo:create(0.07, cc.p(self.m_ptFinal.x, self.m_ptFinal.y + 20))
    local ani2 = cc.MoveTo:create(0.07, cc.p(self.m_ptFinal.x, self.m_ptFinal.y - 30))
    local ani3 = cc.MoveTo:create(0.2, self.m_ptOrigin)
    local seq = cc.Sequence:create(ani1, ani2, ani3, cc.CallFunc:create(function () cc.Director:getInstance():popScene() end))
    self.m_functionBg:runAction(seq)
end

--ctor()
function ASMJ_SlipBaseView:ctor(tex_bg, file_board)
    print("ASMJ_SlipBaseView:ctor")

    self:setIgnoreAnchorPointForPosition(false)

    self:init(tex_bg, file_board)

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

--onEnter()
function ASMJ_SlipBaseView:onEnter()
    print("ASMJ_SlipBaseView:onEnter")

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--onExit()
function ASMJ_SlipBaseView:onExit()
    print("ASMJ_SlipBaseView:onExit")
end

--create( ... )
function ASMJ_SlipBaseView_createLayer(tex_bg, file_board)
    cclog("ASMJ_SlipBaseView_createLayer")
    local layer = ASMJ_SlipBaseView.new(tex_bg, file_board)
    return layer
end

--touch begin
function ASMJ_SlipBaseView:onTouchBegan(touch, event)

    if self:isVisible() then
        return false
    end
    return true

end

--touch end
function ASMJ_SlipBaseView:onTouchEnded(touch, event)
    self:onHide()
end