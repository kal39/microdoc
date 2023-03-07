Source = { _next = 1, _lines = {} }

function Source:new(file)
    for line in io.open(file, "r"):lines() do
        self._lines[#self._lines + 1] = line
    end
    return self
end

function Source:parse()
    local doc = ""
    while self:peekLine() do
        local docType = self:nextLine():isDocStart()
        if docType == "code" then
            local ds = self:parseDocSection("  ")
            local cs = self:parseCodeSection("  ")
            doc = doc .. "\n- ```c\n" .. cs .. "  ```\n" .. ds .. "\n<br/>\n\n"
        elseif docType == "" then
            doc = doc .. self:parseDocSection("")
        elseif docType then
            error("unknow doc type '" .. docType .. "'")
        end
    end
    return doc
end

function Source:parseDocSection(prepend)
    local doc = ""
    while true do
        if not self:peekLine() or self:peekLine():isDocEnd() then break end
        doc = doc .. prepend .. self:nextLine():parseDocLine() .. "\n"
    end
    return self:nextLine() and doc
end

function Source:parseCodeSection(prepend)
    local doc = ""
    while true do
        if not self:peekLine() or self:peekLine():isDocStart() then break end
        doc = doc .. prepend .. self:nextLine() .. "\n"
    end
    return prepend .. string.match(doc, "^%s*(.-)%s*$") .. "\n"
end

function Source:peekLine()
    return self._lines[self._next]
end

function Source:nextLine()
    self._next = self._next + 1
    return self._lines[self._next - 1]
end

function string:isDocStart()
    return self:match("^/%*%*%s*(%w*)")
end

function string:isDocEnd()
    return self:match("^ %*/")
end

function string:parseDocLine()
    return self:match("^ %* (.*)") or self:match("^ %*(.*)")
end

if #arg ~= 2 then error("provide 2 arguments") end
io.open(arg[2], "w"):write(Source:new(arg[1]):parse())
