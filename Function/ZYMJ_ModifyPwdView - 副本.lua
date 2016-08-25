local ASMJ_ModifyPwdView = class("ASMJ_ModifyPwdView", function() return cc.Layer:create() end)
--ASMJ_ModifyPwdView.__index = ASMJ_ModifyPwdView

function ASMJ_ModifyPwdView:OnDialogClickEvent(event)
    print("ASMJ_ModifyPwdView OnDialogClickEvent: tag = " .. event.node:getTag())
   
    if event.node:getTag() == IDI_DIALOG_OK_316 then
        if event.clickevent == "ok" then
            event.node:removeFromParent()
        end
    elseif event.node:getTag() == IDI_DIALOG_MODIFY_PWD_ERR_316 then
        if event.clickevent == "ok" then
            event.node:removeFromParent()
        end
    end
end

--function OnClickEvent
function ASMJ_ModifyPwdView:OnClickEvent(clickcmd)
    cclog("ASMJ_ModifyPwdView:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDI_BT_SLIP_CLOSE_316 then
        self.m_pSlipBaseLayer:onHide()
    elseif clickcmd:getnTag() == IDI_BT_MODIFY_LOGIN_316 then
        self:ModifyLoginPWD()
    elseif clickcmd:getnTag() == IDI_BT_MODIFY_BANK_316 then
        self:ModifyBankPWD()
    else
        cclog("error id clickcmd")
    end
end

--function ModifyLoginPWD
function ASMJ_ModifyPwdView:ModifyLoginPWD()

    local password_src = self.m_editLoginSrc:getText()
    local password_dst = self.m_editLoginDst:getText()
    local password_ag = self.m_editLoginEnsure:getText()

    if password_src == "" or password_dst == "" or password_ag == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_modify_password_error_0"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)  
        return
    end

    local iCount = CUtilEx:getUTF8StringCount(password_src)
    if iCount < 6 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_modify_password_error_1"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    iCount = CUtilEx:getUTF8StringCount(password_dst)
    if iCount < 6 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_modify_password_error_1"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    iCount = CUtilEx:getUTF8StringCount(password_ag)
    if iCount < 6 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_modify_password_error_1"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    if password_dst ~= password_ag then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_modify_password_error_2"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
    CClientKernel:GetInstance():WritecharToBuffers(password_dst,33,true)
    CClientKernel:GetInstance():WritecharToBuffers(password_src,33,true)

    if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_MODIFY_LOGON_PASS) then
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end

--function ModifyBankPWD
function ASMJ_ModifyPwdView:ModifyBankPWD()

    local password_dst = self.m_editBankDst:getText()
    local password_ag = self.m_editBankEnsure:getText()

    if password_dst == "" or password_ag == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_modify_password_error_0"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    local iCount = CUtilEx:getUTF8StringCount(password_dst)
    if iCount < 6 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_modify_password_error_1"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    iCount = CUtilEx:getUTF8StringCount(password_ag)
    if iCount < 6 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_modify_password_error_1"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    if password_dst ~= password_ag then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_modify_password_error_2"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    if myItem.cbHaveSetInsurePassword > 0 then

        local pBankEnterKeyLayer = ASMJ_BankEnterKey_create(myItem:GetUserID(), password_ag, 0)
        self:addChild(pBankEnterKeyLayer, 500)
        
    else

        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
        CClientKernel:GetInstance():WritecharToBuffers(password_dst,33,true)
        CClientKernel:GetInstance():WritecharToBuffers(password_ag,33,true)

        if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_MODIFY_INSURE_PASS) then
            ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
        else
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
        end
    end
end

-----------------------------------------function HanderMessage-------------------
function ASMJ_ModifyPwdView:HanderMessage(msgcmd)
    if msgcmd:getMainCmdID() == MDM_GP_USER_SERVICE then
        self:OnUserServiceEvent(msgcmd)
    end
end

function ASMJ_ModifyPwdView:OnUserServiceEvent(msgcmd)
    if msgcmd:getSubCmdID() == SUB_GP_OPERATE_SUCCESS then
        self:OnUserOperateSuccess(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_GP_OPERATE_FAILURE then
        self:OnUserOperateFailure(msgcmd)
    end
end


function ASMJ_ModifyPwdView:OnUserOperateSuccess(msgcmd)
    ASMJ_Toast_Dismiss()
    local lErrorCode = msgcmd:readLONG()
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)
    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
    dialog:setTag(IDI_POPUP_OK_316)
end

function ASMJ_ModifyPwdView:OnUserOperateFailure(msgcmd)
    ASMJ_Toast_Dismiss()
    local lErrorCode = msgcmd:readLONG()
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)
    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
    dialog:setTag(IDI_POPUP_OK_316)
end

-- function OnGroupCheckEvent
function ASMJ_ModifyPwdView:OnGroupCheckEvent(groupcheckcmd)
    print("ASMJ_ModifyPwdView:OnGroupCheckEvent " .. groupcheckcmd:getnGroupID() .. "," .. groupcheckcmd:getnTag())
    if groupcheckcmd:getnGroupID() == IDI_RG_MODIFY_PWD_316 then
        if groupcheckcmd:getnTag() == IDI_RBT_MODIFY_LOGIN_316 then
            self.m_pLoginImg:setVisible(true)
            self.m_pBankImg:setVisible(false)
            self.m_btModifyLoginOK:SetClickable(true)
            self.m_btModifyBankOK:SetClickable(false)
        elseif groupcheckcmd:getnTag() == IDI_RBT_MODIFY_BANK_316 then
            self.m_pBankImg:setVisible(true)
            self.m_pLoginImg:setVisible(false)
            self.m_btModifyBankOK:SetClickable(true)
            self.m_btModifyLoginOK:SetClickable(false)
        end
    end
end

--init()
function ASMJ_ModifyPwdView:init(tex_bg)
    print("ASMJ_ModifyPwdView:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape

    self.m_pSlipBaseLayer = ASMJ_SlipBaseView_createLayer(tex_bg, "316_modify_bg.png")
    self.m_pSlipBaseLayer:setPosition(m_visibleSize.width/2, m_visibleSize.height/2)
    self:addChild(self.m_pSlipBaseLayer, -1)

    local btClose = CImageButton:Create("316_modify_bt_close0.png", "316_modify_bt_close1.png", IDI_BT_SLIP_CLOSE_316)
    btClose:setPosition(950, 520)
    self.m_pSlipBaseLayer.m_functionBg:addChild(btClose, 10)
    ------------------------------------------
    --rbt
    local m_rbtLogin = CRadioButton:Create("316_modify_bt_login0.png","316_modify_bt_login1.png", "",IDI_RBT_MODIFY_LOGIN_316,TEXT_Direction["CENTRE"])
    local m_rbtBank = CRadioButton:Create("316_modify_bt_bank0.png","316_modify_bt_bank1.png", "",IDI_RBT_MODIFY_BANK_316,TEXT_Direction["CENTRE"])
    m_rbtLogin:setPosition(450, 472)
    m_rbtBank:setPosition(720, 472)
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_rbtLogin)
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_rbtBank)

    m_rbtLogin:SetChecked(true)
    
    local m_rgGender = CRadioGroup:createInstance()
    m_rgGender:SetTag(IDI_RG_MODIFY_PWD_316)
    m_rgGender:AddControlChild(m_rbtLogin)
    m_rgGender:AddControlChild(m_rbtBank)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_rgGender, "cc.Ref"), handler(self,self.OnGroupCheckEvent), cc.Handler.EVENT_CUSTOMCMD)
    ----------------------------

    self.m_pLoginImg = cc.Sprite:create("316_modify_body_login.png")
    self.m_pLoginImg:setPosition(568, 290)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_pLoginImg)

    self.m_btModifyLoginOK = CImageButton:Create("316_modify_confirm_ok.png", "316_modify_confirm_ok.png", IDI_BT_MODIFY_LOGIN_316)
    self.m_btModifyLoginOK:setPosition(268, -50)
    self.m_pLoginImg:addChild(self.m_btModifyLoginOK)

    -- edit account
    local editBoxSize = cc.size(310, 52)
    self.m_editLoginSrc = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create())
    self.m_editLoginSrc:setPlaceHolder("")
    self.m_editLoginSrc:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editLoginSrc:setMaxLength(LEN_ACCOUNTS)
    self.m_editLoginSrc:setFontSize(14)
    self.m_editLoginSrc:setFontColor(cc.c3b(0, 0, 0))
    self.m_editLoginSrc:setPlaceholderFontSize(12)
    self.m_editLoginSrc:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editLoginSrc:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.m_editLoginSrc:setPosition(380, 193)
    self.m_pLoginImg:addChild(self.m_editLoginSrc)

    --m_editLoginDst = m_editSrcLPass
    self.m_editLoginDst = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create())
    self.m_editLoginDst:setPlaceHolder("")
    self.m_editLoginDst:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editLoginDst:setMaxLength(LEN_ACCOUNTS)
    self.m_editLoginDst:setFontSize(14)
    self.m_editLoginDst:setFontColor(cc.c3b(0, 0, 0))
    self.m_editLoginDst:setPlaceholderFontSize(12)
    self.m_editLoginDst:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editLoginDst:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.m_editLoginDst:setPosition(380, 116)
    self.m_pLoginImg:addChild(self.m_editLoginDst, 3)

    --m_editLoginEnsure = m_editSrcLPass
    self.m_editLoginEnsure = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create())
    self.m_editLoginEnsure:setPlaceHolder("")
    self.m_editLoginEnsure:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editLoginEnsure:setMaxLength(LEN_ACCOUNTS)
    self.m_editLoginEnsure:setFontSize(14)
    self.m_editLoginEnsure:setFontColor(cc.c3b(0, 0, 0))
    self.m_editLoginEnsure:setPlaceholderFontSize(12)
    self.m_editLoginEnsure:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editLoginEnsure:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.m_editLoginEnsure:setPosition(380, 39)
    self.m_pLoginImg:addChild(self.m_editLoginEnsure, 3)

    self.m_pBankImg = cc.Sprite:create("316_modify_body_bank.png")
    self.m_pBankImg:setPosition(568, 290)
    self.m_pBankImg:setVisible(false)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_pBankImg)

    self.m_btModifyBankOK = CImageButton:Create("316_modify_confirm_ok.png", "316_modify_confirm_ok.png", IDI_BT_MODIFY_BANK_316)
    self.m_btModifyBankOK:setPosition(268, -50)
    self.m_pBankImg:addChild(self.m_btModifyBankOK)

    --m_editBankDst = m_editSrcLPass
    self.m_editBankDst = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create())
    self.m_editBankDst:setPlaceHolder("")
    self.m_editBankDst:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editBankDst:setMaxLength(LEN_ACCOUNTS)
    self.m_editBankDst:setFontSize(14)
    self.m_editBankDst:setPlaceholderFontSize(12)
    self.m_editBankDst:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editBankDst:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.m_editBankDst:setFontColor(cc.c3b(0, 0, 0))
    self.m_editBankDst:setPosition(380, 119)
    self.m_pBankImg:addChild(self.m_editBankDst, 3)

    --m_editBankEnsure = m_editSrcLPass
    self.m_editBankEnsure = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create())
    self.m_editBankEnsure:setPlaceHolder("")
    self.m_editBankEnsure:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editBankEnsure:setMaxLength(LEN_ACCOUNTS)
    self.m_editBankEnsure:setFontSize(14)
    self.m_editBankEnsure:setPlaceholderFontSize(12)
    self.m_editBankEnsure:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editBankEnsure:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.m_editBankEnsure:setFontColor(cc.c3b(0, 0, 0))
    self.m_editBankEnsure:setPosition(380, 40)
    self.m_pBankImg:addChild(self.m_editBankEnsure, 3)

    --ScriptHandlerMgr
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btModifyLoginOK, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btModifyBankOK, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end

--ctor()
function ASMJ_ModifyPwdView:ctor(tex_bg)
    print("ASMJ_ModifyPwdView:ctor")

    self:init(tex_bg)

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
function ASMJ_ModifyPwdView:onEnter()
    print("ASMJ_ModifyPwdView:onEnter")

    local eventDispatcher = self:getEventDispatcher()
    local listener = nil
    listener = cc.EventListenerCustom:create("OnDialogClickEvent", handler(self, self.OnDialogClickEvent))
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(CClientKernel:GetInstance(), "cc.Ref"), handler(self, self.HanderMessage), cc.Handler.EVENT_CUSTOMCMD)
end

--onExit()
function ASMJ_ModifyPwdView:onExit()
    print("ASMJ_ModifyPwdView:onExit")
end

--create( ... )
function ASMJ_ModifyPwdView.create(tex_bg)
    cclog("ASMJ_ModifyPwdView")
    local layer = ASMJ_ModifyPwdView.new(tex_bg)
    return layer
end

--[====[   ASMJ_Function_KFView_createScene()  ]====]
function ASMJ_ModifyPwdView_createScene(tex_bg)
    cclog("ASMJ_ModifyPwdView")
    local scene = cc.Scene:create()
    scene:addChild(ASMJ_ModifyPwdView.create(tex_bg), 0)
    return scene
end