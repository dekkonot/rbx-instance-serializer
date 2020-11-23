local Constants = require(script.Parent.Parent.Constants, "Serializer.Constants")
local MakeNameList = require(script.Parent.Parent.MakeNameList, "Serializer.MakeNameList")

local REQUIRE_OBJECT_STRING = Constants.Minified.REQUIRE_OBJECT_STRING
local SET_PROPERTY_STRING = Constants.Minified.SET_PROPERTY_STRING

local makeFullName = MakeNameList.makeFullNameMinified

local function serializeReferents(scope, containerMap, nameList, referents, node)
    local name = nameList[node]
    local container = containerMap[node]

    scope[node] = name

    local statements = {
        string.format(REQUIRE_OBJECT_STRING, name, "script." .. container:GetFullName())
    }
    local statIndex = 1

    for i, ref in ipairs(referents) do
        local propName, propValue = ref[1], ref[2]
        local serialized = scope[node]
        if not serialized then
            if node:IsAncestorOf(propValue) and containerMap[propValue] then
                serialized = string.format("require(script.%s)", container[propValue]:GetFullName())
            else
                serialized = makeFullName(propValue)
            end
        end
        statements[i + statIndex] = string.format(SET_PROPERTY_STRING, name, propName, serialized)
    end

    return statements
end

return serializeReferents