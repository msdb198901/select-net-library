local ASMJ_RoomShareDialog = class("ASMJ_RoomShareDialog", function()
    return cc.Layer:create()
    end)

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--function OnClickEvent
function ASMJ_RoomShareDialog:OnClickEvent(clickcmd)
    print("ASMJ_RoomShareDialog:OnClickEvent " .. clickcmd:getnTag())

    -------------------------------------------------------
    
    -------------------------------------------------------

    if self.m_bDelay then
        return
    end

    if clickcmd:getnTag() == IDI_DialogWithTxt_Btn_OK then
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        local event = cc.EventCustom:new("OnDialogClickEvent")
        event.node = self
        event.clickevent = "ok"
        eventDispatcher:dispatchEvent(event) 

    elseif clickcmd:getnTag() == IDI_DialogWithTxt_Btn_CANCEL then
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        local event = cc.EventCustom:new("OnDialogClickEvent")
        event.node = self
        event.clickevent = "cancel"
        eventDispatcher:dispatchEvent(event) 

    else
        print("click tag unknow")
    end
end
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--init()
function ASMJ_RoomShareDialog:init(pngname_ok, pngname_cancel, btn_ok, btn_cancel, outsidedismiss)
    print("ASMJ_RoomShareDialog:init")

    --scale variable
    local m_visibleSize = cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape
    local m_scalemin = display.scalemin_landscape

    self:setPosition(m_visibleSize.width / 2, m_visibleSize.height / 2)

    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,100),m_visibleSize.width,m_visibleSize.height)
    self:addChild(layerColor,-1)

    self.m_bOutsideDismiss = outsidedismiss
    self.m_ListerOK = btn_ok
    self.m_ListerCancel = btn_cancel

    --background
    self.m_backGround = CSpriteEx:Create("316_gift_share_bg.png")
    self.m_backGround:setPosition(m_visibleSize.width / 2, m_visibleSize.height / 2)
    self:addChild(self.m_backGround,0)

    local status = -1
    if btn_ok == nil or btn_cancel == nil then
        status = 0
    else
        status = 1
    end

    --btn ok
    if btn_ok ~= nil then
        local normal = pngname_ok
        normal = normal .. "1.png"
        local clicked = pngname_ok
        clicked = clicked .. "0.png"

        local m_btOK = CImageButton:Create(normal, clicked, IDI_DialogWithTxt_Btn_OK)
        if status == 0 then
            m_btOK:setPosition(self.m_backGround:getContentSize().width / 2, m_btOK:getContentSize().height/2 + 5)
        else
            m_btOK:setPosition(self.m_backGround:getContentSize().width / 2 - m_btOK:getContentSize().width / 2 - 10, 
                m_btOK:getContentSize().height/2 + 5)
        end
        m_btOK:setScale(0.8)
        self.m_backGround:addChild(m_btOK,3)
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_btOK, "cc.Ref"), handler(self,self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)    
    end

    --btn cancel
    if btn_cancel ~= nil then
        local normal = pngname_cancel
        normal = normal .. "1.png"
        local clicked = pngname_cancel
        clicked = clicked .. "0.png"

        local m_btCANCLE = CImageButton:Create(normal, clicked, IDI_DialogWithTxt_Btn_CANCEL)
        if status == 0 then
            m_btCANCLE:setPosition(self.m_backGround:getContentSize().width / 2, m_btCANCLE:getContentSize().height/2 + 5)
        else
            m_btCANCLE:setPosition(self.m_backGround:getContentSize().width / 2 + m_btCANCLE:getContentSize().width / 2 + 10, 
                m_btCANCLE:getContentSize().height/2 + 5)
        end
        m_btCANCLE:setScale(0.8)
        self.m_backGround:addChild(m_btCANCLE,3)
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btn_cancel, "cc.Ref"), handler(self,self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    end

    self.m_backGround:setScale(0)
    self.m_backGround:runAction(cc.ScaleTo:create(0.2, m_scalex, m_scaley))

    -- touch function
    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        --function Dismiss
        local function Dismiss()
            --function OnKeyBackEvent
            local function OnKeyBackEvent()
                --function OnAcitonEnd
                local function OnAcitonEnd()
                    self:removeFromParent()
                end

                if self:isVisible() and self.m_bDelay == false then
                    self.m_bDelay = true
                    self.m_backGround:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25, 0), cc.CallFunc:create(OnAcitonEnd)))
                end
            end

            OnKeyBackEvent()
        end
        
        if self.m_bOutsideDismiss and self.m_bDelay == false then
            Dismiss()
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    
    return self
end

--onEnter()
function ASMJ_RoomShareDialog:onEnter()
    print("ASMJ_RoomShareDialog:onEnter")
end

--onExit()
function ASMJ_RoomShareDialog:onExit()
    print("ASMJ_RoomShareDialog:onExit")
end

--ctor()
function ASMJ_RoomShareDialog:ctor(pngname_ok, pngname_cancel, btn_ok, btn_cancel, outsidedismiss)
    print("ASMJ_RoomShareDialog:ctor")

    self.m_bOutsideDismiss = false
    self.m_bDelay = false
    self.m_ListerOK = nil
    self.m_ListerCancel = nil

    self:setIgnoreAnchorPointForPosition(false)

    self:init(pngname_ok, pngname_cancel, btn_ok, btn_cancel, outsidedismiss)

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
function ASMJ_RoomShareDialog.create(pngname_ok, pngname_cancel, btn_ok, btn_cancel, outsidedismiss)
    print("ASMJ_RoomShareDialog.create")
    local layer = ASMJ_RoomShareDialog.new(pngname_ok, pngname_cancel, btn_ok, btn_cancel, outsidedismiss)
    return layer
end

--[====[   ASMJ_RoomShareDialog_ShowDialog  ]====]
function ASMJ_RoomShareDialog_ShowDialog(pngname_ok, pngname_cancel, btn_ok, btn_cancel, outsidedismiss, parent)
    print("ASMJ_RoomShareDialog_ShowDialog")
    outsidedismiss = outsidedismiss or false
    parent = parent or nil

    local temp_layer = ASMJ_RoomShareDialog.create(pngname_ok, pngname_cancel, btn_ok, btn_cancel, outsidedismiss)
    if parent ~= nil then
        parent:addChild(temp_layer, 1000)
    else
        cc.Director:getInstance():getRunningScene():addChild(temp_layer, 1000)
    end

    return temp_layer
end
