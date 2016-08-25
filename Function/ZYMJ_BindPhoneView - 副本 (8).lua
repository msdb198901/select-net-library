local ASMJ_BindPhoneView = class("ASMJ_BindPhoneView", function() return cc.Layer:create() end)
--ASMJ_BindPhoneView.__index = ASMJ_BindPhoneView

function ASMJ_BindPhoneView:OnDialogClickEvent(event)
    print("ASMJ_BindPhoneView OnDialogClickEvent: tag = " .. event.node:getTag())
end

--function OnClickEvent
function ASMJ_BindPhoneView:OnClickEvent(clickcmd)
    cclog("ASMJ_BindPhoneView:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDI_BT_SLIP_CLOSE_316 then
        self.m_pSlipBaseLayer:onHide()
    elseif clickcmd:getnTag() == IDI_BT_PHONE_SEND_316 or clickcmd:getnTag() == IDI_BT_PHONE_RESEND_316 then
        self:OnSendVerify()
    elseif clickcmd:getnTag() == IDI_BT_PHONE_BIND_316 then
        self:OnBindConfirm()
    elseif clickcmd:getnTag() == IDI_BT_PHONE_UNBIND_316 then
        self:OnUnBindConfirm()
    else
        cclog("error id clickcmd")
    end
end

--function ModifyLoginPWD
function ASMJ_BindPhoneView:OnSendVerify()

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    local myItemIndividual= CClientKernel:GetInstance():GetMyUserIndividual()
    
    local phonenumber = ""
    if myItem.cbHaveBindMobilePhone > 0 then
        phonenumber = myItemIndividual:GetSeatPhone()
    else
        phonenumber = self.m_editPhone:getText()
    end

    if phonenumber == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_0"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)  
        return
    end

    local iCount = CUtilEx:getUTF8StringCount(phonenumber)
    if iCount ~= 11 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_1"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)
    CClientKernel:GetInstance():WritecharToBuffers(phonenumber,12,true)

    if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_CHECKCODE, SUB_GP_GET_CODE) then
        
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
        self.m_btSend:setVisible(false)
        self.m_btSend:SetClickable(false)
        self.m_btResend:setVisible(true)
        self.m_btResend:SetClickable(true)

    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end

--function ModifyBankPWD
function ASMJ_BindPhoneView:OnBindConfirm()

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    local myItemIndividual= CClientKernel:GetInstance():GetMyUserIndividual()
    
    local phonenumber = self.m_editPhone:getText()
    local code = self.m_editVerify:getText()
    local newpass = ""

    if myItem.cbHaveSetLogonPassword > 0 then

        if phonenumber == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_1"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        if code == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_2"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        local iCount = CUtilEx:getUTF8StringCount(phonenumber)
        if iCount ~= 11 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_3"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
            return
        end

        iCount = CUtilEx:getUTF8StringCount(code)
        if iCount ~= 6 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_4"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
            return
        end
    else
        newpass = self.m_editPassword:getText()

        if phonenumber == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_1"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        if code == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_2"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        if newpass == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_5"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        if CUtilEx:checkLetterNumberUnderline(newpass) then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_6"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        local iCount = CUtilEx:getUTF8StringCount(phonenumber)
        if iCount ~= 11 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_3"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
            return
        end

        iCount = CUtilEx:getUTF8StringCount(code)
        if iCount ~= 6 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_4"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
            return
        end

        iCount = CUtilEx:getUTF8StringCount(newpass)
        if iCount < 6 or iCount > 16 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_7"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
            return
        end
    end

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteBYTEToBuffers(1)
    CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
    CClientKernel:GetInstance():WritecharToBuffers(phonenumber,12,true)
    CClientKernel:GetInstance():WritecharToBuffers(code,7,true)
    CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)
    CClientKernel:GetInstance():WritecharToBuffers(newpass,33,true)

    if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_BIND_MOBILE) then
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end

--function ModifyBankPWD
function ASMJ_BindPhoneView:OnUnBindConfirm()

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    local myItemIndividual= CClientKernel:GetInstance():GetMyUserIndividual()

    if myItem:GetGoldA() < 50000 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_8"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)  
        return
    end

    local phonenumber = self.m_editPhone:getText()
    local code = self.m_editVerify:getText()
    local newpass = ""

    if myItem.cbHaveSetLogonPassword > 0 then

        if phonenumber == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_1"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        if code == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_2"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        local iCount = CUtilEx:getUTF8StringCount(phonenumber)
        if iCount ~= 11 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_3"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
            return
        end

        iCount = CUtilEx:getUTF8StringCount(code)
        if iCount ~= 6 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_4"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
            return
        end
    else
        newpass = self.m_editPassword:getText()

        if phonenumber == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_1"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        if code == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_2"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        if newpass == "" then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_5"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        if CUtilEx:checkLetterNumberUnderline(newpass) then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_6"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)  
            return
        end

        local iCount = CUtilEx:getUTF8StringCount(phonenumber)
        if iCount ~= 11 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_3"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
            return
        end

        iCount = CUtilEx:getUTF8StringCount(code)
        if iCount ~= 6 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_4"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
            return
        end

        iCount = CUtilEx:getUTF8StringCount(newpass)
        if iCount < 6 or iCount > 16 then
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_error_7"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
            return
        end
    end

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteBYTEToBuffers(2)
    CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
    CClientKernel:GetInstance():WritecharToBuffers(phonenumber,12,true)
    CClientKernel:GetInstance():WritecharToBuffers(code,7,true)
    CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)
    CClientKernel:GetInstance():WritecharToBuffers("",33,true)

    if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_BIND_MOBILE) then
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end

-----------------------------------------function HanderMessage-------------------
function ASMJ_BindPhoneView:HanderMessage(msgcmd)
    if msgcmd:getMainCmdID() == MDM_GP_USER_SERVICE then
        self:OnUserServiceEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GP_CHECKCODE then
        self:OnUserCheckCode(msgcmd)
    end
end

function ASMJ_BindPhoneView:OnUserCheckCode(msgcmd)
    if msgcmd:getSubCmdID() == SUB_GP_S_GET_CODE then
        
        ASMJ_Toast_Dismiss()
        local wRetCode = msgcmd:readWORD()
        local szCheckCode = CMCipher:g2u_forlua(msgcmd:readChars(7), 7)
        local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(64), 64)
        if wRetCode == 0 then
            self.m_btResend:setVisible(true)
            self.m_btResend:SetClickable(false)
            self.m_bWaitting = true
            self.m_iTime = 180
        end

        local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)

    elseif msgcmd:getSubCmdID() == SUB_GP_S_CODE_ERRO  then
        ASMJ_Toast_Dismiss()

        local wRetCode = msgcmd:readWORD()
        local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(64), 64)
        if wRetCode ~= 0 then
            self.m_btResend:setVisible(true)
            self.m_btResend:SetClickable(true)
            self.m_bWaitting = false
            self.m_pTimeLab:setVisible(false)
        end

        local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end

function ASMJ_BindPhoneView:OnUserServiceEvent(msgcmd)
    if msgcmd:getSubCmdID() == SUB_GP_OPERATE_SUCCESS then
        self:OnUserOperateSuccess(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_GP_OPERATE_FAILURE then
        self:OnUserOperateFailure(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_GP_BIND_RESULT then
        self:OnUserBindResult(msgcmd)
    end
end


function ASMJ_BindPhoneView:OnUserOperateSuccess(msgcmd)
    ASMJ_Toast_Dismiss()
    
    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
    CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_QUERY_INDIVIDUAL)

    local lErrorCode = msgcmd:readLONG()
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)
    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
    dialog:setTag(IDI_POPUP_OK_316)
end

function ASMJ_BindPhoneView:OnUserOperateFailure(msgcmd)
    ASMJ_Toast_Dismiss()
    
    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
    CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_QUERY_INDIVIDUAL)

    local lErrorCode = msgcmd:readLONG()
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)
    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
    dialog:setTag(IDI_POPUP_OK_316)
end

function ASMJ_BindPhoneView:OnUserBindResult(msgcmd)
    ASMJ_Toast_Dismiss()
    local cbBindOrRemove = msgcmd:readBYTE()
    local cbRecode = msgcmd:readBYTE()
    local lChangeScore = msgcmd:readLONGLONG()
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(64, 64))
    
    if cbBindOrRemove == 1 then
        if cbRecode == 0 then

            local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
            myItem.lGoldA = myItem.lGoldA + lChangeScore
            myItem.cbHaveSetLogonPassword = 1

            CClientKernel:GetInstance():ResetBuffers()
            CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
            CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_QUERY_INDIVIDUAL)

            self.m_btBind:setVisible(false)
            self.m_btBind:SetClickable(false)
            self.m_btUnBind:setVisible(true)
            self.m_btUnBind:SetClickable(true)

            self.m_editPhone:setText(CUtilEx:subStringWithFormatStrCount(myItemIndividual and myItemIndividual:GetSeatPhone() or "", 3, "***"))   
            self.m_editPhone:setEnabled(false)
            self.m_editPassword:setText("*******") 
            self.m_editPassword:setEnabled(false)

            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_phone_bind_success"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
        else
            local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
        end

    elseif cbBindOrRemove == 2 then
        
        if cbRecode == 0 then
            local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
            myItem.lGoldA = myItem.lGoldA + lChangeScore

            self.m_btBind:setVisible(true)
            self.m_btBind:SetClickable(true)
            self.m_btUnBind:setVisible(false)
            self.m_btUnBind:SetClickable(false)

            self.m_editPhone:setEnabled(true)
            self.m_editPassword:setEnabled(true)
        else
            local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
        end
    end
end

--init()
function ASMJ_BindPhoneView:init(tex_bg)
    print("ASMJ_BindPhoneView:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape

    self.m_pSlipBaseLayer = ASMJ_SlipBaseView_createLayer(tex_bg, "316_phone_bg.png")
    self.m_pSlipBaseLayer:setPosition(m_visibleSize.width/2, m_visibleSize.height/2)
    self:addChild(self.m_pSlipBaseLayer, -1)

    local btClose = CImageButton:Create("316_modify_bt_close0.png", "316_modify_bt_close1.png", IDI_BT_SLIP_CLOSE_316)
    btClose:setPosition(740, 500)
    self.m_pSlipBaseLayer.m_functionBg:addChild(btClose, 10)
    ------------------------------------------
    self.m_bWaitting = false

    self.m_editPhone = cc.EditBox:create(cc.size(300, 51), cc.Scale9Sprite:create())
    self.m_editPhone:setPlaceHolder("")
    self.m_editPhone:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editPhone:setMaxLength(LEN_ACCOUNTS)
    self.m_editPhone:setFontSize(14)
    self.m_editPhone:setFontColor(cc.c3b(0, 0, 0))
    self.m_editPhone:setPlaceholderFontSize(14)
    self.m_editPhone:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.m_editPhone:setPosition(480, 378)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_editPhone)

    self.m_editVerify = cc.EditBox:create(cc.size(145, 43), cc.Scale9Sprite:create())
    self.m_editVerify:setPlaceHolder("")
    self.m_editVerify:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editVerify:setMaxLength(LEN_ACCOUNTS)
    self.m_editVerify:setFontSize(14)
    self.m_editVerify:setFontColor(cc.c3b(0, 0, 0))
    self.m_editVerify:setPlaceholderFontSize(14)
    self.m_editVerify:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.m_editVerify:setPosition(405, 300)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_editVerify, 3)

    self.m_editPassword = cc.EditBox:create(cc.size(300, 51), cc.Scale9Sprite:create())
    self.m_editPassword:setPlaceHolder("")
    self.m_editPassword:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editPassword:setMaxLength(LEN_ACCOUNTS)
    self.m_editPassword:setFontSize(14)
    self.m_editPassword:setFontColor(cc.c3b(0, 0, 0))
    self.m_editPassword:setPlaceholderFontSize(14)
    self.m_editPassword:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_editPassword:setPosition(480, 223)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_editPassword, 3)

    self.m_btSend = CImageButton:Create("316_phone_bt_send.png", "316_phone_bt_send.png", IDI_BT_PHONE_SEND_316)
    self.m_btSend:setPosition(570, 300)
    self.m_btSend:SetEffect(true, BE_SCALE, m_scalex, m_scaley)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_btSend)

    self.m_btResend = CImageButton:Create("316_phone_bt_resend.png", "316_phone_bt_resend.png", IDI_BT_PHONE_RESEND_316)
    self.m_btResend:setPosition(570, 300)
    self.m_btResend:setVisible(false)
    self.m_btResend:SetClickable(false)
    self.m_btResend:SetEffect(true, BE_SCALE, m_scalex, m_scaley)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_btResend)

    local ttfConfig = {}
    ttfConfig.fontFilePath = "default.ttf"
    ttfConfig.fontSize     = 24
    self.m_pTimeLab = cc.Label:createWithTTF(ttfConfig, "0 s")
    self.m_pTimeLab:setPosition(675, 300)
    self.m_pTimeLab:setVisible(false)
    self.m_pTimeLab:setColor(cc.c3b(105, 55, 0, 255))
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_pTimeLab)

    self.m_btBind = CImageButton:Create("316_phone_bt_bind.png", "316_phone_bt_bind.png", IDI_BT_PHONE_BIND_316)
    self.m_btBind:setPosition(400, 97)
    self.m_btBind:SetEffect(true, BE_SCALE, m_scalex, m_scaley)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_btBind)

    self.m_btUnBind = CImageButton:Create("316_phone_bt_unbind.png", "316_phone_bt_unbind.png", IDI_BT_PHONE_UNBIND_316)
    self.m_btUnBind:setPosition(400, 97)
    self.m_btUnBind:SetEffect(true, BE_SCALE, m_scalex, m_scaley)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_btUnBind)

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    local myItemIndividual= CClientKernel:GetInstance():GetMyUserIndividual()
    
    if myItem.cbHaveBindMobilePhone > 0 then
        
        self.m_btBind:setVisible(false)
        self.m_btBind:SetClickable(false)
        self.m_btUnBind:setVisible(true)
        self.m_btUnBind:SetClickable(true)

        self.m_editPhone:setText(CUtilEx:subStringWithFormatStrCount(myItemIndividual and myItemIndividual:GetSeatPhone() or "", 3, "***"))   
        self.m_editPhone:setEnabled(false)
        self.m_editPassword:setText("*******") 
        self.m_editPassword:setEnabled(false)
    else
        self.m_btBind:setVisible(true)
        self.m_btBind:SetClickable(true)
        self.m_btUnBind:setVisible(false)
        self.m_btUnBind:SetClickable(false)
    end

    if myItem.cbHaveSetLogonPassword > 0 then
        self.m_editPassword:setText("*******") 
        self.m_editPassword:setEnabled(false)
    end

    local ani1 = cc.CallFunc:create(
            function ()

                if not self.m_bWaitting then
                    return
                end

                if self.m_iTime == nil or self.m_iTime <= 0 then
                    self.m_pTimeLab:setVisible(false)
                    self.m_btResend(true)
                    return
                end

                self.m_iTime = self.m_iTime - 1
                self.m_pTimeLab:setVisible(true)
                self.m_pTimeLab:setString(string.format("%ds", self.m_iTime))
            end)

    local ani2 = cc.DelayTime:create(1)
    local ani3 = cc.RepeatForever:create(cc.Sequence:create(ani1, ani2))
    self.m_pSlipBaseLayer.m_functionBg:runAction(ani3)

    --ScriptHandlerMgr
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btResend, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btSend, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btBind, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btUnBind, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end

--ctor()
function ASMJ_BindPhoneView:ctor(tex_bg)
    print("ASMJ_BindPhoneView:ctor")

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
function ASMJ_BindPhoneView:onEnter()
    print("ASMJ_BindPhoneView:onEnter")

    local eventDispatcher = self:getEventDispatcher()
    local listener = nil
    listener = cc.EventListenerCustom:create("OnDialogClickEvent", handler(self, self.OnDialogClickEvent))
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(CClientKernel:GetInstance(), "cc.Ref"), handler(self, self.HanderMessage), cc.Handler.EVENT_CUSTOMCMD)
end

--onExit()
function ASMJ_BindPhoneView:onExit()
    print("ASMJ_BindPhoneView:onExit")
end

--create( ... )
function ASMJ_BindPhoneView.create(tex_bg)
    cclog("ASMJ_BindPhoneView")
    local layer = ASMJ_BindPhoneView.new(tex_bg)
    return layer
end

--[====[   ASMJ_Function_KFView_createScene()  ]====]
function ASMJ_BindPhoneView_createScene(tex_bg)
    cclog("ASMJ_BindPhoneView")
    local scene = cc.Scene:create()
    scene:addChild(ASMJ_BindPhoneView.create(tex_bg), 0)
    return scene
end