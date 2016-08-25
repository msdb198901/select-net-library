local ASMJ_TableOutMJControl = class("ASMJ_TableOutMJControl", function() return cc.Node:create() end)

--create( ... )
function ASMJ_TableOutMJControl_create()
    print("ASMJ_TableOutMJControl_create")
    local Node = ASMJ_TableOutMJControl.new()
    return Node
end

--ctor()
function ASMJ_TableOutMJControl:ctor()
    print("ASMJ_TableOutMJControl:ctor")

    self.m_TableOutMJData = {}
    
    self.m_fMinScaleY = 1
    self.m_fMinScaleX = 1

    self.m_OriginMJPoint = cc.p(0,0)
    self.m_OutMJDirection = Direction_North_316
end

----------------------------------
function ASMJ_TableOutMJControl:TableOutMJClear()
    self.m_TableOutMJData = {}
    self:removeAllChildren()
end

function ASMJ_TableOutMJControl:SetScaleMin(iMinScaleX, iMinScaleY)
    self.m_fMinScaleX = iMinScaleX 
    self.m_fMinScaleY = iMinScaleY
end

function ASMJ_TableOutMJControl:SetOriginControlPoint(iXPos, iYPos)
    self.m_OriginMJPoint = cc.p(iXPos,iYPos)
end

function ASMJ_TableOutMJControl:SetDirection(Direction)
    self.m_OutMJDirection = Direction
end

function ASMJ_TableOutMJControl:GetOutMJPoint()

    local iOutMJCount = #self.m_TableOutMJData > 0 and #self.m_TableOutMJData - 1 or 0

    local iRowIndex = math.floor(iOutMJCount/9)
    local iColumnIndex = iOutMJCount%9

    local pt = cc.p(0,0)
    local pMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_meUp_0.png")
    
    if self.m_OutMJDirection == Direction_East_316 then
        
        local nItemWidth = pMJBack:getContentSize().width
        local nItemHeight = Y_TABLE_LR_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x - nItemWidth*iRowIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y - iColumnIndex*nItemHeight*self.m_fMinScaleY
    
    elseif self.m_OutMJDirection == Direction_South_316 then
        
        local nItemWidth = pMJBack:getContentSize().width-OUT_MJ_X_GAP_316
        local nItemHeight = Y_TABLE_BT_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x + nItemWidth*iColumnIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y - nItemHeight*iRowIndex*self.m_fMinScaleY

    elseif self.m_OutMJDirection == Direction_West_316 then

        local nItemWidth = pMJBack:getContentSize().width
        local nItemHeight = Y_TABLE_LR_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x + nItemWidth*iRowIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y + iColumnIndex*nItemHeight*self.m_fMinScaleY

    elseif self.m_OutMJDirection == Direction_North_316 then

        local nItemWidth = pMJBack:getContentSize().width-OUT_MJ_X_GAP_316
        local nItemHeight = Y_TABLE_BT_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x - nItemWidth*iColumnIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y + nItemHeight*iRowIndex*self.m_fMinScaleY

    end

    return pt
end

function ASMJ_TableOutMJControl:GetCurrentOutMJPoint()

    local iOutMJCount = #self.m_TableOutMJData
    local iRowIndex = 0
    local iColumnIndex = iOutMJCount%ONCE_ROW_MJ_COUNT_316
    local iTmpMJRow = math.floor(iOutMJCount/ONCE_ROW_MJ_COUNT_316)

    if iTmpMJRow > 0 then
    
        iColumnIndex = (iOutMJCount - ONCE_ROW_MJ_COUNT_316)%OTHER_ROW_MJ_COUNT_316
       
        repeat
            iTmpMJRow = math.floor(iTmpMJRow/OTHER_ROW_MJ_COUNT_316)
            iRowIndex = iRowIndex + 1
        until iTmpMJRow == 0
    end

    if iRowIndex == 0 then
        iColumnIndex = iColumnIndex + 1
    end

    local pt = cc.p(0,0)
    local pMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_meUp_0.png")
    
    if self.m_OutMJDirection == Direction_East_316 then
        
        local nItemWidth = pMJBack:getContentSize().width
        local nItemHeight = Y_TABLE_LR_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x - nItemWidth*iRowIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y - iColumnIndex*nItemHeight*self.m_fMinScaleY
    
    elseif self.m_OutMJDirection == Direction_South_316 then
        
        local nItemWidth = pMJBack:getContentSize().width-OUT_MJ_X_GAP_316
        local nItemHeight = Y_TABLE_BT_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x + nItemWidth*iColumnIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y - nItemHeight*iRowIndex*self.m_fMinScaleY

    elseif self.m_OutMJDirection == Direction_West_316 then

        local nItemWidth = pMJBack:getContentSize().width
        local nItemHeight = Y_TABLE_LR_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x + nItemWidth*iRowIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y + iColumnIndex*nItemHeight*self.m_fMinScaleY

    elseif self.m_OutMJDirection == Direction_North_316 then

        local nItemWidth = pMJBack:getContentSize().width-OUT_MJ_X_GAP_316
        local nItemHeight = Y_TABLE_BT_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x - nItemWidth*iColumnIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y + nItemHeight*iRowIndex*self.m_fMinScaleY

    end

    return pt
end

function ASMJ_TableOutMJControl:DrawOutMJControl(cbMJData, cbFirstChichen, ptOrigin, bShowRound)
    
    cbFirstChichen = cbFirstChichen or 0
    ptOrigin = ptOrigin or cc.p(0,0)
    bShowRound = bShowRound or false

    local iOutMJCount = #self.m_TableOutMJData

    local iRowIndex = math.floor(iOutMJCount/9)
    local iColumnIndex = iOutMJCount%9

    local pt = cc.p(0,0)

    
    local pOutMJInfo = {}
    pOutMJInfo.cbMJData = cbMJData
    pOutMJInfo.cbFirstChicken = cbFirstChichen
    pOutMJInfo.pFirstChicken = nil

    if self.m_OutMJDirection == Direction_East_316 then

        local str = string.format("316_tile_leftRight_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15))
        pOutMJInfo.pOutMJData = cc.Sprite:createWithSpriteFrameName(str)
        pOutMJInfo.pOutMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_leftRight_0.png")

        pOutMJInfo.pOutMJBack:setPosition(ptOrigin.x, ptOrigin.y)
        pOutMJInfo.pOutMJData:setPosition(ptOrigin.x, ptOrigin.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
        pOutMJInfo.pOutMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        pOutMJInfo.pOutMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

        if cbMJData == 17 then
            pOutMJInfo.pOutMJBack:setColor(cc.c3b(243,170,175))
            pOutMJInfo.pOutMJData:setColor(cc.c3b(243,170,175))
        end

        self:addChild(pOutMJInfo.pOutMJBack, iOutMJCount)
        self:addChild(pOutMJInfo.pOutMJData, iOutMJCount+1)

        local nItemWidth = pOutMJInfo.pOutMJBack:getContentSize().width-OUT_MJ_X_GAP_316
        local nItemHeight = Y_TABLE_LR_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x - nItemWidth*iRowIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y - iColumnIndex*nItemHeight*self.m_fMinScaleY

        local bezier = {
            cc.p(ptOrigin.x + (pt.x - ptOrigin.x)/2, ptOrigin.y),
            cc.p(pt.x, ptOrigin.y + (pt.y - ptOrigin.y)/2),
            cc.p(pt.x, pt.y),
        }

        pt.y = pt.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY

        local bezier1 = {
            cc.p(ptOrigin.x + (pt.x - ptOrigin.x)/2, ptOrigin.y),
            cc.p(pt.x, ptOrigin.y + (pt.y - ptOrigin.y)/2),
            cc.p(pt.x, pt.y),
        }
        
        local pSeqBack = cc.Sequence:create(cc.BezierTo:create(OUT_MJ_TIME_316, bezier))
        local pSeqData = cc.Sequence:create(cc.BezierTo:create(OUT_MJ_TIME_316, bezier1), cc.CallFunc:create(
            function ()
                if cbFirstChichen == 1 then
                    pOutMJInfo.pFirstChicken = cc.Sprite:createWithSpriteFrameName("316_cf_flag.png")
                    pOutMJInfo.pFirstChicken:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                    pOutMJInfo.pFirstChicken:setPosition(pOutMJInfo.pOutMJData:getPosition())
                    self:addChild(pOutMJInfo.pFirstChicken, 100)
                end
            end))

        pOutMJInfo.pOutMJBack:runAction(pSeqBack)
        pOutMJInfo.pOutMJData:runAction(pSeqData)

    elseif self.m_OutMJDirection == Direction_South_316 then
        
        local str = string.format("316_tile_meUp_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15))
        pOutMJInfo.pOutMJData = cc.Sprite:createWithSpriteFrameName(str)
        pOutMJInfo.pOutMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_meUp_0.png")

        pOutMJInfo.pOutMJBack:setPosition(ptOrigin.x, ptOrigin.y)
        pOutMJInfo.pOutMJData:setPosition(ptOrigin.x, ptOrigin.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
        pOutMJInfo.pOutMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        pOutMJInfo.pOutMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

        if cbMJData == 17 then
            pOutMJInfo.pOutMJBack:setColor(cc.c3b(243,170,175))
            pOutMJInfo.pOutMJData:setColor(cc.c3b(243,170,175))
        end

        self:addChild(pOutMJInfo.pOutMJBack, iOutMJCount)
        self:addChild(pOutMJInfo.pOutMJData, iOutMJCount+1)

        local nItemWidth = pOutMJInfo.pOutMJBack:getContentSize().width-OUT_MJ_X_GAP_316
        local nItemHeight = Y_TABLE_BT_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x + nItemWidth*iColumnIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y - iRowIndex*nItemHeight*self.m_fMinScaleY

        local bezier = {
            cc.p(ptOrigin.x, ptOrigin.y + (pt.y - ptOrigin.y)/2),
            cc.p(ptOrigin.x + (pt.x - ptOrigin.x)/2, pt.y),
            cc.p(pt.x, pt.y),
        }

        pt.y = pt.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY

        local bezier1 = {
            cc.p(ptOrigin.x, ptOrigin.y + (pt.y - ptOrigin.y)/2),
            cc.p(ptOrigin.x + (pt.x - ptOrigin.x)/2, pt.y),
            cc.p(pt.x, pt.y),
        }

        local pSeqBack = cc.Sequence:create(cc.BezierTo:create(OUT_MJ_TIME_316, bezier))
        local pSeqData = cc.Sequence:create(cc.BezierTo:create(OUT_MJ_TIME_316, bezier1), cc.CallFunc:create(

            function ()
                if cbFirstChichen == 1 then
                    pOutMJInfo.pFirstChicken = cc.Sprite:createWithSpriteFrameName("316_cf_flag.png")
                    pOutMJInfo.pFirstChicken:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                    pOutMJInfo.pFirstChicken:setPosition(pOutMJInfo.pOutMJData:getPosition())
                    self:addChild(pOutMJInfo.pFirstChicken, 100)
                end
            end))

        pOutMJInfo.pOutMJBack:runAction(pSeqBack)
        pOutMJInfo.pOutMJData:runAction(pSeqData)

    elseif self.m_OutMJDirection == Direction_West_316 then
       
        local str = string.format("316_tile_leftRight_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15))
        pOutMJInfo.pOutMJData = cc.Sprite:createWithSpriteFrameName(str)
        pOutMJInfo.pOutMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_leftRight_0.png")

        pOutMJInfo.pOutMJBack:setPosition(ptOrigin.x, ptOrigin.y)
        pOutMJInfo.pOutMJData:setPosition(ptOrigin.x, ptOrigin.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
        pOutMJInfo.pOutMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        pOutMJInfo.pOutMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

        pOutMJInfo.pOutMJData:setRotation3D(cc.Vertex3F(0,0,180))

        if cbMJData == 17 then
            pOutMJInfo.pOutMJBack:setColor(cc.c3b(243,170,175))
            pOutMJInfo.pOutMJData:setColor(cc.c3b(243,170,175))
        end

        self:addChild(pOutMJInfo.pOutMJBack, 50-iOutMJCount)
        self:addChild(pOutMJInfo.pOutMJData, 50-iOutMJCount+1)

        local nItemWidth = pOutMJInfo.pOutMJBack:getContentSize().width-OUT_MJ_X_GAP_316
        local nItemHeight = Y_TABLE_LR_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x + nItemWidth*iRowIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y + iColumnIndex*nItemHeight*self.m_fMinScaleY

        local bezier = {
            cc.p(ptOrigin.x + (pt.x - ptOrigin.x)/2, ptOrigin.y),
            cc.p(pt.x, ptOrigin.y + (pt.y - ptOrigin.y)/2),
            cc.p(pt.x, pt.y),
        }

        pt.y = pt.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY

        local bezier1 = {
            cc.p(ptOrigin.x + (pt.x - ptOrigin.x)/2, ptOrigin.y),
            cc.p(pt.x, ptOrigin.y + (pt.y - ptOrigin.y)/2),
            cc.p(pt.x, pt.y),
        }

        local pSeqBack = cc.Sequence:create(cc.BezierTo:create(OUT_MJ_TIME_316, bezier))
        local pSeqData = cc.Sequence:create(cc.BezierTo:create(OUT_MJ_TIME_316, bezier1), cc.CallFunc:create(

            function ()
                if cbFirstChichen == 1 then
                    pOutMJInfo.pFirstChicken = cc.Sprite:createWithSpriteFrameName("316_cf_flag.png")
                    pOutMJInfo.pFirstChicken:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                    pOutMJInfo.pFirstChicken:setPosition(pOutMJInfo.pOutMJData:getPosition())
                    pOutMJInfo.pFirstChicken:setRotation3D(cc.Vertex3F(0,0,270))
                    self:addChild(pOutMJInfo.pFirstChicken, 100)
                end
            end))

        pOutMJInfo.pOutMJBack:runAction(pSeqBack)
        pOutMJInfo.pOutMJData:runAction(pSeqData)

    elseif self.m_OutMJDirection == Direction_North_316 then
        
        local str = string.format("316_tile_meUp_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15))
        pOutMJInfo.pOutMJData = cc.Sprite:createWithSpriteFrameName(str)
        pOutMJInfo.pOutMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_meUp_0.png")

        pOutMJInfo.pOutMJBack:setPosition(ptOrigin.x, ptOrigin.y)
        pOutMJInfo.pOutMJData:setPosition(ptOrigin.x, ptOrigin.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
        pOutMJInfo.pOutMJData:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        pOutMJInfo.pOutMJBack:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

        if cbMJData == 17 then
            pOutMJInfo.pOutMJBack:setColor(cc.c3b(243,170,175))
            pOutMJInfo.pOutMJData:setColor(cc.c3b(243,170,175))
        end

        self:addChild(pOutMJInfo.pOutMJBack, 50-iOutMJCount)
        self:addChild(pOutMJInfo.pOutMJData, 50-iOutMJCount+1)

        local nItemWidth = pOutMJInfo.pOutMJBack:getContentSize().width-OUT_MJ_X_GAP_316
        local nItemHeight = Y_TABLE_BT_EXCUSION_316

        pt.x = self.m_OriginMJPoint.x - nItemWidth*iColumnIndex*self.m_fMinScaleX
        pt.y = self.m_OriginMJPoint.y + nItemHeight*iRowIndex*self.m_fMinScaleY

        local bezier = {
            cc.p(ptOrigin.x, ptOrigin.y + (pt.y - ptOrigin.y)/2),
            cc.p(ptOrigin.x + (pt.x - ptOrigin.x)/2, pt.y),
            cc.p(pt.x, pt.y),
        }

        pt.y = pt.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY

        local bezier1 = {
            cc.p(ptOrigin.x, ptOrigin.y + (pt.y - ptOrigin.y)/2),
            cc.p(ptOrigin.x + (pt.x - ptOrigin.x)/2, pt.y),
            cc.p(pt.x, pt.y),
        }

        local pSeqBack = cc.Sequence:create(cc.BezierTo:create(OUT_MJ_TIME_316, bezier))
        local pSeqData = cc.Sequence:create(cc.BezierTo:create(OUT_MJ_TIME_316, bezier1), cc.CallFunc:create(

            function ()
                if cbFirstChichen == 1 then
                    pOutMJInfo.pFirstChicken = cc.Sprite:createWithSpriteFrameName("316_cf_flag.png")
                    pOutMJInfo.pFirstChicken:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                    pOutMJInfo.pFirstChicken:setPosition(pOutMJInfo.pOutMJData:getPosition())
                    self:addChild(pOutMJInfo.pFirstChicken, 100)
                end
            end))

        pOutMJInfo.pOutMJBack:runAction(pSeqBack)
        pOutMJInfo.pOutMJData:runAction(pSeqData)

    end

    table.insert(self.m_TableOutMJData, pOutMJInfo)

    if bShowRound and self.m_OutMJDirection ~= Direction_South_316 then

        local seqOutRound = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(2), cc.Hide:create())
        self.m_OutRound:runAction(seqOutRound)

        local str = string.format("316_tile_me_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15))
        local pOutRoundMJData = cc.Sprite:createWithSpriteFrameName(str)
        local pOutRoundMJBack = cc.Sprite:createWithSpriteFrameName("316_tileBase_me_0.png")

        pOutRoundMJBack:setScale(self.m_fMinScaleX*0.8, self.m_fMinScaleY*0.8)
        pOutRoundMJData:setScale(self.m_fMinScaleX*0.8, self.m_fMinScaleY*0.8)
        pOutRoundMJBack:setPosition(self.m_OutRound:getPosition())
        pOutRoundMJData:setPosition(pOutRoundMJBack:getPositionX(), pOutRoundMJBack:getPositionY() - 6*self.m_fMinScaleY)

        self:addChild(pOutRoundMJBack, ZORDER_ROUND_316)
        self:addChild(pOutRoundMJData, ZORDER_ROUND_316+1)

        local seqOutRoundMJBack = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(2), cc.Hide:create(), cc.CallFunc:create(function () pOutRoundMJBack:removeFromParent() end))
        local seqOutRoundMJData = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(2), cc.Hide:create(), cc.CallFunc:create(function () pOutRoundMJData:removeFromParent() end))
        pOutRoundMJBack:runAction(seqOutRoundMJBack)
        pOutRoundMJData:runAction(seqOutRoundMJData)

    end

    return true
end

function ASMJ_TableOutMJControl:SetRoundSprite()

    local Visible = cc.Director:getInstance():getVisibleSize()
    self.m_OutRound = cc.Sprite:createWithSpriteFrameName("316_table_out_bg.png")
    self.m_OutRound:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    
    if self.m_OutMJDirection == Direction_East_316 then
        self.m_OutRound:setPosition(cc.p(210*self.m_fMinScaleX, Visible.height/2))
    elseif self.m_OutMJDirection == Direction_South_316 then
        --todo
    elseif self.m_OutMJDirection == Direction_West_316 then
        self.m_OutRound:setPosition(cc.p(Visible.width - 210*self.m_fMinScaleX, Visible.height/2))
    elseif self.m_OutMJDirection == Direction_North_316 then
        self.m_OutRound:setPosition(cc.p(Visible.width/2, Visible.height - 150*self.m_fMinScaleY))
    end

    self.m_OutRound:setVisible(false)
    self:addChild(self.m_OutRound, ZORDER_ROUND_316-1)
end

function ASMJ_TableOutMJControl:DeleteTableOutMJ()

    local iOutMJCount = #self.m_TableOutMJData
    self.m_TableOutMJData[iOutMJCount].pOutMJBack:removeFromParent()
    self.m_TableOutMJData[iOutMJCount].pOutMJData:removeFromParent()

    if self.m_TableOutMJData[iOutMJCount].cbFirstChicken == 1 then
        self.m_TableOutMJData[iOutMJCount].pFirstChicken:removeFromParent()
    end

    table.remove(self.m_TableOutMJData, iOutMJCount)
end

function ASMJ_TableOutMJControl:SetSwayChichenColor(cbSwayData, cbSwayCount)

    local iOutMJCount = #self.m_TableOutMJData
    
    for i=1,iOutMJCount do
        for j=1,cbSwayCount do

            if self.m_TableOutMJData[i].cbMJData ~= 17 and self.m_TableOutMJData[i].cbMJData ~= cbSwayData[j] then
            else
               self.m_TableOutMJData[i].pOutMJBack:setColor(cc.c3b(243,170,175))
               self.m_TableOutMJData[i].pOutMJData:setColor(cc.c3b(243,170,175))
            end

        end
    end
end

function ASMJ_TableOutMJControl:CancelSwayChichenColor()

    local iOutMJCount = #self.m_TableOutMJData
    
    for i=1,iOutMJCount do
        if self.m_TableOutMJData[i].cbMJData == 17 then
            self.m_TableOutMJData[i].pOutMJBack:setColor(cc.c3b(255,255,255))
            self.m_TableOutMJData[i].pOutMJData:setColor(cc.c3b(255,255,255))
        end
    end
end