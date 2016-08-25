require "src/app/Game/AnShunMaJiang/Function/ASMJ_FaceChoice"
require "src/app/Game/AnShunMaJiang/Function/ASMJ_ModifyPwdView"
require "src/app/Game/AnShunMaJiang/Function/ASMJ_PerfectView"
require "src/app/Game/AnShunMaJiang/Function/ASMJ_BindPhoneView"

local ASMJ_PersonalView = class("ASMJ_PersonalView", function() return cc.Layer:create() end)

gameExprience = 
{
    0,10,20,40,70,110,160,230,330,430,
    550,680,840,1110,1330,1570,1850,2150,2680,3080,
    3520,3990,4510,5430,6080,6770,7520,8320,9790,10760,
    11790,12890,14050,16240,17620,19080,20620,22230,25340,27230,
    29210,31280,33450,37700,40200,42810,45520,48350,54000,57220,
    60560,64040,67650,74950,79020,83230,87590,92100,101370,106420,
    111620,117000,122550,134100,140260,146610,153140,159870,174040,181470,
    189110,196950,205020,222180,231040,240120,249440,259000,279550,289990,
    300690,311650,322880,347230,359440,371940,384720,397790,426380,440540,
    455020,469810,484910,518210,534520,551170,568170,585510,624000,666666
}

vipExprience = {0,300,900,3600,7200,14400,25200,43200}

function ASMJ_PersonalView:OnDialogClickEvent(event)
    print("ASMJ_PersonalView OnDialogClickEvent: tag = " .. event.node:getTag())
 
    if event.node:getTag() == IDI_DIALOG_OK_316 then
        if event.clickevent == "ok" then
            event.node:removeFromParent()
        end
    end
end

--function OnClickEvent
function ASMJ_PersonalView:OnClickEvent(clickcmd)
    print("ASMJ_PersonalView:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDI_BT_SLIP_CLOSE_316  then
        self.m_pSlipBaseLayer:onHide()
    elseif clickcmd:getnTag() == IDI_BT_PERSONAL_XGMM_316 then
        self:ModifyPwd()
    
    elseif clickcmd:getnTag() == IDI_BT_PERSONAL_AWARD_316 then
        
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_dialog_notify_0"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    
    elseif clickcmd:getnTag() == IDI_BT_PERSONAL_PERFECT_316 then
       
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local m_scalex = display.scalex_landscape
        local m_scaley = display.scaley_landscape
        local renderTexture = cc.RenderTexture:create(visibleSize.width, visibleSize.height)
        renderTexture:begin()
        self:visit()
        renderTexture:endToLua()
        local pServiceScene = ASMJ_PerfectView_createScene(renderTexture:getSprite():getTexture())
        cc.Director:getInstance():pushScene(pServiceScene)

    elseif clickcmd:getnTag() == IDI_BT_PERSONAL_BING_316 then

        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local m_scalex = display.scalex_landscape
        local m_scaley = display.scaley_landscape
        local renderTexture = cc.RenderTexture:create(visibleSize.width, visibleSize.height)
        renderTexture:begin()
        self:visit()
        renderTexture:endToLua()
        local pServiceScene = ASMJ_BindPhoneView_createScene(renderTexture:getSprite():getTexture())
        cc.Director:getInstance():pushScene(pServiceScene)

    elseif clickcmd:getnTag() == IDI_BT_PERSONAL_FACE_CHOICE_316 then
        self:ChoiceFace()
    else
        print("error id clickcmd")
    end
end

--function handermessage
function ASMJ_PersonalView:HanderMessage(msgcmd)
    print("ASMJ_PersonalView:HanderMessage main:%d, sub=%d, len=%d", msgcmd:getMainCmdID(), msgcmd:getSubCmdID(), msgcmd:getLen())
    if msgcmd:getMainCmdID() == MDM_GP_USER_SERVICE then
        self:onUserServiceEvent(msgcmd)
    end
end

--function onUserServiceEvent
function ASMJ_PersonalView:onUserServiceEvent(msgcmd)
    local iSubMsgID = msgcmd:getSubCmdID() 
    if iSubMsgID == SUB_GP_OPERATE_SUCCESS then
        self:OnGenderOperateSuccess(msgcmd)
    elseif iSubMsgID == SUB_GP_USER_FACE_INFO then
        self:OnUserFaceInfo(msgcmd)
    end
end

--function OnGenderOperateSuccess
function ASMJ_PersonalView:OnGenderOperateSuccess(msgcmd)

    ASMJ_Toast_Dismiss()
	
    local m_rbtBoy = self.m_pSlipBaseLayer.m_functionBg:getChildByTag(IDI_RBT_UVIEW_BOY_316)
	local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
	myItem.cbGender = m_rbtBoy:IsChecked() and GENDER_MANKIND or GENDER_FEMALE

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteWORDToBuffers(not m_rbtBoy:IsChecked() and 50 or 0)
    CClientKernel:GetInstance():WriteDWORDToBuffers(ASMJ_MyUserItem:GetInstance():GetUserID())
    CClientKernel:GetInstance():WritecharToBuffers(ASMJ_MyUserItem:GetInstance():GetPassword(),33,true)
    CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)
    CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_SYSTEM_FACE_INFO)
    
    local lResultCode = msgcmd:readLONG()
    local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)
    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
    dialog:setTag(IDI_POPUP_OK_316)
end

--function OnUserFaceInfo
function ASMJ_PersonalView:OnUserFaceInfo(msgcmd)
    --read data
    local wFaceID       = msgcmd:readWORD()
    local dwCustomID    = msgcmd:readDWORD()
    ------
    local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
	myItem.wFaceID = wFaceID

    local m_userFaceImg = self.m_pSlipBaseLayer.m_functionBg:getChildByTag(IDI_BT_PERSONAL_FACE_316)
    m_userFaceImg:SetFaceID(myItem and myItem:GetFaceID() or -1)

    local faceChoiceLayer = self.m_pSlipBaseLayer.m_functionBg:getChildByTag(IDI_BG_PERSONAL_FACE_CHOICE_316)
    if faceChoiceLayer~= nil then
        faceChoiceLayer:OnKeyBackEvent()
    end
end

--choice face
function ASMJ_PersonalView:ModifyPwd()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape
    local renderTexture = cc.RenderTexture:create(visibleSize.width, visibleSize.height)
    renderTexture:begin()
    self:visit()
    renderTexture:endToLua()
    local pServiceScene = ASMJ_ModifyPwdView_createScene(renderTexture:getSprite():getTexture())
    cc.Director:getInstance():pushScene(pServiceScene)
end

--choice face
function ASMJ_PersonalView:ChoiceFace()
    local m_choiceFaceLayer = ASMJ_FaceChoice_createLayer()
    m_choiceFaceLayer:setTag(IDI_BG_PERSONAL_FACE_CHOICE_316)
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_choiceFaceLayer, 20)
end

--init()
function ASMJ_PersonalView:init(tex_bg)
    print("ASMJ_PersonalView:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape
    local m_scaleyMin = math.min(m_scalex, m_scaley)

    self.m_pSlipBaseLayer = ASMJ_SlipBaseView_createLayer(tex_bg, "316_personal_bg.png")
    self.m_pSlipBaseLayer:setPosition(m_visibleSize.width/2, m_visibleSize.height/2)
    self:addChild(self.m_pSlipBaseLayer, -1)

    local btClose = CImageButton:Create("316_slip_bt_close0.png", "316_slip_bt_close1.png", IDI_BT_SLIP_CLOSE_316)
    btClose:setPosition(996, 540)
    self.m_pSlipBaseLayer.m_functionBg:addChild(btClose, 10)
    ----------------------------
    local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    local m_userFaceImg = ASMJ_FaceView_createLayer()
    m_userFaceImg:setScale(2.5, 2.5)
    m_userFaceImg:setTag(IDI_BT_PERSONAL_FACE_316)
    m_userFaceImg:SetFaceID(MyUserData and MyUserData:GetFaceID() or -1)  
    m_userFaceImg:setPosition(277, 339)
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_userFaceImg, -1)

    local btChangeFace = CImageButton:Create("316_personal_mask.png", "316_personal_mask.png", IDI_BT_PERSONAL_FACE_CHOICE_316)
    btChangeFace:setPosition(279, 245)
    self.m_pSlipBaseLayer.m_functionBg:addChild(btChangeFace)

    local ttfConfig = {}
    ttfConfig.fontFilePath = "default.ttf"
    ttfConfig.fontSize     = 27
    local strName = CUtilEx:subStringWithFormatStrWidth(MyUserData and MyUserData:GetNickName() or "", 300, 40, 1, 1)
    self.m_nickNameLab = cc.Label:createWithTTF(ttfConfig, strName)
    self.m_nickNameLab:setPosition(282, 170)
    self.m_nickNameLab:setColor(cc.c3b(255, 255, 40))
    self.m_pSlipBaseLayer.m_functionBg:addChild(self.m_nickNameLab)

    local m_userIDLab = cc.Label:createWithCharMap("316_personal_num_gold1.png", 19, 23, string.byte("/"))
    m_userIDLab:setPosition(567, 447)
    m_userIDLab:setAnchorPoint(cc.p(0, 0.5))
    m_userIDLab:setString(string.format("%d",MyUserData and MyUserData:GetGameID() or 0))
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_userIDLab)

    --rbt sex
    local m_rbtBoy = CRadioButton:Create("316_personal_btn_male0.png","316_personal_btn_male1.png", "",IDI_RBT_UVIEW_BOY_316,TEXT_Direction["CENTRE"])
    local m_rbtGirl = CRadioButton:Create("316_personal_bt_female0.png","316_personal_bt_female1.png", "",IDI_RBT_UVIEW_GIRL_316,TEXT_Direction["CENTRE"])
    m_rbtBoy:setPosition(944, 447)
    m_rbtGirl:setPosition(1010, 447)
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_rbtBoy)
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_rbtGirl)

    if MyUserData ~= nil and MyUserData:GetGender() == GENDER_FEMALE then
        m_rbtGirl:SetChecked(true)
    else
        m_rbtBoy:SetChecked(true)
    end
    local m_rgGender = CRadioGroup:createInstance()
    m_rgGender:SetTag(IDI_RG_UVIEW_GENDER_316)
    m_rgGender:AddControlChild(m_rbtGirl)
    m_rgGender:AddControlChild(m_rbtBoy)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_rgGender, "cc.Ref"), handler(self,self.OnGroupCheckEvent), cc.Handler.EVENT_CUSTOMCMD)
    ----------------------------
    local m_JinDouLabA = cc.Label:createWithCharMap("316_personal_num_gold1.png", 19, 23, string.byte("/"))
    m_JinDouLabA:setPosition(567, 372)
    m_JinDouLabA:setAnchorPoint(cc.p(0, 0.5))
    m_JinDouLabA:setString(string.format("%d",MyUserData and MyUserData:GetGoldA() or 0))
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_JinDouLabA)
  
    local m_JiangPaiLabA = cc.Label:createWithCharMap("316_personal_num_gold1.png", 19, 23, string.byte("/"))
    m_JiangPaiLabA:setPosition(919, 372)
    m_JiangPaiLabA:setAnchorPoint(cc.p(0, 0.5))
    m_JiangPaiLabA:setString(string.format("%d",MyUserData and MyUserData:GetUserMedal() or 0))
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_JiangPaiLabA)

    local m_HuaFeiQuanLabA = cc.Label:createWithCharMap("316_personal_num_gold1.png", 19, 23, string.byte("/"))
    m_HuaFeiQuanLabA:setPosition(567, 307)
    m_HuaFeiQuanLabA:setAnchorPoint(cc.p(0, 0.5))
    m_HuaFeiQuanLabA:setString(string.format("%d", CMyUserDataInfo:GetInstance():GetMyUserData().dwPhoneFare))
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_HuaFeiQuanLabA)

    --ob percent
    local gamelevel = 0
    local viplevel = 0
    local percent_gamelevel = 0
    local percent_viplevel = 0
    local isVip = MyUserData.isVip

    for i = 1, 100 do
        if MyUserData:GetExperience() < gameExprience[i] then
            gamelevel = i - 1
            percent_gamelevel = (MyUserData:GetExperience() - gameExprience[i-1]) / (gameExprience[i] - gameExprience[i-1])
            break
        elseif (i==100 and (MyUserData:GetExperience() >= gameExprience[i])) then
            gamelevel = 99
            percent_gamelevel = 0
        end
    end

    if isVip then
        for i=2,8 do
            if MyUserData:GetMemberPoint() < vipExprience[i] then
                viplevel = i-1
                percent_viplevel = (MyUserData:GetMemberPoint() - vipExprience[i-1]) / (vipExprience[i] - vipExprience[i-1])
                break
            elseif (i == 8 and MyUserData:GetMemberPoint() >= vipExprience[i]) then
                viplevel = 8
                percent_viplevel = 0
            end
        end
    end

    local m_gameLevelLabA = cc.Label:createWithCharMap("316_personal_num_level.png", 19, 23, string.byte("0"))
    m_gameLevelLabA:setPosition(647, 225)
    m_gameLevelLabA:setString(string.format("%d",gamelevel))
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_gameLevelLabA)

    local m_vipLevelLabA = cc.Label:createWithCharMap("316_personal_num_level.png", 19, 23, string.byte("0"))
    m_vipLevelLabA:setPosition(647, 142)
    m_vipLevelLabA:setString(string.format("%d",viplevel))
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_vipLevelLabA)

    if isVip then
         if MyUserData ~= nil then
            local y = MyUserData:GetMemberOverDate().wYear
            local m = MyUserData:GetMemberOverDate().wMonth
            local d = MyUserData:GetMemberOverDate().wDay
            
            ttfConfig.fontFilePath = "default.ttf"
            ttfConfig.fontSize     = 25
            local szstr = string.format("%d-%d-%d", MyUserData:GetMemberOverDate().wYear, MyUserData:GetMemberOverDate().wMonth, MyUserData:GetMemberOverDate().wDay) .. CUtilEx:getString("0_grzx_vip_deadtime")
            local m_vipDataTimeLab = cc.Label:createWithTTF(ttfConfig, szstr)
            m_vipDataTimeLab:setPosition(1020, 114)
            m_vipDataTimeLab:setColor(cc.c3b(107, 9, 9))
            m_vipDataTimeLab:setAnchorPoint(cc.p(1, 0.5))
            self.m_pSlipBaseLayer.m_functionBg:addChild(m_vipDataTimeLab)
         end
    end

    --Progress loading
    local pProgressBg1 = cc.Sprite:create("316_personal_exp_bg.png")
    pProgressBg1:setPosition(665, 224)
    pProgressBg1:setAnchorPoint(cc.p(0, 0.5))
    self.m_pSlipBaseLayer.m_functionBg:addChild(pProgressBg1)

    local pProgressBg2 = cc.Sprite:create("316_personal_vip_bg.png")
    pProgressBg2:setPosition(665, 140)
    pProgressBg2:setAnchorPoint(cc.p(0, 0.5))
    self.m_pSlipBaseLayer.m_functionBg:addChild(pProgressBg2)

    local pPTimer1 = cc.ProgressTimer:create(cc.Sprite:create("316_personal_exp_bar.png"))
    pPTimer1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    pPTimer1:setMidpoint(cc.p(0, 0))
    pPTimer1:setBarChangeRate(cc.p(1, 0))
    pPTimer1:setAnchorPoint(cc.p(0, 0.5))
    pPTimer1:setPosition(pProgressBg1:getPosition())
    pPTimer1:setPercentage(percent_gamelevel*100)
    self.m_pSlipBaseLayer.m_functionBg:addChild(pPTimer1, 1)

    local pPTimer2 = cc.ProgressTimer:create(cc.Sprite:create("316_personal_vip_bar.png"))
    pPTimer2:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    pPTimer2:setMidpoint(cc.p(0, 0))
    pPTimer2:setBarChangeRate(cc.p(1, 0))
    pPTimer2:setAnchorPoint(cc.p(0, 0.5))
    pPTimer2:setPosition(pProgressBg2:getPosition())
    pPTimer2:setPercentage(percent_viplevel*100)
    self.m_pSlipBaseLayer.m_functionBg:addChild(pPTimer2, 1)

    local m_btModifyPwd = CImageButton:Create("316_personal_bt_pswd0.png","316_personal_bt_pswd1.png", IDI_BT_PERSONAL_XGMM_316)
    m_btModifyPwd:setPosition(946, 309)
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_btModifyPwd)

    local m_btAward = CImageButton:Create("316_personal_bt_award0.png","316_personal_bt_award1.png", IDI_BT_PERSONAL_AWARD_316)
    m_btAward:setPosition(988, 227)
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_btAward)

    local m_btPerfect = CImageButton:Create("316_personal_bt_perfect.png","316_personal_bt_perfect.png", IDI_BT_PERSONAL_PERFECT_316)
    m_btPerfect:setPosition(210, 110)
    m_btPerfect:SetEffect(true, BE_SCALE, m_scalex, m_scaley)
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_btPerfect)

    local m_btBingPhone = CImageButton:Create("316_personal_bt_phone.png","316_personal_bt_phone.png", IDI_BT_PERSONAL_BING_316)
    m_btBingPhone:setPosition(360, 110)
    m_btBingPhone:SetEffect(true, BE_SCALE, m_scalex, m_scaley)
    self.m_pSlipBaseLayer.m_functionBg:addChild(m_btBingPhone)

    local eventDispatcher = self:getEventDispatcher()
    local listener = nil
    listener = cc.EventListenerCustom:create("OnDialogClickEvent", handler(self, self.OnDialogClickEvent))
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    --ScriptHandlerMgr
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btClose, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btChangeFace, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_btModifyPwd, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_btAward, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_btPerfect, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_btBingPhone, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end

-- function OnGroupCheckEvent
function ASMJ_PersonalView:OnGroupCheckEvent(groupcheckcmd)
    print("ASMJ_PersonalView:OnGroupCheckEvent " .. groupcheckcmd:getnGroupID() .. "," .. groupcheckcmd:getnTag())

    if groupcheckcmd:getnGroupID() == IDI_RG_UVIEW_GENDER_316 then
        self:OnGenderModeCheckEvent(groupcheckcmd:getnTag())
    end
end

function ASMJ_PersonalView:OnGenderModeCheckEvent(nTag)

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteBYTEToBuffers(nTag == IDI_RBT_UVIEW_BOY_316 and GENDER_MANKIND or GENDER_FEMALE)
    CClientKernel:GetInstance():WriteDWORDToBuffers(ASMJ_MyUserItem:GetInstance():GetUserID())
    CClientKernel:GetInstance():WritecharToBuffers(ASMJ_MyUserItem:GetInstance():GetPassword(),33,true)

    if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_MODIFY_INDIVIDUAL) then
        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    else
        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
    end
end

--ctor()
function ASMJ_PersonalView:ctor(tex_bg)
    print("ASMJ_PersonalView:ctor")

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
function ASMJ_PersonalView:onEnter()
    print("ASMJ_PersonalView:onEnter")

    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(CClientKernel:GetInstance(), "cc.Ref"), handler(self, self.HanderMessage), cc.Handler.EVENT_CUSTOMCMD)
end

--onExit()
function ASMJ_PersonalView:onExit()
    print("ASMJ_PersonalView:onExit")
end

--create( ... )
function ASMJ_PersonalView.create(tex_bg)
    print("ASMJ_PersonalView")
    local layer = ASMJ_PersonalView.new(tex_bg)
    return layer
end

--[====[   ASMJ_PersonalView_createScene()  ]====]
function ASMJ_PersonalView_createScene(tex_bg)
    print("ASMJ_PersonalView_createScene")
    local scene = cc.Scene:create()
    scene:addChild(ASMJ_PersonalView.create(tex_bg), 0)
    return scene
end