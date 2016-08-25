local ASMJ_OptionSet = class("ASMJ_OptionSet", function() return cc.Layer:create() end)

function ASMJ_OptionSet:OnClickEvent(clickcmd)
    print("ASMJ_OptionSet:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDI_BT_OPTION_MUSIC_316  then

        local bShow = not cc.UserDefault:getInstance():getBoolForKey("316_BackMusic", true)
        cc.UserDefault:getInstance():setBoolForKey("316_BackMusic", bShow)
        cc.UserDefault:getInstance():flush()

        if bShow then
            ccexp.AudioEngine:play2d("316_background.MP3", true, 0.3)
            self.m_btMusicOpen:setVisible(true)
            self.m_btMusicClose:setVisible(false)
        else
            ccexp.AudioEngine:stopAll()

            self.m_btMusicOpen:setVisible(false)
            self.m_btMusicClose:setVisible(true)
        end

    elseif clickcmd:getnTag() == IDI_BT_OPTION_EFFECT_316 then

        local bShow = not cc.UserDefault:getInstance():getBoolForKey("316_GameMusic", true)
        cc.UserDefault:getInstance():setBoolForKey("316_GameMusic", bShow)
        cc.UserDefault:getInstance():flush()

        if bShow then
            self.m_btEffectOpen:setVisible(true)
            self.m_btEffectClose:setVisible(false)
        else 
            self.m_btEffectOpen:setVisible(false)
            self.m_btEffectClose:setVisible(true)
        end

    elseif clickcmd:getnTag() == IDI_BT_OPTION_EXIT_316 then

        ccexp.AudioEngine:stopAll()

        self:onAcitonEnd()

        CClientKernel:GetInstance():CloseRoomThread()

        local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()

        local reScene = ASMJ_LobbyListScene_createScene(iRoomType)
        if reScene then
            cc.Director:getInstance():replaceScene( cc.TransitionSlideInR:create(TIME_SCENE_CHANGE, reScene) )
        end
    else
        print("click tag unknow")
    end
end

--ctor()
function ASMJ_OptionSet:ctor()
    print("ASMJ_OptionSet:ctor")
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
function ASMJ_OptionSet_create()
    print("ASMJ_OptionSet_create")
    local layer = ASMJ_OptionSet.new()
    return layer
end

--onEnter()
function ASMJ_OptionSet:onEnter()
    
    print("ASMJ_OptionSet:onEnter")
    -- touch
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--onExit()
function ASMJ_OptionSet:onExit()
    print("ASMJ_OptionSet:onExit")
end

--touch begin
function ASMJ_OptionSet:onTouchBegan(touch, event)
    return self.m_optionSetBg:onTouchBegan(touch, event)
end

--touch end
function ASMJ_OptionSet:onTouchEnded(touch, event)
    self:onAcitonEnd()
    --self.m_optionSetBg:onTouchEnded(touch, event)
end

function ASMJ_OptionSet:onAcitonEnd()
    self:removeFromParent()
end

--init()
function ASMJ_OptionSet:init()

    local scalex = display.scalex_landscape
    local scaley = display.scaley_landscape

    local size = self:getContentSize()
    self:setPosition(size.width / 2, size.height / 2)

    local m_layerColor = cc.LayerColor:create(cc.c4b(0,0,0,100),size.width,size.height)
    self:addChild(m_layerColor, -1)

    self.m_optionSetBg = CSpriteEx:CreateWithSpriteFrameName("316_option_set_bg.png")
    self.m_optionSetBg:setScale(scalex, scaley)
    self.m_optionSetBg:setPosition(size.width / 2, size.height / 2)
    self:addChild(self.m_optionSetBg)

    local iTopX = self.m_optionSetBg:getPositionX() - self.m_optionSetBg:getBoundingBox().width / 2
    local iTopY = self.m_optionSetBg:getPositionY() + self.m_optionSetBg:getBoundingBox().height / 2

    self.m_btMusicOpen = CImageButton:CreateWithSpriteFrameName("316_muisc_open.png", "316_muisc_open.png", IDI_BT_OPTION_MUSIC_316)
    self.m_btMusicOpen:setScale(scalex, scaley)
    self.m_btMusicOpen:setPosition(iTopX + 255 * scalex, iTopY - 100 * scaley)
    self:addChild(self.m_btMusicOpen, 1)

    self.m_btMusicClose = CImageButton:CreateWithSpriteFrameName("316_muisc_close.png", "316_muisc_close.png", IDI_BT_OPTION_MUSIC_316)
    self.m_btMusicClose:setScale(scalex, scaley)
    self.m_btMusicClose:setPosition(iTopX + 255 * scalex, iTopY - 100 * scaley)
    self:addChild(self.m_btMusicClose, 1)

    if cc.UserDefault:getInstance():getBoolForKey("316_BackMusic", true) then
        self.m_btMusicClose:setVisible(false)
        self.m_btMusicOpen:setVisible(true)
    else
        self.m_btMusicClose:setVisible(true)
        self.m_btMusicOpen:setVisible(false)
    end

    self.m_btEffectOpen = CImageButton:CreateWithSpriteFrameName("316_muisc_open.png", "316_muisc_open.png", IDI_BT_OPTION_EFFECT_316)
    self.m_btEffectOpen:setScale(scalex, scaley)
    self.m_btEffectOpen:setPosition(iTopX + 255 * scalex, iTopY - 165 * scaley)
    self:addChild(self.m_btEffectOpen, 1)

    self.m_btEffectClose = CImageButton:CreateWithSpriteFrameName("316_muisc_close.png", "316_muisc_close.png", IDI_BT_OPTION_EFFECT_316)
    self.m_btEffectClose:setScale(scalex, scaley)
    self.m_btEffectClose:setPosition(iTopX + 255 * scalex, iTopY - 165 * scaley)
    self:addChild(self.m_btEffectClose, 1)

    if cc.UserDefault:getInstance():getBoolForKey("316_GameMusic", true) then
        self.m_btEffectClose:setVisible(false)
        self.m_btEffectOpen:setVisible(true)
    else
        self.m_btEffectClose:setVisible(true)
        self.m_btEffectOpen:setVisible(false)
    end

    local m_btExit = CImageButton:CreateWithSpriteFrameName("316_option_bt_exit.png", "316_option_bt_exit_select.png", IDI_BT_OPTION_EXIT_316)
    m_btExit:setScale(scalex, scaley)
    m_btExit:setPosition(size.width / 2, iTopY - 240 * scaley)
    self:addChild(m_btExit, 1)

    -- ScriptHandlerMgr
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btMusicOpen, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btMusicClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btEffectOpen, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btEffectClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_btExit, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end
