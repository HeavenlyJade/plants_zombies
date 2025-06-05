local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.code.common.ClassMgr) ---@type ClassMgr
local Spell = require(MainStorage.code.server.spells.Spell) ---@type Spell
local CastParam = require(MainStorage.code.server.spells.CastParam) ---@type CastParam
local Battle = require(MainStorage.code.server.Battle) ---@type Battle
local ItemTypeConfig = require(MainStorage.code.common.config.ItemTypeConfig) ---@type ItemTypeConfig

---@class ItemSpell:Spell
---@field itemType ItemType 物品类型
---@field baseAmount number 基础数量
---@field baseMultiplier number 基础倍率
---@field amountAmplifiers DamageAmplifier[] 基于释放者的属性增加数量
---@field targetAmountAmplifiers DamageAmplifier[] 基于目标的属性增加数量
local ItemSpell = ClassMgr.Class("ItemSpell", Spell)

function ItemSpell:OnInit(data)
    Spell.OnInit(self, data)
    self.itemType = ItemTypeConfig.Get(data["物品类型"])
    self.baseAmount = data["基础数量"] or 0
    self.baseMultiplier = data["基础倍率"] or 1
    self.amountAmplifiers = data["属性增数"] or {}
    self.targetAmountAmplifiers = data["目标属性增数"] or {}
end

--- 实际执行魔法
---@param caster Entity 施法者
---@param target Entity 目标
---@param param CastParam 参数
---@return boolean 是否成功释放
function ItemSpell:CastReal(caster, target, param)
    if not target.isPlayer then return false end ---@cast target Player
    
    local battle = Battle.New(caster, target, self.spellName, nil)
    local amount = param:GetValue(self, "基础数量", self.baseAmount)
    local multiplier = param:GetValue(self, "基础倍率", self.baseMultiplier) * param.power
    
    if amount > 0 then
        battle:AddModifier("BASE", "增加", amount * multiplier)
    end
    
    -- 处理释放者属性增数
    if #self.amountAmplifiers > 0 then
        for _, amplifier in ipairs(self.amountAmplifiers) do
            local modifier = amplifier:GetModifier(caster, amount, multiplier, param)
            if modifier then
                battle:AddModifier(modifier)
            end
        end
    end
    
    -- 处理目标属性增数
    if #self.targetAmountAmplifiers > 0 then
        for _, amplifier in ipairs(self.targetAmountAmplifiers) do
            local modifier = amplifier:GetModifier(target, amount, multiplier, param)
            if modifier then
                battle:AddModifier(modifier)
            end
        end
    end
    
    -- 打印获得物品信息
    if self.printInfo then
        local log = {}
        table.insert(log, string.format("=== %s 获得物品数量构成 ===", self.spellName))
        
        table.insert(log, "基础数量修饰器:")
        for _, modifier in ipairs(battle:GetBaseModifiers()) do
            table.insert(log, string.format("  %s: %s (%s)", 
                modifier.source, 
                modifier.amount, 
                modifier.modifierType))
        end
        
        table.insert(log, "倍率修饰器:")
        for _, modifier in ipairs(battle:GetMultiplyModifiers()) do
            table.insert(log, string.format("  %s: %s (%s)", 
                modifier.source, 
                modifier.amount, 
                modifier.modifierType))
        end
        
        table.insert(log, "最终倍率修饰器:")
        for _, modifier in ipairs(battle:GetFinalMultiplyModifiers()) do
            table.insert(log, string.format("  %s: %s (%s)", 
                modifier.source, 
                modifier.amount, 
                modifier.modifierType))
        end
        
        table.insert(log, string.format("最终数量: %s", battle:GetFinalDamage()))
        table.insert(log, "=====================")
        
        print(table.concat(log, "\n"))
    end
    
    local finalAmount = math.floor(battle:GetFinalDamage() + 0.5) -- 四舍五入
    target.bag:GiveItem(self.itemType:ToItem(finalAmount))
    self:PlayEffect(self.castEffects, caster, target, param)
    
    return true
end

return ItemSpell 