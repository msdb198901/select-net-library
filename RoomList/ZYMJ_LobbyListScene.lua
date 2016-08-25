require "src/app/Game/AnShunMaJiang/Function/ASMJ_SlipBaseView"
require "src/app/Game/AnShunMaJiang/Function/ASMJ_FaceView"
require "src/app/Game/AnShunMaJiang/Function/ASMJ_PersonalView"
require "src/app/Game/AnShunMaJiang/Function/ASMJ_BankView"
require "src/app/Game/AnShunMaJiang/Function/ASMJ_ServiceView"

require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomShareDialog"
require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomReceiveJJDialog"

require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomXSScrollView"
require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomXSItemView"
require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomXSIntroduce"

require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomCGScrollView"
require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomCGItemView"
require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomCGIntroduce"

require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomFLScrollView"
require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomFLItemView"
require "src/app/Game/AnShunMaJiang/RoomList/ASMJ_RoomFLIntroduce"


require "src/app/Game/AnShunMaJiang/Game/ASMJ_GameClientView"



local ASMJ_LobbyListScene = class("ASMJ_LobbyListScene", function() return cc.Layer:create() end)
--ASMJ_LobbyListScene.__index = ASMJ_LobbyListScene

-----------------------------------------function OnClickEvent-------------------
function ASMJ_LobbyListScene:OnClickEvent(clickcmd)
    print("ASMJ_LobbyListScene:OnClickEvent " .. clickcmd:getnTag())
    
    ccexp.AudioEngine:play2d("316_game_select.MP3", false, 1)

    if clickcmd:getnTag() == IDI_BT_LOBBY_BACK_316  then

        local ani1 = cc.MoveBy:create(0.05, cc.p(0, -20))
        local ani2 = cc.MoveBy:create(0.05, cc.p(0, 30))
        local ani3 = cc.MoveBy:create(0.05, cc.p(0, -10))
        local func = cc.CallFunc:create(
            function ()
                if self.m_iCurrentRoomType == ERT_XS_316 then
                    self:SkipRoom(ERT_GJ_316)
                elseif self.m_iCurrentRoomType <= ERT_GJ_316 then
                    local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_room_exit"), "316_popup_ok", "316_popup_cancel", self, self, true)    
                    dialog:setTag(IDI_POPUP_BACK_HALL_316)
                elseif self.m_iCurrentRoomType == ERT_FL_316 then
                    self:SkipRoom(ERT_GJ_316)
                end
            end
            )
        local seq = cc.Sequence:create(ani1, ani2, ani3, func)
        self.m_pBackBg:stopAllActions()
        self.m_pBackBg:setPosition(self.m_ptBackFinal)
        self.m_pBackBg:runAction(seq)

    elseif clickcmd:getnTag() == IDI_BT_LOBBY_SERVICE_316 then
        
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local m_scalex = display.scalex_landscape
        local m_scaley = display.scaley_landscape
        local renderTexture = cc.RenderTexture:create(visibleSize.width, visibleSize.height)
        renderTexture:begin()
        self:visit()
        renderTexture:endToLua()
        local pServiceScene = ASMJ_ServiceView_createScene(renderTexture:getSprite():getTexture())
        cc.Director:getInstance():pushScene(pServiceScene)

    elseif clickcmd:getnTag() == IDI_BT_LOBBY_BANK_316 then
        
        local dwUserID = ASMJ_MyUserItem:GetInstance():GetUserID()
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteDWORDToBuffers(dwUserID)
        if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_QUERY_INSURE_INFO) then
            ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
        else
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
        end

    elseif clickcmd:getnTag() == IDI_BT_LOBBY_FACE_316 or
        -- todo
    clickcmd:getnTag() == IDI_BT_LOBBY_PERSONAL_316 then

        self:TransitePersonal()

    elseif clickcmd:getnTag() == IDI_BT_LOBBY_FLUSH_GOLD_316 then
        self:FlushGold()
    --------------------------------------   
    elseif clickcmd:getnTag() == IDI_BT_LOBBY_RANK_316 or
        --todo
    clickcmd:getnTag() == IDI_BT_LOBBY_FRIEND_316 or
            --todo    
    clickcmd:getnTag() == IDI_BT_LOBBY_AWARD_316 or
    
    clickcmd:getnTag() == IDI_BT_LOBBY_RECHARGE_316 then

        local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("0_dialog_notify_0"), "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)

    end
end

--back hall
function ASMJ_LobbyListScene:BackHall()
    --delete resource
    ASMJ_CServerManager:ReleaseInstance()
    ASMJ_ClientUserManager:ReleaseInstance()

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    if (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        PlatAndroid:ChangePortrait(visibleSize.height, visibleSize.width)

    elseif (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        PlatAndroid:ChangePortrait(visibleSize.height, visibleSize.width)

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        
    end

    local reScene = CGameListScene_createScene()
    if reScene then
        cc.Director:getInstance():replaceScene( cc.TransitionSlideInR:create(TIME_SCENE_CHANGE, reScene) )
    end
end

--function RefreshYX
function ASMJ_LobbyListScene:TransitePersonal()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape
    local renderTexture = cc.RenderTexture:create(visibleSize.width, visibleSize.height)
    renderTexture:begin()
    self:visit()
    renderTexture:endToLua()
    local pServiceScene = ASMJ_PersonalView_createScene(renderTexture:getSprite():getTexture())
    cc.Director:getInstance():pushScene(pServiceScene)
end

--back hall
function ASMJ_LobbyListScene:FlushGold()

    CClientKernel:GetInstance():ResetBuffers()
    CClientKernel:GetInstance():WriteDWORDToBuffers(ASMJ_MyUserItem:GetInstance():GetUserID())
    CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_QUERY_TREASURE)

    local pBtFlushGold = self:getChildByTag(IDI_BT_LOBBY_FLUSH_GOLD_316)
    if pBtFlushGold ~= nil then

        pBtFlushGold:runAction(
            cc.Sequence:create(
                cc.CallFunc:create(
                    function ()
                        pBtFlushGold:SetClickable(false)
                        pBtFlushGold:SetImg("316_room_flush_bt_gray0.png", "316_room_flush_bt_gray0.png")
                    end),
                cc.DelayTime:create(10),
                cc.CallFunc:create(
                    function ()
                        pBtFlushGold:SetClickable(true)
                        pBtFlushGold:SetImg("316_room_flush_bt_light0.png", "316_room_flush_bt_light1.png")
                    end)
                )
            )
    end
end

function ASMJ_LobbyListScene:ReceiveJiuJi()
    local pReceiveJJDialog = ASMJ_RoomReceiveJJDialog_ShowDialog(self.m_cbCanGetAlms, "316_alms_bt_", "316_alms_bt_", self, self, true)
    pReceiveJJDialog:setTag(IDI_DIALOG_ALMS_316)
end

-----------------------------------------function HanderMessage-------------------
function ASMJ_LobbyListScene:HanderMessage(msgcmd)

    if msgcmd:getMainCmdID() == MDM_GR_LOGON or msgcmd:getMainCmdID() == MDM_MB_LOGON then
        self:OnSocketLogon(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GR_FAST_MODE  then
        self:onFastMode(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GR_USER then
        self:OnUserInfoEvent(msgcmd)
    elseif msgcmd:getMainCmdID() == MDM_GR_MATCH then
        self:OnMatchEvent(msgcmd)
    end
end

--function onUserServiceEvent
function ASMJ_LobbyListScene:onUserServiceEvent(msgcmd)
    print("ASMJ_LobbyListScene:onUserServiceEvent")
    if msgcmd:getSubCmdID() == SUB_GP_USER_INSURE_INFO then
      
        ASMJ_Toast_Dismiss()

        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local m_scalex = display.scalex_landscape
        local m_scaley = display.scaley_landscape
        local renderTexture = cc.RenderTexture:create(visibleSize.width, visibleSize.height)
        renderTexture:begin()
        self:visit()
        renderTexture:endToLua()
        local pServiceScene = ASMJ_BankView_createScene(renderTexture:getSprite():getTexture())
        cc.Director:getInstance():pushScene(pServiceScene)

    elseif msgcmd:getSubCmdID() == SUB_GP_USER_TREASURE then
        -- read data
        local dwUserID      = msgcmd:readDWORD()
        local dwUserMedal   = msgcmd:readDWORD()
        local cbIngotFlags  = msgcmd:readBYTE()
        local lUserGold     = msgcmd:readLONGLONG()
        local lUserInsure   = msgcmd:readLONGLONG()
        local lUserIngot    = msgcmd:readdouble()
        ---------
        local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
        if myItem:GetUserID() == dwUserID then
            myItem.dwUserMedal = dwUserMedal
            myItem.lScore = lUserGold
            myItem.lInsure = lUserInsure
            myItem.lUserIngot = lUserIngot
            myItem.lGoldA = lUserGold

            self.m_scoreLab:setString(CUtilEx:subStringWithFormatNumCount(lUserGold, 8, "///"))
            self.m_jpLab:setString(CUtilEx:subStringWithFormatNumCount(dwUserMedal, 8, "///"))
        end
    elseif msgcmd:getSubCmdID() == SUB_GP_QUERY_CAN_GET_ALMS_RESULT then
        -- read data
                                msgcmd:readDWORD()
	    self.m_cbCanGetAlms  = {msgcmd:readBYTE(), msgcmd:readBYTE()}
        -----------
        local bShow = false
		local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
        if (self.m_cbCanGetAlms[1] == 1 or self.m_cbCanGetAlms[2] == 1) and 
           (myItem:GetGoldA() + myItem:GetInsure() < CS_ALMS_GOLD_FLOOR_316) then
            bShow = true
        end
        self.m_btJJ:setVisible(bShow)

    elseif msgcmd:getSubCmdID() == SUB_GP_GET_ALMS_RESULT then

        ASMJ_Toast_Dismiss()

        --read data
        local cbType            = msgcmd:readBYTE()
        local lReliefAlmsNumber = msgcmd:readLONGLONG()
        local lResultCode       = msgcmd:readLONG()
        local szDescribeString  = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)
        -------
        local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)
        
        if lResultCode == 0 then
            local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
            myItem.lScore = myItem.lScore + lReliefAlmsNumber
            myItem.lGoldA = myItem.lScore

            self.m_scoreLab:setString(CUtilEx:subStringWithFormatNumCount(lGoldA, 8, "///"))
            self.m_btJJ:setVisible(myItem:GetGoldA() + myItem:GetInsure() < CS_ALMS_GOLD_FLOOR_316 and true or false)
        end
    end
end

--function OnSocketLogon
function ASMJ_LobbyListScene:OnSocketLogon(msgcmd)
    print("ASMJ_LobbyListScene:OnSocketLogon")

    ASMJ_Toast_Dismiss()

    if msgcmd:getSubCmdID() == SUB_GR_LOGON_SUCCESS then

        CClientKernel:GetInstance():UpdataLoginInfo()
        CAccountListView:Reload()

    elseif msgcmd:getSubCmdID() == SUB_GR_LOGON_FAILURE then
        msgcmd:readLONG()
        local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)

        print("szDescribeString", szDescribeString)
        local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316) 

        CClientKernel:GetInstance():CloseRoomThread()

    elseif msgcmd:getSubCmdID() == SUB_GR_LOGON_FINISH then
        
        local m_scalex = display.scalex_landscape
        local m_scaley = display.scaley_landscape

        local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
    
        local cbAllowLookon = 0
        local dwFrameVersion = 101056515
        local dwClientVersion = 102301699
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteBYTEToBuffers(cbAllowLookon)
        CClientKernel:GetInstance():WriteDWORDToBuffers(dwFrameVersion)
        CClientKernel:GetInstance():WriteDWORDToBuffers(dwClientVersion)
        CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_FRAME, SUB_GF_GAME_OPTION)
        
        self:onHideBottom()

        if iRoomType == ERT_XS_316 then
            
            local iRoomXSIndex = ASMJ_CServerManager:GetInstance():GetOnClickRoomIndex()
            local m_roomXSIntroduceLayer = ASMJ_RoomXSIntroduce_create()
            self:addChild(m_roomXSIntroduceLayer, 1000)

        elseif iRoomType <= ERT_GJ_316  then

            local m_roomCGIntroduceLayer = ASMJ_RoomCGIntroduce_create(iRoomType)
            self:addChild(m_roomCGIntroduceLayer, 1000)
   
        end

    elseif msgcmd:getSubCmdID() == SUB_MB_UPDATE_NOTIFY then
        
        local cmd = msgcmd:getBuffer()
        tolua.cast(cmd, "CMD_MB_UpdateNotify")

    ----------------------MDM_MB_LOGON-------------------------
    elseif msgcmd:getSubCmdID() == SUB_GF_GAME_STATUS then
        
        local pOffLine = ASMJ_MyUserItem:GetInstance():GetOffLine()
        pOffLine.cbGameStatus = msgcmd:readBYTE()

    elseif msgcmd:getSubCmdID() == SUB_GF_GAME_SCENE then
        
        local pOffLine = ASMJ_MyUserItem:GetInstance():GetOffLine()
        if pOffLine.cbGameStatus == GS_MJ_FREE_316 then

        elseif pOffLine.cbGameStatus == GS_MJ_PLAY_316 then
            
            ASMJ_MyUserItem:GetInstance():SetOffLine(msgcmd)

            ASMJ_CServerManager:GetInstance():SetEntryRoomStatus(ES_CG_Play_316)
            local reScene = ASMJ_GameClientView_createScene()
            if reScene then
                cc.Director:getInstance():replaceScene( cc.TransitionSlideInR:create(TIME_SCENE_CHANGE, reScene) )
            end
        end
    end
end

--function onUserServiceEvent
function ASMJ_LobbyListScene:onFastMode(msgcmd)
    print("ASMJ_LobbyListScene:onFastMode")
    if msgcmd:getSubCmdID() == SUB_GR_FAST_SIGNUP_RESULT then
        ASMJ_Toast_Dismiss()

        local cbResultCode = msgcmd:readBYTE()
        local wLastTime = msgcmd:readWORD()
        local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(256), 256)
            
        if cbResultCode == 1 then
            ASMJ_CServerManager:GetInstance():SetEntryRoomStatus(ES_CG_Free_316)
            local reScene = ASMJ_GameClientView_createScene()
            if reScene then
                cc.Director:getInstance():replaceScene( cc.TransitionSlideInR:create(TIME_SCENE_CHANGE, reScene) )
            end
        else
            local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()--CClientKernel:GetInstance():GetMyUserData()
            if not MyUserData then
                return
            end
            
            local lUserScore = MyUserData:GetGoldA() + MyUserData:GetInsure()
            local iRoomType = ASMJ_CServerManager:GetInstance():GetOnClickRoomType()
            print("ASMJ_LobbyListScene172", iRoomType)
            if iRoomType <= ERT_GJ_316 then
                local lRoomGold = {ROOM_XS_ENTER_GOLD_316, ROOM_CJ_ENTER_GOLD_316, ROOM_GJ_ENTER_GOLD_316}
                if MyUserData:GetGoldA() < lRoomGold[iRoomType] then 
                    local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
                    dialog:setTag(IDI_POPUP_OK_316)
                    return 
                end
            end

            local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
        end
    end
end

function ASMJ_LobbyListScene:OnUserInfoEvent(msgcmd)
    print("ASMJ_LobbyListScene:OnUserInfoEvent", msgcmd:getSubCmdID())
    if msgcmd:getSubCmdID() == SUB_GR_USER_ENTER then
        
        ASMJ_ClientUserManager:GetInstance():UpdataItem_Cmd(msgcmd)
        -- restart 
        msgcmd:SetPos(4)
        local dwUserID = msgcmd:readDWORD()
        if dwUserID == ASMJ_MyUserItem:GetInstance():GetUserID() then
            msgcmd:SetPos(0)
            ASMJ_MyUserItem:GetInstance():UpdataItem_Cmd(msgcmd)
        end

        --if (CClientKernel:GetInstance():GetMyUserData():wTableID == cmd:wTableID)
        --CClientKernel:SendMsg(MDM_GR_USER, SUB_GR_USER_STATUS, pBuffer, len)

    elseif msgcmd:getSubCmdID() == SUB_GR_USER_SELF_STANDUP then
        
        local dwUserID = ASMJ_MyUserItem:GetInstance():GetUserID()
        ASMJ_ClientUserManager:GetInstance():ResetOtherList(dwUserID)

    elseif msgcmd:getSubCmdID() == SUB_GR_REQUEST_FAILURE then
        ASMJ_Toast_Dismiss()

        local lErrorCode = msgcmd:readLONG()
        local szDescribeString = CMCipher:g2u_forlua(msgcmd:readChars(256), 256)
        local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
        dialog:setTag(IDI_POPUP_OK_316)

    elseif msgcmd:getSubCmdID() == SUB_GR_USER_STATUS then
        
        local dwUserID = msgcmd:readDWORD()
        local wTableID = msgcmd:readWORD()
        local wChairID = msgcmd:readWORD() + 1
        local cbUserStatus = msgcmd:readBYTE()

        local UserItem = ASMJ_ClientUserManager:GetInstance():SeachByUserID(dwUserID)
        if UserItem ~= nil then
            UserItem.wTableID = wTableID
            UserItem.wChairID = wChairID
            UserItem.cbUserStatus = cbUserStatus
        end

        if dwUserID == ASMJ_MyUserItem:GetInstance():GetUserID() then
            local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
            if (cbUserStatus ~= US_SIT) and (myItem.cbUserStatus ~= US_PLAYING) then
                -- offline ReEntry game option
                local cbAllowLookon = 0
                local dwFrameVersion = 101056515
                local dwClientVersion = 102301699
                CClientKernel:GetInstance():ResetBuffers()
                CClientKernel:GetInstance():WriteBYTEToBuffers(cbAllowLookon)
                CClientKernel:GetInstance():WriteDWORDToBuffers(dwFrameVersion)
                CClientKernel:GetInstance():WriteDWORDToBuffers(dwClientVersion)
                CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_FRAME, SUB_GF_GAME_OPTION)
            end
            myItem.wTableID     = wTableID
            myItem.wChairID     = wChairID
            myItem.cbUserStatus = cbUserStatus
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_USER_SCORE then

        local dwUserID = msgcmd:readDWORD()
        local lScore = msgcmd:readLONGLONG()         
        local lGrade = msgcmd:readLONGLONG()        
        local lInsure = msgcmd:readLONGLONG()     
        local lGoldA = msgcmd:readLONGLONG()   
        local dwRankScore = msgcmd:readDWORD()  
        local dwWinCount = msgcmd:readDWORD()   
        local dwLostCount = msgcmd:readDWORD()  
        local dwDrawCount = msgcmd:readDWORD()  
        local dwFleeCount = msgcmd:readDWORD()   
        local dwUserMedal = msgcmd:readDWORD()   
        local dwExperience = msgcmd:readDWORD()  
        local dwMatchTiket = msgcmd:readDWORD() 
        local lLoveLiness = msgcmd:readLONG()   

        local UserItem = ASMJ_ClientUserManager:GetInstance():SeachByUserID(dwUserID)
        if UserItem ~= nil then
            UserItem.dwWinCount = dwWinCount
            UserItem.dwLostCount = dwLostCount
            UserItem.dwDrawCount = dwDrawCount
            UserItem.dwFleeCount = dwFleeCount
            UserItem.dwUserMedal = dwUserMedal
            UserItem.dwExperience = dwExperience
            UserItem.dwMatchTiket = dwMatchTiket

            UserItem.lGrade = lGrade
            UserItem.lInsure = lInsure

            UserItem.lScore = lScore
            UserItem.lGoldA = lGoldA
        end

        local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
        if myItem ~= nil and myItem:GetUserID() == dwUserID then
            myItem.dwWinCount = dwWinCount
            myItem.dwLostCount = dwLostCount
            myItem.dwDrawCount = dwDrawCount
            myItem.dwFleeCount = dwFleeCount
            myItem.dwUserMedal = dwUserMedal
            myItem.dwExperience = dwExperience
            myItem.dwMatchTiket = dwMatchTiket

            myItem.lGrade = lGrade
            myItem.lInsure = lInsure

            myItem.lScore = lScore
            myItem.lGoldA = lGoldA

            self.m_scoreLab:setString(CUtilEx:subStringWithFormatNumCount(lGoldA, 8, "///"))
            self.m_jpLab:setString(CUtilEx:subStringWithFormatNumCount(dwUserMedal, 8, "///"))
        end
 
    ----------------------MDM_GP_USER_SERVICE-------------------
    elseif msgcmd:getSubCmdID() == SUB_GP_USER_INSURE_INFO  or 
           msgcmd:getSubCmdID() == SUB_GP_USER_TREASURE     or
           msgcmd:getSubCmdID() == SUB_GP_QUERY_CAN_GET_ALMS_RESULT or
           msgcmd:getSubCmdID() == SUB_GP_GET_ALMS_RESULT   then
        self:onUserServiceEvent(msgcmd)
    end
end


function ASMJ_LobbyListScene:OnMatchEvent(msgcmd)
    if msgcmd:getSubCmdID() == SUB_GR_MATCH_FEE then
    
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteBYTEToBuffers(0)
        CClientKernel:GetInstance():WriteWORDToBuffers(FEE_TYPE_GOLDA)
        CClientKernel:GetInstance():SendSocketToGameServer(MDM_GR_MATCH, SUB_GR_MATCH_FEE)

    elseif msgcmd:getSubCmdID() == SUB_GR_NEW_MATCH_OPTION then

        ASMJ_Toast_Dismiss()
                                msgcmd:SetPos(4+4+4+1) 
        local cbMatchStatus  =  msgcmd:readBYTE()
                                msgcmd:SetPos(237-4)
        local dwServerTime   =  msgcmd:readDWORD()    
        print("ASMJ_RoomFLListScene:OnMatchEvent")
        print("cbMatchStatus", cbMatchStatus)
        print("dwServerTime", dwServerTime)
       
        ASMJ_MyUserItem:GetInstance():SetMatchStatus(cbMatchStatus)
        ASMJ_MyUserItem:GetInstance():SetMatchCurrentServerTime(dwServerTime)
        ASMJ_MyUserItem:GetInstance():SetMatchCurrentLocalTime(os.time())

        local pMyItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()
        if cbMatchStatus == MS_MATCHING and pMyItem:GetUserStatus() ~= US_PLAYING then
            ASMJ_CServerManager:GetInstance():SetEntryRoomStatus(ES_FL_Play_Free_316)
            local reScene = ASMJ_GameClientView_createScene()
            if reScene then
                cc.Director:getInstance():replaceScene( cc.TransitionSlideInR:create(TIME_SCENE_CHANGE, reScene) )
            end
        end

        self:onHideBottom()

        local iIndex= ASMJ_CServerManager:GetInstance():GetOnClickRoomIndex()
        local m_roomFLIntroduceLayer = ASMJ_RoomFLIntroduce_create(iIndex)
        self:addChild(m_roomFLIntroduceLayer, 1000)

    elseif msgcmd:getSubCmdID() == SUB_GR_MATCH_JIONQUUIT_RESULT then
        
        ASMJ_Toast_Dismiss()

        local cbResult          = msgcmd:readBYTE()
                                  msgcmd:readBYTE()
        local cbMatchStatus     = msgcmd:readBYTE()
                                  msgcmd:readLONGLONG()  
                                  msgcmd:readDWORD()
                                  msgcmd:readWORD()  
        local szDescribeString  = CMCipher:g2u_forlua(msgcmd:readChars(128), 128)                           

        if cbResult == 0 and  cbMatchStatus == MS_SIGNUP then
            ASMJ_CServerManager:GetInstance():SetEntryRoomStatus(ES_FL_Free_316)
            local reScene = ASMJ_GameClientView_createScene()
            if reScene then
                cc.Director:getInstance():replaceScene( cc.TransitionSlideInR:create(TIME_SCENE_CHANGE, reScene) )
            end
        else
            -- CClientKernel:GetInstance():CloseRoomThread()
            local dialog = ASMJ_PopupBox_ShowDialog(szDescribeString, "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
        end

    elseif msgcmd:getSubCmdID() == SUB_GR_NEW_MATCH_SENCE_INFO then

        --read data
        local dwMatchID     = msgcmd:readDWORD()
        local dwMatchNo     = msgcmd:readDWORD()
        local dwStartTime   = msgcmd:readDWORD()
        local wSenceIndex   = msgcmd:readBYTE()
        local wTableRank    = msgcmd:readBYTE()
        local dwBaseScore   = msgcmd:readDWORD()
        local dwTotalCount  = msgcmd:readWORD()
        local dwRank        = msgcmd:readWORD()
        local dwPlayCount   = msgcmd:readWORD()
        local dwGameCount   = msgcmd:readWORD()
        local dwMatchTime   = msgcmd:readWORD()
        local dwEndCount    = msgcmd:readWORD()
        local dwPromtCount  = msgcmd:readWORD()
        --------

        local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()
        pMatchAttribute.dwMatchID = dwMatchID
        pMatchAttribute.dwMatchNo = dwMatchNo
        pMatchAttribute.wMatchSenceIndex = wSenceIndex
        pMatchAttribute.dwNowBaseScore = dwBaseScore
        pMatchAttribute.dwMatchTime = dwMatchTime + os.time()
        pMatchAttribute.dwMatchStartTime = dwStartTime
        pMatchAttribute.dwTotalCount = dwTotalCount
        pMatchAttribute.dwCurRank = dwRank
        pMatchAttribute.dwEndCount = dwEndCount
        pMatchAttribute.dwPromtCount = dwPromtCount
        pMatchAttribute.dwTableRank = wTableRank
        pMatchAttribute.wContiunePlayCount = dwGameCount
        pMatchAttribute.wGameCount = dwPlayCount

    elseif msgcmd:getSubCmdID() == SUB_GR_MATCH_GAMECOUNT then

        -- read data
        local wGameCount        = msgcmd:readWORD()
        local lBaseScore        = msgcmd:readDWORD()
        local wTableRank        = msgcmd:readBYTE()
        local wCurSenceIndex    = msgcmd:readBYTE()
        local dwUserIDArry      = {}
        for i=1,4 do
            dwUserIDArry[i]     = msgcmd:readDWORD()
        end

        local wRankArry         = {}
        for i=1,4 do
            wRankArry[i]        = msgcmd:readBYTE()
        end
        ----------
        local pMatchAttribute = ASMJ_MyUserItem:GetInstance():GetMatchAttribute()

        pMatchAttribute.wGameCount = wGameCount
        pMatchAttribute.dwNowBaseScore = lBaseScore
        pMatchAttribute.dwTableRank = wTableRank
        pMatchAttribute.wMatchSenceIndex = wCurSenceIndex

        for i=1,4 do
            pMatchAttribute.dwUserIDArry[i] = dwUserIDArry[i]
            pMatchAttribute.wRankArry[i] = wRankArry[i]
        end
    end
end

-----------------------------------------virtual function-----------------------------
-- OnDialogClickEvent
function ASMJ_LobbyListScene:OnDialogClickEvent(event)
    print("ASMJ_LobbyListScene OnDialogClickEvent: tag = " .. event.node:getTag())
   
    if event.node:getTag() == IDI_POPUP_BACK_HALL_316 then
        if event.clickevent == "ok" then
            self:BackHall()
        end
    elseif event.node:getTag() == IDI_POPUP_MATCH_PROMPT_316 then
        if event.clickevent == "ok" then
            local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()--CClientKernel:GetInstance():GetMyUserData()
            if MyUserData and MyUserData:GetUserStatus() ~= US_PLAYING then
                -- ready
                CClientKernel:GetInstance():ResetBuffers()
                CClientKernel:GetInstance():SendSocketToGameServer(MDM_GF_FRAME, SUB_GF_USER_READY)

                -- sit down
                local wTableID = 65535
                local wChairID = 65535
                local szPassword = ""
                CClientKernel:GetInstance():ResetBuffers()
                CClientKernel:GetInstance():WriteWORDToBuffers(wTableID)
                CClientKernel:GetInstance():WriteWORDToBuffers(wChairID)
                CClientKernel:GetInstance():WritecharToBuffers(szPassword,33)
       
                if CClientKernel:GetInstance():SendSocketToGameServer(MDM_GR_USER, SUB_GR_USER_SITDOWN) then
                    ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
                else
                    local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
                    dialog:setTag(IDI_POPUP_OK_316)
                end
            end
        else
            -- CClientKernel:GetInstance():CloseRoomThread()
        end

    elseif event.node:getTag() == IDI_DIALOG_ALMS_316 then
        event.node:removeFromParent()
        if event.clickevent == "ok" then
            
        else
            CClientKernel:GetInstance():ResetBuffers()
            CClientKernel:GetInstance():WriteDWORDToBuffers(ASMJ_MyUserItem:GetInstance():GetUserID())
            CClientKernel:GetInstance():WriteBYTEToBuffers(1)
            if CClientKernel:GetInstance():SendSocketToLoginServer(MDM_GP_USER_SERVICE, SUB_GP_GET_ALMS_REQUEST) then
                ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
            else
                local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
                dialog:setTag(IDI_POPUP_OK_316)
            end
        end
    end
end

--onEnter()
function ASMJ_LobbyListScene:onEnter()
    print("ASMJ_LobbyListScene:onEnter")

    local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()
    local iScore = MyUserData and MyUserData:GetGoldA() or 0
    self.m_scoreLab:setString(CUtilEx:subStringWithFormatNumCount(iScore, 8, "///"))

    local m_userFaceImg = self:getChildByTag(IDI_BT_LOBBY_FACE_316)
    if m_userFaceImg ~= nil then
        m_userFaceImg:SetFaceID(MyUserData and MyUserData:GetFaceID() or -1)
    end

    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(CClientKernel:GetInstance(), "cc.Ref"), handler(self, self.HanderMessage), cc.Handler.EVENT_CUSTOMCMD)
end

--onExit()
function ASMJ_LobbyListScene:onExit()
    print("ASMJ_LobbyListScene:onExit")
end

--hello()
function ASMJ_LobbyListScene:SkipRoom(iRoomType)
    print("ASMJ_LobbyListScene:SkipRoom")

    if iRoomType == ERT_XS_316 then
    
        self.m_RoomCGScrollView:runAction(cc.MoveTo:create(0.2, self.m_ptRoomCGHide))

        local ani1 = cc.MoveTo:create(0.2, cc.p(self.m_ptRoomXSShow.x - 30, self.m_ptRoomXSShow.y))
        local ani2 = cc.MoveTo:create(0.1, cc.p(self.m_ptRoomXSShow.x + 20, self.m_ptRoomXSShow.y))
        local ani3 = cc.MoveTo:create(0.1, cc.p(self.m_ptRoomXSShow))
        self.m_RoomXSScrollView:runAction(cc.Sequence:create(ani1, ani2, ani3))

    elseif iRoomType <= ERT_GJ_316 then
        
        if self.m_iCurrentRoomType == ERT_XS_316 then
           
            self.m_RoomXSScrollView:runAction(cc.MoveTo:create(0.2, self.m_ptRoomXSHide))

            local ani1 = cc.MoveTo:create(0.2, cc.p(self.m_ptRoomCGShow.x + 30, self.m_ptRoomCGShow.y))
            local ani2 = cc.MoveTo:create(0.1, cc.p(self.m_ptRoomCGShow.x - 20, self.m_ptRoomCGShow.y))
            local ani3 = cc.MoveTo:create(0.1, cc.p(self.m_ptRoomCGShow))
            self.m_RoomCGScrollView:runAction(cc.Sequence:create(ani1, ani2, ani3))

        elseif self.m_iCurrentRoomType == ERT_FL_316 then
            
            self.m_RoomFLScrollView:runAction(cc.MoveTo:create(0.2, self.m_ptRoomFLHide))

            local ani1 = cc.MoveTo:create(0.2, cc.p(self.m_ptRoomCGShow.x + 30, self.m_ptRoomCGShow.y))
            local ani2 = cc.MoveTo:create(0.1, cc.p(self.m_ptRoomCGShow.x - 20, self.m_ptRoomCGShow.y))
            local ani3 = cc.MoveTo:create(0.1, cc.p(self.m_ptRoomCGShow))
            self.m_RoomCGScrollView:runAction(cc.Sequence:create(ani1, ani2, ani3))
        end

    elseif iRoomType <= ERT_FL_316 then

        self.m_RoomCGScrollView:runAction(cc.MoveTo:create(0.2, self.m_ptRoomCGHide))
        
        local ani1 = cc.MoveTo:create(0.2, cc.p(self.m_ptRoomFLShow.x - 30, self.m_ptRoomFLShow.y))
        local ani2 = cc.MoveTo:create(0.1, cc.p(self.m_ptRoomFLShow.x + 20, self.m_ptRoomFLShow.y))
        local ani3 = cc.MoveTo:create(0.1, cc.p(self.m_ptRoomFLShow))
        self.m_RoomFLScrollView:runAction(cc.Sequence:create(ani1, ani2, ani3))
    end

    self.m_iCurrentRoomType = iRoomType
end

-- onShowBottom
function ASMJ_LobbyListScene:onShowBottom()
    local ani1 = cc.MoveTo:create(0.5, self.m_ptBottomFinal)
    self.m_pBottom:stopAllActions()
    self.m_pBottom:setPosition(self.m_ptBottomOrigin)
    self.m_pBottom:runAction(ani1)

   local ani2 = cc.MoveTo:create(0.5, self.m_ptBackFinal)
   self.m_pBackBg:stopAllActions()
   self.m_pBackBg:setPosition(self.m_ptBackOrigin)
   self.m_pBackBg:runAction(ani2)
end

-- onHideBottom
function ASMJ_LobbyListScene:onHideBottom()
    local ani1 = cc.MoveTo:create(0.5, self.m_ptBottomOrigin)
    self.m_pBottom:stopAllActions()
    self.m_pBottom:setPosition(self.m_ptBottomFinal)
    self.m_pBottom:runAction(ani1)

   local ani2 = cc.MoveTo:create(0.5, self.m_ptBackOrigin)
   self.m_pBackBg:stopAllActions()
   self.m_pBackBg:setPosition(self.m_ptBackFinal)
   self.m_pBackBg:runAction(ani2)
end

--init()
function ASMJ_LobbyListScene:init()
    print("ASMJ_LobbyListScene:init")
    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    local m_scalex = display.scalex_landscape
    local m_scaley = display.scaley_landscape

	--background
    local m_roomBg = cc.Sprite:create("316_lobby_bg.png")
    m_roomBg:setPosition(m_visibleSize.width / 2, m_visibleSize.height / 2)
    m_roomBg:setScale(m_scalex, m_scaley)
    self:addChild(m_roomBg)

    -- light l 
    local pLightLImg = cc.Sprite:create("316_ani_light_l_01.png")
    pLightLImg:setScale(m_scalex, m_scaley)
    pLightLImg:setAnchorPoint(cc.p(0.5, 1))
    pLightLImg:setPosition(370*m_scalex, 635*m_scaley)
    self:addChild(pLightLImg, 1)

    local animationL = cc.Animation:create()
    for i=1,22 do
        local szName =string.format("316_ani_light_l_%02d.png", i)
        animationL:addSpriteFrameWithFile(szName)
    end  

    animationL:setDelayPerUnit(0.15)
    animationL:setLoops(1000)

    local animateL =cc.Animate:create(animationL) 
    pLightLImg:runAction(animateL)

    -- light R 
    local pLightRImg = cc.Sprite:create("316_ani_light_r_01.png")
    pLightRImg:setScale(m_scalex, m_scaley)
    pLightRImg:setAnchorPoint(cc.p(0.5, 1))
    pLightRImg:setPosition(770*m_scalex, 635*m_scaley)
    self:addChild(pLightRImg, 1)

    local animationR = cc.Animation:create()
    for i=1,22 do
        local szName =string.format("316_ani_light_r_%02d.png",i)
        animationR:addSpriteFrameWithFile(szName)
    end  

    animationR:setDelayPerUnit(0.18)
    animationR:setLoops(1000)

    local animateR =cc.Animate:create(animationR) 
    pLightRImg:runAction(animateR)

    -- left
    local pLeafImg = cc.Sprite:create("316_ani_leaf_01.png")
    pLeafImg:setScale(m_scalex, m_scaley)
    pLeafImg:setAnchorPoint(cc.p(0, 0))
    pLeafImg:setPosition(0,0)
    self:addChild(pLeafImg, 1)

    local animationLeaf = cc.Animation:create()
    for i=1,52 do
        local szName =string.format("316_ani_leaf_%02d.png",i)
        animationLeaf:addSpriteFrameWithFile(szName)
    end  

    animationLeaf:setDelayPerUnit(0.1)
    animationLeaf:setLoops(1000)
    local animateLeaf =cc.Animate:create(animationLeaf) 
    pLeafImg:runAction(cc.Sequence:create(animateLeaf, cc.DelayTime:create(2)))
    
    -- back bt
    self.m_ptBackOrigin = cc.p(50*m_scalex,  m_visibleSize.height + 60*m_scaley)
    self.m_ptBackFinal = cc.p(50*m_scalex,  m_visibleSize.height - 60*m_scaley)

    self.m_pBackBg = cc.Sprite:create("316_lobby_bt_return_bg.png")
    self.m_pBackBg:setScale(m_scalex, m_scaley)
    self.m_pBackBg:setPosition(self.m_ptBackOrigin)
    self:addChild(self.m_pBackBg, 5)

    local btBack = CImageButton:Create("316_lobby_bt_return0.png", "316_lobby_bt_return1.png", IDI_BT_LOBBY_BACK_316)
    btBack:setPosition(33, 47)
    self.m_pBackBg:addChild(btBack, 5)

    --user face
    local MyUserData = ASMJ_MyUserItem:GetInstance():GetMyUserData()--CClientKernel:GetInstance():GetMyUserData()
    local m_userFaceImg = ASMJ_FaceView_createLayer()--CFaceView:CreateWithFrameName("0_user_face.plist", "0_user_face.png", IDI_BT_LOBBY_FACE_316)
    m_userFaceImg:setScale(m_scalex, m_scaley)
    m_userFaceImg:setTag(IDI_BT_LOBBY_FACE_316)
    m_userFaceImg:SetFaceID(MyUserData and MyUserData:GetFaceID() or -1)-- a and b or c (b must true, otherwise return c)
    m_userFaceImg:setPosition(138 * m_scalex, m_visibleSize.height - 42 * m_scaley)
    self:addChild(m_userFaceImg, -1)

    --user name
    local txtsize = 22
    local m_nameLab =  cc.LabelTTF:create(CUtilEx:subStringWithFormatStrWidth(MyUserData and MyUserData:GetNickName() or "", 300, txtsize, m_scalex, m_scaley), "Arial", txtsize)
    m_nameLab:setScale(m_scalex, m_scaley)
    m_nameLab:setAnchorPoint(cc.p(0, 0.5))
    m_nameLab._eHorizAlign = cc.TEXT_ALIGNMENT_LEFT
    m_nameLab._eVertAlign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    m_nameLab:setPosition(186 * m_scalex, m_visibleSize.height - 34 * m_scaley)
    m_nameLab:setColor(cc.c3b(255, 255, 0))
    self:addChild(m_nameLab, 2)

    --label score
    local iScore = MyUserData and MyUserData:GetGoldA() or 0
    local ttfConfig = {}
    ttfConfig.fontFilePath = "default.ttf"
    ttfConfig.fontSize     = 22
    self.m_scoreLab = cc.Label:createWithTTF(ttfConfig, CUtilEx:subStringWithFormatNumCount(iScore, 8, "..."))
    self.m_scoreLab:setAnchorPoint(cc.p(0, 0.5))
    self.m_scoreLab:setScale(m_scalex, m_scaley)
    self.m_scoreLab:setPosition(830 * m_scalex, m_visibleSize.height - 33 * m_scaley)
    self.m_scoreLab:setColor(cc.c3b(255, 255, 0))
    self:addChild(self.m_scoreLab, 2)

    --buy add bt
    local m_btFlushGold = CImageButton:Create("316_lobby_bt_refresh0.png", "316_lobby_bt_refresh1.png", IDI_BT_LOBBY_FLUSH_GOLD_316)
    m_btFlushGold:setScale(m_scalex, m_scaley)
    m_btFlushGold:setPosition(955 * m_scalex, m_visibleSize.height - 35 * m_scaley)
    self:addChild(m_btFlushGold, 5)

    --label jp
    local iJiangpai = MyUserData and MyUserData:GetUserMedal() or 0
    self.m_jpLab = cc.Label:createWithTTF(ttfConfig, CUtilEx:subStringWithFormatNumCount(iJiangpai, 7, "..."))
    self.m_jpLab:setAnchorPoint(cc.p(0, 0.5))
    self.m_jpLab:setScale(m_scalex, m_scaley)
    self.m_jpLab:setPosition(1030 * m_scalex, m_visibleSize.height - 35 * m_scaley)
    self:addChild(self.m_jpLab, 2)

    -----------------------bottom------------------------
    self.m_ptBottomOrigin = cc.p(m_visibleSize.width/2, -70)
    self.m_ptBottomFinal = cc.p(m_visibleSize.width/2, 40)

    self.m_pBottom = cc.Sprite:create("316_lobby_bottom.png")
    self.m_pBottom:setScale(m_scalex, m_scaley)
    self.m_pBottom:setPosition(1030 * m_scalex, m_visibleSize.height - 35 * m_scaley)
    self:addChild(self.m_pBottom, 5)

    local btAward = CImageButton:Create("316_lobby_bt_award0.png", "316_lobby_bt_award1.png", IDI_BT_LOBBY_AWARD_316)
    btAward:SetEffect(true, BE_JELLY, m_scalex, m_scaley)
    btAward:setPosition(138*1, 50)
    self.m_pBottom:addChild(btAward, 5)

    local btService = CImageButton:Create("316_lobby_bt_service0.png", "316_lobby_bt_service1.png", IDI_BT_LOBBY_SERVICE_316)
    btService:SetEffect(true, BE_JELLY, m_scalex, m_scaley)
    btService:setPosition(138*2, 50)
    self.m_pBottom:addChild(btService, 5)

    local btBank = CImageButton:Create("316_lobby_bt_bank0.png", "316_lobby_bt_bank1.png", IDI_BT_LOBBY_BANK_316)
    btBank:SetEffect(true, BE_JELLY, m_scalex, m_scaley)
    btBank:setPosition(138*3, 50)
    self.m_pBottom:addChild(btBank, 5)

    local btPersonal = CImageButton:Create("316_lobby_bt_personal0.png", "316_lobby_bt_personal1.png", IDI_BT_LOBBY_PERSONAL_316)
    btPersonal:SetEffect(true, BE_JELLY, m_scalex, m_scaley)
    btPersonal:setPosition(138*4, 50)
    self.m_pBottom:addChild(btPersonal, 5)

    local btFriend = CImageButton:Create("316_lobby_bt_friend0.png", "316_lobby_bt_friend1.png", IDI_BT_LOBBY_FRIEND_316)
    btFriend:SetEffect(true, BE_JELLY, m_scalex, m_scaley)
    btFriend:setPosition(138*5, 50)
    self.m_pBottom:addChild(btFriend, 5)

    local btRecharge = CImageButton:Create("316_lobby_bt_recharge0.png", "316_lobby_bt_recharge1.png", IDI_BT_LOBBY_RECHARGE_316)
    btRecharge:SetEffect(true, BE_JELLY, m_scalex, m_scaley)
    btRecharge:setPosition(138*6, 50)
    self.m_pBottom:addChild(btRecharge, 5)

    local btRank = CImageButton:Create("316_lobby_bt_rank.png", "316_lobby_bt_rank.png", IDI_BT_LOBBY_RANK_316)
    btRank:SetEffect(true, BE_SCALE, m_scalex, m_scaley)
    btRank:setPosition(1020*m_scalex, 505*m_scaley)
    self:addChild(btRank, 10)

    local posStart = btAward:getPositionY() + btAward:getBoundingBox().height / 2
    local posEnd = m_userFaceImg:getPositionY() - m_userFaceImg:getBoundingBox().height / 2 - 50
   
    self.m_ptRoomCGShow = cc.p(m_visibleSize.width / 2, posStart + (posEnd - posStart) / 2)
    self.m_ptRoomCGHide = cc.p(-m_visibleSize.width / 2,self.m_ptRoomCGShow.y)

    self.m_ptRoomXSShow = cc.p(m_visibleSize.width / 2, posStart + (posEnd - posStart) / 2)
    self.m_ptRoomXSHide = cc.p(m_visibleSize.width * 3 / 2, self.m_ptRoomXSShow.y)

    self.m_ptRoomFLShow = cc.p(m_visibleSize.width / 2, posStart + (posEnd - posStart) / 2)
    self.m_ptRoomFLHide = cc.p(m_visibleSize.width * 3 / 2, self.m_ptRoomFLShow.y)
    ------------------------------------------------------
    -- room cg
    self.m_RoomCGScrollView = ASMJ_RoomCGScrollView_create(m_visibleSize.width, (posEnd - posStart))
    self.m_RoomCGScrollView:setPosition((self.m_iCurrentRoomType == ERT_CJ_316 or self.m_iCurrentRoomType == ERT_GJ_316) and self.m_ptRoomCGShow or self.m_ptRoomCGHide)
    self:addChild(self.m_RoomCGScrollView, 2)

    -- room xs
    self.m_RoomXSScrollView = ASMJ_RoomXSScrollView_create(m_visibleSize.width, (posEnd - posStart))
    self.m_RoomXSScrollView:setPosition(self.m_iCurrentRoomType == ERT_XS_316 and self.m_ptRoomXSShow or self.m_ptRoomXSHide)
    self:addChild(self.m_RoomXSScrollView, 2)

    -- room fl
    self.m_RoomFLScrollView = ASMJ_RoomFLScrollView_create(m_visibleSize.width, (posEnd - posStart))
    self.m_RoomFLScrollView:setPosition(self.m_iCurrentRoomType == ERT_FL_316 and self.m_ptRoomFLShow or self.m_ptRoomFLHide)
    self:addChild(self.m_RoomFLScrollView, 2)
    
    --------------------------------------------------
    self:onShowBottom()
    -------------------------------------------------
    local eventDispatcher = self:getEventDispatcher()
    local listener = nil
    listener = cc.EventListenerCustom:create("OnDialogClickEvent", handler(self, self.OnDialogClickEvent))
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(m_userFaceImg, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btBack, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btAward, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btService, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btBank, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btPersonal, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btFriend, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btRecharge, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(btRank, "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
end

--ctor()
function ASMJ_LobbyListScene:ctor(iEnterType)
    print("ASMJ_LobbyListScene:ctor")

    self.m_iCurrentRoomType = iEnterType

    self:init()

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
function ASMJ_LobbyListScene.create(iEnterType)
    print("ASMJ_LobbyListScene.create")
    local layer = ASMJ_LobbyListScene.new(iEnterType)
    return layer
end

--[====[   ASMJ_LoadingScene_createScene()  ]====]
function ASMJ_LobbyListScene_createScene(iEnterType)
    print("ASMJ_LobbyListScene_createScene")
    local scene = cc.Scene:create()
    scene:addChild(ASMJ_LobbyListScene.create(iEnterType), 0)
    return scene
end