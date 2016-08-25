require "src/app/Game/AnShunMaJiang/Function/ASMJ_BankEnterKey"

local ASMJ_BankView = class("ASMJ_BankView", function() return cc.Layer:create() end )--ASMJ_SlipBaseView)
--ASMJ_BankView.__index = ASMJ_BankView
function ASMJ_BankView:OnDialogClickEvent(event)
    print("ASMJ_BankView OnDialogClickEvent: tag = " .. event.node:getTag())
   
    if event.node:getTag() == IDI_DIALOG_TASK_SCORE_ERR_316 then
        if event.clickevent == "ok" then
            event.node:removeFromParent()
        end
    elseif event.node:getTag() == IDI_DIALOG_OK_316 then
        if event.clickevent == "ok" then
            event.node:removeFromParent()
        end
    end
end

--function OnClickEvent
function ASMJ_BankView:OnClickEvent(clickcmd)
    print("ASMJ_BankView:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDI_BT_BANK_TAKE_316 then
        self:OnTakeScore()
    elseif clickcmd:getnTag() == IDI_BT_BANK_SAVE_316 then
        self:OnSaveScore()
    elseif clickcmd:getnTag() == IDI_BT_SLIP_CLOSE_316 then
        self.m_pSlipBaseLayer:onHide()
    end
end

function ASMJ_BankView:OnTakeScore()

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    if myItem == nil then
        --todo
    end

    local szScore = self.m_editScore:getText()
    if szScore == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_bank_error_00"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    local lScore = tonumber(szScore)
    if lScore < 1 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_bank_error_00"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    if lScore > myItem:GetInsure() then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_bank_error_03"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    if myItem.cbHaveSetInsurePassword > 0 then

        local pBankEnterKeyLayer = ASMJ_BankEnterKey_create(myItem:GetUserID(), "", lScore)
        self:addChild(pBankEnterKeyLayer, 500)
        
    else

        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
        CClientKernel:GetInstance():WriteLONGLONGToBuffers(lScore)
        CClientKernel:GetInstance():WritecharToBuffers(bankpwd,33,true)
        CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)
        if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_USER_TAKE_SCORE) then
            ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
        else
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
        end
    end
end

function ASMJ_BankView:OnSaveScore()

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    local szScore = self.m_editScore:getText()
    if szScore == "" then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_bank_error_00"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    local lScore = tonumber(szScore)

    if lScore < 1 then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_bank_error_00"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    if lScore > myItem:GetGoldA() then
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_bank_error_01"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        return
    end

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
    CClientKernel:GetInstance():WriteLONGLONGToBuffers(lScore)
    CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)

    if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_USER_SAVE_SCORE) then
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end
-----------------------------------------function HanderMessage-------------------
function ASMJ_BankView:HanderMessage(msgcmd)
    if msgcmd:getMainCmdID() == MDM_GP_USER_SERVICE then
        self:OnUserServiceEvent(msgcmd)
    end
end

function ASMJ_BankView:OnUserServiceEvent(msgcmd)
    print("ASMJ_BankView:OnUserServiceEvent", msgcmd:getSubCmdID())
    if msgcmd:getSubCmdID() == SUB_GP_USER_INSURE_SUCCESS then
        self:OnUserInsureSuccess(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_GP_USER_INSURE_FAILURE then
        self:OnUserInsureFailure(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_GP_OPERATE_SUCCESS then
        self:OnUserOperateSuccess(msgcmd)
    elseif msgcmd:getSubCmdID() == SUB_GP_OPERATE_FAILURE then
        self:OnUserOperateFailure(msgcmd)
    end
end

function ASMJ_BankView:OnUserInsureSuccess(msgcmd)

    ASMJ_Toast_Dismiss()

    local dwUserID          = msgcmd:readDWORD()
    local lUserScore        = msgcmd:readLONGLONG()
    local lUserInsure       = msgcmd:readLONGLONG()
    local szDescribeString  = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)

    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    if myItem:GetUserID() == dwUserID then
        myItem.lScore = lUserScore
        myItem.lGoldA = lUserScore
        myItem.lInsure = lUserInsure
    end

    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
    dialog:setTag(IDI_POPUP_OK_316)

    self:OnUpdataScoreInfo()
end

function ASMJ_BankView:OnUserInsureFailure(msgcmd)

    ASMJ_Toast_Dismiss()

    local lErrorCode = msgcmd:readLONG()
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)
   
    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
    dialog:setTag(IDI_POPUP_OK_316)  
end

function ASMJ_BankView:OnUserOperateSuccess(msgcmd)
    ASMJ_Toast_Dismiss()

    local lErrorCode = msgcmd:readLONG()
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)

    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
    dialog:setTag(IDI_POPUP_OK_316)
end

function ASMJ_BankView:OnUserOperateFailure(msgcmd)
    ASMJ_Toast_Dismiss()
    local lErrorCode = msgcmd:readLONG()
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)
    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
    dialog:setTag(IDI_POPUP_OK_316)
end

function ASMJ_BankView:OnUpdataScoreInfo()
    local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()

    if MyUserData == nil then
        return
    end
    
    self.m_userScoreLab:setString(CUtilEx:stringformat(MyUserData ~= nil and MyUserData:GetGoldA() or 0, 3, ","))
    self.m_bankScoreLab:setString(CUtilEx:stringformat(MyUserData ~= nil and MyUserData:GetInsure() or 0, 3, ","))
end

--init()
function ASMJ_BankView:init(tex_bg)
    print("ASMJ_BankView:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape
    local m_scaleMin = math.min(m_scalex, m_scaley)

    self.m_pSlipBaseLayer = ASMJ_SlipBaseView_createLayer(tex_bg, "316_bank_bg.png")
    self.m_pSlipBaseLayer:setPosition(m_visibleSize.width/2, m_visibleSize.height/2)
    self:addChild(self.m_pSlipBaseLayer, -1)

    ---------------------------------
    local btClose = CImageButton:Create("316_slip_bt_close0.png", "316_slip_bt_close1.png", IDI_BT_SLIP_CLOSE_316)
    btClose:setPosition(996, 540)
    self.m_pSlipBaseLayer.m_functionBg:addChild(btClose, 10)

     --label
    local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    local txtsize = 32*m_scaleMin
    
    local ttfConfig = {}
    ttfConfig.fontFilePath = "default.ttf"
    ttfConfig.fontSize     = 32
    self.m_userScoreLab = cc.Label:createWithTTF(ttfConfig, CUtilEx:stringformat(MyUserData ~= nil and MyUserData:GetGoldA() or 0, 3, ","))
    self.m_userScoreLab:setAnchorPoint(cc.p(0, 0.5))
    self.m_userScoreLab:setScale(m_scalex, m_scaley)
    self.m_userScoreLab:setPosition(500, 415)
    self.m_userScoreLab:setColor(cc.c3b(85, 55, 0))
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_userScoreLab, 2)

    self.m_bankScoreLab = cc.Label:createWithTTF(ttfConfig, CUtilEx:stringformat(MyUserData ~= nil and MyUserData:GetInsure() or 0, 3, ","))
    self.m_bankScoreLab:setPosition(500, 340)
    self.m_bankScoreLab:setAnchorPoint(cc.p(0, 0.5))
    self.m_bankScoreLab:setColor(cc.c3b(85, 55, 0))
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_bankScoreLab, 2)

    --access score
    self.m_editScore = cc.EditBox:create(cc.size(380, 53), cc.Scale9Sprite:create())
    self.m_editScore:setPlaceHolder("")
    self.m_editScore:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.m_editScore:setMaxLength(LEN_ACCOUNTS)
    self.m_editScore:setFontSize(14)
    self.m_editScore:setFontColor(cc.c3b(190, 90, 0))
    self.m_editScore:setPlaceholderFontSize(12)
    self.m_editScore:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.m_editScore:setPosition(655, 255)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_editScore, 3)

    self.m_btTask = CImageButton:Create("316_bank_bt_task.png","316_bank_bt_task.png", IDI_BT_BANK_TAKE_316)
    self.m_btTask:setPosition(455, 150)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_btTask,3)

    self.m_btSave = CImageButton:Create("316_bank_bt_save.png","316_bank_bt_save.png", IDI_BT_BANK_SAVE_316)
    self.m_btSave:setPosition(662, 150)
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_btSave,3)

    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btTask, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btSave, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end

--ctor()
function ASMJ_BankView:ctor(tex_bg)
    print("ASMJ_BankView:ctor")

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
function ASMJ_BankView:onEnter()
    print("ASMJ_BankView:onEnter")

    local eventDispatcher = self:getEventDispatcher()
    local listener = nil
    listener = cc.EventListenerCustom:create("OnDialogClickEvent", handler(self, self.OnDialogClickEvent))
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(CClientKernel:GetInstance(), "cc.Ref"), handler(self, self.HanderMessage), cc.Handler.EVENT_CUSTOMCMD)
end

--onExit()
function ASMJ_BankView:onExit()
    print("ASMJ_BankView:onExit")
end
--create( ... )
function ASMJ_BankView.create(tex_bg)
    cclog("ASMJ_BankView")
    local layer = ASMJ_BankView.new(tex_bg)
    return layer
end

--[====[   ASMJ_BankView_createScene()  ]====]
function ASMJ_BankView_createScene(tex_bg)
    cclog("ASMJ_BankView")
    local scene = cc.Scene:create()
    scene:addChild(ASMJ_BankView.create(tex_bg), 0)
    return scene
end