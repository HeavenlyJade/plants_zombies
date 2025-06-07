local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Spell = require(MainStorage.code.server.spells.Spell) ---@type Spell
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam
local SubSpell = require(MainStorage.code.server.spells.SubSpell) ---@type SubSpell

---@class MultiSpell:Spell
---@field randomOrder boolean 随机顺序
---@field castCount number 释放个数
---@field isCombo boolean 组合技
local MultiSpell = ClassMgr.Class("MultiSpell", Spell)

function MultiSpell:OnInit(data)
    self.randomOrder = data["随机顺序"] or false
    self.castCount = data["释放个数"] or 999
    self.isCombo = data["组合技"] or false
end

--- 实际执行魔法
---@param caster Entity 施法者
---@param target Entity 目标
---@param param CastParam 参数
---@return boolean 是否成功释放
function MultiSpell:CastReal(caster, target, param)
    self:PlayEffect(self.castEffects, caster, target, param)
    local anySucceed = false

    local log = {}
    if self.isCombo then
        -- 组合技逻辑
        local spells
        if self.randomOrder then
            spells = gg.clone(self.subSpells)
            self:Shuffle(spells)
        else
            spells = self.subSpells
        end

        -- 获取当前施法者的组合技进度
        if not caster.comboSpellProgress then
            caster.comboSpellProgress = {}
        end
        if not caster.comboSpellProgress[self.spellName] then
            caster.comboSpellProgress[self.spellName] = 0
        end
        local currentIndex = caster.comboSpellProgress[self.spellName]
        local startIndex = currentIndex

        -- 尝试执行当前索引的子魔法
        local subParam = param:Clone()
        local currentSpell = spells[currentIndex + 1] -- Lua数组从1开始
            
        -- 如果当前魔法无法释放，尝试下一个
        for i = 1, #spells do
            local checkParam = CastParam.New()
            if self.printInfo then
                table.insert(log, string.format("尝试释放魔法：%s，当前索引：%d", 
                    currentSpell.spell.spellName, currentIndex))
            end
            if currentSpell.spell:CanCast(caster, target, checkParam, log) then
                if self.printInfo and #log > 0 then
                    table.insert(log, string.format("释放组合技成功，释放魔法：%s", 
                        currentSpell.spell.spellName))
                    print(table.concat(log, "\n"))
                end
                currentSpell:Cast(caster, target, subParam)

                -- 更新索引到下一个魔法
                caster.comboSpellProgress[self.spellName] = (currentIndex + 1) % #spells
                return true
            end
            currentIndex = (currentIndex + 1) % #spells
            currentSpell = spells[currentIndex + 1]
        end
        if self.printInfo and #log > 0 then
            print(table.concat(log, "\n"))
        end
    else
        -- 原有的非组合技逻辑
        if self.randomOrder then
            local castingSpellsList = gg.clone(self.subSpells)
            self:Shuffle(castingSpellsList)
            for i = 1, math.min(self.castCount, #castingSpellsList) do
                local subParam = param:Clone()
                local castSuccessed = castingSpellsList[i]:Cast(caster, target, subParam)
                anySucceed = anySucceed or castSuccessed
            end
        else
            for i = 1, math.min(self.castCount, #self.subSpells) do
                local subParam = param:Clone()
                local castSuccessed = self.subSpells[i]:Cast(caster, target, subParam)
                anySucceed = anySucceed or castSuccessed
            end
        end
    end
    return anySucceed
end

--- 随机打乱列表
---@generic T
---@param list T[] 要打乱的列表
function MultiSpell:Shuffle(list)
    local n = #list
    while n > 1 do
        n = n - 1
        -- 生成 1 到 n（包括 n）之间的随机数
        local k = math.random(1, n + 1)
        -- 交换元素
        local temp = list[k]
        list[k] = list[n + 1]
        list[n + 1] = temp
    end
end

return MultiSpell
