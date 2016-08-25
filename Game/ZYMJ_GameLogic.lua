ASMJ_GameLogic = class("ASMJ_GameLogic", nil)


MASK_COLOR_316                  =240
MASK_VALUE_316                  =15

WIK_NULL_316                    =0                                
WIK_LEFT_316                    =1                                
WIK_CENTER_316                  =2                                
WIK_RIGHT_316                   =4                              
WIK_PENG_316                    =8                                
WIK_GANG_316                    =16                               
WIK_LISTEN_316                  =32                                
WIK_CHI_HU_316                  =64                            
WIK_REPLACE_316                 =128


CHR_PING_HU_316                 =16
CHR_DA_DUI_ZI_316               =32
CHR_QI_DUI_316                  =64
CHR_LONG_QI_DUI_316             =128
CHR_QING_YI_SE_316              =256
CHR_QING_DA_DUI_316             =512
CHR_QING_LONG_BEI_316           =1024
CHR_GANG_SHANG_HU_316           =2048
CHR_RE_PAO_316                  =4096
CHR_QIANG_GANG_316              =8192
CHR_QING_QI_DUI_316             =16384
CHR_TIAN_HU_316                 =32768
CHR_DI_HU_316                   =65536
CHR_BAO_TING_316                =131072
CHR_SHA_BAO_316                 =262144


function ASMJ_GameLogic:new(o)
    print("ASMJ_GameLogic:new")
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function ASMJ_GameLogic:GetInstance()
    if self.instance == nil then
        self.instance = self:new()

        self.m_iTest = 1
        self.m_cbMagicIndex = MAX_INDEX_316 + 1
    end
    return self.instance
end

function ASMJ_GameLogic:ReleaseInstance()
    print("ASMJ_GameLogic:ReleaseInstance")
    if self.instance then
        self.instance = nil
    end
end

function ASMJ_GameLogic:IsValidCard(cbCardData)
    local cbValue = bit:_and(cbCardData,MASK_VALUE_316)  
    local cbColor = bit:_rshift(bit:_and(cbCardData,MASK_COLOR_316), 4) 
    return (cbValue>=1 and cbValue<=9 and cbColor<=2) or (cbValue>=1 and cbValue<=15 and cbColor==3)
end

function ASMJ_GameLogic:SwitchToCardIndex(cbCardData)
    assert(self:IsValidCard(cbCardData))
    return (bit:_rshift(bit:_and(cbCardData,MASK_COLOR_316), 4))*10 + (bit:_and(cbCardData,MASK_VALUE_316))
end

function ASMJ_GameLogic:SwitchToCardData(cbCardIndex)
    assert(cbCardIndex <= MAX_INDEX_316, "error cbCardIndex")
    if cbCardIndex <= MAX_INDEX_316 then

        return bit:_or(bit:_lshift(math.floor(cbCardIndex/10),4), cbCardIndex%10)
    else 
        --return bit:_or(48, cbCardIndex-MAX_INDEX_316)
    end
end

function ASMJ_GameLogic:SwitchTableToCardIndex(cbCardData, cbCardCount, cbCardIndex)
    print("ASMJ_GameLogic:SwitchTableToCardIndex")
   
    for i=1,MAX_INDEX_316 do
        cbCardIndex[i] = 0
    end
    
    for i=1,cbCardCount do
        assert(self:IsValidCard(cbCardData[i]), "error mj data invalid")
        local Index = self:SwitchToCardIndex(cbCardData[i])
        cbCardIndex[Index] = cbCardIndex[Index] + 1
    end
    return cbCardCount
end

function ASMJ_GameLogic:SwitchTableToCardData(cbCardIndex, cbCardData)
    local cbPosition = 0

    for i=1,MAX_INDEX_316 do
        if cbCardIndex[i] ~= 0 then
            for j=1,cbCardIndex[i] do
                assert(cbPosition <= MAX_COUNT_316, "error cbPosition")
                cbPosition = cbPosition + 1
                cbCardData[cbPosition] = self:SwitchToCardData(i)
            end
        end
    end

    return cbPosition
end

function ASMJ_GameLogic:GetCardCount(cbCardIndex)
    local cbCardCount = 0
    for i=1,MAX_INDEX_316 do
        cbCardCount = cbCardCount + cbCardIndex[i]
    end
    return cbCardCount
end

function ASMJ_GameLogic:RandCardData(cbCardData, cbCardCount)
    if cbCardCount == 0 then
        return
    end

    -- table "=" is &
    local cbCardDataTemp = {}
    for i=1,cbCardCount do
        cbCardDataTemp[i] = cbCardData[i]
    end
   
    local cbRandCount = 1
    local cbPosition = 1

    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

    repeat
        cbPosition = math.random(cbCardCount - cbRandCount + 1)
        cbCardData[cbRandCount] = cbCardDataTemp[cbPosition]
        cbRandCount = cbRandCount + 1
        cbCardDataTemp[cbPosition]=cbCardDataTemp[cbCardCount-cbRandCount + 2]     
    until cbRandCount > cbCardCount

    return
end

function ASMJ_GameLogic:AnalyseGangCard(cbCardIndex, WeaveItem, cbWeaveCount, cbEnjoinCard, GangCardResult)
   
    local cbActionMask = WIK_NULL_316
    GangCardResult.cbCardData = {}
    GangCardResult.cbCardCount = 0

    local cbEnjoinCount = 0
    for i=1,MAX_COUNT_316 do
        if cbEnjoinCard[i] ~= 0 then
            cbEnjoinCount = cbEnjoinCount + 1
        end
    end

    for i=1,MAX_INDEX_316 do
        if cbCardIndex[i] == 4 then
            local bEnjoinGang = false

            for j=1,cbEnjoinCount do
                if self:SwitchToCardData(i) == cbEnjoinCard[j] then
                    bEnjoinGang = true
                end
            end

            if not bEnjoinGang then

                cbActionMask = bit:_or(cbActionMask, WIK_GANG_316)
                GangCardResult.cbCardCount = GangCardResult.cbCardCount + 1
                GangCardResult.cbCardData[GangCardResult.cbCardCount] = self:SwitchToCardData(i)

            end
        end
    end

    for i=1,cbWeaveCount do
        if WeaveItem[i].cbWeaveKind == WIK_PENG_316 then
            if cbCardIndex[self:SwitchToCardIndex(WeaveItem[i].cbCenterCard)] == 1 then
                if cbEnjoinCount > 0 then
                    local j = 1
                    for j=1,10 do
                        
                    end

                    if j == cbEnjoinCount then
                        cbActionMask = bit:_or(cbActionMask, WIK_GANG_316)
                        GangCardResult.cbCardCount = GangCardResult.cbCardCount + 1
                        GangCardResult.cbCardData[GangCardResult.cbCardCount] = WeaveItem[i].cbCenterCard
                    end
                else
                    cbActionMask = bit:_or(cbActionMask, WIK_GANG_316)
                    GangCardResult.cbCardCount = GangCardResult.cbCardCount + 1
                    GangCardResult.cbCardData[GangCardResult.cbCardCount] = WeaveItem[i].cbCenterCard
                end
            end
        end
    end

    return cbActionMask
end

function ASMJ_GameLogic:RemoveCard(cbCardIndex, cbRemoveCard)

    assert(self:IsValidCard(cbRemoveCard))
    assert(cbCardIndex[self:SwitchToCardIndex(cbRemoveCard)]>0)

    local cbRemoveIndex = self:SwitchToCardIndex(cbRemoveCard)
    if cbCardIndex[cbRemoveIndex] > 0 then
        cbCardIndex[cbRemoveIndex] = cbCardIndex[cbRemoveIndex] - 1
        return true
    end

    assert(false, "error removemj failed")
    return false
end 

function ASMJ_GameLogic:RemoveCard1(cbCardIndex, cbRemoveCard, cbRemoveCount)
 
    for i=1,cbRemoveCount do
        assert(self:IsValidCard(cbRemoveCard[i]), "error cbRemoveCard")
        assert(cbCardIndex[self:SwitchToCardIndex(cbRemoveCard[i])]>0)

        local cbRemoveIndex = self:SwitchToCardIndex(cbRemoveCard[i])

        if cbCardIndex[cbRemoveIndex]==0 then
            assert(false, "error cbCardIndex ")
            for j=1, j < i do
                assert(self:IsValidCard(cbRemoveCard[j]), "error cbRemoveCard")
                cbCardIndex[self:SwitchToCardIndex(cbRemoveCard[j])] = cbCardIndex[self:SwitchToCardIndex(cbRemoveCard[j])] + 1
            end
            return false
        else 
            cbCardIndex[cbRemoveIndex] = cbCardIndex[cbRemoveIndex] - 1
        end
    end

    return true
end


function ASMJ_GameLogic:DeleteCard(cbCardData, cbCardCount, cbRemoveCard, cbRemoveCount)

    assert(cbCardCount<=MAX_COUNT_316, "error DeleteCard cbCardCount")
    assert(cbRemoveCount<=cbCardCount, "error DeleteCard cbRemoveCount")

    local cbDeleteCount = 0
    local cbTempCardData = {}
    
    for i=1,MAX_COUNT_316 do
        cbTempCardData[i] = cbCardData[i]
    end

    for i=1,cbRemoveCount do
        for j=1,cbCardCount do
            if cbRemoveCard[i] == cbTempCardData[j] then
                cbDeleteCount = cbDeleteCount + 1
                cbTempCardData[j] = 0
                break
            end
        end
    end

    if cbDeleteCount ~= cbRemoveCount then
        assert(false, "error DeleteCard cbDeleteCount")
        return false
    end

    local cbCardPos = 0
    -- cbCardData[i] = {} 释放原来的表 创建先表(为了表示引用，一定不能创建新表)
    for i=1,cbCardCount do
        cbCardData[i] = 0
        if cbTempCardData[i] ~= 0 then
            cbCardPos = cbCardPos + 1
            cbCardData[cbCardPos] = cbTempCardData[i]
        end
    end
    cbCardCount = cbCardCount - cbDeleteCount

    return true
end

function ASMJ_GameLogic:IsQiXiaoDui(cbCardIndex, WeaveItem, cbWeaveCount, cbCurrentCard)

    if cbWeaveCount~=0 then
        return false
    end

    local cbReplaceCount = 0

    
    local cbCardIndexTemp = {}
    for i=1,MAX_INDEX_316 do
        cbCardIndexTemp[i] = cbCardIndex[i]
    end

    local cbCurrentIndex = self:SwitchToCardIndex(cbCurrentCard)
    cbCardIndexTemp[cbCurrentIndex] = cbCardIndexTemp[cbCurrentIndex] + 1

    for i=1,MAX_INDEX_316 do
        local cbCardCount = cbCardIndexTemp[i]

        if i == self.m_cbMagicIndex then
    
        else
            if cbCardCount == 1 or cbCardCount == 3 then
                cbReplaceCount = cbReplaceCount + 1
            end
        end
    end

    if (self.m_cbMagicIndex ~= MAX_INDEX_316 + 1 and cbReplaceCount > cbCardIndexTemp[m_cbMagicIndex]) or
        (self.m_cbMagicIndex == MAX_INDEX_316 + 1 and cbReplaceCount > 0) then
        return false
    end

    return true
end


function ASMJ_GameLogic:IsLongQiDui(cbCardIndex, WeaveItem, cbWeaveCount, cbCurrentCard)

    local cbCardIndexTemp = {}
    for i=1,MAX_INDEX_316 do
        cbCardIndexTemp[i] = cbCardIndex[i]
    end
    
    local cbCurrentIndex = self:SwitchToCardIndex(cbCurrentCard)
    cbCardIndexTemp[cbCurrentIndex] = cbCardIndexTemp[cbCurrentIndex] + 1


    for i=1,MAX_INDEX_316 do

        local cbCardCount = cbCardIndexTemp[i]

        if i == self.m_cbMagicIndex then
        else
            if cbCardCount == 4 then
                return true
            end
        end
    end
    return false
end

function ASMJ_GameLogic:IsQingYiSe(cbCardIndex, WeaveItem, cbItemCount, cbCurrentCard)
    
    local cbCardColor = 255

    -- 01 - 09
    -- 11 - 19
    -- 21 - 29

    for i=1,MAX_INDEX_316 do
        if i == self.m_cbMagicIndex then
            -- continue
        else
            if cbCardIndex[i] ~= 0 then
                if cbCardColor ~= 255 then
                    return false
                end

                cbCardColor = bit:_and(self:SwitchToCardData(i), MASK_COLOR_316)

                i = (i/10)*10 + 1
            end
        end
    end

    if cbCardColor == 255 then
        assert (self.m_cbMagicIndex ~= MAX_INDEX_316 + 1 and cbCardIndex[self.m_cbMagicIndex] > 0, "error m_cbMagicIndex is 0")
        assert (cbItemCount > 0, "error weave")
        cbCardColor = bit:_and(WeaveItem[1].cbCenterCard, MASK_COLOR_316)
    end

    if bit:_and(cbCurrentCard, MASK_COLOR_316) ~= cbCardColor then
        return false
    end

    for i=1,cbItemCount do
        local cbCenterCard = WeaveItem[i].cbCenterCard
        if bit:_and(cbCenterCard, MASK_COLOR_316) ~= cbCardColor then
            return false
        end
    end

    return true
end


function ASMJ_GameLogic:AnalyseCard(cbCardIndex, WeaveItem, cbWeaveCount, AnalyseItemArray)

    local cbCardCount = self:GetCardCount(cbCardIndex)

    
    assert(cbCardCount >= 2 and cbCardCount <= MAX_COUNT_316 and (cbCardCount-2)%3==0, "error AnalyseCard mj count")
    if cbCardCount<2  or cbCardCount>MAX_COUNT_316 or (cbCardCount-2)%3~=0 then
        return false
    end

    local cbKindItemCount = 0
    local KindItem = {}
    local floor = math.floor
    local cbLessKindItem = floor((cbCardCount-2)/3)
    assert((cbLessKindItem+cbWeaveCount)==MAX_WEAVE_316, "error AnalyseCard cbLessKindItem")

    if cbLessKindItem==0 then
    
        assert(cbCardCount==2 and cbWeaveCount==MAX_WEAVE_316, "error AnalyseCard dandiao")

        for i=1,MAX_INDEX_316 do
            if cbCardIndex[i] == 2 or (self.m_cbMagicIndex ~= MAX_INDEX_316 + 1 and i ~= self.m_cbMagicIndex and cbCardIndex[self.m_cbMagicIndex]+cbCardIndex[i]==2) then

                local AnalyseItem = {}
                AnalyseItem.cbWeaveKind = {}
                AnalyseItem.cbCenterCard = {}
                AnalyseItem.cbCardData = {}

                for j=1,cbWeaveCount do
    
                    AnalyseItem.cbWeaveKind[j] = WeaveItem[j].cbWeaveKind
                    AnalyseItem.cbCenterCard[j] = WeaveItem[j].cbCenterCard

                    for z=1,4 do
                        AnalyseItem.cbCardData[j] = {}
                        AnalyseItem.cbCardData[j][z] = WeaveItem[j][z]
                    end
                end

                AnalyseItem.cbCardEye= self:SwitchToCardData(i)

                if cbCardIndex[i] < 2 or i == self.m_cbMagicIndex then
                    AnalyseItem.bMagicEye = true
                else 
                    AnalyseItem.bMagicEye = false
                end

                table.insert(AnalyseItemArray, AnalyseItem)

                return true
            end
        end

        return false
    end

    local cbMagicCardIndex = {}
    for i=1,MAX_INDEX_316 do
        cbMagicCardIndex[i] = cbCardIndex[i]
    end
    
    local cbMagicCardCount = 0

    -- this is What ghost
    if cbCardCount>=3 then
    
        for i=1,MAX_INDEX_316 do
            if cbMagicCardIndex[i] >= 3 then

                local nTempIndex = cbMagicCardIndex[i]
                repeat
                    local cbIndex = i
                    local cbCenterCard = self:SwitchToCardData(i)
        
                    local pTmpKindItem = {}
                    pTmpKindItem.cbWeaveKind = WIK_PENG_316
                    pTmpKindItem.cbCenterCard = cbCenterCard
                    pTmpKindItem.cbValidIndex = {}
                    pTmpKindItem.cbValidIndex[1] = cbIndex
                    pTmpKindItem.cbValidIndex[2] = cbIndex
                    pTmpKindItem.cbValidIndex[3] = cbIndex
                    table.insert(KindItem, pTmpKindItem)

                    if i == MAX_INDEX_316 then
                        break
                    end

                    nTempIndex = nTempIndex - 3
                    if nTempIndex == 0 then
                        break
                    end
                until (nTempIndex+cbMagicCardCount < 3)
            end


            if i <= MAX_INDEX_316 - 2 and i % 10 < 8 then
                if cbMagicCardCount + cbMagicCardIndex[i] + cbMagicCardIndex[i + 1] + cbMagicCardIndex[i + 2] >= 3 then
                    local cbIndex = {cbMagicCardIndex[i], cbMagicCardIndex[i+1], cbMagicCardIndex[i+2]}
                    local nMagicCountTemp = cbMagicCardCount
                    local cbValidIndex = {}

                    while nMagicCountTemp + cbIndex[1]+cbIndex[2]+cbIndex[3] >= 3 do
                        
                        for j=1,#cbIndex do
                            if cbIndex[j] > 0 then
                                cbIndex[j] = cbIndex[j] - 1
                                cbValidIndex[j] = i+j-1
                            else
                                nMagicCountTemp = nMagicCountTemp - 1
                                cbValidIndex[j] = self.m_cbMagicIndex
                            end
                        end
                        
                        if nMagicCountTemp >= 0 then

                            local pTmpKindItem = {}
                            pTmpKindItem.cbWeaveKind = WIK_LEFT_316
                            pTmpKindItem.cbCenterCard = self:SwitchToCardData(i)
                            pTmpKindItem.cbValidIndex = {}
                            pTmpKindItem.cbValidIndex[1] = cbValidIndex[1]
                            pTmpKindItem.cbValidIndex[2] = cbValidIndex[2]
                            pTmpKindItem.cbValidIndex[3] = cbValidIndex[3]

                            table.insert(KindItem, pTmpKindItem)
                        else
                            break
                        end
                    end
                end
            end
        end
    end

    cbKindItemCount = #KindItem
    if cbKindItemCount >= cbLessKindItem then
    
        local cbCardIndexTemp = {}
        local cbIndex = {}

        for i=1,MAX_WEAVE_316 do
            cbIndex[i] = i
        end

        local KindItemTemp = {}
        if self.m_cbMagicIndex ~= MAX_INDEX_316 + 1 then
            for i=1,#KindItem do
                local pTmpKindItem = {}
                pTmpKindItem.cbWeaveKind = KindItem[i].cbWeaveKind
                pTmpKindItem.cbCenterCard = KindItem[i].cbCenterCard
                pTmpKindItem.cbValidIndex = {}
                pTmpKindItem.cbValidIndex[1] = KindItem[i].cbValidIndex[1]
                pTmpKindItem.cbValidIndex[2] = KindItem[i].cbValidIndex[2]
                pTmpKindItem.cbValidIndex[3] = KindItem[i].cbValidIndex[3]
                table.insert(KindItemTemp, pTmpKindItem)
            end 
        end
        local iAnalyseItemCount = 0
        while true do
           
            local cbPKindItemCount = 0
            local pKindItem = {}

            for i=1,MAX_INDEX_316 do
                cbCardIndexTemp[i] = cbCardIndex[i]
            end

            cbMagicCardCount = 0
            if self.m_cbMagicIndex ~= MAX_INDEX_316 + 1 then
                for i=1,#KindItem do
                    KindItem[i].cbWeaveKind = KindItemTemp[i].cbWeaveKind
                    KindItem[i].cbCenterCard = KindItemTemp[i].cbCenterCard
                    KindItem[i].cbValidIndex = {}
                    KindItem[i].cbValidIndex[1] = KindItemTemp[i].cbValidIndex[1]
                    KindItem[i].cbValidIndex[2] = KindItemTemp[i].cbValidIndex[2]
                    KindItem[i].cbValidIndex[3] = KindItemTemp[i].cbValidIndex[3]
                end 
            end

            for i=1,cbLessKindItem do
                local pTmpKindItem = {}
                pTmpKindItem.cbWeaveKind = KindItem[cbIndex[i]].cbWeaveKind
                pTmpKindItem.cbCenterCard = KindItem[cbIndex[i]].cbCenterCard
                pTmpKindItem.cbValidIndex = {}
                pTmpKindItem.cbValidIndex[1] = KindItem[cbIndex[i]].cbValidIndex[1]
                pTmpKindItem.cbValidIndex[2] = KindItem[cbIndex[i]].cbValidIndex[2]
                pTmpKindItem.cbValidIndex[3] = KindItem[cbIndex[i]].cbValidIndex[3]
                table.insert(pKindItem, pTmpKindItem)
            end

            local bEnoughCard = true

            for i=1,cbLessKindItem*3 do
                
                local i1 = floor((i-1)/3) + 1
                local i2 = (i-1)%3 + 1
                local cbCardIndex = pKindItem[i1].cbValidIndex[i2]

                if cbCardIndexTemp[cbCardIndex] == 0 then
                    if self.m_cbMagicIndex ~= MAX_INDEX_316 + 1 and cbCardIndexTemp[self.m_cbMagicIndex] > 0 then
                        cbCardIndexTemp[self.m_cbMagicIndex] = cbCardIndexTemp[self.m_cbMagicIndex] -1
                        pKindItem[i1].cbValidIndex[i2] = self.m_cbMagicIndex
                    else
                        bEnoughCard = false
                        break
                    end
                else
                    cbCardIndexTemp[cbCardIndex] = cbCardIndexTemp[cbCardIndex] - 1
                end
            end

            if bEnoughCard==true then
            
                local cbCardEye = 0
                local bMagicEye = false
                if self:GetCardCount(cbCardIndexTemp) == 2 then
                
                    for i=1,MAX_INDEX_316 do
                        if cbCardIndexTemp[i]==2 then
                            cbCardEye= self:SwitchToCardData(i)
                            if self.m_cbMagicIndex ~= MAX_INDEX_316 + 1 and i == self.m_cbMagicIndex then
                                bMagicEye = true
                                break
                            end
                        elseif i~=self.m_cbMagicIndex and self.m_cbMagicIndex ~= MAX_INDEX_316 + 1 and cbCardIndexTemp[i]+cbCardIndexTemp[self.m_cbMagicIndex]==2 then
                            cbCardEye = self:SwitchToCardData(i)
                            bMagicEye = true
                        end
                    end
                end


                if cbCardEye~=0 then

                    local AnalyseItem = {}
                    AnalyseItem.cbWeaveKind = {}
                    AnalyseItem.cbCenterCard = {}
                    AnalyseItem.cbCardData = {}

                    for i=1,cbWeaveCount do
                        AnalyseItem.cbWeaveKind[i] = WeaveItem[i].cbWeaveKind
                        AnalyseItem.cbCenterCard[i] = WeaveItem[i].cbCenterCard
                        AnalyseItem.cbCardData[i] = {}
                        self:GetWeaveCard (WeaveItem[i].cbWeaveKind,WeaveItem[i].cbCenterCard,AnalyseItem.cbCardData[i])
                    end

                    for i=1,cbLessKindItem do
                        AnalyseItem.cbWeaveKind[i + cbWeaveCount] = pKindItem[i].cbWeaveKind
                        AnalyseItem.cbCenterCard[i + cbWeaveCount] = pKindItem[i].cbCenterCard
                        AnalyseItem.cbCardData[i + cbWeaveCount] = {}
                        AnalyseItem.cbCardData[i + cbWeaveCount][1] = self:SwitchToCardData(pKindItem[i].cbValidIndex[1])
                        AnalyseItem.cbCardData[i + cbWeaveCount][2] = self:SwitchToCardData(pKindItem[i].cbValidIndex[2])
                        AnalyseItem.cbCardData[i + cbWeaveCount][3] = self:SwitchToCardData(pKindItem[i].cbValidIndex[3])
                    end

                    AnalyseItem.cbCardEye = cbCardEye
                    AnalyseItem.bMagicEye = bMagicEye

                    table.insert(AnalyseItemArray, AnalyseItem)
                end
            end

            if cbIndex[cbLessKindItem] == cbKindItemCount then
                local i=cbLessKindItem
                while true do
                    if cbIndex[i-1]+1 ~= cbIndex[i] then
                        local cbNewIndex = cbIndex[i-1]
                        for j=i-1,cbLessKindItem do
                            cbIndex[j]=cbNewIndex+j-i+2
                        end
                        break
                    end
                    i = i - 1
                    if i == 1 then
                        break
                    end
                end
                if i==1 then
                    break
                end
            else
                cbIndex[cbLessKindItem] = cbIndex[cbLessKindItem] + 1
            end
        end
    end   

    return (#AnalyseItemArray>0)
end

function ASMJ_GameLogic:GetWeaveCard(cbWeaveKind, cbCenterCard, cbCardBuffer)

    if cbWeaveKind == WIK_LEFT_316 then

        cbCardBuffer[1]=cbCenterCard
        cbCardBuffer[2]=cbCenterCard+1
        cbCardBuffer[3]=cbCenterCard+2
        return 3

    elseif cbWeaveKind == WIK_RIGHT_316 then

        cbCardBuffer[1]=cbCenterCard-2
        cbCardBuffer[2]=cbCenterCard-1
        cbCardBuffer[3]=cbCenterCard
        return 3

    elseif cbWeaveKind == WIK_CENTER_316 then

        cbCardBuffer[1]=cbCenterCard-1
        cbCardBuffer[2]=cbCenterCard
        cbCardBuffer[3]=cbCenterCard+1
        return 3

    elseif cbWeaveKind == WIK_PENG_316 then

        cbCardBuffer[1]=cbCenterCard
        cbCardBuffer[2]=cbCenterCard
        cbCardBuffer[3]=cbCenterCard
        return 3

    elseif cbWeaveKind == WIK_GANG_316 then

        cbCardBuffer[1]=cbCenterCard
        cbCardBuffer[2]=cbCenterCard
        cbCardBuffer[3]=cbCenterCard
        cbCardBuffer[4]=cbCenterCard
        return 4
    end

    return 0
end

function ASMJ_GameLogic:AnalyseChiHuCard(cbCardIndex, WeaveItem, cbWeaveCount, cbCurrentCard, ChiHuRight, bZiMo, bGang)

    ChiHuRight = 0
    local cbChiHuKind = WIK_NULL_316
    local AnalyseItemArray = {}
    
    local cbCardIndexTemp = {}
    for i=1,MAX_INDEX_316 do
        cbCardIndexTemp[i] = cbCardIndex[i]
    end
  
    assert(cbCurrentCard ~= 0, "error AnalyseChiHuCard cbCurrentCard") 
    if cbCurrentCard == 0 or cbCurrentCard == 16 or cbCurrentCard == 32 then 
        return WIK_NULL_316
    end

    if self:IsQiXiaoDui(cbCardIndex,WeaveItem,cbWeaveCount,cbCurrentCard) then
    
        if self:IsLongQiDui(cbCardIndex,WeaveItem,cbWeaveCount,cbCurrentCard) then
            ChiHuRight = bit:_or(ChiHuRight, CHR_LONG_QI_DUI_316)
        else
            ChiHuRight = bit:_or(ChiHuRight, CHR_QI_DUI_316)
        end

        
        if self:IsQingYiSe(cbCardIndex, WeaveItem, cbWeaveCount, cbCurrentCard) then
            ChiHuRight = bit:_or(ChiHuRight, CHR_QING_YI_SE_316)
        end

    end

    if cbCurrentCard ~= 0 then
        local cbCurrentIndex = self:SwitchToCardIndex(cbCurrentCard)
        cbCardIndexTemp[cbCurrentIndex] = cbCardIndexTemp[cbCurrentIndex] + 1
    end

    self:AnalyseCard(cbCardIndexTemp, WeaveItem, cbWeaveCount, AnalyseItemArray)
    
    if #AnalyseItemArray > 0 then
        
        for i=1,#AnalyseItemArray do
            local pAnalyseItem = AnalyseItemArray[i]

            if self:IsPengPeng(pAnalyseItem) then
                ChiHuRight = bit:_or(ChiHuRight, CHR_DA_DUI_ZI_316)
            end

            if self:IsQingYiSe(cbCardIndex, WeaveItem, cbWeaveCount, cbCurrentCard) then
                ChiHuRight = bit:_or(ChiHuRight, CHR_QING_YI_SE_316)
            end

        end

        if self:IsMingGang(WeaveItem,cbWeaveCount) > 0 or self:IsAnGang(WeaveItem,cbWeaveCount) > 0 or bZiMo or bGang then
            ChiHuRight = bit:_or(ChiHuRight, CHR_PING_HU_316)
        end
    end

    if bit:_and(ChiHuRight, CHR_LONG_QI_DUI_316) ~= 0  and bit:_and(ChiHuRight, CHR_QING_YI_SE_316) ~= 0 then 
        ChiHuRight = bit:_and(ChiHuRight, bit:_not(CHR_LONG_QI_DUI_316))
        ChiHuRight = bit:_and(ChiHuRight, bit:_not(CHR_QING_YI_SE_316))
        ChiHuRight = bit:_or(ChiHuRight, CHR_QING_LONG_BEI)
    elseif bit:_and(ChiHuRight, CHR_QI_DUI_316) ~= 0  and bit:_and(ChiHuRight, CHR_QING_YI_SE_316) ~= 0  then
        ChiHuRight = bit:_and(ChiHuRight, bit:_not(CHR_QI_DUI_316))
        ChiHuRight = bit:_and(ChiHuRight, bit:_not(CHR_QING_YI_SE_316))
        ChiHuRight = bit:_or(ChiHuRight, CHR_QING_QI_DUI)
    elseif bit:_and(ChiHuRight, CHR_DA_DUI_ZI_316) ~= 0  and bit:_and(ChiHuRight, CHR_QING_YI_SE_316) ~= 0  then
        ChiHuRight = bit:_and(ChiHuRight, bit:_not(CHR_DA_DUI_ZI_316))
        ChiHuRight = bit:_and(ChiHuRight, bit:_not(CHR_QING_YI_SE_316))
        ChiHuRight = bit:_or(ChiHuRight, CHR_QING_DA_DUI)
    end

    if ChiHuRight ~= 0 then
        cbChiHuKind = WIK_CHI_HU_316
    end
  
    return cbChiHuKind
end 

function ASMJ_GameLogic:IsPengPeng(pAnalyseItem)

    local iChiType = bit:_and(WIK_RIGHT_316,bit:_and(WIK_LEFT_316, WIK_CENTER_316))

    for i=1,#pAnalyseItem.cbWeaveKind do
        if bit:_and(pAnalyseItem.cbWeaveKind[i], iChiType) ~= 0 then
            return false
        end
    end

    return true
end

function ASMJ_GameLogic:IsQingYiSe(cbCardIndex, WeaveItem, cbItemCount, cbCurrentCard)

    local cbCardColor = 255

    for i=1,MAX_INDEX_316 do
        if i == self.m_cbMagicIndex then
        
        elseif cbCardIndex[i] ~= 0 then
            
            if cbCardColor ~= 255 then
                return false
            end

            cbCardColor = bit:_and(self:SwitchToCardData(i),MASK_COLOR_316)

            i = math.floor(i/10)*10 + 1
        end
    end

    
    if cbCardColor == 255 then
        cbCardColor = bit:_and(WeaveItem[1].cbCenterCard, MASK_COLOR_316)
    end

    if bit:_and(cbCurrentCard, MASK_COLOR_316) ~= cbCardColor then
        return false
    end

    for i=1,cbItemCount do
        local cbCenterCard = WeaveItem[i].cbCenterCard
        if bit:_and(cbCenterCard, MASK_COLOR) ~= cbCardColor then
            return false
        end
    end
    
    return true
end

function ASMJ_GameLogic:IsMingGang(WeaveItem, cbWeaveCount)
    
    local iCount = 0
    for i=1,cbWeaveCount do
        if WeaveItem[i].cbWeaveKind == WIK_GANG_316 and  WeaveItem[i].cbPublicCard == 1 then
            iCount = iCount + 1
        end
    end

    return iCount
end

function ASMJ_GameLogic:IsAnGang(WeaveItem, cbWeaveCount)
    
    local iCount = 0
    for i=1,cbWeaveCount do
        if WeaveItem[i].cbWeaveKind == WIK_GANG_316 and  WeaveItem[i].cbPublicCard == 0 then
            iCount = iCount + 1
        end
    end

    return iCount
end
