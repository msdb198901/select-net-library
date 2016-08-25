local ASMJ_BankEnterKey = class("ASMJ_BankEnterKey", function() return cc.Layer:create() end)
--ASMJ_BankEnterKey.__index = ASMJ_BankEnterKey

--function OnClickEvent
function ASMJ_BankEnterKey:OnClickEvent(clickcmd)
    cclog("ASMJ_BankEnterKey:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDI_BT_BANK_KEY_OK_316 then
        self:OnComfirm()
    elseif clickcmd:getnTag() == IDI_BT_BANK_KEY_CANCEL_316 then
        self.m_spBackGround:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25, 0), cc.CallFunc:create(function () self:removeFromParent() end)))
    elseif clickcmd:getnTag() == IDI_BT_BANK_PWD_OK_316 then
        self:OnComfirmPWD()
    else
        cclog("error id clickcmd")
    end
end

function ASMJ_BankEnterKey:OnComfirm()

    local bankpwd = self.m_editBankPwd:getText()

    if bankpwd == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_bank_error_05"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteDWORDToBuffers(self.m_dwUserID)
    CClientKernel:GetInstance():WriteLONGLONGToBuffers(self.m_lScore)
    CClientKernel:GetInstance():WritecharToBuffers(bankpwd,33,true)
    CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)

    if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_USER_TAKE_SCORE) then
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end

    self:removeFromParent()
end

function ASMJ_BankEnterKey:OnComfirmPWD()

    local bankpwd = self.m_editBankPwd:getText()

    if bankpwd == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_bank_error_05"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteDWORDToBuffers(self.m_dwUserID)
    CClientKernel:GetInstance():WritecharToBuffers(bankpwd,33,true)
    CClientKernel:GetInstance():WritecharToBuffers(self.m_password,33,true)

    if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_MODIFY_INSURE_PASS) then
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end

    self:removeFromParent()
end

--init()
function ASMJ_BankEnterKey:init()
    print("ASMJ_BankEnterKey:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local scalex = display.scalex_landscape
    local scaley = display.scaley_landscape
    local scaleMin = math.min(scalex, scaley)

    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), m_visibleSize.width, m_visibleSize.height)
    layerColor:setPosition(-m_visibleSize.width/4, -m_visibleSize.height/4)
    self:addChild(layerColor, -1)

    self.m_spBackGround = CSpriteEx:Create("316_bank_confirm_bg.png")
    self:addChild(self.m_spBackGround)

    local size = self.m_spBackGround:getContentSize()
    self:setContentSize(size)
    self:setPosition(m_visibleSize.width / 2, m_visibleSize.height / 2)
    self.m_spBackGround:setPosition(size.width / 2, size.height / 2)

    local m_btConfirm = CImageButton:Create("316_popup_ok0.png", "316_popup_ok1.png", self.m_iConfirmID)
    m_btConfirm:setPosition(190, 130)
    self.m_spBackGround:addChild(m_btConfirm)

    local m_btCancel = CImageButton:Create("316_popup_cancel0.png", "316_popup_cancel1.png", IDI_BT_BANK_KEY_CANCEL_316)
    m_btCancel:setPosition(380, 130)
    self.m_spBackGround:addChild(m_btCancel)

    self.m_editBankPwd = cc.EditBox:create(cc.size(310, 52), cc.Scale9Sprite:create())
    self.m_editBankPwd:setPlaceHolder("")
    self.m_editBankPwd:setMaxLength(LEN_PASSWORD)
    self.m_editBankPwd:setFontSize(14)
    self.m_editBankPwd:setFontColor(cc.c3b(0, 0, 0))
    self.m_editBankPwd:setPlaceholderFontSize(12)
    self.m_editBankPwd:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editBankPwd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.m_editBankPwd:setPosition(290, 228)
    self.m_spBackGround:addChild(self.m_editBankPwd, 3)

    self.m_spBackGround:setScale(0.1, 0.1)
    local ani1 = cc.ScaleTo:create(0.15, 1.1)
    local ani2 = cc.ScaleTo:create(0.05, 0.95)
    local ani3 = cc.ScaleTo:create(0.05, 1)
    local seq = cc.Sequence:create(ani1, ani2, ani3)
    self.m_spBackGround:runAction(seq)

    --ScriptHandlerMgr
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_btConfirm, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_btCancel, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end

--ctor()
function ASMJ_BankEnterKey:ctor(dwUserID, password, lScore)
    cclog("ASMJ_BankEnterKey:ctor")

    self:setIgnoreAnchorPointForPosition(false)

    if password == "" and lScore > 0 then
        self.m_iType = 0
    elseif password ~= "" and lScore == 0 then
        self.m_iType = 1
    end

    if self.m_iType == 0 then
        self.m_dwUserID = dwUserID
        self.m_lScore = lScore
        self.m_iConfirmID = IDI_BT_BANK_KEY_OK_316
    elseif self.m_iType == 1 then
        self.m_dwUserID = dwUserID
        self.m_password = password
        self.m_iConfirmID = IDI_BT_BANK_PWD_OK_316
    end
    
    self:init()

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--create( ... )
function ASMJ_BankEnterKey_create(dwUserID, password, lScore)
    cclog("ASMJ_BankEnterKey")
    local layer = ASMJ_BankEnterKey.new(dwUserID, password, lScore)
    return layer
end

--touch begin
function ASMJ_BankEnterKey:onTouchBegan(touch, event)
    return not self.m_spBackGround:onTouchBegan(touch, event)
end

--touch end
function ASMJ_BankEnterKey:onTouchEnded(touch, event)
    self.m_spBackGround:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25, 0), cc.CallFunc:create(function () self:removeFromParent() end)))
end