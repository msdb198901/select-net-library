local ASMJ_PerfectView = class("ASMJ_PerfectView", function() return cc.Layer:create() end)

function ASMJ_PerfectView:OnDialogClickEvent(event)
    print("ASMJ_PerfectView OnDialogClickEvent: tag = " .. event.node:getTag())
   
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
function ASMJ_PerfectView:OnClickEvent(clickcmd)
    cclog("ASMJ_PerfectView:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDI_BT_SLIP_CLOSE_316 then
        self.m_pSlipBaseLayer:onHide()
    elseif clickcmd:getnTag() == IDI_BT_RERFECT_OK_316 then
        self:OnConfirmPerfect()
    elseif clickcmd:getnTag() == IDI_BT_RERFECT_BIND_316 then
        self:OnConfirmBind()
    else
        cclog("error id clickcmd")
    end
end

--function ModifyLoginPWD
function ASMJ_PerfectView:OnConfirmPerfect()

    local account = self.m_editAccount:getText()
    local password = self.m_editPassword:getText()
    local nickname = self.m_editNickName:getText()

    if account == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_perfect_account_error_0"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)  
        return
    end

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    if myItem.cbHaveSetLogonPassword > 0 then
        if password == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_perfect_password_error_0"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
        end
    end

    if nickname == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_perfect_nickname_error_0"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)  
        return
    end

    if CUtilEx:checkLetterNumberUnderline(account) then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_perfect_account_error_1"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)  
        return
    end

    local iCount = CUtilEx:getUTF8StringCount(password)
    if iCount < 6 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_perfect_password_error_1"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
    CClientKernel:GetInstance():WritecharToBuffers(account,32,true)
    CClientKernel:GetInstance():WritecharToBuffers(password,33,true)
    CClientKernel:GetInstance():WritecharToBuffers(nickname,32,true)
    CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)

    if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_VISITOR_CHANGE) then
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end

--function ModifyBankPWD
function ASMJ_PerfectView:OnConfirmBind()

    local realname = self.m_editRealName:getText()
    local idnumber = self.m_editIdentity:getText()

    if realname == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_perfect_bind_error_0"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    if idnumber == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_perfect_bind_error_1"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    local iCount = CUtilEx:getUTF8StringCount(idnumber)
    if iCount ~= 18 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_perfect_bind_error_2"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    if myItem == nil then
        return
    end

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
    CClientKernel:GetInstance():WritecharToBuffers(realname,16,true)
    CClientKernel:GetInstance():WritecharToBuffers(idnumber,19,true)
    CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)

    if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_MODIFY_INSURE_PASS) then
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end

-----------------------------------------function HanderMessage-------------------
function ASMJ_PerfectView:HanderMessage(msgcmd)
    if msgcmd:getMainCmdID() == MDM_GP_USER_SERVICE then
        self:OnUserServiceEvent(msgcmd)
    end
end

function ASMJ_PerfectView:OnUserServiceEvent(msgcmd)
    if msgcmd:getSubCmdID() == SUB_GP_REALINFO_RESULT then
        self:OnUserBindInfo(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_GP_VISITOR_CHANGE_RESULT then
        self:OnUserPerfectInfo(msgcmd)
    end
end


function ASMJ_PerfectView:OnUserPerfectInfo(msgcmd)
    ASMJ_Toast_Dismiss()
    local wRetCode = msgcmd:readWORD()
    local szAccounts = CMCipher:g2u_forlua(msgcmd:readChars(32), 32)
    local szNickName = CMCipher:g2u_forlua(msgcmd:readChars(32), 32)
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(64), 64)
    
    if wRetCode == 0 then

        local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
        CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_QUERY_INDIVIDUAL)

        myItem.cbHaveSetLogonPassword = 1
        myItem.szNickName = szNickName

        self.m_btOK:setVisible(false)
        self.m_btOK:SetClickable(false)

        self.m_editAccount:setEnabled(false)
        self.m_editPassword:setEnabled(false)
        self.m_editNickName:setEnabled(false)

        self.m_editAccount:setText(CUtilEx:subStringWithFormatStrCount(myItem and myItem:GetAccounts() or "", 3, "***"))   
        self.m_editPassword:setText("*******")
        self.m_editNickName:setText(myItem and myItem:GetNickName() or "") 

        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_perfect_account_success"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    else
        local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end

function ASMJ_PerfectView:OnUserBindInfo(msgcmd)
    ASMJ_Toast_Dismiss()
    local cbRetCode = msgcmd:readBYTE()
    local lChangeScore = msgcmd:readLONGLONG()
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(64), 64)
    
    if cbRetCode == 0 then
        
        local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
        CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_QUERY_INDIVIDUAL)

        self.m_spBingFlag:setVisible(true)
        self.m_btBingPhone:setVisible(false)
        self.m_btBingPhone:SetClickable(false)
        self.m_editRealName:setEnabled(false)
        self.m_editIdentity:setEnabled(false)
        self.m_editRealName:setText(CUtilEx:subStringWithFormatStrCount(myItemIndividual and myItemIndividual:GetCompellation(), 3, "***"))
        self.m_editIdentity:setText(CUtilEx:subStringWithFormatStrCount(myItemIndividual and myItemIndividual:GetPassPortID(), 2, "*******"))
        
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_perfect_bind_success"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end

    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
    dialog:setTag(IDI_POPUP_OK_316)
end

--init()
function ASMJ_PerfectView:init(tex_bg)
    print("ASMJ_PerfectView:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape

    self.m_pSlipBaseLayer = ASMJ_SlipBaseView_createLayer(tex_bg, "316_perfect_bg.png")
    self.m_pSlipBaseLayer:setPosition(m_visibleSize.width/2, m_visibleSize.height/2)
    self:addChild(self.m_pSlipBaseLayer, -1)

    local btClose = CImageButton:Create("316_modify_bt_close0.png", "316_modify_bt_close1.png", IDI_BT_SLIP_CLOSE_316)
    btClose:setPosition(990, 540)
    self.m_pSlipBaseLayer.m_functionBg:addChild(btClose, 10)
    ------------------------------------------
    -- edit account
    local editBoxSize = cc.size(300, 48)
    self.m_editAccount = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create())
    self.m_editAccount:setPlaceHolder("")
    self.m_editAccount:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editAccount:setMaxLength(LEN_ACCOUNTS)
    self.m_editAccount:setFontSize(10)
    self.m_editAccount:setFontColor(cc.c3b(0, 0, 0))
    self.m_editAccount:setPlaceholderFontSize(10)
    self.m_editAccount:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editAccount:setPosition(590, 464)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_editAccount)

    self.m_editPassword = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create())
    self.m_editPassword:setPlaceHolder("")
    self.m_editPassword:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editPassword:setMaxLength(LEN_ACCOUNTS)
    self.m_editPassword:setFontSize(10)
    self.m_editPassword:setFontColor(cc.c3b(0, 0, 0))
    self.m_editPassword:setPlaceholderFontSize(10)
    self.m_editPassword:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editPassword:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.m_editPassword:setPosition(590, 415)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_editPassword, 3)

    self.m_editNickName = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create())
    self.m_editNickName:setPlaceHolder("")
    self.m_editNickName:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editNickName:setMaxLength(LEN_ACCOUNTS)
    self.m_editNickName:setFontSize(10)
    self.m_editNickName:setFontColor(cc.c3b(0, 0, 0))
    self.m_editNickName:setPlaceholderFontSize(10)
    self.m_editNickName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editNickName:setPosition(590, 365)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_editNickName, 3)

    self.m_btOK = CImageButton:Create("316_perfect_bt_ok.png", "316_perfect_bt_ok.png", IDI_BT_RERFECT_OK_316)
    self.m_btOK:setPosition(577, 316)
    self.m_btOK:SetEffect(true, BE_SCALE, m_scalex, m_scaley)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_btOK)
    -----------------------------------------

    self.m_editRealName = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create())
    self.m_editRealName:setPlaceHolder("")
    self.m_editRealName:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editRealName:setMaxLength(LEN_ACCOUNTS)
    self.m_editRealName:setFontSize(10)
    self.m_editRealName:setPlaceholderFontSize(10)
    self.m_editRealName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editRealName:setFontColor(cc.c3b(0, 0, 0))
    self.m_editRealName:setPosition(590, 225)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_editRealName, 3)

    self.m_editIdentity = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create())
    self.m_editIdentity:setPlaceHolder("")
    self.m_editIdentity:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editIdentity:setMaxLength(LEN_ACCOUNTS)
    self.m_editIdentity:setFontSize(10)
    self.m_editIdentity:setPlaceholderFontSize(10)
    self.m_editIdentity:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editIdentity:setFontColor(cc.c3b(0, 0, 0))
    self.m_editIdentity:setPosition(590, 160)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_editIdentity, 3)

    self.m_btBingPhone = CImageButton:Create("316_perfect_bt_bind.png", "316_perfect_bt_bind.png", IDI_BT_RERFECT_BIND_316)
    self.m_btBingPhone:setPosition(577, 90)
    self.m_btBingPhone:SetEffect(true, BE_SCALE, m_scalex, m_scaley)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_btBingPhone)

    self.m_spBingFlag = cc.Sprite:create("316_perfect_flag_binded.png")
    self.m_spBingFlag:setPosition(720, 185)
    self.m_spBingFlag:setVisible(false)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_spBingFlag)

    ----------------------------------
    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    if myItem.cbHaveSetLogonPassword > 0 then
        self.m_editPassword:setText("*******")
        self.m_editPassword:setEnabled(false)
    end

    if string.find(myItem.szAccounts, CUtilEx:getString("0_perfect_account_0")) == nil then
        self.m_btOK:setVisible(false)
        self.m_btOK:SetClickable(false)

        self.m_editAccount:setEnabled(false)
        self.m_editAccount:setText(CUtilEx:subStringWithFormatStrCount(myItem and myItem:GetAccounts() or "", 3, "***"))   
        self.m_editNickName:setEnabled(false)
        self.m_editNickName:setText(myItem and myItem:GetNickName() or "") 
    end

    local myItemIndividual = CClientKernel:GetInstance():GetMyUserIndividual()
    if myItemIndividual:GetCompellation() ~= "" and myItemIndividual:GetPassPortID() ~= "" then
        self.m_spBingFlag:setVisible(true)
        self.m_btBingPhone:setVisible(false)
        self.m_btBingPhone:SetClickable(false)
        self.m_editRealName:setEnabled(false)
        self.m_editIdentity:setEnabled(false)
        self.m_editRealName:setText(CUtilEx:subStringWithFormatStrCount(myItemIndividual and myItemIndividual:GetCompellation(), 3, "***"))
        self.m_editIdentity:setText(CUtilEx:subStringWithFormatStrCount(myItemIndividual and myItemIndividual:GetPassPortID(), 2, "*******"))
    end

    --ScriptHandlerMgr
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btOK, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btBingPhone, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end

--ctor()
function ASMJ_PerfectView:ctor(tex_bg)
    print("ASMJ_PerfectView:ctor")

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
function ASMJ_PerfectView:onEnter()
    print("ASMJ_PerfectView:onEnter")

    local eventDispatcher = self:getEventDispatcher()
    local listener = nil
    listener = cc.EventListenerCustom:create("OnDialogClickEvent", handler(self, self.OnDialogClickEvent))
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(CClientKernel:GetInstance(), "cc.Ref"), handler(self, self.HanderMessage), cc.Handler.EVENT_CUSTOMCMD)
end

--onExit()
function ASMJ_PerfectView:onExit()
    print("ASMJ_PerfectView:onExit")
end

--create( ... )
function ASMJ_PerfectView.create(tex_bg)
    cclog("ASMJ_PerfectView")
    local layer = ASMJ_PerfectView.new(tex_bg)
    return layer
end

--[====[   ASMJ_Function_KFView_createScene()  ]====]
function ASMJ_PerfectView_createScene(tex_bg)
    cclog("ASMJ_PerfectView")
    local scene = cc.Scene:create()
    scene:addChild(ASMJ_PerfectView.create(tex_bg), 0)
    return scene
end