local ASMJ_RoomFLScrollView = class("ASMJ_RoomFLScrollView", function() return cc.Layer:create() end)

--create( ... )
function ASMJ_RoomFLScrollView_create(width, height)
    cclog("ASMJ_RoomFLScrollView_create")
    local layer = ASMJ_RoomFLScrollView.new(width, height)
    return layer
end

--ctor()
function ASMJ_RoomFLScrollView:ctor(width, height)
    cclog("ASMJ_RoomFLScrollView:ctor")
    self:init(width, height)
    self:setIgnoreAnchorPointForPosition(false)
end


function ASMJ_RoomFLScrollView:init(width, height)

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

function ASMJ_RoomFLScrollView:scrollViewDidScroll(view)
    
end

function ASMJ_RoomFLScrollView:scrollViewDidZoom(view)
    print("scrollViewDidZoom")
end

function ASMJ_RoomFLScrollView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())

    --AudioEngine.playEffect("316_game_select.MP3")
    ccexp.AudioEngine:play2d("316_game_select.MP3", false, 1)

    local pFLDataItem = ASMJ_CServerManager:GetInstance():GetRoomFLItem(cell:getTag() + 1)
    if pFLDataItem == nil then
        return
    end
    -----------------------------XSRoom-----------------------------------
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
    ---------------------

    -- send room login
    ASMJ_CServerManager:GetInstance():SetOnClickRoomType(ERT_FL_316)
    ASMJ_CServerManager:GetInstance():SetOnClickRoomIndex(cell:getTag()+1)
    if pFLDataItem then
        if CClientKernel:GetInstance():SendLoginToGameServer(pFLDataItem.dwServerAddr, pFLDataItem.wServerPort, MDM_GR_LOGON, SUB_GR_LOGON_MOBILE) then
            ASMJ_Toast_ShowToast(CUtilEx:getString("gamehall_0_pls_wait"))
        else
            local dialog = ASMJ_PopupBox_ShowDialog(CUtilEx:getString("gamehall_0_network_connect_failed"), "316_popup_ok", nil, self, nil, true)    
            dialog:setTag(IDI_POPUP_OK_316)
        end
    end
end

function ASMJ_RoomFLScrollView:cellSizeForTable(table,idx) 
    --error cocos2dx
    return  self.m_cellSize.width, self.m_cellSize.width 
end

function ASMJ_RoomFLScrollView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        item = ASMJ_RoomFLItemView_create(idx + 1)  --cc.Sprite:create("316_room_cycle_1.png")--
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

function ASMJ_RoomFLScrollView:numberOfCellsInTableView(table)
   return ASMJ_CServerManager:GetInstance():GetRoomFLCount()
end
