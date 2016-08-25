local ASMJ_ServiceView = class("ASMJ_ServiceView", function() return cc.Layer:create() end )--ASMJ_SlipBaseView)

--function OnClickEvent
function ASMJ_ServiceView:OnClickEvent(clickcmd)
    print("ASMJ_ServiceView:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDI_BT_SLIP_CLOSE_316 then
        self.m_pSlipBaseLayer:onHide()
    end
end

--init()
function ASMJ_ServiceView:init(tex_bg)
    print("ASMJ_ServiceView:init")

    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape

    self.m_pSlipBaseLayer = ASMJ_SlipBaseView_createLayer(tex_bg, "316_service_bg.png")
    self.m_pSlipBaseLayer:setPosition(m_visibleSize.width/2, m_visibleSize.height/2)
    self:addChild(self.m_pSlipBaseLayer, -1)
    
    self.m_ptOrigin = cc.p(m_visibleSize.width/2, m_visibleSize.height*3/2)
    self.m_ptFinal = cc.p(m_visibleSize.width/2, m_visibleSize.height/2)

    local btClose = CImageButton:Create("316_slip_bt_close0.png", "316_slip_bt_close1.png", IDI_BT_SLIP_CLOSE_316)
    btClose:setPosition(996, 540)
    self.m_pSlipBaseLayer.m_functionBg:addChild(btClose, 10)

    local btTel = cc.Sprite:create("316_service_tel.png")
    btTel:setPosition(653, 320)
    self.m_pSlipBaseLayer.m_functionBg:addChild(btTel, 10)

    local btQQ = cc.Sprite:create("316_service_qq.png")
    btQQ:setPosition(653, 210)
    self.m_pSlipBaseLayer.m_functionBg:addChild(btQQ, 10)

    --ScriptHandlerMgr
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end

--ctor()
function ASMJ_ServiceView:ctor(tex_bg)
    print("ASMJ_ServiceView:ctor")

    self:init(tex_bg)

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
function ASMJ_ServiceView:onEnter()
    print("ASMJ_ServiceView:onEnter")
    --self.m_pSlipBaseLayer:onEnter()
end

--onExit()
function ASMJ_ServiceView:onExit()
    print("ASMJ_ServiceView:onExit")
    --self.m_pSlipBaseLayer:onExit()
end

--create( ... )
function ASMJ_ServiceView.create(tex_bg)
    print("ASMJ_ServiceView.create")
    local layer = ASMJ_ServiceView.new(tex_bg)
    return layer
end

--[====[   ASMJ_LoadingScene_createScene()  ]====]
function ASMJ_ServiceView_createScene(tex_bg)
    print("ASMJ_ServiceView_createScene")
    local scene = cc.Scene:create()
    scene:addChild(ASMJ_ServiceView.create(tex_bg), 0)
    return scene
end

--touch begin
function ASMJ_ServiceView:onTouchBegan(touch, event)
    return self.m_pSlipBaseLayer:onTouchBegan(touch, event)
end

--touch end
function ASMJ_ServiceView:onTouchEnded(touch, event)
    self.m_pSlipBaseLayer:onHide()
end