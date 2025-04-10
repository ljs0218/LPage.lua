# LPage.lua

펑크랜드에서 [Punkland UI Builder](https://github.com/ljs0218/PunkUIBuilder) 로 Export된 Page 데이터를 UI로 빌드하여 주는 라이브러리 입니다.

사용 예시
``` lua
local page = LClient.LoadPage("PunkPage")

local closeButton = self.page:GetControlByHash("CloseButton")
closeButton.onClick.Add(function()
    print("페이지를 닫았어요.")
    self:Close()
end)
```

* `Page`: 페이지의 정보를 담고 있는 클래스입니다.
  * `필드`
    * `name` 페이지의 이름
    * `controls` 페이지의 자식 컨트롤
  * `메소드`
    * `Destroy()` 페이지를 제거합니다.
    * `GetControl(string name)` name와 일치하는 Control을 검색(BFS) 후 Game.Scripts.UI.Control을 반환합니다.
    * `GetControls(name)` name와 일치하는 Control들을 검색(BFS) 후 테이블(Game.Scripts.UI.Control)로 반환합니다.
    * `GetControlByHash(hash)`  hash와 일치하는 Control을 Game.Scripts.UI.Control로 반환합니다.

* LClient.LoadPage(string pageName): 특정 페이지를 로드합니다.
