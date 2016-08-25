local ASMJ_HuControl = class("ASMJ_HuControl", function() return cc.Node:create() end)

HT_LEAF_316         =0
HT_CENTER_316       =1
HT_RIGHT_316        =2

HT_PENG_316         =3
HT_MING_GANG_316    =4
HT_ZIMO_GANG_316    =5
HT_AN_GANG_316      =6

HT_TING_316         =7
HT_HU_316           =8

--create( ... )
function ASMJ_HuControl_create()
    print("ASMJ_HuControl_create")
    local Node = ASMJ_HuControl.new()
    return Node
end

--ctor()
function ASMJ_HuControl:ctor()
    print("ASMJ_HuControl:ctor")

    self.m_HuMJSprite = {}
    
    self.m_fMinScaleX = 1
    self.m_fMinScaleY = 1
    
    self.m_OriginHuPoint = cc.p(0,0)
    self.m_HuMJDirection = Direction_North_316
end

----------------------------------
function ASMJ_HuControl:HuMJClear()
    self.m_HuMJSprite = {}
    self:removeAllChildren()
end

function ASMJ_HuControl:SetScaleMin(iMinScaleX, iMinScaleY)
    self.m_fMinScaleX = iMinScaleX 
    self.m_fMinScaleY = iMinScaleY
end

function ASMJ_HuControl:SetOriginHuPoint(iXPos, iYPos)
    self.m_OriginHuPoint = cc.p(iXPos,iYPos)
end

function ASMJ_HuControl:SetDirection(Direction)
    self.m_OutMJDirection = Direction
end

function ASMJ_HuControl:GetLastHuMJPoint()

    local pt = cc.p(0,0)
    local iHuCount = #self.m_HuMJSprite

    if self.m_HuMJDirection == Direction_East_316 then

        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBase_leftRight_0.png")
        local nItemHeight = Y_TABLE_LR_EXCUSION_316
        pt.x = self.m_OriginHuPoint.x
        pt.y = self.m_OriginHuPoint.y - iHuCount*(2*nItemHeight + pHuMJGAP:getContentSize().height + 5)*self.m_fMinScaleY

    elseif self.m_HuMJDirection == Direction_South_316 then
    
        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")
        local nItemWidth = pHuMJGAP:getContentSize().width
        pt.y = self.m_OriginHuPoint.y
        pt.x = self.m_OriginHuPoint.x + iHuCount*(3*nItemWidth + 10)*self.m_fMinScaleX + 20*self.m_fMinScaleX

    elseif self.m_HuMJDirection == Direction_West_316 then
        
        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBase_leftRight_0.png")
        local nItemHeight = Y_TABLE_LR_EXCUSION_316
        pt.x = self.m_OriginHuPoint.x
        pt.y = self.m_OriginHuPoint.y + iHuCount*(2*nItemHeight + pHuMJGAP:getContentSize().height + 5)*self.m_fMinScaleY

    elseif self.m_HuMJDirection == Direction_North_316 then

        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBase_meUp_0.png")
        local nItemWidth = pHuMJGAP:getContentSize().width
        pt.y = self.m_OriginHuPoint.y
        pt.x = self.m_OriginHuPoint.x - iHuCount*(3*nItemWidth + 10)*self.m_fMinScaleX

    end

    return pt
end


function ASMJ_HuControl:ChickenColorClear()

    for i=1,#self.m_HuMJSprite do
        if self.m_HuMJSprite[i].cbHuMJData ~= 17 then
        else
            if self.m_HuMJSprite[i].cbHuMJType <= HT_RIGHT_316 then
            
            elseif self.m_HuMJSprite[i].cbHuMJType <= HT_PENG_316 then
                for j=1,3 do
                    self.m_HuMJSprite[i].pHuMJData[j]:setColor(cc.c3b(255,255,255))
                    self.m_HuMJSprite[i].pHuMJBack[j]:setColor(cc.c3b(255,255,255))
                end
            elseif self.m_HuMJSprite[i].cbHuMJType == HT_MING_GANG_316 or self.m_HuMJSprite[i].cbHuMJType == HT_ZIMO_GANG_316 then
                for j=1,4 do
                    self.m_HuMJSprite[i].pHuMJData[j]:setColor(cc.c3b(255,255,255))
                    self.m_HuMJSprite[i].pHuMJBack[j]:setColor(cc.c3b(255,255,255))
                end
            elseif self.m_HuMJSprite[i].cbHuMJType == HT_AN_GANG_316 then
                self.m_HuMJSprite[i].pHuMJData[4]:setColor(cc.c3b(255,255,255))
                self.m_HuMJSprite[i].pHuMJBack[4]:setColor(cc.c3b(255,255,255))
            end
        end
    end

    return
end

function ASMJ_HuControl:DrawHuControl(cbMJData, cbHuMJType, ptOutMJ, wProvider, bAction, bNotOffLine)
    
    bAction = bAction == nil and true or false
    bNotOffLine = bNotOffLine == nil and true or false 
    
    local hmj = {}
    hmj.cbHuMJData = cbMJData
    hmj.cbHuMJType = cbHuMJType
    hmj.iProvider = wProvider

    if cbHuMJType <= HT_PENG_316 then
        hmj.cbHuMJCount = 3
    elseif cbHuMJType == HT_MING_GANG_316 then
        hmj.cbHuMJCount = 4
    elseif cbHuMJType == HT_ZIMO_GANG_316 then
        if bNotOffLine and self:DrawOtherZiMoMing(cbMJData, hmj, bAction) then
            return 
        else
            hmj.cbHuMJCount = 4
        end
    elseif cbHuMJType == HT_AN_GANG_316 then
        hmj.bHide = true
        hmj.cbHuMJCount = 4
    end

    local iHuCount = #self.m_HuMJSprite

    if self.m_HuMJDirection == Direction_East_316 then

        hmj.pHuMJBack = {}
        hmj.pHuMJData = {}

        hmj.ptHuMJBack = {}
        hmj.ptHuMJData = {}

        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_leftRight_0.png")
        for i=1,hmj.cbHuMJCount do

            local nItemWidth = pHuMJGAP:getContentSize().width-3
            local nItemHeight = Y_TABLE_LR_EXCUSION_316

            if i ~= 4 then
                hmj.ptHuMJBack[i] = cc.p(self.m_OriginHuPoint.x,  self.m_OriginHuPoint.y - iHuCount*(2*nItemHeight + pHuMJGAP:getContentSize().height+5)*self.m_fMinScaleY - (i-1)*nItemHeight*self.m_fMinScaleY)
                hmj.ptHuMJData[i] = cc.p(hmj.ptHuMJBack[i].x, hmj.ptHuMJBack[i].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
            end

            if i == 2 then
                hmj.ptHuMJBack[4] = cc.p(self.m_OriginHuPoint.x, self.m_OriginHuPoint.y - iHuCount*(2*nItemHeight + pHuMJGAP:getContentSize().height+5)*self.m_fMinScaleY - (nItemHeight/2+4)*self.m_fMinScaleY)
                hmj.ptHuMJData[4] = cc.p(hmj.ptHuMJBack[4].x, hmj.ptHuMJBack[4].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
            end

            if hmj.bHide and i <= 3 then

                hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_leftRight_0.png")
                hmj.pHuMJBack[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                hmj.pHuMJBack[i]:setPosition(hmj.ptHuMJBack[i])
                self:addChild(hmj.pHuMJBack[i], ZORDER_HU_MJ_HIDE_316+iHuCount*3+i)
            else
                
                hmj.pHuMJData[i] = cc.Sprite:createWithSpriteFrameName(string.format("316_tile_leftRight_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15)))
                hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileBase_leftRight_0.png")

                hmj.pHuMJData[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                hmj.pHuMJBack[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

                hmj.pHuMJData[i]:setPosition(hmj.ptHuMJData[i])
                hmj.pHuMJBack[i]:setPosition(hmj.ptHuMJBack[i])

                if cbMJData == 17 then
                    hmj.pHuMJData[i]:setColor(cc.c3b(243,170,175))
                    hmj.pHuMJBack[i]:setColor(cc.c3b(243,170,175))
                end

                self:addChild(hmj.pHuMJBack[i], ZORDER_HU_MJ_BACK_316+iHuCount*3+i)
                self:addChild(hmj.pHuMJData[i], ZORDER_HU_MJ_DATA_316+iHuCount*3+i)

            
                if wProvider ~= self.m_HuMJDirection then
                    if (cbHuMJType == HT_MING_GANG_316 and i == 4) or (cbHuMJType == HT_PENG_316 and i == 2) then
                        hmj.pIndicate = cc.Sprite:createWithSpriteFrameName(string.format("316_whmj_%d.png", hmj.iProvider))
                        hmj.pIndicate:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                        hmj.pIndicate:setPosition(hmj.ptHuMJData[i])
                        self:addChild(hmj.pIndicate, ZORDER_HU_MJ_DATA_316+1+iHuCount*3+i)
                    end
                end
            end
        end
        
    elseif self.m_HuMJDirection == Direction_West_316 then
        
        hmj.pHuMJBack = {}
        hmj.pHuMJData = {}

        hmj.ptHuMJBack = {}
        hmj.ptHuMJData = {}

        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_leftRight_0.png")
        for i=1,hmj.cbHuMJCount do

            local nItemWidth = pHuMJGAP:getContentSize().width-3
            local nItemHeight = Y_TABLE_LR_EXCUSION_316

            if i ~= 4 then
                hmj.ptHuMJBack[i] = cc.p(self.m_OriginHuPoint.x,  self.m_OriginHuPoint.y + iHuCount*(2*nItemHeight + pHuMJGAP:getContentSize().height+5)*self.m_fMinScaleY + (i-1)*nItemHeight*self.m_fMinScaleY)
                hmj.ptHuMJData[i] = cc.p(hmj.ptHuMJBack[i].x, hmj.ptHuMJBack[i].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
            end

            if i == 2 then
                hmj.ptHuMJBack[4] = cc.p(self.m_OriginHuPoint.x, self.m_OriginHuPoint.y + iHuCount*(2*nItemHeight + pHuMJGAP:getContentSize().height+5)*self.m_fMinScaleY + (3.0/2*nItemHeight-4)*self.m_fMinScaleY)
                hmj.ptHuMJData[4] = cc.p(hmj.ptHuMJBack[4].x, hmj.ptHuMJBack[4].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
            end

            local iZorderIndex = (i == 4) and 50 or (49-i-iHuCount*3)


            if hmj.bHide and i <= 3 then

                hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_leftRight_0.png")
                hmj.pHuMJBack[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                hmj.pHuMJBack[i]:setPosition(hmj.ptHuMJBack[i])
                self:addChild(hmj.pHuMJBack[i], iZorderIndex)
            else
                
                hmj.pHuMJData[i] = cc.Sprite:createWithSpriteFrameName(string.format("316_tile_leftRight_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15)))
                hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileBase_leftRight_0.png")

                hmj.pHuMJData[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                hmj.pHuMJBack[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

                hmj.pHuMJData[i]:setPosition(hmj.ptHuMJData[i])
                hmj.pHuMJBack[i]:setPosition(hmj.ptHuMJBack[i])

                hmj.pHuMJData[i]:setRotation3D(cc.Vertex3F(0,0,180))

                if cbMJData == 17 then
                    hmj.pHuMJData[i]:setColor(cc.c3b(243,170,175))
                    hmj.pHuMJBack[i]:setColor(cc.c3b(243,170,175))
                end

                self:addChild(hmj.pHuMJBack[i], iZorderIndex)
                self:addChild(hmj.pHuMJData[i], iZorderIndex+1)

                if wProvider ~= self.m_HuMJDirection then
                    if (cbHuMJType == HT_MING_GANG_316 and i == 4) or (cbHuMJType == HT_PENG_316 and i == 2) then
                        hmj.pIndicate = cc.Sprite:createWithSpriteFrameName(string.format("316_whmj_%d.png", hmj.iProvider))
                        hmj.pIndicate:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                        hmj.pIndicate:setPosition(hmj.ptHuMJData[i])
                        self:addChild(hmj.pIndicate, iZorderIndex+2)
                    end
                end
            end
        end
        
    elseif self.m_HuMJDirection == Direction_South_316 then    

        if bAction then
            self:DrawMyHuMJAction(hmj, ptOutMJ)
            return
        end

        hmj.pHuMJBack = {}
        hmj.pHuMJData = {}

        hmj.ptHuMJBack = {}
        hmj.ptHuMJData = {}

        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")
        for i=1,hmj.cbHuMJCount do
            local nItemWidth = pHuMJGAP:getContentSize().width-3
            local nItemHeight = Y_TABLE_LR_EXCUSION_316

            if i ~= 4 then
                hmj.ptHuMJBack[i] = cc.p(self.m_OriginHuPoint.x + iHuCount*(3*nItemWidth + Y_HU_BT_EXCUSION_316)*self.m_fMinScaleX + (i-1)*nItemWidth*self.m_fMinScaleX, self.m_OriginHuPoint.y)
                hmj.ptHuMJData[i] = cc.p(hmj.ptHuMJBack[i].x, hmj.ptHuMJBack[i].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
            end

            if i == 2 then
                hmj.ptHuMJBack[4] = cc.p(self.m_OriginHuPoint.x + iHuCount*(3*nItemWidth + Y_HU_BT_EXCUSION_316 )*self.m_fMinScaleX + nItemWidth*self.m_fMinScaleX , self.m_OriginHuPoint.y + 18*self.m_fMinScaleY)
                hmj.ptHuMJData[4] = cc.p(hmj.ptHuMJBack[4].x, hmj.ptHuMJBack[4].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
            end

            if hmj.bHide and i <= 3 then
            
                hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileDown_me_0.png")
                hmj.pHuMJBack[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                hmj.pHuMJBack[i]:setPosition(hmj.ptHuMJBack[i])
                addChild(hmj.pHuMJBack[i], ZORDER_HU_MJ_HIDE+iHuCount*3+i)
            
            else
            
                hmj.pHuMJData[i] = cc.Sprite:createWithSpriteFrameName(string.format("316_tile_me_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15)))
                hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")

                hmj.pHuMJData[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                hmj.pHuMJBack[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

                hmj.pHuMJData[i]:setPosition(hmj.ptHuMJData[i])
                hmj.pHuMJBack[i]:setPosition(hmj.ptHuMJBack[i])

                if cbMJData == 17 then
                    hmj.pHuMJData[i]:setColor(cc.c3b(243,170,175))
                    hmj.pHuMJBack[i]:setColor(cc.c3b(243,170,175))
                end

                self:addChild(hmj.pHuMJBack[i], ZORDER_HU_MJ_BACK_316+iHuCount*3+i)
                self:addChild(hmj.pHuMJData[i], ZORDER_HU_MJ_DATA_316+iHuCount*3+i)

                if wProvider ~= self.m_HuMJDirection then
                    if (cbHuMJType == HT_MING_GANG_316 and i == 4) or (cbHuMJType == HT_PENG_316 and i == 2) then
                        hmj.pIndicate = cc.Sprite:createWithSpriteFrameName(string.format("316_whmj_%d.png", hmj.iProvider))
                        hmj.pIndicate:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                        hmj.pIndicate:setPosition(hmj.ptHuMJData[i])
                        self:addChild(hmj.pIndicate, ZORDER_HU_MJ_DATA_316+1+iHuCount*3+i)
                    end
                end
            end
        end

    elseif self.m_HuMJDirection == Direction_North_316 then           

        hmj.pHuMJBack = {}
        hmj.pHuMJData = {}

        hmj.ptHuMJBack = {}
        hmj.ptHuMJData = {}

        local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBase_meUp_0.png")
        for i=1,hmj.cbHuMJCount do
            local nItemWidth = pHuMJGAP:getContentSize().width-3
            local nItemHeight = Y_TABLE_LR_EXCUSION_316

            if i ~= 4 then
                hmj.ptHuMJBack[i] = cc.p(self.m_OriginHuPoint.x - iHuCount*(3*nItemWidth + Y_HU_BT_EXCUSION_316)*self.m_fMinScaleX - (i-1)*nItemWidth*self.m_fMinScaleX, self.m_OriginHuPoint.y)
                hmj.ptHuMJData[i] = cc.p(hmj.ptHuMJBack[i].x, hmj.ptHuMJBack[i].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
            end

            if i == 2 then
                hmj.ptHuMJBack[4] = cc.p(self.m_OriginHuPoint.x - iHuCount*(3*nItemWidth + Y_HU_BT_EXCUSION_316 )*self.m_fMinScaleX - nItemWidth*self.m_fMinScaleX , self.m_OriginHuPoint.y + 18*self.m_fMinScaleY)
                hmj.ptHuMJData[4] = cc.p(hmj.ptHuMJBack[4].x, hmj.ptHuMJBack[4].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
            end

            if hmj.bHide and i <= 3 then
            
                hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileUpSet_Up_0.png")
                hmj.pHuMJBack[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                hmj.pHuMJBack[i]:setPosition(hmj.ptHuMJBack[i])
                self:addChild(hmj.pHuMJBack[i], ZORDER_HU_MJ_HIDE_316+iHuCount*3+i)
            
            else
            
                hmj.pHuMJData[i] = cc.Sprite:createWithSpriteFrameName(string.format("316_tile_meUp_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15)))
                hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileBase_meUp_0.png")

                hmj.pHuMJData[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                hmj.pHuMJBack[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

                hmj.pHuMJData[i]:setPosition(hmj.ptHuMJData[i])
                hmj.pHuMJBack[i]:setPosition(hmj.ptHuMJBack[i])

                if cbMJData == 17 then
                    hmj.pHuMJData[i]:setColor(cc.c3b(243,170,175))
                    hmj.pHuMJBack[i]:setColor(cc.c3b(243,170,175))
                end

                self:addChild(hmj.pHuMJBack[i], ZORDER_HU_MJ_BACK_316+iHuCount*3+i)
                self:addChild(hmj.pHuMJData[i], ZORDER_HU_MJ_DATA_316+iHuCount*3+i)

                if wProvider ~= self.m_HuMJDirection then
                    if (cbHuMJType == HT_MING_GANG_316 and i == 4) or (cbHuMJType == HT_PENG_316 and i == 2) then
                        hmj.pIndicate = cc.Sprite:createWithSpriteFrameName(string.format("316_whmj_%d.png", hmj.iProvider))
                        hmj.pIndicate:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
                        hmj.pIndicate:setPosition(hmj.ptHuMJData[i])
                        self:addChild(hmj.pIndicate, ZORDER_HU_MJ_DATA_316+1+iHuCount*3+i)
                    end
                end
            end
        end

    end

    table.insert(self.m_HuMJSprite, hmj)
    
end

function ASMJ_HuControl:DrawOtherZiMoMing(cbMJData, hmj, bAction)

    if self.m_HuMJDirection == Direction_South_316 and bAction then
        return false
    end

    for i=1,#self.m_HuMJSprite do
        if self.m_HuMJSprite[i].cbHuMJData == cbMJData and self.m_HuMJSprite[i].cbHuMJType == HT_PENG_316 then
            
            local strData = ""
            local strBack = ""

            if self.m_HuMJDirection == Direction_North_316 then
                
                strBack = string.format("316_tileBase_meUp_0.png")
                strData = string.format("316_tile_meUp_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15))

            elseif self.m_HuMJDirection == Direction_South_316 then
                
                strBack = string.format("316_tileBaseFinish_me_0.png")
                strData = string.format("316_tile_me_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15))

            elseif self.m_HuMJDirection == Direction_East_316 or self.m_HuMJDirection == Direction_West_316 then
                
                strBack = string.format("316_tileBase_leftRight_0.png")
                strData = string.format("316_tile_leftRight_%d%d.png", bit:_rshift(cbMJData, 4), bit:_and(cbMJData, 15))

            end

            self.m_HuMJSprite[i].cbHuMJType = HT_ZIMO_GANG_316
            self.m_HuMJSprite[i].pHuMJData[4] = cc.Sprite:createWithSpriteFrameName(strData)
            self.m_HuMJSprite[i].pHuMJBack[4] = cc.Sprite:createWithSpriteFrameName(strBack) 

            self.m_HuMJSprite[i].pHuMJData[4]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            self.m_HuMJSprite[i].pHuMJBack[4]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

            self.m_HuMJSprite[i].pHuMJData[4]:setPosition(self.m_HuMJSprite[i].ptHuMJData[4])
            self.m_HuMJSprite[i].pHuMJBack[4]:setPosition(self.m_HuMJSprite[i].ptHuMJBack[4])

            if cbMJData == 17 then
                for i=1,4 do
                    self.m_HuMJSprite[i].pHuMJData[i]:setColor(cc.c3b(243,170,175))
                    self.m_HuMJSprite[i].pHuMJBack[i]:setColor(cc.c3b(243,170,175))
                end
            end

            if self.m_HuMJDirection == Direction_West_316 then
                self.m_HuMJSprite[i].pHuMJData[4]:setRotation3D(cc.Vertex3F(0,0,180))
            end

            self:addChild(self.m_HuMJSprite[i].pHuMJBack[4], ZORDER_HU_MJ_TOP_316)
            self:addChild(self.m_HuMJSprite[i].pHuMJData[4], ZORDER_HU_MJ_TOP_316+1)

            break
        end
    end

    return true
end

function ASMJ_HuControl:SetSwayChichenColor(cbSwayData, cbSwayCount)

    for i=1,#self.m_HuMJSprite do
        for j=1,cbSwayCount do
            if self.m_HuMJSprite[i].cbHuMJData == 17 or self.m_HuMJSprite[i].cbHuMJData == cbSwayData[j] then

                if self.m_HuMJSprite[i].cbHuMJType == HT_PENG_316 then
                    for z=1,3 do
                        self.m_HuMJSprite[i].pHuMJData[z]:setColor(cc.c3b(243,170,175))
                        self.m_HuMJSprite[i].pHuMJBack[z]:setColor(cc.c3b(243,170,175))
                    end
                elseif self.m_HuMJSprite[i].cbHuMJType == HT_MING_GANG_316 or self.m_HuMJSprite[i].cbHuMJType == HT_ZIMO_GANG_316 then
                    for z=1,4 do
                        self.m_HuMJSprite[i].pHuMJData[z]:setColor(cc.c3b(243,170,175))
                        self.m_HuMJSprite[i].pHuMJBack[z]:setColor(cc.c3b(243,170,175))
                    end
                elseif self.m_HuMJSprite[i].cbHuMJType == HT_AN_GANG_316 then
                    self.m_HuMJSprite[i].pHuMJData[4]:setColor(cc.c3b(243,170,175))
                    self.m_HuMJSprite[i].pHuMJBack[4]:setColor(cc.c3b(243,170,175))
                end

            end
        end
    end

    return
end

function ASMJ_HuControl:DrawMyHuMJAction(hmj, ptOutMJ)

    if hmj.cbHuMJType == HT_PENG_316 then
        self:DrawMyHuMJPengAction(hmj, ptOutMJ)
    elseif hmj.cbHuMJType == HT_MING_GANG_316 or hmj.cbHuMJType == HT_AN_GANG_316 then
        self:DrawMyHuMJAnAction(hmj, ptOutMJ)
    elseif hmj.cbHuMJType == HT_ZIMO_GANG_316 then
        self:DrawMyHuMJZiMoMingAction(hmj, ptOutMJ)
    end

end

function ASMJ_HuControl:DrawMyHuMJPengAction(hmj, ptOutMJ)

    print("ASMJ_HuControl:DrawMyHuMJPengAction")

    hmj.pHuMJData = {}
    hmj.pHuMJBack = {}

    hmj.ptHuMJData = {}
    hmj.ptHuMJBack = {}

    local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")
    pHuMJGAP:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

    local Visible = cc.Director:getInstance():getVisibleSize()
    local iTargetWidth = (pHuMJGAP:getContentSize().width-3)*self.m_fMinScaleX
    local ptTargetBack = {}
    local ptTargetData = {}

    for i=1,3 do
        ptTargetBack[i] = cc.p(Visible.width/2 - 3/2*iTargetWidth + (i-1)*iTargetWidth, 240*self.m_fMinScaleY)
        ptTargetData[i] = cc.p(ptTargetBack[i].x, ptTargetBack[i].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
    end
    
    
    local str = string.format("316_tile_me_%d%d.png", bit:_rshift(hmj.cbHuMJData, 4), bit:_and(hmj.cbHuMJData, 15))
    for i=1,2 do
        hmj.pHuMJData[i] = cc.Sprite:createWithSpriteFrameName(str)
        hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")

        if hmj.cbHuMJData == 17 then
            hmj.pHuMJData[i]:setColor(cc.c3b(243,170,175))
            hmj.pHuMJBack[i]:setColor(cc.c3b(243,170,175))
        end

        hmj.pHuMJData[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        hmj.pHuMJData[i]:setPosition(ptTargetData[i])
        self:addChild(hmj.pHuMJData[i], ZORDER_HU_MJ_DATA_316)

        hmj.pHuMJBack[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        hmj.pHuMJBack[i]:setPosition(ptTargetBack[i])
        self:addChild(hmj.pHuMJBack[i], ZORDER_HU_MJ_BACK_316)
    end

    hmj.pHuMJData[3] = cc.Sprite:createWithSpriteFrameName(str)
    hmj.pHuMJBack[3] = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")
    if hmj.cbHuMJData == 17 then
        hmj.pHuMJData[3]:setColor(cc.c3b(243,170,175))
        hmj.pHuMJBack[3]:setColor(cc.c3b(243,170,175))
    end

    hmj.pHuMJData[3]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    hmj.pHuMJData[3]:setPosition(ptOutMJ.x,  ptOutMJ.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
    self:addChild(hmj.pHuMJData[3], ZORDER_HU_MJ_DATA_316)

    hmj.pHuMJBack[3]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    hmj.pHuMJBack[3]:setPosition(ptOutMJ)
    self:addChild(hmj.pHuMJBack[3], ZORDER_HU_MJ_BACK_316)

    local bezierOutMJ = {
        cc.p(ptOutMJ.x + (ptTargetBack[3].x - ptOutMJ.x)/2,  ptOutMJ.y),
        cc.p(ptTargetBack[3].x, ptOutMJ.y + (ptTargetBack[3].y - ptOutMJ.y)/2),
        cc.p(ptTargetBack[3]),
    }

    hmj.pHuMJBack[3]:runAction(cc.BezierTo:create(0.3, bezierOutMJ))
    hmj.pHuMJData[3]:runAction(cc.BezierTo:create(0.3, bezierOutMJ))
    
    local iHuCount = #self.m_HuMJSprite
    for i=1,hmj.cbHuMJCount do
        local nItemWidth = pHuMJGAP:getContentSize().width-3
        local nItemHeight = Y_TABLE_LR_EXCUSION_316

        if i ~= 4 then
            hmj.ptHuMJBack[i] = cc.p(self.m_OriginHuPoint.x + iHuCount*(3*nItemWidth + Y_HU_BT_EXCUSION_316)*self.m_fMinScaleX + (i-1)*nItemWidth*self.m_fMinScaleX, self.m_OriginHuPoint.y)
            hmj.ptHuMJData[i] = cc.p(hmj.ptHuMJBack[i].x, hmj.ptHuMJBack[i].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
        end

        if i == 2 then
            hmj.ptHuMJBack[4] = cc.p(self.m_OriginHuPoint.x + iHuCount*(3*nItemWidth + Y_HU_BT_EXCUSION_316)*self.m_fMinScaleX + nItemWidth*self.m_fMinScaleX, self.m_OriginHuPoint.y + 18*self.m_fMinScaleY)
            hmj.ptHuMJData[4] = cc.p(hmj.ptHuMJBack[4].x, hmj.ptHuMJBack[4].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
        end
    end

    local pMoveByBack = {}
    local pMoveByData = {}

    for i=1,3 do
        pMoveByBack[i] = cc.MoveBy:create(0.3, cc.p((i == 3 and 100 or -100)*self.m_fMinScaleX, 0))
        pMoveByData[i] = cc.MoveBy:create(0.3, cc.p((i == 3 and 100 or -100)*self.m_fMinScaleX, 0))
    end

    local bezierHuMJBack = {}
    local bezierHuMJData = {}

    for i=1,3 do
        bezierHuMJBack[i] = {
            cc.p(ptTargetBack[i].x, ptTargetBack[i].y*5/4),
            cc.p(hmj.ptHuMJBack[i].x, ptTargetBack[i].y*5/4),
            cc.p(hmj.ptHuMJBack[i]),
        }

        bezierHuMJData[i] = {
            cc.p(ptTargetData[i].x, ptTargetData[i].y*5/4),
            cc.p(hmj.ptHuMJData[i].x, ptTargetData[i].y*5/4),
            cc.p(hmj.ptHuMJData[i]),
        }
    end
 
    for i=1,3 do
        local pCall = nil
        local seqBack = cc.Sequence:create(cc.DelayTime:create(0.3), pMoveByBack[i], pMoveByBack[i]:reverse(), cc.BezierTo:create(0.4, bezierHuMJBack[i]))
        local seqData = cc.Sequence:create(cc.DelayTime:create(0.3), pMoveByData[i], pMoveByData[i]:reverse(), cc.BezierTo:create(0.4, bezierHuMJData[i]), i == 2 and cc.CallFunc:create(handler(self, self.DrawMyHuMJIndirect)) or nil)
        hmj.pHuMJBack[i]:runAction(seqBack)
        hmj.pHuMJData[i]:runAction(seqData)
    end
    
    table.insert(self.m_HuMJSprite, hmj)
end


function ASMJ_HuControl:DrawMyHuMJAnAction(hmj, ptOutMJ)
    hmj.pHuMJData = {}
    hmj.pHuMJBack = {}

    hmj.ptHuMJData = {}
    hmj.ptHuMJBack = {}

    local pHuMJGAP = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")
    pHuMJGAP:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

    local Visible = cc.Director:getInstance():getVisibleSize()
    local iTargetWidth = (pHuMJGAP:getContentSize().width-3)*self.m_fMinScaleX
    local ptTargetBack = {}
    local ptTargetData = {}

    for i=1,4 do
        ptTargetBack[i] = cc.p(Visible.width/2 - 3/2*iTargetWidth + (i-1)*iTargetWidth, 240*self.m_fMinScaleY)
        ptTargetData[i] = cc.p(ptTargetBack[i].x, ptTargetBack[i].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
    end
    
    local str = string.format("316_tile_me_%d%d.png", bit:_rshift(hmj.cbHuMJData, 4), bit:_and(hmj.cbHuMJData, 15))
    for i=1,3 do

        if hmj.bHide then
        
            hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileDown_me_0.png")
        
        else
            hmj.pHuMJData[i] = cc.Sprite:createWithSpriteFrameName(str)
            hmj.pHuMJBack[i] = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")
            hmj.pHuMJData[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            hmj.pHuMJData[i]:setPosition(ptTargetData[i])
            self:addChild(hmj.pHuMJData[i], ZORDER_HU_MJ_DATA_316)
        end

        if hmj.cbHuMJData == 17 and hmj.cbHuMJType == HT_MING_GANG_316 then
            hmj.pHuMJData[i]:setColor(cc.c3b(243,170,175))
            hmj.pHuMJBack[i]:setColor(cc.c3b(243,170,175))
        end

        hmj.pHuMJBack[i]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
        hmj.pHuMJBack[i]:setPosition(ptTargetBack[i])
        self:addChild(hmj.pHuMJBack[i], ZORDER_HU_MJ_BACK_316)
    end

    if hmj.cbHuMJType ==  HT_AN_GANG_316 then
        ptOutMJ = cc.p(ptTargetBack[4].x, ptTargetBack[4].y+90*self.m_fMinScaleY)
    end

    hmj.pHuMJData[4] = cc.Sprite:createWithSpriteFrameName(str)
    hmj.pHuMJBack[4] = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")
    if hmj.cbHuMJData == 17 then
        hmj.pHuMJData[4]:setColor(cc.c3b(243,170,175))
        hmj.pHuMJBack[4]:setColor(cc.c3b(243,170,175))
    end

    hmj.pHuMJData[4]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    hmj.pHuMJData[4]:setPosition(ptOutMJ.x,  ptOutMJ.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
    self:addChild(hmj.pHuMJData[4], ZORDER_HU_MJ_TOP_316+1)

    hmj.pHuMJBack[4]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
    hmj.pHuMJBack[4]:setPosition(ptOutMJ)
    self:addChild(hmj.pHuMJBack[4], ZORDER_HU_MJ_TOP_316)

    if hmj.cbHuMJType ==  HT_AN_GANG_316 then
    
        local moveAction = cc.MoveTo:create(0.5, ptTargetBack[4])
        local easeAction = cc.EaseBounceOut:create(moveAction:clone())

        local moveActionData = cc.MoveTo:create(0.5, ptTargetData[4])
        local easeActionData = cc.EaseBounceOut:create(moveActionData:clone())

        hmj.pHuMJBack[4]:runAction(easeAction)
        hmj.pHuMJData[4]:runAction(easeActionData)
    
    else
    
        local bezierOutMJ = {
            cc.p(ptOutMJ.x + (ptTargetBack[4].x - ptOutMJ.x)/2,  ptOutMJ.y),
            cc.p(ptTargetBack[4].x, ptOutMJ.y + (ptTargetBack[4].y - ptOutMJ.y)/2),
            cc.p(ptTargetBack[4]),
        }

        hmj.pHuMJBack[4]:runAction(cc.BezierTo:create(0.5, bezierOutMJ))
        hmj.pHuMJData[4]:runAction(cc.BezierTo:create(0.5, bezierOutMJ))
    end


    local iHuCount = #self.m_HuMJSprite
    for i=1,hmj.cbHuMJCount do
        local nItemWidth = pHuMJGAP:getContentSize().width-3
        local nItemHeight = Y_TABLE_LR_EXCUSION_316

        if i ~= 4 then
            hmj.ptHuMJBack[i] = cc.p(self.m_OriginHuPoint.x + iHuCount*(3*nItemWidth + Y_HU_BT_EXCUSION_316)*self.m_fMinScaleX + (i-1)*nItemWidth*self.m_fMinScaleX, self.m_OriginHuPoint.y)
            hmj.ptHuMJData[i] = cc.p(hmj.ptHuMJBack[i].x, hmj.ptHuMJBack[i].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
        end

        if i == 2 then
            hmj.ptHuMJBack[4] = cc.p(self.m_OriginHuPoint.x + iHuCount*(3*nItemWidth + Y_HU_BT_EXCUSION_316)*self.m_fMinScaleX + nItemWidth*self.m_fMinScaleX, self.m_OriginHuPoint.y + 18*self.m_fMinScaleY)
            hmj.ptHuMJData[4] = cc.p(hmj.ptHuMJBack[4].x, hmj.ptHuMJBack[4].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)
        end
    end

    local bezierHuMJBack = {}
    local bezierHuMJData = {}
    for i=1,4 do
        bezierHuMJBack[i] = {
            cc.p(ptTargetBack[i].x, ptTargetBack[i].y*5/4),
            cc.p(hmj.ptHuMJBack[i].x, ptTargetBack[i].y*5/4),
            cc.p(hmj.ptHuMJBack[i]),
        }

        bezierHuMJData[i] = {
            cc.p(ptTargetData[i].x, ptTargetData[i].y*5/4),
            cc.p(hmj.ptHuMJData[i].x, ptTargetData[i].y*5/4),
            cc.p(hmj.ptHuMJData[i]),
        }
    end

    for i=1,4 do
        hmj.pHuMJBack[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.BezierTo:create(0.3, bezierHuMJBack[i])))
        if hmj.pHuMJData[i] ~= nil then
            hmj.pHuMJData[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.BezierTo:create(0.3, bezierHuMJData[i]), i == 4 and cc.CallFunc:create(handler(self, self.DrawMyHuMJIndirect)) or nil))
        end
    end

    table.insert(self.m_HuMJSprite, hmj)
end


function ASMJ_HuControl:DrawMyHuMJZiMoMingAction(hmj, ptOutMJ)

    local ptZiMoMJ = ptOutMJ
    local Visible = cc.Director:getInstance():getVisibleSize()

    for i=1,#self.m_HuMJSprite do
        if self.m_HuMJSprite[i].cbHuMJData == hmj.cbHuMJData and self.m_HuMJSprite[i].cbHuMJType == HT_PENG_316 then
            
            self.m_HuMJSprite[i].pIndicate:removeFromParent()

            self.m_HuMJSprite[i].pHuMJData[4] = cc.Sprite:createWithSpriteFrameName(string.format("316_tile_me_%d%d.png", bit:_rshift(hmj.cbHuMJData, 4), bit:_and(hmj.cbHuMJData, 15)))
            self.m_HuMJSprite[i].pHuMJBack[4] = cc.Sprite:createWithSpriteFrameName("316_tileBaseFinish_me_0.png")

            self.m_HuMJSprite[i].pHuMJData[4]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)
            self.m_HuMJSprite[i].pHuMJBack[4]:setScale(self.m_fMinScaleX, self.m_fMinScaleY)

            self.m_HuMJSprite[i].pHuMJBack[4]:setPosition(ptZiMoMJ)
            self.m_HuMJSprite[i].pHuMJData[4]:setPosition(ptZiMoMJ.x,  ptZiMoMJ.y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)

            if hmj.cbHuMJData == 17 then
                for j=1,4 do
                    self.m_HuMJSprite[i].pHuMJData[j]:setColor(cc.c3b(243,170,175))
                    self.m_HuMJSprite[i].pHuMJBack[j]:setColor(cc.c3b(243,170,175))
                end
            end

            self:addChild(self.m_HuMJSprite[i].pHuMJBack[4], ZORDER_HU_MJ_TOP_316)
            self:addChild(self.m_HuMJSprite[i].pHuMJData[4], ZORDER_HU_MJ_TOP_316+1)

            local iTargetWidth = self.m_HuMJSprite[i].pHuMJBack[1]:getBoundingBox().width
            local ptTargetBack = {}
            local ptTargetData = {}

            local ptOriginBack = {}
            local ptOriginData = {}

            for j=1,4 do
                ptTargetBack[j] = cc.p(Visible.width/2 - 3/2*iTargetWidth + (j-1)*iTargetWidth, 240*self.m_fMinScaleY)
                ptTargetData[j] = cc.p(ptTargetBack[j].x, ptTargetBack[j].y + DATA_MJ_EDGE_LRT_316*self.m_fMinScaleY)

                ptOriginData[j] = cc.p(self.m_HuMJSprite[i].pHuMJData[j]:getPosition())
                ptOriginBack[j] = cc.p(self.m_HuMJSprite[i].pHuMJBack[j]:getPosition())
            end

            for j=1,4 do
                local bezierMJBack = {
                    cc.p(ptOriginBack[j].x, ptTargetBack[j].y*5/4),
                    cc.p(ptTargetBack[j].x, ptTargetBack[j].y*5/4),
                    cc.p(ptTargetBack[j]),
                }

                local bezierMJData = {
                    cc.p(ptOriginData[j].x, ptTargetData[j].y*5/4),
                    cc.p(ptTargetData[j].x, ptTargetData[j].y*5/4),
                    cc.p(ptTargetData[j]),
                }

                self.m_HuMJSprite[i].pHuMJBack[j]:runAction(cc.BezierTo:create(0.3, bezierMJBack))
                self.m_HuMJSprite[i].pHuMJData[j]:runAction(cc.BezierTo:create(0.3, bezierMJData))
            end


            local bezierHuMJBack = {}
            local bezierHuMJData = {}

            for j=1,4 do
                bezierHuMJBack[j] = {
                    cc.p(self.m_HuMJSprite[i].ptHuMJBack[j].x, ptTargetBack[j].y*5/4),
                    cc.p(self.m_HuMJSprite[i].ptHuMJBack[j].x, ptTargetBack[j].y*5/4),
                    cc.p(self.m_HuMJSprite[i].ptHuMJBack[j]),
                }

                bezierHuMJData[j] = {
                    cc.p(self.m_HuMJSprite[i].ptHuMJData[j].x, ptTargetData[j].y*5/4),
                    cc.p(self.m_HuMJSprite[i].ptHuMJData[j].x, ptTargetData[j].y*5/4),
                    cc.p(self.m_HuMJSprite[i].ptHuMJData[j]),
                }

                self.m_HuMJSprite[i].pHuMJBack[j]:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.BezierTo:create(0.3, bezierHuMJBack[j])))
                self.m_HuMJSprite[i].pHuMJData[j]:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.BezierTo:create(0.3, bezierHuMJData[j])))
            end

            self.m_HuMJSprite[i].cbHuMJCount = 4
            self.m_HuMJSprite[i].cbHuMJType = HT_ZIMO_GANG_316
        end
    end

    return
end

function ASMJ_HuControl:DrawMyHuMJIndirect()

    local iCurrentMJIndex = #self.m_HuMJSprite

    local str = string.format("316_whmj_%d.png", self.m_HuMJSprite[iCurrentMJIndex].iProvider)
    self.m_HuMJSprite[iCurrentMJIndex].pIndicate = cc.Sprite:createWithSpriteFrameName(str)
    self.m_HuMJSprite[iCurrentMJIndex].pIndicate:setScale(self.m_fMinScaleX/0.8, self.m_fMinScaleY/0.8)

    if self.m_HuMJSprite[iCurrentMJIndex].cbHuMJType == HT_PENG_316 then

        self.m_HuMJSprite[iCurrentMJIndex].pIndicate:setPosition(self.m_HuMJSprite[iCurrentMJIndex].pHuMJData[2]:getPosition())
        self:addChild(self.m_HuMJSprite[iCurrentMJIndex].pIndicate, ZORDER_HU_MJ_DATA_316+1)

    elseif self.m_HuMJSprite[iCurrentMJIndex].cbHuMJType == HT_MING_GANG_316 then
        
        self.m_HuMJSprite[iCurrentMJIndex].pIndicate:setPosition(self.m_HuMJSprite[iCurrentMJIndex].pHuMJData[4]:getPosition())
        self:addChild(self.m_HuMJSprite[iCurrentMJIndex].pIndicate, ZORDER_HU_MJ_TOP_316+10)

    end
end

