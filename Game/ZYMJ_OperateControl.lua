local ASMJ_OperateControl = class("ASMJ_OperateControl", function() return cc.Node:create() end)

OPERATE_TYPE_316    =7  

IDC_BT_CHI_316      =200 
IDC_BT_PENG_316     =201
IDC_BT_GANE_316     =202
IDC_BT_TING_316     =203
IDC_BT_HU_316       =204
IDC_BT_GUO_316      =205
IDC_BT_CANCLE_316   =206

IDC_BT_GANG_ALTER_316=   310

function ASMJ_OperateControl:OnClickEvent(clickcmd)
    print("ASMJ_OperateControl:OnClickEvent " .. clickcmd:getnTag())
    if clickcmd:getnTag() == IDC_BT_PENG_316 then
        local ot = {}
        for i=1,#self.m_OperateType do

            if self.m_OperateType[i].cbOperateType == WIK_PENG_316 then
                ot.cbOperateMJ = self.m_OperateType[i].cbOperateMJ
                ot.cbOperateType = self.m_OperateType[i].cbOperateType
                break
            end
        end

        print("cbOperateType", ot.cbOperateType)
        print("cbOperateMJ", ot.cbOperateMJ)

        self:ClearAllOperate()
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteBYTEToBuffers(ot.cbOperateType)
        CClientKernel:GetInstance():WriteBYTEToBuffers(ot.cbOperateMJ)
        CClientKernel:GetInstance():SendMsgForLua(MDM_IPHONE_MESSAGE, SUB_IM_OPERATE)
        
    elseif clickcmd:getnTag() == IDC_BT_GUO_316 or clickcmd:getnTag() == IDC_BT_CANCLE_316 then

        self:ClearAllOperate()
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteBYTEToBuffers(WIK_NULL_316)
        CClientKernel:GetInstance():WriteBYTEToBuffers(0)
        CClientKernel:GetInstance():SendMsgForLua(MDM_IPHONE_MESSAGE, SUB_IM_OPERATE)
        
    elseif clickcmd:getnTag() == IDC_BT_TING_316  then

        self:ClearAllOperate()
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteBYTEToBuffers(WIK_LISTEN_316)
        CClientKernel:GetInstance():WriteBYTEToBuffers(0)
        CClientKernel:GetInstance():SendMsgForLua(MDM_IPHONE_MESSAGE, SUB_IM_OPERATE)

    elseif clickcmd:getnTag() == IDC_BT_HU_316 then
            
        self:ClearAllOperate()
        CClientKernel:GetInstance():ResetBuffers()
        CClientKernel:GetInstance():WriteBYTEToBuffers(WIK_CHI_HU_316)
        CClientKernel:GetInstance():WriteBYTEToBuffers(0)
        CClientKernel:GetInstance():SendMsgForLua(MDM_IPHONE_MESSAGE, SUB_IM_OPERATE)

    elseif clickcmd:getnTag() == IDC_BT_GANE_316 then

        self:OperateAlterResult(IDC_BT_GANE_316)

    elseif clickcmd:getnTag() >= IDC_BT_GANG_ALTER_316 then
       
        local iGangCurrentIndex = 0
        local iGangIndex = clickcmd:getnTag() - IDC_BT_GANG_ALTER_316
        
        for i=1,#self.m_OperateType do

            if self.m_OperateType[i].cbOperateType == WIK_GANE_316 then
                iGangCurrentIndex = iGangCurrentIndex + 1
            end

            if iGangCurrentIndex == iGangIndex then
                self:ClearAllOperate()
                CClientKernel:GetInstance():ResetBuffers()
                CClientKernel:GetInstance():WriteBYTEToBuffers(self.m_OperateType[i].cbOperateType)
                CClientKernel:GetInstance():WriteBYTEToBuffers(self.m_OperateType[i].cbOperateMJ)
                CClientKernel:GetInstance():SendMsgForLua(MDM_IPHONE_MESSAGE, SUB_IM_OPERATE)
                break
            end
        end

    else
        print("click tag unknow")
    end
end

--ctor()
function ASMJ_OperateControl:ctor()
    print("ASMJ_OperateControl:ctor")

    self.m_fMinScaleX = 1
    self.m_fMinScaleY = 1
    self.m_ptPoint = {}
    self.m_cbActionMask = 0      
    self.m_OperateType = {}
    self.m_OperateAlter = {}
end

--create( ... )
function ASMJ_OperateControl_create()
    print("ASMJ_OperateControl_create")
    local Node = ASMJ_OperateControl.new()
    return Node
end

function ASMJ_OperateControl:SetOriginPoint(x, y)
    self.m_ptPoint[1] = cc.p(x, y)
end

function ASMJ_OperateControl:SetScaleMin(iMinScaleX, iMinScaleY)
    self.m_fMinScaleX = iMinScaleX 
    self.m_fMinScaleY = iMinScaleY
end

--init()
function ASMJ_OperateControl:InitOperateButton()

    self.m_btOperate = {}

    self.m_btOperate[1] = CImageButton:CreateWithSpriteFrameName("316_tray_word_chi.png", "316_tray_word_chi.png", IDC_BT_CHI_316)
    self.m_btOperate[2] = CImageButton:CreateWithSpriteFrameName("316_tray_word_peng.png", "316_tray_word_peng.png", IDC_BT_PENG_316)
    self.m_btOperate[3] = CImageButton:CreateWithSpriteFrameName("316_tray_word_gang.png", "316_tray_word_gang.png", IDC_BT_GANE_316)
    self.m_btOperate[4] = CImageButton:CreateWithSpriteFrameName("316_tray_ting.png", "316_tray_ting.png", IDC_BT_TING_316)
    self.m_btOperate[5] = CImageButton:CreateWithSpriteFrameName("316_tray_hu.png", "316_tray_hu.png", IDC_BT_HU_316)
    self.m_btOperate[6] = CImageButton:CreateWithSpriteFrameName("316_tray_guo.png", "316_tray_guo.png", IDC_BT_GUO_316)
    self.m_btOperate[7] = CImageButton:CreateWithSpriteFrameName("316_tray_cancel.png", "316_tray_cancel.png", IDC_BT_CANCLE_316)

    for i=1,OPERATE_TYPE_316 do
        self.m_btOperate[i]:setVisible(false)
        self.m_btOperate[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        self.m_btOperate[i]:SetEffect(true, BE_SCALE, self.m_fMinScaleX, self.m_fMinScaleY)
        self:addChild(self.m_btOperate[i])
    end

    for i=2,OPERATE_TYPE_316 do

        self.m_ptPoint[i] = cc.p(self.m_ptPoint[1].x - ((i-1)*self.m_btOperate[1]:getContentSize().width-(i-1)*30)*self.m_fMinScaleX, self.m_ptPoint[1].y)

    end

    self.m_btOperate[6]:setPosition(self.m_ptPoint[1])

    -- ScriptHandlerMgr
    for i=1,OPERATE_TYPE_316 do
        ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(self.m_btOperate[i], "cc.Ref"), handler(self, self.OnClickEvent), cc.Handler.EVENT_CUSTOMCMD)
    end
end

function ASMJ_OperateControl:SetOperateControl(cbCenterCard, cbActionMask, GangCardResult)
    
    self.m_cbActionMask = cbActionMask

    self.m_OperateType = {}
    for i=1,GangCardResult.cbCardCount do
        local ot = {}
        ot.cbOperateMJ = GangCardResult.cbCardData[i]
        ot.cbOperateType = WIK_GANG_316
        table.insert(self.m_OperateType, ot)
    end

    local cbItemKind = {WIK_PENG_316, WIK_LISTEN_316, WIK_CHI_HU_316, WIK_LEFT_316, WIK_CENTER_316, WIK_RIGHT_316}
    for i=1,#cbItemKind do
        if bit:_and(self.m_cbActionMask, cbItemKind[i]) == 0 then
        else
            local ot = {}
            ot.cbOperateMJ = cbCenterCard
            ot.cbOperateType = cbItemKind[i]
            table.insert(self.m_OperateType, ot)
        end
    end

    table.sort(self.m_OperateType, function (ot1, ot2)
        if ot1.cbOperateType ~= ot2.cbOperateType then
            return ot1.cbOperateType > ot2.cbOperateType
        else
            return ot1.cbOperateMJ < ot2.cbOperateMJ
        end
    end)
   
    local ibtIndex = 2
    local bFirstOperateBit = {}
    for i=1,#self.m_OperateType do
        if self.m_OperateType[i].cbOperateType == WIK_LEFT_316 or 
            self.m_OperateType[i].cbOperateType == WIK_CENTER_316 or
            self.m_OperateType[i].cbOperateType == WIK_RIGHT_316 then

            if not bFirstOperateBit[1] then
                bFirstOperateBit[1] = true
                self.m_btOperate[1]:setPosition(self.m_ptPoint[ibtIndex])
                self.m_btOperate[1]:setVisible(true)
                ibtIndex = ibtIndex + 1
            end
        elseif self.m_OperateType[i].cbOperateType == WIK_PENG_316 then
            if not bFirstOperateBit[2] then
                bFirstOperateBit[2] = true
                self.m_btOperate[2]:setPosition(self.m_ptPoint[ibtIndex])
                self.m_btOperate[2]:setVisible(true)
                ibtIndex = ibtIndex + 1
            end
        elseif self.m_OperateType[i].cbOperateType == WIK_GANG_316 then
            if not bFirstOperateBit[3] then
                bFirstOperateBit[3] = true
                self.m_btOperate[3]:setPosition(self.m_ptPoint[ibtIndex])
                self.m_btOperate[3]:setVisible(true)
                ibtIndex = ibtIndex + 1
            end
        elseif self.m_OperateType[i].cbOperateType == WIK_LISTEN_316 then
            if not bFirstOperateBit[4] then
                bFirstOperateBit[4] = true
                self.m_btOperate[4]:setPosition(self.m_ptPoint[ibtIndex])
                self.m_btOperate[4]:setVisible(true)
                ibtIndex = ibtIndex + 1
            end
        elseif self.m_OperateType[i].cbOperateType == WIK_CHI_HU_316 then
            if not bFirstOperateBit[5] then
                bFirstOperateBit[5] = true
                self.m_btOperate[5]:setPosition(self.m_ptPoint[ibtIndex])
                self.m_btOperate[5]:setVisible(true)
                ibtIndex = ibtIndex + 1
            end
        end
    end
   
    self.m_btOperate[6]:setVisible(true)
end

function ASMJ_OperateControl:ClearAllOperate()
    self.m_cbActionMask = 0

    for i=1,#self.m_OperateAlter do
        for j=1,#self.m_OperateAlter[i].pMJBack do
            self.m_OperateAlter[i].pMJBack[j]:removeFromParent()
        end
        
        for j=1,#self.m_OperateAlter[i].pMJData do
            self.m_OperateAlter[i].pMJData[j]:removeFromParent()
        end

        self.m_OperateAlter[i].pAlterMJBack:removeFromParent()
    end

    self.m_OperateAlter = {}

    for i=1,OPERATE_TYPE_316 do
        self.m_btOperate[i]:setVisible(false)
    end

    return
end

function ASMJ_OperateControl:OperateAlterResult(iOperateType)
    
    for i=1,OPERATE_TYPE_316 do
        self.m_btOperate[i]:setVisible(false)
    end
    
    if iOperateType == IDC_BT_GANE_316 then

        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local iGangCount = 0
        for i=1,#self.m_OperateType do
            if self.m_OperateType[i].cbOperateType == WIK_GANG_316 then
                iGangCount = iGangCount + 1
            end
        end

        if iGangCount == 1 then
            for i=1,#self.m_OperateType do
                if self.m_OperateType[i].cbOperateType == WIK_GANG_316 then
                    self:ClearAllOperate()
                    CClientKernel:GetInstance():ResetBuffers()
                    CClientKernel:GetInstance():WriteBYTEToBuffers(WIK_GANG_316)
                    CClientKernel:GetInstance():WriteBYTEToBuffers(self.m_OperateType[i].cbOperateMJ)
                    CClientKernel:GetInstance():SendMsgForLua(MDM_IPHONE_MESSAGE, SUB_IM_OPERATE)
                    break
                end
            end
            return
        end

        for i=1,iGangCount do
            local pAlterMJBack = CImageButton:CreateWithSpriteFrameName("316_tray_back_cpg.png", "316_tray_back_cpg.png", IDC_BT_GANG_ALTER_316+i)
            local fX = (2*(i-1)-(iGangCount-1))*(20 + pAlterMJBack:getContentSize().width/2)*self.m_fMinScaleX
            pAlterMJBack:setScale(m_fMinScaleX, m_fMinScaleY)
            pAlterMJBack:setPosition(visibleSize.width/2 + fX, 190*m_fMinScaleY)
            self:addChild(pAlterMJBack)

            self.m_OperateAlter[i].pAlterMJBack = pAlterMJBack
        end

        for i=1,#self.m_OperateAlter do
            for j=1,#self.m_OperateType do
                
                if self.m_OperateType[j].cbOperateType == WIK_GANG_316 then
                    
                    local str = string.format("316_tile_meUp_%d%d.png", bit:_rshift(self.m_OperateType[j].cbOperateMJ, 4), bit:_and(self.m_OperateType[j].cbOperateMJ, 15))
                    
                    self.m_OperateAlter[i].pMJBack = {}
                    self.m_OperateAlter[i].pMJData = {}
                    for i=1,4 do
                        local pMJData = cc.Sprite:createWithSpriteFrameName(str)
                        local pMJBack = cc.Sprite:createWithSpriteFrameName("tileBase_meUp_0.png");
                        
                        pMJData:setScale(m_fMinScaleX, m_fMinScaleY)
                        pMJBack:setScale(m_fMinScaleX, m_fMinScaleY)

                        --pMJData:setTag(self.m_OperateType[j].cbOperateMJ)

                        pMJBack:setPosition(self.m_OperateAlter[i].getPositionX()+m_fMinScaleX*(2*(i-1)-3)*pMJBack:getContentSize().width/2,self.m_OperateAlter[i].getPositionY())
                        pMJData:setPosition(pMJBack:getPositionX(), pMJBack:getPositionY() + 8*m_fMinScaleX)
                        
                        self.addChild(pMJBack)
                        self.addChild(pMJData)

                        table.insert(self.m_OperateAlter[i].pMJBack, pMJBack)
                        table.insert(self.m_OperateAlter[i].pMJData, pMJData)
                    end

                    break
                end
            end
        end

    end
end