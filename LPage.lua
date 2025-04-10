local pageData = nil

local pages = {}

local function CreateControlTree(data, page)
    local function createControl(node)
        local ctrlType = node.type
        if not ctrlType then return nil end

        local ctrl = _G[ctrlType]() -- 예: Image(), Button()

        -- 프로퍼티 설정
        for key, value in pairs(node.properties or {}) do
            if type(value) == "table" then
                -- 구조체 처리
                if key == "color" or key == "textColor" then
                    ctrl[key] = Color(value.r, value.g, value.b, value.a)
                elseif key == "padding" then -- TODO: sliceBorder 확인
                    ctrl[key] = RectOff(value.bottom, value.left, value.right, value.top)
                elseif key == "cellSize" or key == "spacing" then
                    ctrl[key] = Point(value.x, value.y)
                end
            else
                if key == "controlName" then
                    ctrl["name"] = value
                elseif key == "image" then
                    ctrl["SetImage"](value)
                elseif key ~= "hash" and key ~= "contentHash" then
                    ctrl[key] = value
                end
            end
        end

        -- 페이지에 추가된 컨트롤을 저장한다.
        table.insert(page.controls, ctrl)
        page.hashes[node.properties.hash] = ctrl

        -- 자식 처리
        for _, child in ipairs(node.children or {}) do
            local childCtrl = createControl(child)
            if childCtrl then
                ctrl.AddChild(childCtrl)
                if ctrlType == "ScrollPanel" then -- 부모의 타입이 스크롤 패널일 경우 content 설정
                    if node.properties["contentHash"] == child.properties["hash"] then
                        ctrl["content"] = childCtrl
                    end
                end
            end
        end


        return ctrl
    end
    
    createControl(data)
end

local Page = {}
function Page:new(name, data)
    local instance = setmetatable({}, self)
    self.__index = self

    instance.data = data
    instance.name = name
    instance.controls = {}
    instance.hashes = {}

    return instance
end

function Page:Destroy()
    -- 페이지를 파괴하는 메서드
    for _, control in ipairs(self.controls) do
        control.Destroy()
    end

    self.controls = nil
    self.hashes = nil
    self.data = nil
    self.name = nil

end

function Page:GetControl(name)
    -- BFS 탐색을 통해 name과 일치하는 Control을 찾는다.
    local queue = { self.data }
    while #queue > 0 do
        local current = table.remove(queue, 1)
        if current.properties and current.properties.controlName == name then
            return self.hashes[current.properties.hash]
        end

        for _, child in ipairs(current.children or {}) do
            table.insert(queue, child)
        end
    end

    return nil
end

function Page:GetControlByHash(hash)
    return self.hashes[hash]
end

function Page:GetControls(name)
    -- BFS 탐색을 통해 name과 일치하는 Control을 찾는다.
    local queue = { self.data }
    local controls = {}
    while #queue > 0 do
        local current = table.remove(queue, 1)
        if current.properties and current.properties.controlName == name then
            table.insert(controls, self.hashes[current.properties.hash])
        end

        for _, child in ipairs(current.children or {}) do
            table.insert(queue, child)
        end
    end

    return controls
end

LClient = LClient or {}

function LClient.LoadPage(pageName)
    if Client.platform == "WindowsPlayer" then -- 디버그 모드에서 페이지 항상 새로고침
        LClient.RefreshPages()
    end
    
    local pageData = pages[pageName]
    if not pageData then
        return nil
    end
    
    local page = Page:new(pageName, pageData)
    for _, child in ipairs(page.data.children) do
        CreateControlTree(child, page)
    end

    return page
end

--- 페이지 데이터를 초기화합니다.
function LClient.RefreshPages()
    pageData = Utility.JSONParseFromFile("UI_Hierarchy_Tree.json")
    for i, page in pairs(pageData) do
        if page.type == "Page" then
            local pageName = page.properties.name
            pages[pageName] = page
        end
    end
end

LClient.RefreshPages()
