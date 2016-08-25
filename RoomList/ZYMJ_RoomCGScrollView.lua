local ASMJ_RoomCGScrollView = class("ASMJ_RoomCGScrollView", function() return cc.Layer:create() end)

--create( ... )
function ASMJ_RoomCGScrollView_create(width, height)
    cclog("ASMJ_RoomCGScrollView_create")
    local layer = ASMJ_RoomCGScrollView.new(width, height)
    return layer
end

--ctor()
function ASMJ_RoomCGScrollView:ctor(width, height)
    cclog("ASMJ_RoomCGScrollView:ctor")
    self:init(width, height)
    self:setIgnoreAnchorPointForPosition(false)
end


function ASMJ_RoomCGScrollView:init(width, height)

    local m_visibleSize =  cc.Director:getInstance():getVisibleSize()
    self.m_scalex = display.scalex_landscape
    self.m_scaley = display.scaley_landscape

    self:setContentSize(cc.size(width, height))
    self.m_cellSize = cc.size(width / 4, height)

    local tableView = cc.TableView:create(cc.size(width, height))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(0, 0)
    tableView:setDelegate()
    self:addChild(tableView)

    --registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(handler(self, self.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(handler(self, self.tableCellTouched),cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(handler(self, self.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(handler(self, self.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end

function ASMJ_RoomCGScrollView:scrollViewDidScroll(view)
    
end

function ASMJ_RoomCGScrollView:scrollViewDidZoom(view)
    print("scrollViewDidZoom")
end

function ASMJ_RoomCGScrollView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())

    --AudioEngine.playEffect("316_game_select.MP3")
    ccexp.AudioEngine:play2d("316_game_select.MP3", false, 1)

    local m_RoomItem = ASMJ_CServerManager:GetInstance():GetRoomCGItem(cell:getTag() + 1)
    
    if m_RoomItem.m_iType == ERT_XS_316 or m_RoomItem.m_iType == ERT_FL_316 then
 
        local iRoomItem = cell:getChildByTag(60)
        if iRoomItem then
            iRoomItem.m_itemBg:stopAllActions()
            if m_RoomItem.m_iType == ERT_XS_316 then
                iRoomItem.m_pOnlineCountLabA:setVisible(false)
            end
        end

        ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
        local animation = cc.Animation:create()
        for i=1,10 do
            local szName =string.format("316_ani_room_%d%d_%d%d.png", math.floor(m_RoomItem.m_iType/10), m_RoomItem.m_iType%10, math.floor(i/10), i%10)
            animation:addSpriteFrameWithFile(szName)
        end  

        animation:setDelayPerUnit(0.06)
        animation:setLoops(1)

        local animate = cc.Animate:create(animation) 
        local callback = cc.CallFunc:create(
            function()
                
                ASMJ_Toast_Dismiss()
                if iRoomItem then
                    iRoomItem.m_itemBg:setTexture(string.format("316_room_item_%d.png",m_RoomItem.m_iType))
                    iRoomItem.m_itemBg:stopAllActions()
                    if m_RoomItem.m_iType == ERT_XS_316 then
                        iRoomItem.m_pOnlineCountLabA:setVisible(true)
                    end
                end

                local pParentLayer = self:getParent()
                if pParentLayer == nil then
                    return
                end
                pParentLayer:SkipRoom(m_RoomItem.m_iType)   
            end)

        iRoomItem.m_itemBg:runAction(cc.Sequence:create(animate, callback))
        return
    end

    -----------------------------CGRoom-----------------------------------
    local iRoomCGItem = cell:getChildByTag(60)
    if iRoomCGItem then
        iRoomCGItem.m_itemBg:stopAllActions()
        iRoomCGItem.m_pOnlineCountLabA:setVisible(false)
    end

    ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
    local animation = cc.Animation:create()
    for i=1,10 do
        local szName =string.format("316_ani_room_%d%d_%d%d.png", math.floor(iRoomCGItem.m_iType/10), iRoomCGItem.m_iType%10, math.floor(i/10), i%10)
        animation:addSpriteFrameWithFile(szName)
    end

    animation:setDelayPerUnit(0.06)
    animation:setLoops(1)

    local animate = cc.Animate:create(animation) 
    local callback = cc.CallFunc:create(
        function()
            if iRoomCGItem then
                iRoomCGItem.m_itemBg:setTexture(string.format("316_room_item_%d.png",iRoomCGItem.m_iType))
                iRoomCGItem.m_itemBg:stopAllActions()
                iRoomCGItem.m_pOnlineCountLabA:setVisible(true)
            end

            local password = ASMJ_MyUserItem:GetInstance():GetPassword()
            local moduleid = KIND_ID_316
            local devicetype = display.DeviceType
            local wBehaviorFlags = 0
            local wPageTableCount = 60
            local dwSiteID = 1000
            local plazaversion = 0

            if (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
                plazaversion = 101842947
            else
                plazaversion = 101056515
            end

            local myItem = ASMJ_MyUserItem:GetInstance():GetMyUserData()--CClientKernel:GetInstance():GetMyUserData()
            assert(myItem, "MyUserData is error")

            local cbLogonMode = 0

            CClientKernel:GetInstance():ResetBuffers()
            CClientKernel:GetInstance():WriteWORDToBuffers(moduleid)
            CClientKernel:GetInstance():WriteDWORDToBuffers(plazaversion)
            CClientKernel:GetInstance():WriteBYTEToBuffers(devicetype)
            CClientKernel:GetInstance():WriteWORDToBuffers(wBehaviorFlags)
            CClientKernel:GetInstance():WriteWORDToBuffers(wPageTableCount)
            CClientKernel:GetInstance():WriteDWORDToBuffers(dwSiteID)
            CClientKernel:GetInstance():WriteDWORDToBuffers(myItem:GetUserID())
            CClientKernel:GetInstance():WritecharToBuffers(password,33,true)
            CClientKernel:GetInstance():WritecharToBuffers(display.MachineID,33,true)
            CClientKernel:GetInstance():WriteBYTEToBuffers(cbLogonMode)

            -- explicit room index  1,2,3,4 ---1XS 2CJ 3GJ 4FL
            local iRoomType = m_RoomItem.m_iType
            assert(iRoomType == ERT_CJ_316 or iRoomType == ERT_GJ_316, "error room type for CGRoom")
            ---------------------

            -- send room login
            ASMJ_CServerManager:GetInstance():SetOnClickRoomType(iRoomType)
            ASMJ_CServerManager:GetInstance():SetOnClickRoomIndex(cell:getTag()+1)
            -- xs[1] = cgitem[1] cj[2] = cgitem[2] gj[3] = cgitem[3] fl[4]  roomindex = iroomtype + 1
            local pCGDataItem = ASMJ_CServerManager:GetInstance():GetRoomCGItem(cell:getTag()+1)
            if pCGDataItem then
                if not CClientKernel:GetInstance():SendLoginToGameServer(pCGDataItem.dwServerAddr, pCGDataItem.wServerPort, MDM_GR_LOGON, SUB_GR_LOGON_MOBILE) then
                    ASMJ_Toast_Dismiss()
                    local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
                    dialog:setTag(IDI_POPUP_OK_316) 
                end
            else
                ASMJ_Toast_Dismiss()
            end
        end)

    iRoomCGItem.m_itemBg:runAction(cc.Sequence:create(animate, callback))
end

function ASMJ_RoomCGScrollView:cellSizeForTable(table,idx) 
    --error cocos2dx
    return  self.m_cellSize.width, self.m_cellSize.width 
end

function ASMJ_RoomCGScrollView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        item = ASMJ_RoomCGItemView_create(idx + 1)  --cc.Sprite:create("316_room_cycle_1.png")--
        item:setPosition(self.m_cellSize.width/2, self.m_cellSize.height/2)
        item:setScale(self.m_scalex, self.m_scaley)
        item:setTag(60)
        cell:addChild(item)
    else
        item = cell:getChildByTag(60)
        item:SetType(idx + 1)
    end

    cell:setTag(idx)
    return cell
end

function ASMJ_RoomCGScrollView:numberOfCellsInTableView(table)
   return ASMJ_CServerManager:GetInstance():GetRoomCGCount()
end
