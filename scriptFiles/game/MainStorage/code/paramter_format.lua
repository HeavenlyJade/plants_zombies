---@class SkillData
---@field skill string
---@field level number
---@field slot number

---@class SkillDataContainer
---@field skills table<string, SkillData>

---@class SyncPlayerSkillsData
---@field cmd string
---@field uin number
---@field skillData SkillDataContainer --- 服务器返回的加载的技能格式



