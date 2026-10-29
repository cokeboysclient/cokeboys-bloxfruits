--[[
████                                    ████
██░░██                                ██░░██
██░░░░██                            ██░░░░██
  ██░░░░██                        ██░░░░██
    ██░░░░░░████████████████████░░░░░░██
    ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██
  ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██
  ██░░░░░░████░░░░░░░░░░░░░░░░████░░░░░░██                       ██████╗ ██████╗ ██╗  ██╗███████╗██████╗  ██████╗ ██╗   ██╗███████╗
  ██░░░░░░████░░░░░░░░░░░░░░░░████░░░░░░██                      ██╔════╝██╔═══██╗██║ ██╔╝██╔════╝██╔══██╗██╔═══██╗╚██╗ ██╔╝██╔════╝
  ██▒▒▒▒░░░░░░░░░░░░████░░░░░░░░░░░░▒▒▒▒██        ████████      ██║     ██║   ██║█████╔╝ █████╗  ██████╔╝██║   ██║ ╚████╔╝ ███████╗
  ██▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒██    ████░░░░░░██      ██║     ██║   ██║██╔═██╗ ██╔══╝  ██╔══██╗██║   ██║  ╚██╔╝  ╚════██║
    ██░░░░░░░░░░██░░░░░░░░██░░░░░░░░░░██  ████░░░░░░░░██        ╚██████╗╚██████╔╝██║  ██╗███████╗██████╔╝╚██████╔╝   ██║   ███████║
      ██░░░░░░░░░░████████░░░░░░░░██    ██░░░░░░░░██             ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
    ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░██    ██████░░░░██
  ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██      ██░░░░██
  ██░░░░░░░░░░░░██░░░░██░░░░░░░░░░░░██  ██████░░██
  ██░░░░░░░░░░░░██░░░░██░░░░░░░░░░░░████░░░░░░██
    ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░██░░░░░░░░██
      ████░░░░░░░░░░░░░░░░░░░░████░░██████
      ██░░░░░░████████████░░░░░░████
      ████████            ████████
]]
local environment=(type(getgenv)=="function" and getgenv()) or _G
local HttpService=game:GetService("HttpService")
local Players=game:GetService("Players")
local LocalizationService=game:GetService("LocalizationService")

local START_URL="https://cokeboys-luaprot-pilot.cokeboysclient.workers.dev/luaprot/experimental/start"
local function createKeyProviderPicker(options)
    local gui,anchor=options.gui,options.anchor
    local inputService=game:GetService("UserInputService")
    local connections={}
    local popup,shield,escapeConnection
    local disposed=false
    local expansionValue,expansionTween
    local function expandTo(height)
        if not options.expansion then return end
        if expansionTween then expansionTween:Cancel();expansionTween=nil end
        if disposed then options.expansion(0);return end
        expansionTween=game:GetService("TweenService"):Create(expansionValue,TweenInfo.new(.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value=height})
        expansionTween:Play()
    end
    local text={
        English={"Choose a provider","3-hour key","24-hour key","Link copied. Paste it into your browser.","Copy this link into your browser:","Close"},
        Spanish={"Elige un proveedor","Clave de 3 horas","Clave de 24 horas","Enlace copiado. Pégalo en tu navegador.","Copia este enlace en tu navegador:","Cerrar"},
        Portuguese={"Escolha um provedor","Chave de 3 horas","Chave de 24 horas","Link copiado. Cole no navegador.","Copie este link no navegador:","Fechar"},
        French={"Choisissez un fournisseur","Clé de 3 heures","Clé de 24 heures","Lien copié. Collez-le dans votre navigateur.","Copiez ce lien dans votre navigateur :","Fermer"},
        Vietnamese={"Chọn nhà cung cấp","Key 3 giờ","Key 24 giờ","Đã sao chép liên kết. Dán vào trình duyệt.","Sao chép liên kết này vào trình duyệt:","Đóng"},
        Indonesian={"Pilih penyedia","Key 3 jam","Key 24 jam","Tautan disalin. Tempel di browser Anda.","Salin tautan ini ke browser Anda:","Tutup"},
        Filipino={"Pumili ng provider","3-oras na key","24-oras na key","Nakopya ang link. I-paste sa browser mo.","Kopyahin ang link na ito sa browser:","Isara"},
    }
    local providers={
        {name="Linkvertise",url="https://tinyurl.com/cokeboys-linkvertise",duration=2},
        {name="Work.ink",url="https://tinyurl.com/cokeboys-workink",duration=3},
    }
    local function words() return text[options.language()] or text.English end
    local function make(class,parent,props)
        local object=Instance.new(class)
        for k,v in pairs(props) do object[k]=v end
        object.Parent=parent
        return object
    end
    local function connect(signal,fn)
        local c=signal:Connect(fn);connections[#connections+1]=c;return c
    end
    local function close()
        local wasOpen=shield~=nil
        if escapeConnection then escapeConnection:Disconnect();escapeConnection=nil end
        if shield then shield:Destroy() end
        shield=nil;popup=nil
        anchor:SetAttribute("ProviderPickerOpen",false)
        if wasOpen then expandTo(0) end
    end
    local function place()
        if not popup or not shield then return end
        local size=shield.AbsoluteSize
        if size.X<1 or size.Y<1 then return end
        local attachment=options.attachment or anchor
        local factor=options.scale and options.scale() or 1
        local width=math.min(attachment.AbsoluteSize.X,math.max(1,size.X-24))
        local logicalHeight=popup:GetAttribute("PreferredHeight") or 116
        local height=math.min(logicalHeight*factor,math.max(1,size.Y-24))
        local origin=attachment.AbsolutePosition-shield.AbsolutePosition
        local x=math.clamp(origin.X,12,math.max(12,size.X-width-12))
        local below=origin.Y+attachment.AbsoluteSize.Y+8*factor
        local y=below+height<=size.Y-12 and below or origin.Y-height-8
        popup.Position=UDim2.fromOffset(x,math.clamp(y,12,math.max(12,size.Y-height-12)))
        popup.Size=UDim2.fromOffset(width/math.max(.01,factor),height/math.max(.01,factor))
        popup.UIScale.Scale=factor
        popup.Visible=not expansionValue or expansionValue.Value>=logicalHeight+11
    end
    local function open()
        if disposed or options.busy() or not gui.Enabled or not anchor.Parent or gui:FindFirstChild("LanguagePicker") then return end
        if shield then close();return end
        shield=make("TextButton",gui,{Name="KeyProviderPicker",Text="",AutoButtonColor=false,Active=true,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=80})
        popup=make("TextButton",shield,{Name="ProviderMenu",Text="",AutoButtonColor=false,Active=true,BackgroundColor3=Color3.fromRGB(16,15,20),BorderSizePixel=0,ZIndex=81})
        popup:SetAttribute("PreferredHeight",116)
        make("UIScale",popup,{Scale=1})
        make("UICorner",popup,{CornerRadius=UDim.new(0,9)})
        make("UIStroke",popup,{Color=Color3.fromRGB(77,65,45),Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
        shield.Activated:Connect(close)
        local chosen=false
        for i,provider in ipairs(providers) do
            local row=make("TextButton",popup,{Name=i==1 and "LinkvertiseOption" or "WorkinkOption",Text="",AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(28,26,33),BorderSizePixel=0,Position=UDim2.fromOffset(8,8+(i-1)*53),Size=UDim2.new(1,-16,0,47),ZIndex=82})
            make("UICorner",row,{CornerRadius=UDim.new(0,6)})
            make("TextLabel",row,{Text=provider.name,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.fromRGB(245,244,247),TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.fromOffset(12,3),Size=UDim2.new(1,-24,0,23),ZIndex=83})
            make("TextLabel",row,{Text=words()[provider.duration],Font=Enum.Font.Gotham,TextSize=11,TextColor3=Color3.fromRGB(184,180,191),TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.fromOffset(12,25),Size=UDim2.new(1,-24,0,17),ZIndex=83})
            row.MouseEnter:Connect(function() row.BackgroundColor3=Color3.fromRGB(49,39,28) end)
            row.MouseLeave:Connect(function() row.BackgroundColor3=Color3.fromRGB(28,26,33) end)
            row.MouseButton1Down:Connect(function() row.BackgroundColor3=Color3.fromRGB(65,47,27) end)
            row.Activated:Connect(function()
                if chosen or options.busy() then return end
                chosen=true
                local writer=options.clipboard or setclipboard or toclipboard
                local ok,result=false,nil
                if type(writer)=="function" then ok,result=pcall(writer,provider.url) end
                if ok and result~=false then
                    close();options.status("✓ "..provider.name..": "..words()[4])
                else
                    for _,child in ipairs(popup:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
                    popup:SetAttribute("PreferredHeight",152)
                    make("TextLabel",popup,{Text=words()[5],Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Color3.fromRGB(238,236,243),TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,44),ZIndex=82})
                    local url=make("TextBox",popup,{Name="ProviderLinkFallback",Text=provider.url,ClearTextOnFocus=false,TextEditable=false,MultiLine=true,TextWrapped=true,Font=Enum.Font.Code,TextSize=12,TextColor3=Color3.fromRGB(255,219,112),TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,BackgroundColor3=Color3.fromRGB(9,9,13),BorderSizePixel=0,Position=UDim2.fromOffset(12,59),Size=UDim2.new(1,-24,0,80),ZIndex=82})
                    expandTo(164)
                    make("UICorner",url,{CornerRadius=UDim.new(0,5)});place()
                end
            end)
        end
        anchor:SetAttribute("ProviderPickerOpen",true)
        expandTo(128)
        escapeConnection=inputService.InputBegan:Connect(function(input,processed)
            if input.KeyCode==Enum.KeyCode.Escape then close() end
        end)
        place()
    end
    if options.expansion then
        expansionValue=make("NumberValue",gui,{Name="ProviderExpansion",Value=0})
        connect(expansionValue.Changed,function(height) options.expansion(height);place() end)
    end
    connect(anchor.Activated,open)
    connect(anchor:GetPropertyChangedSignal("AbsolutePosition"),place)
    connect(anchor:GetPropertyChangedSignal("AbsoluteSize"),place)
    connect(gui:GetPropertyChangedSignal("AbsoluteSize"),place)
    connect(gui:GetPropertyChangedSignal("Enabled"),function() if not gui.Enabled then close() end end)
    connect(gui.ChildAdded,function(child) if child.Name=="LanguagePicker" then close() end end)
    connect(gui.Destroying,function()
        disposed=true;close()
        for _,c in ipairs(connections) do c:Disconnect() end
        table.clear(connections)
    end)
    return {close=close}
end


local DISCORD_INVITE="https://discord.gg/VfEn7Zywmd"
local KEY_FILE="cokeboys_tester_experimental_key.txt"
local LANGUAGE_FILE="CokeboysLanguage_v1.json"
local KEY_PAGE_BACKGROUND_ASSET="rbxassetid://88742259971314"
local REQUEST_TIMEOUT=15
local STARTUP_OWNERSHIP_SECONDS=120
local MAX_RESPONSE_BYTES=262144

local currentJob=tostring(game.JobId or "")
local function trim(value)
    return type(value)=="string" and value:match("^%s*(.-)%s*$") or ""
end

local function unsupportedExecutor()
    local detectors={}
    local function add(value) if type(value)=="function" and not table.find(detectors,value) then detectors[#detectors+1]=value end end
    add(getexecutorname)
    add(identifyexecutor)
    if type(environment)=="table" then add(environment.getexecutorname) add(environment.identifyexecutor) end
    for _,detect in ipairs(detectors) do
        local ok,name=pcall(detect)
        if ok and type(name)=="string" and #name<=128 then
            local normalized=name:lower():match("^%s*(.-)%s*$")
            for _,entry in ipairs({{"xeno","Xeno"},{"solara","Solara"}}) do
                local rest=normalized:sub(#entry[1]+1)
                if normalized:sub(1,#entry[1])==entry[1] and (rest=="" or rest:match("^[%s%-%_vV%d%(]")) then return entry[2] end
            end
        end
    end
    return nil
end
local blockedExecutor=unsupportedExecutor()

local providerSession=environment.__CokeboysLuaProtSession
if type(providerSession)=="table" and providerSession.JobId==currentJob and providerSession.Starting==true then
    warn("Cokeboys: authentication is already starting. Please wait; do not execute again.")
    return
end
local providerPending=environment.__CokeboysLuaProtPendingStart
if type(providerPending)=="table" and providerPending.JobId==currentJob then
    warn(providerPending.Failed and "Cokeboys: loading did not finish. Rejoin before trying again."
        or "Cokeboys: authentication is already starting. Please wait; do not execute again.")
    return
end

local previousOwner=environment.__CokeboysPublicLoaderStart
if type(previousOwner)=="table" and previousOwner.JobId==currentJob
    and os.clock()-(tonumber(previousOwner.StartedAt) or 0)<STARTUP_OWNERSHIP_SECONDS then
    if type(previousOwner.Focus)=="function" then pcall(previousOwner.Focus) end
    return
end

local owner={JobId=currentJob,StartedAt=os.clock(),Closed=false,Gui=nil,Blur=nil}
environment.__CokeboysPublicLoaderStart=owner
environment.__CokeboysPVPLaunchJobId=currentJob

pcall(function()
    local stale=game:GetService("Lighting"):FindFirstChild("CokeboysKeyBlur")
    if stale and stale:IsA("BlurEffect") then stale:Destroy() end
end)

local function ownsStartup()
    return not owner.Closed and environment.__CokeboysPublicLoaderStart==owner
        and tostring(game.JobId or "")==currentJob
end
local function releaseStartup()
    owner.Closed=true
    if environment.__CokeboysPublicLoaderStart==owner then
        environment.__CokeboysPublicLoaderStart=nil
    end
end
local function destroyGui()
    local gui=owner.Gui
    local blur=owner.Blur
    owner.Gui=nil
    owner.Blur=nil
    if gui then pcall(function() gui:Destroy() end) end
    if blur then pcall(function() blur:Destroy() end) end
end

local function readFile(path)
    if type(readfile)~="function" then return nil end
    local ok,value=pcall(readfile,path)
    return ok and type(value)=="string" and value or nil
end
local function writeFile(path,value)
    if type(writefile)~="function" then return false end
    local ok,result=pcall(writefile,path,value)
    return ok and result~=false
end

local LANGUAGE_ORDER={"Auto","English","Spanish","Portuguese","French","Vietnamese","Indonesian","Filipino"}
local LANGUAGE_NAMES={Auto="Auto",English="English",Spanish="Español",Portuguese="Português",French="Français",
    Vietnamese="Tiếng Việt",Indonesian="Bahasa Indonesia",Filipino="Filipino"}
local TEXT={
    Spanish={Title="CLAVE DE ACCESO",Prompt="Introduce tu clave para continuar",Placeholder="Introduce tu clave",Validate="Validar clave",
        Checking="Comprobando...",Starting="Iniciando Cokeboys...",GetKey="Obtener clave",Discord="Únete a Discord",Close="Cerrar"},
    Portuguese={Title="CHAVE DE ACESSO",Prompt="Digite sua chave para continuar",Placeholder="Digite sua chave",Validate="Validar chave",
        Checking="Verificando...",Starting="Iniciando Cokeboys...",GetKey="Obter chave",Discord="Entrar no Discord",Close="Fechar"},
    French={Title="CLÉ D'ACCÈS",Prompt="Entrez votre clé pour continuer",Placeholder="Entrez votre clé",Validate="Valider la clé",
        Checking="Vérification...",Starting="Démarrage de Cokeboys...",GetKey="Obtenir une clé",Discord="Rejoindre Discord",Close="Fermer"},
    Vietnamese={Title="KEY TRUY CẬP",Prompt="Nhập key để tiếp tục",Placeholder="Nhập key",Validate="Xác nhận key",
        Checking="Đang kiểm tra...",Starting="Đang khởi động Cokeboys...",GetKey="Lấy key",Discord="Tham gia Discord",Close="Đóng"},
    Indonesian={Title="KUNCI AKSES",Prompt="Masukkan key untuk melanjutkan",Placeholder="Masukkan key",Validate="Validasi key",
        Checking="Memeriksa...",Starting="Memulai Cokeboys...",GetKey="Dapatkan key",Discord="Gabung Discord",Close="Tutup"},
    Filipino={Title="ACCESS KEY",Prompt="Ilagay ang key para magpatuloy",Placeholder="Ilagay ang key",Validate="I-validate ang key",
        Checking="Sinusuri...",Starting="Sinisimulan ang Cokeboys...",GetKey="Kumuha ng key",Discord="Sumali sa Discord",Close="Isara"},
}
local ENGLISH={Title="ACCESS KEY",Prompt="Enter your access key to continue",Placeholder="Enter your access key",Validate="Validate Key",
    Checking="Checking...",Starting="Starting Cokeboys...",GetKey="Get Key",Discord="Join Discord",Close="Close"}

local function detectLanguage()
    local candidates={}
    pcall(function()
        table.insert(candidates,LocalizationService.RobloxLocaleId)
        table.insert(candidates,LocalizationService.SystemLocaleId)
    end)
    for _,value in ipairs(candidates) do
        local locale=tostring(value or ""):lower()
        if locale:match("^es") then return "Spanish" end
        if locale:match("^pt") then return "Portuguese" end
        if locale:match("^fr") then return "French" end
        if locale:match("^vi") then return "Vietnamese" end
        if locale:match("^id") then return "Indonesian" end
        if locale:match("^fil") or locale:match("^tl") then return "Filipino" end
    end
    return "English"
end
local function readLanguagePreference()
    local raw=readFile(LANGUAGE_FILE)
    if raw then
        local ok,data=pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and type(data)=="table" and LANGUAGE_NAMES[data.language] then return data.language end
    end
    return "Auto"
end
local languagePreference=readLanguagePreference()
local function activeLanguage()
    return languagePreference=="Auto" and detectLanguage() or languagePreference
end
local function copyText(value)
    local writer=setclipboard or toclipboard
    return type(writer)=="function" and pcall(writer,value)
end

local function readRememberedHidden()
    local function decode(path)
        local raw=readFile(path)
        if not raw then return nil end
        local ok,value=pcall(function() return HttpService:JSONDecode(raw) end)
        return ok and type(value)=="table" and value or nil
    end
    local legacy=decode("CokeboysConfig_v1.json")
    local store=decode("CokeboysProfiles_v1.json")
    local profile
    if store and type(store.profiles)=="table" then
        profile=store.profiles[tostring(store.active or "")]
        if type(profile)~="table" and type(store.order)=="table" then
            for _,id in ipairs(store.order) do
                local candidate=store.profiles[tostring(id)]
                if type(candidate)=="table" then profile=candidate break end
            end
        end
    end
    local preferences=type(profile)=="table" and type(profile.config)=="table" and profile.config or legacy
    return type(preferences)=="table" and preferences.RememberGuiHidden==true and preferences.GuiHidden==true
end
environment.CokeboysGuiHidden=environment.CokeboysGuiHidden==true or readRememberedHidden()

local function startupPageReady()
    local player=Players.LocalPlayer
    local gui=player and player:FindFirstChild("PlayerGui")
    if not gui then return false end
    local main=gui:FindFirstChild("CokeboysUI")
    if main and main:IsA("ScreenGui") then return true end
    local keyPage=gui:FindFirstChild("CokeboysKeySystem")
    local layout=keyPage and keyPage:FindFirstChild("ExperiencePageLayout")
    local card=layout and layout:FindFirstChild("ExperienceSelectorCard")
    if not card then return false end
    local full=card:FindFirstChild("FullExperienceCard")
    local core=card:FindFirstChild("LiteExperienceCard")
    local launch=card:FindFirstChild("LoadSelectedExperienceButton")
    return full~=nil and full:IsA("TextButton") and core~=nil and core:IsA("TextButton")
        and launch~=nil and launch:IsA("TextButton")
end
local function createLoadingNotice()
    local stale=environment.__CokeboysAuthNotice
    if type(stale)=="table" and type(stale.cleanup)=="function" then pcall(stale.cleanup) end
    local manager={Closed=false,Gui=nil,State="checking",Previous=environment.LP_CUSTOM_LOADER,Deadline=os.clock()+110}
    local body,bar
    local messages={checking="Wait like a good boy… checking your access.",connecting="Connecting securely… almost there.",
        waiting="Lots of people are loading. Hang tight…",success="Access confirmed. Starting Cokeboys…",
        failed="Couldn’t finish loading. Please execute again."}
    local function render()
        if not body or not bar then return end
        body.Text=messages[manager.State] or messages.checking
        bar.BackgroundColor3=manager.State=="failed" and Color3.fromRGB(255,105,105) or Color3.fromRGB(255,212,55)
        bar.Size=UDim2.new(({checking=0.3,connecting=0.65,waiting=0.65,success=1,failed=1})[manager.State] or 0.15,0,1,0)
    end
    local function mount()
        if manager.Closed or manager.Gui or manager.Visible==false or environment.CokeboysGuiHidden==true then return end
        local player=Players.LocalPlayer
        if not player then return end
        local gui=Instance.new("ScreenGui")
        gui.Name="CokeboysAuthLoading";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=1009
        local card=Instance.new("Frame")
        card.Name="Card";card.Active=false;card.BorderSizePixel=0;card.BackgroundColor3=Color3.fromRGB(18,18,23)
        card.Size=UDim2.new(1,-32,0,104);card.AnchorPoint=Vector2.new(0.5,0);card.Position=UDim2.new(0.5,0,0,65);card.Parent=gui
        local size=Instance.new("UISizeConstraint");size.MaxSize=Vector2.new(390,104);size.MinSize=Vector2.new(160,104);size.Parent=card
        local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,9);corner.Parent=card
        local border=Instance.new("UIStroke");border.Color=Color3.fromRGB(64,62,68);border.Thickness=1;border.Parent=card
        local title=Instance.new("TextLabel")
        title.BackgroundTransparency=1;title.Position=UDim2.fromOffset(14,10);title.Size=UDim2.new(1,-28,0,22)
        title.Font=Enum.Font.GothamBold;title.TextSize=17;title.TextXAlignment=Enum.TextXAlignment.Left
        title.TextColor3=Color3.fromRGB(255,212,55);title.Text="COKEBOYS";title.Parent=card
        body=Instance.new("TextLabel")
        body.Name="Message";body.BackgroundTransparency=1;body.Position=UDim2.fromOffset(14,35);body.Size=UDim2.new(1,-28,0,48)
        body.Font=Enum.Font.Gotham;body.TextSize=14;body.TextWrapped=true;body.TextXAlignment=Enum.TextXAlignment.Left
        body.TextColor3=Color3.fromRGB(240,240,245);body.Parent=card
        local track=Instance.new("Frame")
        track.BorderSizePixel=0;track.BackgroundColor3=Color3.fromRGB(45,44,50);track.Position=UDim2.new(0,14,1,-12)
        track.Size=UDim2.new(1,-28,0,3);track.Parent=card
        bar=Instance.new("Frame");bar.BorderSizePixel=0;bar.Parent=track
        gui.Parent=player:WaitForChild("PlayerGui");manager.Gui=gui;render()
    end
    function manager.set(state,message,immediate)
        if manager.Closed or manager.Terminal and state~="success" and state~="failed" then return end
        manager.State=state
        if type(message)=="string" and message~="" then messages[state]=message end
        if immediate then mount() end
        render()
    end
    function manager.cleanup()
        if manager.Closed then return end
        manager.Closed=true
        if environment.LP_CUSTOM_LOADER==manager.Callback then environment.LP_CUSTOM_LOADER=manager.Previous end
        if environment.__CokeboysAuthNotice==manager then environment.__CokeboysAuthNotice=nil end
        if manager.Gui then pcall(function() manager.Gui:Destroy() end) end
        manager.Gui=nil
    end
    function manager.finish()
        if manager.Closed or manager.Terminal then return end
        manager.Terminal=true
        if manager.Gui then manager.set("success") task.delay(1.5,manager.cleanup) else manager.cleanup() end
    end
    function manager.fail(message)
        if manager.Closed or manager.Terminal then return end
        manager.Terminal=true
        manager.set("failed",message,true)
        task.delay(6,manager.cleanup)
    end
    function manager.waiting(seconds)
        manager.set("waiting","Lots of people are loading. Hang tight… retrying in "..tostring(seconds).."s.",false)
    end
    function manager.setVisible(visible)
        manager.Visible=visible==true
        if manager.Gui then manager.Gui.Enabled=visible==true and environment.CokeboysGuiHidden~=true end
    end
    manager.Callback=function(step)
        if manager.Closed or manager.Terminal then return end
        if type(step)=="number" then manager.set("connecting") end
    end
    environment.__CokeboysAuthNotice=manager
    environment.LP_CUSTOM_LOADER=manager.Callback
    task.delay(0.8,mount)
    task.spawn(function()
        while not manager.Closed do
            if manager.HandoffStarted and startupPageReady() then manager.cleanup() return end
            if not manager.Terminal and os.clock()>=manager.Deadline then
                manager.fail("The access check took too long. Please execute again.")
                return
            end
            task.wait(0.05)
        end
    end)
    return manager
end

if environment.CokeboysScriptLoaded==true then
    local showExisting=_G.__CokeboysShowInterface
    if environment.CokeboysGuiHidden~=true and type(showExisting)=="function" then pcall(showExisting) end
    releaseStartup()
    return
end

local function getIdentity()
    local player=Players.LocalPlayer
    if not player then return nil,nil end
    local ok,clientId=pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
    local hwid=ok and type(clientId)=="string" and clientId~="" and clientId or tostring(player.UserId)
    return hwid,player.Name
end

local function requestFunction()
    local candidates={}
    local function add(candidate)
        if type(candidate)=="function" then table.insert(candidates,candidate) end
    end
    add(type(syn)=="table" and syn.request or nil)
    add(type(http)=="table" and http.request or nil)
    add(request)
    add(http_request)
    for _,candidate in ipairs(candidates) do
        return candidate
    end
    return nil
end
local function requestBeforeDeadline(callback,seconds)
    local settled,callOk,result=false,nil,nil
    local thread=task.spawn(function()
        local ok,value=pcall(callback)
        if settled then return end
        callOk,result=ok,value
        settled=true
    end)
    local deadline=os.clock()+seconds
    while not settled do
        if os.clock()>=deadline then
            settled=true
            pcall(task.cancel,thread)
            return false,nil,true
        end
        task.wait(0.05)
    end
    return callOk,result,false
end
local function parseResponse(response)
    if type(response)~="table" then return nil,nil end
    local status=tonumber(response.StatusCode or response.status_code or response.Status or response.status)
    if status==nil and response.Success==true then status=200 end
    local body=response.Body or response.body
    if type(body)~="string" or #body<2 or #body>MAX_RESPONSE_BYTES then return status,nil end
    local ok,data=pcall(function() return HttpService:JSONDecode(body) end)
    return status,ok and type(data)=="table" and data or nil
end

local lastPreflightFailure
local function transportFailureCategory(value)
    if type(value)~="string" or #value>4096 then return "request-error" end
    local text=value:lower()
    for _,needle in ipairs({"could not resolve","couldn't resolve","dnsresolve","dns resolve","dns resolution","name resolution","getaddrinfo","resolve host","host not found"}) do
        if text:find(needle,1,true) then return "dns" end
    end
    for _,needle in ipairs({"certificate","ssl","tls","securechannel","secure channel","handshake"}) do
        if text:find(needle,1,true) then return "tls" end
    end
    for _,needle in ipairs({"timed out","timeout","time-out"}) do
        if text:find(needle,1,true) then return "timeout" end
    end
    return "request-error"
end

local PREFLIGHT_MESSAGES={
    English={network="Couldn't connect to LuaProt.",dns="Couldn't find LuaProt's server.",tls="Secure connection to LuaProt failed.",timeout="LuaProt took too long to respond.",response="Couldn't read the LuaProt connection response.",busy="LuaProt is busy.",service="LuaProt is temporarily unavailable.",retry="Check your connection, then press Validate Key again.",wait="Wait a moment, then press Validate Key again.",support="Key unchanged. Support code: %s"},
    Spanish={network="No se pudo conectar con LuaProt.",dns="No se pudo encontrar el servidor de LuaProt.",tls="Falló la conexión segura con LuaProt.",timeout="LuaProt tardó demasiado en responder.",response="No se pudo leer la respuesta de conexión de LuaProt.",busy="LuaProt está ocupado.",service="LuaProt no está disponible temporalmente.",retry="Revisa tu conexión y pulsa Validar clave de nuevo.",wait="Espera un momento y pulsa Validar clave de nuevo.",support="Clave sin cambios. Código de soporte: %s"},
    Portuguese={network="Não foi possível conectar ao LuaProt.",dns="Não foi possível encontrar o servidor do LuaProt.",tls="A conexão segura com o LuaProt falhou.",timeout="O LuaProt demorou demais para responder.",response="Não foi possível ler a resposta de conexão do LuaProt.",busy="O LuaProt está ocupado.",service="O LuaProt está temporariamente indisponível.",retry="Verifique sua conexão e pressione Validar chave novamente.",wait="Aguarde um momento e pressione Validar chave novamente.",support="Chave inalterada. Código de suporte: %s"},
    French={network="Connexion à LuaProt impossible.",dns="Le serveur LuaProt est introuvable.",tls="La connexion sécurisée à LuaProt a échoué.",timeout="LuaProt a mis trop de temps à répondre.",response="La réponse de connexion de LuaProt est illisible.",busy="LuaProt est occupé.",service="LuaProt est temporairement indisponible.",retry="Vérifiez votre connexion, puis cliquez sur Valider la clé.",wait="Patientez un instant, puis cliquez sur Valider la clé.",support="Clé inchangée. Code de support : %s"},
    Vietnamese={network="Không thể kết nối với LuaProt.",dns="Không tìm thấy máy chủ LuaProt.",tls="Kết nối bảo mật với LuaProt thất bại.",timeout="LuaProt mất quá lâu để phản hồi.",response="Không thể đọc phản hồi kết nối từ LuaProt.",busy="LuaProt đang bận.",service="LuaProt tạm thời không khả dụng.",retry="Kiểm tra kết nối rồi nhấn Xác nhận key lần nữa.",wait="Chờ một lát rồi nhấn Xác nhận key lần nữa.",support="Key không thay đổi. Mã hỗ trợ: %s"},
    Indonesian={network="Tidak dapat terhubung ke LuaProt.",dns="Server LuaProt tidak dapat ditemukan.",tls="Koneksi aman ke LuaProt gagal.",timeout="LuaProt terlalu lama merespons.",response="Respons koneksi LuaProt tidak dapat dibaca.",busy="LuaProt sedang sibuk.",service="LuaProt sementara tidak tersedia.",retry="Periksa koneksi, lalu tekan Validasi key lagi.",wait="Tunggu sebentar, lalu tekan Validasi key lagi.",support="Key tidak diubah. Kode dukungan: %s"},
    Filipino={network="Hindi makakonekta sa LuaProt.",dns="Hindi mahanap ang server ng LuaProt.",tls="Nabigo ang ligtas na koneksyon sa LuaProt.",timeout="Masyadong matagal ang tugon ng LuaProt.",response="Hindi mabasa ang tugon ng koneksyon ng LuaProt.",busy="Abala ang LuaProt.",service="Pansamantalang hindi available ang LuaProt.",retry="Suriin ang koneksyon, saka pindutin muli ang I-validate ang key.",wait="Maghintay sandali, saka pindutin muli ang I-validate ang key.",support="Hindi nagbago ang key. Support code: %s"},
}
local PREFLIGHT_HELP={
    English="Still failing? Join Discord for Key Support.",
    Spanish="¿Sigue fallando? Únete a Discord para recibir ayuda.",
    Portuguese="Ainda não funciona? Entre no Discord para obter ajuda.",
    French="Le problème persiste ? Rejoignez Discord pour obtenir de l'aide.",
    Vietnamese="Vẫn lỗi? Tham gia Discord để được hỗ trợ key.",
    Indonesian="Masih gagal? Bergabunglah ke Discord untuk bantuan key.",
    Filipino="Ayaw pa rin? Sumali sa Discord para sa Key Support.",
}

local function preflightFailureMessage(message)
    if type(message)~="string" then return message end
    local phase,reason=message:match("^Access check could not finish %[(%u+):([%w%-]+)%]%. Your key is unchanged%. Try again shortly%.$")
    if phase~="NODE" and phase~="SDK" then return message end
    local known={['transport-error']=true,['transport-missing']=true,['request-timeout']=true,['response-size']=true,['response-json']=true,['response-unusable']=true,['node-missing']=true,['node-unrecognized']=true,['check-malformed']=true}
    local http=reason:match("^HTTP(%d%d%d)$")
    if not known[reason] and not http then return message end
    local category=reason
    if reason=="transport-error" and lastPreflightFailure and lastPreflightFailure.phase==phase then category=lastPreflightFailure.category end
    local words=PREFLIGHT_MESSAGES[activeLanguage()] or PREFLIGHT_MESSAGES.English
    local heading=words.network
    local instruction=words.retry
    if category=="dns" then heading=words.dns
    elseif category=="tls" then heading=words.tls
    elseif category=="timeout" or reason=="request-timeout" then heading=words.timeout
    elseif category=="response-format" or reason:match("^response%-%w+") or reason=="check-malformed" then heading=words.response
    elseif http=="429" then heading=words.busy;instruction=words.wait
    elseif http and tonumber(http)>=500 then heading=words.service;instruction=words.wait end
    local code=phase..":"..reason
    if reason=="transport-error" and category~=reason then code=code.."/"..category end
    return heading.."\n"..instruction.."\n"..(PREFLIGHT_HELP[activeLanguage()] or PREFLIGHT_HELP.English).."\n"..string.format(words.support,code)
end

local function sharedPreflightTransport(options,seconds,maximumBytes)
    lastPreflightFailure=nil
    local sender=requestFunction()
    if type(sender)~="function" then return nil,nil,"transport-missing" end
    local ok,response,timedOut=requestBeforeDeadline(function() return sender(options) end,seconds)
    if timedOut then return nil,nil,"request-timeout" end
    if not ok or type(response)~="table" then
        lastPreflightFailure={phase=options.Method=="GET" and "NODE" or "SDK",category=not ok and transportFailureCategory(response) or (response==nil and "no-response" or "response-format")}
        return nil,nil,"transport-error"
    end
    local body=response.Body or response.body
    if type(body)~="string" or #body<2 or #body>maximumBytes then return nil,nil,"response-size" end
    local status,data=parseResponse(response)
    if type(data)~="table" then return status,nil,"response-json" end
    return status,data,status~=200 and "http-error" or nil
end

local DENIALS={expired="Key has expired",banned="Access is banned",["wrong-device"]="Key is linked to another device",
    ["key-removed"]="Key is invalid or no longer available",["whitelist-removed"]="Your username is not whitelisted for this key"}
local function accessFailureMessage(data)
    local message="Access service is temporarily unavailable. Your saved key was not changed."
    local reference=type(data)=="table" and data.support_ref
    if type(reference)=="string" and #reference==36
        and reference:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-4%x%x%x%-[89aAbB]%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
        return "Access check failed. Key unchanged. Ref: "..reference:lower():gsub("%-",""):sub(1,16)
    end
    return message
end

local function authenticate(key,onWaiting)
    local sender=requestFunction()
    if not sender then return false,"Your executor cannot make the secure request.",nil,false end
    local hwid,username=getIdentity()
    if not hwid or not username then return false,"Player information is unavailable. Rejoin and try again.",nil,false end
    local encoded=HttpService:JSONEncode({key=key,hwid=hwid,username=username})
    local deadline=os.clock()+75
    local ordinaryAttempts=0
    while ownsStartup() and os.clock()<deadline do
        ordinaryAttempts+=1
        local ok,response,timedOut=requestBeforeDeadline(function()
            return sender({Url=START_URL,Method="POST",Headers={["Content-Type"]="application/json",["Cache-Control"]="no-store",["X-Cokeboys-Preflight"]="2"},Body=encoded})
        end,math.min(REQUEST_TIMEOUT,math.max(1,deadline-os.clock())))
        if timedOut then
            if ordinaryAttempts>=3 then return false,"Connection timed out. Your saved key was not changed.",nil,false end
        elseif not ok then
            if ordinaryAttempts>=3 then return false,"Connection failed. Your saved key was not changed.",nil,false end
        else
            local status,data=parseResponse(response)
            if data and data.success==true then
                if status~=200 or data.preflight_version~=2 or type(data.loader_source)~="string" or #data.loader_source<100 or #data.loader_source>MAX_RESPONSE_BYTES
                    or type(data.legacy)~="table" or type(data.legacy.permanent)~="boolean" then
                    return false,"The access service returned an invalid response. Try again shortly.",nil,false
                end
                if not data.legacy.permanent then
                    local expiry=tonumber(data.legacy.expires_at)
                    if not expiry or expiry%1~=0 or expiry<=os.time() then return false,"Key has expired",nil,true end
                end
                return true,"Access confirmed",data,true
            end
            if data and data.reason=="login-busy" and status==503 then
                local seconds=math.ceil(tonumber(data.retry_after) or 2)
                seconds=math.max(1,math.min(60,seconds))
                if onWaiting then onWaiting(seconds) end
                task.wait(seconds+math.random()*0.75)
                ordinaryAttempts-=1
            elseif data and DENIALS[data.reason] then
                return false,DENIALS[data.reason],nil,true
            elseif status==400 or status==403 or (status==200 and data) then
                return false,type(data.message)=="string" and data.message or "Key is invalid or access was denied",nil,true
            elseif status==404 then
                return false,"The secure loader is not enabled for this account yet.",nil,false
            elseif ordinaryAttempts>=3 then
                return false,accessFailureMessage(data),nil,false
            end
        end
        if ordinaryAttempts<3 then task.wait(math.min(4,1.25*(2^(ordinaryAttempts-1)))) end
    end
    return false,"Access check was cancelled or timed out. Your saved key was not changed.",nil,false
end

local function styleCorner(parent,radius)
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,radius or 8)
    corner.Parent=parent
end
local function styleStroke(parent,color)
    local stroke=Instance.new("UIStroke")
    stroke.Color=color or Color3.fromRGB(65,65,73)
    stroke.Thickness=1
    stroke.Parent=parent
    return stroke
end
local function label(parent,text,size,bold)
    local object=Instance.new("TextLabel")
    object.BackgroundTransparency=1
    object.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    object.Text=text
    object.TextColor3=Color3.fromRGB(242,242,247)
    object.TextSize=size
    object.TextXAlignment=Enum.TextXAlignment.Left
    object.Parent=parent
    return object
end
local function button(parent,text,color)
    local object=Instance.new("TextButton")
    object.AutoButtonColor=true
    object.BackgroundColor3=color
    object.Font=Enum.Font.GothamBold
    object.Text=text
    object.TextColor3=Color3.fromRGB(245,245,249)
    object.TextSize=13
    object.Parent=parent
    return object
end

local function compatibilityWords(language)
    local translations={
        English={heading="%s is not supported",body="This executor cannot run Cokeboys. Please switch to a supported executor.",help="Join our Discord for supported executors and help.",discord="Discord Link",copied="Discord link copied. Paste it into your browser."},
        Spanish={heading="%s no es compatible",body="Este ejecutor no puede ejecutar Cokeboys. Usa un ejecutor compatible.",help="Únete a nuestro Discord para conocer los ejecutores compatibles y obtener ayuda.",discord="Enlace de Discord",copied="Enlace de Discord copiado. Pégalo en tu navegador."},
        Portuguese={heading="%s não é compatível",body="Este executor não consegue executar o Cokeboys. Usa um executor compatível.",help="Entra no nosso Discord para conhecer os executores compatíveis e obter ajuda.",discord="Link do Discord",copied="Link do Discord copiado. Cola-o no navegador."},
        French={heading="%s n’est pas compatible",body="Cet exécuteur ne peut pas lancer Cokeboys. Utilise un exécuteur compatible.",help="Rejoins notre Discord pour connaître les exécuteurs compatibles et obtenir de l’aide.",discord="Lien Discord",copied="Lien Discord copié. Colle-le dans ton navigateur."},
        Vietnamese={heading="%s không được hỗ trợ",body="Trình thực thi này không thể chạy Cokeboys. Hãy chuyển sang trình thực thi được hỗ trợ.",help="Tham gia Discord để tìm trình thực thi được hỗ trợ và nhận trợ giúp.",discord="Liên kết Discord",copied="Đã sao chép liên kết Discord. Hãy dán vào trình duyệt."},
        Indonesian={heading="%s tidak didukung",body="Executor ini tidak dapat menjalankan Cokeboys. Gunakan executor yang didukung.",help="Bergabunglah ke Discord kami untuk informasi executor yang didukung dan bantuan.",discord="Tautan Discord",copied="Tautan Discord disalin. Tempelkan di browser."},
        Filipino={heading="Hindi suportado ang %s",body="Hindi kayang patakbuhin ng executor na ito ang Cokeboys. Gumamit ng suportadong executor.",help="Sumali sa Discord namin para sa mga suportadong executor at tulong.",discord="Discord Link",copied="Nakopya ang Discord link. I-paste ito sa browser."},
    }
    return translations[language] or translations.English
end

local function showExecutorWarning(name)
    if not ownsStartup() then return end
    destroyGui()
    local player=Players.LocalPlayer
    if not player then releaseStartup() return end
    local gui=Instance.new("ScreenGui")
    gui.Name="CokeboysKeySystem"
    gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=true
    gui.DisplayOrder=1010
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.Parent=player:WaitForChild("PlayerGui")
    owner.Gui=gui

    local blur
    pcall(function()
        blur=Instance.new("BlurEffect")
        blur.Name="CokeboysKeyBlur"
        blur.Size=14
        blur.Parent=game:GetService("Lighting")
    end)
    owner.Blur=blur

    local background=Instance.new("ImageLabel")
    background.Name="AuthenticationBackgroundImage"
    background.Size=UDim2.fromScale(1,1)
    background.Position=UDim2.fromScale(0,0)
    background.BackgroundTransparency=1
    background.BorderSizePixel=0
    background.Image=KEY_PAGE_BACKGROUND_ASSET
    background.ImageColor3=Color3.fromRGB(190,190,190)
    background.ImageTransparency=0.28
    background.ScaleType=Enum.ScaleType.Crop
    background.ZIndex=0
    background.Parent=gui
    local backdrop=Instance.new("Frame")
    backdrop.Name="Backdrop"
    backdrop.Size=UDim2.fromScale(1,1)
    backdrop.BackgroundColor3=Color3.fromRGB(4,4,7)
    backdrop.BackgroundTransparency=0.52
    backdrop.BorderSizePixel=0
    backdrop.ZIndex=1
    backdrop.Parent=gui
    local root=Instance.new("Frame")
    root.Name="KeyPageLayout"
    root.AnchorPoint=Vector2.new(0.5,0.5)
    root.Position=UDim2.fromScale(0.5,0.5)
    root.Size=UDim2.fromOffset(470,365)
    root.BackgroundTransparency=1
    root.BorderSizePixel=0
    root.ZIndex=2
    root.Parent=gui
    local scale=Instance.new("UIScale")
    scale.Parent=root
    local card=Instance.new("Frame")
    card.Name="AuthenticationCard"
    card.Size=UDim2.fromScale(1,1)
    card.BackgroundColor3=Color3.fromRGB(9,9,11)
    card.BackgroundTransparency=0.06
    card.BorderSizePixel=0
    card.ClipsDescendants=true
    card.Parent=root
    styleCorner(card,8)
    local cardStroke=styleStroke(card,Color3.fromRGB(55,55,64))
    cardStroke.Name="AuthenticationBorder"
    cardStroke.Thickness=1.25
    cardStroke.Transparency=0.08
    cardStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local outerGlow=styleStroke(card,Color3.fromRGB(78,78,88))
    outerGlow.Name="AuthenticationBorderGlow"
    outerGlow.Thickness=2
    outerGlow.Transparency=0.72
    outerGlow.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local underline=Instance.new("Frame")
    underline.Name="BrandUnderline"
    underline.Size=UDim2.fromOffset(46,3)
    underline.Position=UDim2.fromOffset(76,47)
    underline.BackgroundColor3=Color3.fromRGB(255,210,31)
    underline.BorderSizePixel=0
    underline.Parent=card
    styleCorner(underline,2)
    local logo=Instance.new("Frame")
    logo.Name="CokeboysPikachuLogo"
    logo.Size=UDim2.fromOffset(32,32)
    logo.Position=UDim2.fromOffset(32,13)
    logo.BackgroundColor3=Color3.fromRGB(255,210,31)
    logo.BorderSizePixel=0
    logo.Parent=card
    styleCorner(logo,7)
    local logoImage=Instance.new("ImageLabel")
    logoImage.Size=UDim2.fromScale(1,1)
    logoImage.BackgroundTransparency=1
    logoImage.Image="rbxthumb://type=Asset&id=128335611339738&w=420&h=420"
    logoImage.ScaleType=Enum.ScaleType.Crop
    logoImage.Parent=logo
    for index,x in ipairs({5,23}) do
        local cheek=Instance.new("Frame")
        cheek.Name="CheekAccent"..index
        cheek.Size=UDim2.fromOffset(4,2)
        cheek.Position=UDim2.fromOffset(x,26)
        cheek.BackgroundColor3=Color3.fromRGB(166,55,63)
        cheek.BackgroundTransparency=0.18
        cheek.BorderSizePixel=0
        cheek.ZIndex=3
        cheek.Parent=logo
        styleCorner(cheek,2)
    end
    local brand=label(card,"COKEBOYS",16,true)
    brand.Position=UDim2.fromOffset(76,18);brand.Size=UDim2.fromOffset(190,22)
    local bolt=label(brand,"⚡",15,true)
    bolt.Name="BrandBoltAccent"
    bolt.Position=UDim2.fromOffset(91,0);bolt.Size=UDim2.fromOffset(18,22)
    bolt.TextColor3=Color3.fromRGB(255,210,31)
    local version=label(card,"v2.2",12,true)
    version.Name="VersionBadge"
    version.Position=UDim2.new(1,-116,0,17);version.Size=UDim2.fromOffset(58,24)
    version.BackgroundTransparency=0;version.BackgroundColor3=Color3.fromRGB(20,20,23)
    version.TextColor3=Color3.fromRGB(255,210,31);version.TextXAlignment=Enum.TextXAlignment.Center
    styleCorner(version,12)
    local versionStroke=styleStroke(version,Color3.fromRGB(84,74,30))
    versionStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local close=button(card,"X",Color3.fromRGB(17,17,20))
    close.Name="CloseButton"
    close.Position=UDim2.new(1,-50,0,13);close.Size=UDim2.fromOffset(32,32);close.TextSize=12
    close.AutoButtonColor=false;close.TextColor3=Color3.fromRGB(205,202,212)
    styleCorner(close,4)
    local closeStroke=styleStroke(close,Color3.fromRGB(31,31,35))
    closeStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local words=compatibilityWords(detectLanguage())
    local heading=label(card,string.format(words.heading,name),24,true)
    heading.Name="CompatibilityHeading"
    heading.Position=UDim2.fromOffset(32,72);heading.Size=UDim2.new(1,-64,0,32)
    heading.TextWrapped=true;heading.TextYAlignment=Enum.TextYAlignment.Top
    local body=label(card,words.body,15,false)
    body.Name="CompatibilityMessage"
    body.Position=UDim2.fromOffset(32,112);body.Size=UDim2.new(1,-64,0,38)
    body.TextWrapped=true;body.TextYAlignment=Enum.TextYAlignment.Top
    local help=label(card,words.help,15,false)
    help.Position=UDim2.fromOffset(32,160);help.Size=UDim2.new(1,-64,0,20)
    help.TextWrapped=true;help.TextYAlignment=Enum.TextYAlignment.Top;help.TextColor3=Color3.fromRGB(183,181,191)
    local discord=button(card,words.discord,Color3.fromRGB(88,101,242))
    discord.Name="CompatibilityDiscordButton"
    discord.Position=UDim2.fromOffset(32,200);discord.Size=UDim2.new(1,-64,0,40)
    discord.TextSize=14;discord.TextColor3=Color3.fromRGB(255,255,255);styleCorner(discord,6)
    local discordStroke=styleStroke(discord,Color3.fromRGB(119,132,255))
    discordStroke.Transparency=0.35;discordStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local note=label(card,"",13,false)
    note.Name="CompatibilityFooter"
    note.Position=UDim2.fromOffset(32,253);note.Size=UDim2.new(1,-64,0,31)
    note.TextWrapped=true;note.TextColor3=Color3.fromRGB(153,151,164)
    note.Visible=false
    root.Size=UDim2.fromOffset(470,264)
    local textService=game:GetService("TextService")
    local tweenService=game:GetService("TweenService")
    local tweens={}
    local function tint(object,properties)
        if tweens[object] then tweens[object]:Cancel() end
        local animation=tweenService:Create(object,TweenInfo.new(0.14,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),properties)
        tweens[object]=animation
        animation:Play()
    end
    close.MouseEnter:Connect(function() tint(close,{BackgroundColor3=Color3.fromRGB(38,38,44),TextColor3=Color3.fromRGB(255,255,255)}) end)
    close.MouseLeave:Connect(function() tint(close,{BackgroundColor3=Color3.fromRGB(17,17,20),TextColor3=Color3.fromRGB(205,202,212)}) end)
    close.MouseButton1Down:Connect(function() tint(close,{BackgroundColor3=Color3.fromRGB(54,38,43)}) end)
    close.MouseButton1Up:Connect(function() tint(close,{BackgroundColor3=Color3.fromRGB(38,38,44)}) end)
    discord.MouseEnter:Connect(function() tint(discord,{BackgroundColor3=Color3.fromRGB(108,120,255)}) end)
    discord.MouseLeave:Connect(function() tint(discord,{BackgroundColor3=Color3.fromRGB(88,101,242)}) end)
    discord.MouseButton1Down:Connect(function() tint(discord,{BackgroundColor3=Color3.fromRGB(67,78,198)}) end)
    discord.MouseButton1Up:Connect(function() tint(discord,{BackgroundColor3=Color3.fromRGB(108,120,255)}) end)
    local viewportConnection,cameraConnection
    local function resize()
        local camera=workspace.CurrentCamera
        local viewport=camera and camera.ViewportSize or Vector2.new(1280,720)
        local y=72
        for _,entry in ipairs({{heading,32,14},{body,38,12},{help,20,22}}) do
            local object=entry[1]
            local measured=textService:GetTextSize(object.Text,object.TextSize,object.Font,Vector2.new(406,1000))
            local height=math.max(entry[2],math.ceil(measured.Y)+3)
            object.Position=UDim2.fromOffset(32,y);object.Size=UDim2.new(1,-64,0,height)
            y=y+height+entry[3]
        end
        discord.Position=UDim2.fromOffset(32,y)
        y=y+40
        if note.Visible then
            local height=math.max(20,math.ceil(textService:GetTextSize(note.Text,note.TextSize,note.Font,Vector2.new(406,1000)).Y)+3)
            note.Position=UDim2.fromOffset(32,y+12);note.Size=UDim2.new(1,-64,0,height)
            y=y+12+height
        end
        local logicalHeight=y+24
        root.Size=UDim2.fromOffset(470,logicalHeight)
        scale.Scale=math.min(1,math.max(1,viewport.X-24)/470,math.max(1,viewport.Y-24)/logicalHeight)
    end
    local function bindCamera()
        if viewportConnection then viewportConnection:Disconnect() end
        local camera=workspace.CurrentCamera
        viewportConnection=camera and camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) or nil
        resize()
    end
    cameraConnection=workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
    gui.Destroying:Connect(function()
        for _,animation in pairs(tweens) do animation:Cancel() end
        if viewportConnection then viewportConnection:Disconnect() end
        if cameraConnection then cameraConnection:Disconnect() end
        if owner.Blur==blur then owner.Blur=nil end
        if blur then pcall(function() blur:Destroy() end) end
        releaseStartup()
    end)
    close.Activated:Connect(function() destroyGui() releaseStartup() end)
    discord.Activated:Connect(function()
        local copied=copyText(DISCORD_INVITE)
        note.Text=copied and words.copied or DISCORD_INVITE
        note.Visible=true
        resize()
    end)
    bindCamera()
end

local showKeyUi
local function launchHandoff(key,delivery,setStatus,notice)
    if not ownsStartup() then return false,"Startup was cancelled." end
    local compiledOk,loader=false,nil
    if delivery.preflight_version==2 then compiledOk,loader=pcall(loadstring,delivery.loader_source) end
    if not compiledOk or type(loader)~="function" then
        local message="The secure loader response could not be started."
        if notice then notice.cleanup() end
        setStatus(message,Color3.fromRGB(239,98,111),false)
        return false,message
    end
    local preparedOk,prepared=pcall(loader)
    local message="Access check could not finish. Your key is unchanged. Try again."
    if preparedOk and type(prepared)=="table" and prepared.Version=="cb-provider-preflight-v2"
        and type(prepared.Check)=="function" and type(prepared.Start)=="function" then
        local checked,ready,checkMessage=pcall(prepared.Check,ownsStartup,sharedPreflightTransport)
        if checked and ready==true and ownsStartup() then
            loader=prepared.Start
        else
            if checked and type(checkMessage)=="string" then message=checkMessage end
            if notice then notice.cleanup() end
            if ownsStartup() then setStatus(message,Color3.fromRGB(239,98,111),false) end
            return false,message
        end
    else
        if notice then notice.cleanup() end
        if ownsStartup() then setStatus(message,Color3.fromRGB(239,98,111),false) end
        return false,message
    end
    notice=notice or createLoadingNotice()
    notice.HandoffStarted=true
    notice.Deadline=os.clock()+75
    notice.set("connecting")
    writeFile(KEY_FILE,key)
    setStatus((TEXT[activeLanguage()] or ENGLISH).Starting,Color3.fromRGB(112,213,151),true)
    destroyGui()
    releaseStartup()
    local handoffReturned=false
    local previousSession=environment.__CokeboysLuaProtSession
    task.spawn(function()
        for _=1,600 do
            if notice.Closed then return end
            if tostring(game.JobId or "")~=currentJob then notice.cleanup() return end
            if startupPageReady() then notice.cleanup() return end
            local session=environment.__CokeboysLuaProtSession
            if type(session)=="table" and session.Version=="cb-luaprot-bridge-session-v2"
                and session.Variant=="experimental" and session.JobId==currentJob and session.Starting~=true then
                if session~=previousSession or handoffReturned or environment.CokeboysScriptLoaded==true then
                    notice.finish() return
                end
            end
            local pending=environment.__CokeboysLuaProtPendingStart
            if type(pending)=="table" and pending.Failed==true then notice.fail() return end
            task.wait(0.1)
        end
        notice.fail("LuaProt took too long to respond. Please execute again.")
    end)
    task.spawn(function()
        local started,startError=pcall(loader)
        if not started then
            local rejoinRequired=type(startError)=="string" and string.find(startError,"Cokeboys: rejoin before changing access or builds",1,true)~=nil
            notice.fail(rejoinRequired and "Key saved. Rejoin Roblox to use it." or "LuaProt failed to start. Please execute again.")
            warn("Cokeboys: authenticated startup failed: "..tostring(startError))
        else
            handoffReturned=true
        end
    end)
    return true
end

showKeyUi=function(initialKey,initialMessage)
    if not ownsStartup() then return end
    destroyGui()
    local player=Players.LocalPlayer
    if not player then releaseStartup() return end
    local gui=Instance.new("ScreenGui")
    gui.Name="CokeboysKeySystem"
    gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=true
    gui.DisplayOrder=1010
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.Parent=player:WaitForChild("PlayerGui")
    owner.Gui=gui

    local blur
    pcall(function()
        blur=Instance.new("BlurEffect")
        blur.Name="CokeboysKeyBlur"
        blur.Size=14
        blur.Parent=game:GetService("Lighting")
    end)
    owner.Blur=blur

    local background=Instance.new("ImageLabel")
    background.Name="AuthenticationBackgroundImage"
    background.Size=UDim2.fromScale(1,1)
    background.Position=UDim2.fromScale(0,0)
    background.BackgroundTransparency=1
    background.BorderSizePixel=0
    background.Image=KEY_PAGE_BACKGROUND_ASSET
    background.ImageColor3=Color3.fromRGB(190,190,190)
    background.ImageTransparency=0.28
    background.ScaleType=Enum.ScaleType.Crop
    background.ZIndex=0
    background.Parent=gui
    local backdrop=Instance.new("Frame")
    backdrop.Name="Backdrop"
    backdrop.Size=UDim2.fromScale(1,1)
    backdrop.BackgroundColor3=Color3.fromRGB(4,4,7)
    backdrop.BackgroundTransparency=0.52
    backdrop.BorderSizePixel=0
    backdrop.ZIndex=1
    backdrop.Parent=gui
    local root=Instance.new("Frame")
    root.Name="KeyPageLayout"
    root.AnchorPoint=Vector2.new(0.5,0.5)
    root.Position=UDim2.fromScale(0.5,0.5)
    root.Size=UDim2.fromOffset(470,365)
    root.BackgroundTransparency=1
    root.BorderSizePixel=0
    root.ZIndex=2
    root.Parent=gui
    local scale=Instance.new("UIScale")
    scale.Parent=root
    local card=Instance.new("Frame")
    card.Name="AuthenticationCard"
    card.Size=UDim2.fromScale(1,1)
    card.BackgroundColor3=Color3.fromRGB(9,9,11)
    card.BackgroundTransparency=0.06
    card.BorderSizePixel=0
    card.ClipsDescendants=true
    card.Parent=root
    styleCorner(card,8)
    local cardStroke=styleStroke(card,Color3.fromRGB(55,55,64))
    cardStroke.Name="AuthenticationBorder"
    cardStroke.Thickness=1.25
    cardStroke.Transparency=0.08
    cardStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local outerGlow=styleStroke(card,Color3.fromRGB(78,78,88))
    outerGlow.Name="AuthenticationBorderGlow"
    outerGlow.Thickness=2
    outerGlow.Transparency=0.72
    outerGlow.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local underline=Instance.new("Frame")
    underline.Name="BrandUnderline"
    underline.Size=UDim2.fromOffset(46,3)
    underline.Position=UDim2.fromOffset(76,47)
    underline.BackgroundColor3=Color3.fromRGB(255,210,31)
    underline.BorderSizePixel=0
    underline.Parent=card
    styleCorner(underline,2)
    local logo=Instance.new("Frame")
    logo.Name="CokeboysPikachuLogo"
    logo.Size=UDim2.fromOffset(32,32)
    logo.Position=UDim2.fromOffset(32,13)
    logo.BackgroundColor3=Color3.fromRGB(255,210,31)
    logo.BorderSizePixel=0
    logo.Parent=card
    styleCorner(logo,7)
    local logoImage=Instance.new("ImageLabel")
    logoImage.Size=UDim2.fromScale(1,1)
    logoImage.BackgroundTransparency=1
    logoImage.Image="rbxthumb://type=Asset&id=128335611339738&w=420&h=420"
    logoImage.ScaleType=Enum.ScaleType.Crop
    logoImage.Parent=logo
    for index,x in ipairs({5,23}) do
        local cheek=Instance.new("Frame")
        cheek.Name="CheekAccent"..index
        cheek.Size=UDim2.fromOffset(4,2)
        cheek.Position=UDim2.fromOffset(x,26)
        cheek.BackgroundColor3=Color3.fromRGB(166,55,63)
        cheek.BackgroundTransparency=0.18
        cheek.BorderSizePixel=0
        cheek.ZIndex=3
        cheek.Parent=logo
        styleCorner(cheek,2)
    end
    local brand=label(card,"COKEBOYS",16,true)
    brand.Position=UDim2.fromOffset(76,18);brand.Size=UDim2.fromOffset(190,22)
    local bolt=label(brand,"⚡",15,true)
    bolt.Name="BrandBoltAccent"
    bolt.Position=UDim2.fromOffset(91,0);bolt.Size=UDim2.fromOffset(18,22)
    bolt.TextColor3=Color3.fromRGB(255,210,31)
    local version=label(card,"v2.2",12,true)
    version.Name="VersionBadge"
    version.Position=UDim2.new(1,-116,0,17);version.Size=UDim2.fromOffset(58,24)
    version.BackgroundTransparency=0;version.BackgroundColor3=Color3.fromRGB(20,20,23)
    version.TextColor3=Color3.fromRGB(255,210,31);version.TextXAlignment=Enum.TextXAlignment.Center
    styleCorner(version,12)
    local versionStroke=styleStroke(version,Color3.fromRGB(84,74,30))
    versionStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local close=button(card,"X",Color3.fromRGB(17,17,20))
    close.Name="CloseButton"
    close.Position=UDim2.new(1,-50,0,13);close.Size=UDim2.fromOffset(32,32);close.TextSize=12
    close.AutoButtonColor=false;close.TextColor3=Color3.fromRGB(205,202,212)
    styleCorner(close,4)
    local closeStroke=styleStroke(close,Color3.fromRGB(31,31,35))
    closeStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local title=label(card,"",19,true)
    title.Name="AuthenticationHeading"
    title.Position=UDim2.fromOffset(32,55);title.Size=UDim2.new(1,-64,0,27);title.TextSize=22
    local prompt=label(card,"",13,false)
    prompt.Position=UDim2.fromOffset(32,84);prompt.Size=UDim2.new(1,-64,0,18);prompt.TextSize=12;prompt.TextColor3=Color3.fromRGB(174,172,184)
    local keyLabel=label(card,"",11,false)
    keyLabel.Position=UDim2.fromOffset(32,112);keyLabel.Size=UDim2.new(1,-64,0,16);keyLabel.TextColor3=Color3.fromRGB(194,191,202)

    local input=Instance.new("TextBox")
    input.Name="KeyInput"
    input.Position=UDim2.fromOffset(32,134);input.Size=UDim2.new(1,-64,0,42)
    input.BackgroundColor3=Color3.fromRGB(18,18,22);input.BorderSizePixel=0
    input.ClearTextOnFocus=false;input.Font=Enum.Font.Gotham;input.TextSize=13
    input.TextColor3=Color3.fromRGB(245,243,248);input.PlaceholderColor3=Color3.fromRGB(119,117,129)
    input.PlaceholderText="";input.TextXAlignment=Enum.TextXAlignment.Left
    input.Text=initialKey or "";input.Parent=card
    styleCorner(input,6)
    local inputStroke=styleStroke(input,Color3.fromRGB(62,62,70))
    inputStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local padding=Instance.new("UIPadding");padding.PaddingLeft=UDim.new(0,13);padding.PaddingRight=UDim.new(0,13);padding.Parent=input
    local placeholder=label(input,"COKEBOYS-XXXX-XXXX",13,false)
    placeholder.Name="KeyFormatPlaceholder"
    placeholder.Size=UDim2.new(1,-26,1,0)
    placeholder.Position=UDim2.fromOffset(13,0)
    placeholder.TextColor3=Color3.fromRGB(119,117,129)
    placeholder.Active=false
    placeholder.ZIndex=input.ZIndex+1
    placeholder.Visible=input.Text==""

    local submit=button(card,"",Color3.fromRGB(255,210,31))
    submit.Name="ValidateButton"
    submit.Position=UDim2.fromOffset(32,205);submit.Size=UDim2.new(1,-64,0,40);submit.TextColor3=Color3.fromRGB(20,17,0)
    submit.AutoButtonColor=false
    styleCorner(submit,4)
    local submitStroke=styleStroke(submit,Color3.fromRGB(255,230,109))
    submitStroke.Transparency=0.18
    submitStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local statusMessage=initialMessage
    local status=label(card,preflightFailureMessage(statusMessage) or "",12,false)
    status.Name="AuthenticationStatus"
    status.Position=UDim2.fromOffset(32,180);status.Size=UDim2.new(1,-64,0,20);status.TextWrapped=true;status.TextSize=11
    status.AutomaticSize=Enum.AutomaticSize.Y;status.TextYAlignment=Enum.TextYAlignment.Top;status.TextTruncate=Enum.TextTruncate.None
    status.TextColor3=initialMessage and Color3.fromRGB(239,165,93) or Color3.fromRGB(183,181,191)
    local secondary=Instance.new("Frame")
    secondary.Name="SecondaryActions"
    secondary.Position=UDim2.fromOffset(32,252)
    secondary.Size=UDim2.new(1,-64,0,38)
    secondary.BackgroundTransparency=1
    secondary.Parent=card
    local getKey=button(secondary,"",Color3.fromRGB(238,67,84))
    getKey.Name="GetKeyButton"
    getKey.Size=UDim2.new(0.5,-6,1,0);getKey.TextSize=12;getKey.AutoButtonColor=false
    getKey.TextTruncate=Enum.TextTruncate.AtEnd
    styleCorner(getKey,5)
    local getKeyStroke=styleStroke(getKey,Color3.fromRGB(255,105,119))
    getKeyStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local discord=button(secondary,"",Color3.fromRGB(88,101,242))
    discord.Name="DiscordButton"
    discord.Position=UDim2.new(0.5,6,0,0);discord.Size=UDim2.new(0.5,-6,1,0);discord.TextSize=12
    discord.AutoButtonColor=false;discord.TextColor3=Color3.new(1,1,1);discord.TextTruncate=Enum.TextTruncate.AtEnd
    styleCorner(discord,5)
    local discordStroke=styleStroke(discord,Color3.fromRGB(119,132,255))
    discordStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local divider=Instance.new("Frame")
    divider.Position=UDim2.fromOffset(32,301);divider.Size=UDim2.new(1,-64,0,1)
    divider.BackgroundColor3=Color3.fromRGB(31,31,35);divider.BorderSizePixel=0;divider.Parent=card
    local language=button(card,"",Color3.fromRGB(18,18,22))
    language.Name="LanguageButton"
    language.Position=UDim2.fromOffset(32,310);language.Size=UDim2.new(1,-64,0,34);language.TextSize=10
    language.AutoButtonColor=false;language.TextColor3=Color3.fromRGB(211,208,219)
    language.TextTruncate=Enum.TextTruncate.AtEnd;language.Font=Enum.Font.GothamMedium
    styleCorner(language,5)
    local languageStroke=styleStroke(language,Color3.fromRGB(62,62,70))
    languageStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    local viewportConnection
    local cameraConnection
    local statusBoundsConnection
    local providerExpansion=0
    local function updateLayout()
        if not root.Parent then return end
        local camera=workspace.CurrentCamera
        local viewport=camera and camera.ViewportSize or Vector2.new(1280,720)
        local safeWidth=math.max(1,viewport.X-24)
        local safeHeight=math.max(1,viewport.Y-24)
        local stacked=safeWidth<406
        local statusHeight=math.max(20,math.ceil(status.AbsoluteSize.Y/math.max(scale.Scale,0.01)-0.1))
        local extraHeight=statusHeight-20
        local logicalHeight=(stacked and 411 or 365)+extraHeight+providerExpansion
        submit.Position=UDim2.fromOffset(32,205+extraHeight)
        secondary.Position=UDim2.fromOffset(32,252+extraHeight)
        root.Size=UDim2.fromOffset(470,logicalHeight)
        secondary.Size=UDim2.new(1,-64,0,stacked and 82 or 38)
        getKey.Size=stacked and UDim2.new(1,0,0,38) or UDim2.new(0.5,-6,1,0)
        discord.Size=stacked and UDim2.new(1,0,0,38) or UDim2.new(0.5,-6,1,0)
        discord.Position=stacked and UDim2.fromOffset(0,44) or UDim2.new(0.5,6,0,0)
        divider.Position=UDim2.fromOffset(32,(stacked and 347 or 301)+extraHeight+providerExpansion)
        language.Position=UDim2.fromOffset(32,(stacked and 356 or 310)+extraHeight+providerExpansion)
        scale.Scale=math.min(1,safeWidth/470,safeHeight/logicalHeight)
        local pixelHeight=logicalHeight*scale.Scale
        local centerY=viewport.Y*.5+(providerExpansion+extraHeight)*scale.Scale*.5
        centerY=math.clamp(centerY,12+pixelHeight*.5,math.max(12+pixelHeight*.5,viewport.Y-12-pixelHeight*.5))
        root.Position=UDim2.new(.5,0,0,centerY)
    end
    local function bindCamera()
        if viewportConnection then viewportConnection:Disconnect() viewportConnection=nil end
        local camera=workspace.CurrentCamera
        if camera then viewportConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLayout) end
        updateLayout()
    end
    statusBoundsConnection=status:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)
    cameraConnection=workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
    gui.Destroying:Connect(function()
        if viewportConnection then viewportConnection:Disconnect() viewportConnection=nil end
        if cameraConnection then cameraConnection:Disconnect() cameraConnection=nil end
        if statusBoundsConnection then statusBoundsConnection:Disconnect() statusBoundsConnection=nil end
        if owner.Blur==blur then owner.Blur=nil end
        if blur then pcall(function() blur:Destroy() end) blur=nil end
    end)
    bindCamera()

    local busy=false
    local keyProviderPicker
    local function applyLanguage()
        local words=TEXT[activeLanguage()] or ENGLISH
        title.Text=words.Validate;prompt.Text=activeLanguage()=="English" and "Enter your access key to continue to Cokeboys." or words.Prompt
        keyLabel.Text=activeLanguage()=="English" and "Access key" or words.Title
        placeholder.Text=activeLanguage()=="English" and "COKEBOYS-XXXX-XXXX" or words.Placeholder
        if not busy then submit.Text=words.Validate end
        getKey.Text=activeLanguage()=="English" and "Click Here to Get a Key" or words.GetKey
        discord.Text=words.Discord
        local shown=languagePreference=="Auto" and ("Auto Detect  •  "..LANGUAGE_NAMES[activeLanguage()]) or LANGUAGE_NAMES[languagePreference]
        language.Text="🌐  "..shown.."   ▼"
        close:SetAttribute("AccessibilityText",words.Close)
        status.Text=preflightFailureMessage(statusMessage) or ""
    end
    local function setStatus(message,color,isBusy)
        if not ownsStartup() or owner.Gui~=gui then return end
        busy=isBusy==true
        if busy and keyProviderPicker then keyProviderPicker.close() end
        status.TextSize=11;status.Font=Enum.Font.Gotham
        statusMessage=message
        status.Text=preflightFailureMessage(statusMessage) or "";status.TextColor3=color or Color3.fromRGB(183,181,191)
        input.TextEditable=not busy;submit.Active=not busy;submit.Selectable=not busy
        submit.Text=busy and (TEXT[activeLanguage()] or ENGLISH).Checking or (TEXT[activeLanguage()] or ENGLISH).Validate
        submit.TextTransparency=busy and 0.12 or 0
        submit.BackgroundColor3=busy and Color3.fromRGB(91,78,27) or Color3.fromRGB(255,210,31)
    end
    owner.Focus=function()
        if ownsStartup() and owner.Gui==gui then gui.Enabled=true pcall(function() input:CaptureFocus() end) end
    end
    applyLanguage()
    local submitKey

    input.Focused:Connect(function()
        placeholder.Visible=false
        task.defer(function()
            if input.Parent and input:IsFocused() then
                input.SelectionStart=-1
                input.CursorPosition=#input.Text+1
            end
        end)
        inputStroke.Color=Color3.fromRGB(255,210,31)
        inputStroke.Thickness=1.5
    end)
    input.FocusLost:Connect(function(enterPressed)
        placeholder.Visible=input.Text==""
        inputStroke.Color=Color3.fromRGB(62,62,70)
        inputStroke.Thickness=1
        if enterPressed then submitKey() end
    end)
    input:GetPropertyChangedSignal("Text"):Connect(function()
        placeholder.Visible=input.Text=="" and not input:IsFocused()
    end)

    close.MouseEnter:Connect(function()
        close.BackgroundColor3=Color3.fromRGB(28,28,32)
        close.TextColor3=Color3.fromRGB(245,242,248)
    end)
    close.MouseLeave:Connect(function()
        close.BackgroundColor3=Color3.fromRGB(17,17,20)
        close.TextColor3=Color3.fromRGB(205,202,212)
    end)
    submit.MouseEnter:Connect(function() if submit.Active then submit.BackgroundColor3=Color3.fromRGB(255,230,109) end end)
    submit.MouseLeave:Connect(function() if submit.Active then submit.BackgroundColor3=Color3.fromRGB(255,210,31) end end)
    submit.MouseButton1Down:Connect(function() if submit.Active then submit.BackgroundColor3=Color3.fromRGB(226,184,20) end end)
    submit.MouseButton1Up:Connect(function() if submit.Active then submit.BackgroundColor3=Color3.fromRGB(255,230,109) end end)
    getKey.MouseEnter:Connect(function()
        getKey.BackgroundColor3=Color3.fromRGB(249,82,98)
        getKeyStroke.Color=Color3.fromRGB(255,130,141)
    end)
    getKey.MouseLeave:Connect(function()
        getKey.BackgroundColor3=Color3.fromRGB(238,67,84)
        getKeyStroke.Color=Color3.fromRGB(255,105,119)
    end)
    getKey.MouseButton1Down:Connect(function() getKey.BackgroundColor3=Color3.fromRGB(205,50,65) end)
    getKey.MouseButton1Up:Connect(function() getKey.BackgroundColor3=Color3.fromRGB(249,82,98) end)
    discord.MouseEnter:Connect(function()
        discord.BackgroundColor3=Color3.fromRGB(108,120,255)
        discordStroke.Color=Color3.fromRGB(150,159,255)
    end)
    discord.MouseLeave:Connect(function()
        discord.BackgroundColor3=Color3.fromRGB(88,101,242)
        discordStroke.Color=Color3.fromRGB(119,132,255)
    end)
    discord.MouseButton1Down:Connect(function() discord.BackgroundColor3=Color3.fromRGB(67,78,198) end)
    discord.MouseButton1Up:Connect(function() discord.BackgroundColor3=Color3.fromRGB(108,120,255) end)
    language.MouseEnter:Connect(function()
        language.BackgroundColor3=Color3.fromRGB(25,25,30)
        languageStroke.Color=Color3.fromRGB(112,91,20)
    end)
    language.MouseLeave:Connect(function()
        language.BackgroundColor3=Color3.fromRGB(18,18,22)
        languageStroke.Color=Color3.fromRGB(62,62,70)
    end)

    submitKey=function()
        if busy or not ownsStartup() then return end
        local key=trim(input.Text)
        if key=="" then setStatus("Please enter a key",Color3.fromRGB(239,98,111),false) return end
        if #key>128 or not key:match("^[A-Z0-9_-]+$") then setStatus("That key format is invalid",Color3.fromRGB(239,98,111),false) return end
        setStatus((TEXT[activeLanguage()] or ENGLISH).Checking,Color3.fromRGB(198,195,207),true)
        task.spawn(function()
            local valid,message,delivery=authenticate(key,function(seconds)
                setStatus("Lots of people are loading. Retrying in "..tostring(seconds).."s...",Color3.fromRGB(239,165,93),true)
            end)
            if not ownsStartup() or owner.Gui~=gui then return end
            if valid then launchHandoff(key,delivery,setStatus)
            else setStatus(message,Color3.fromRGB(239,98,111),false) end
        end)
    end
    submit.Activated:Connect(function() keyProviderPicker.close();submitKey() end)
    close.Activated:Connect(function() if busy then return end destroyGui() releaseStartup() end)
    keyProviderPicker=createKeyProviderPicker({gui=gui,anchor=getKey,attachment=secondary,
        scale=function() return scale.Scale end,
        expansion=function(height) providerExpansion=height;updateLayout() end,
        language=activeLanguage,busy=function() return busy or not ownsStartup() end,
        status=function(message) setStatus(message,Color3.fromRGB(255,223,125),false);status.TextSize=13;status.Font=Enum.Font.GothamMedium end})
    discord.Activated:Connect(function()
        setStatus(copyText(DISCORD_INVITE) and "Discord invite copied" or "Discord: "..DISCORD_INVITE,Color3.fromRGB(183,181,191),false)
    end)
    language.Activated:Connect(function()
        if gui:FindFirstChild("LanguagePicker") then return end
        local overlay=Instance.new("TextButton")
        overlay.Name="LanguagePicker"
        overlay.Size=UDim2.fromScale(1,1)
        overlay.BackgroundColor3=Color3.new(0,0,0)
        overlay.BackgroundTransparency=0.3
        overlay.BorderSizePixel=0
        overlay.Text=""
        overlay.AutoButtonColor=false
        overlay.Active=true
        overlay.ZIndex=50
        overlay.Parent=gui
        local viewport=overlay.AbsoluteSize
        if viewport.X<=0 or viewport.Y<=0 then
            local camera=workspace.CurrentCamera
            viewport=camera and camera.ViewportSize or Vector2.new(1280,720)
        end
        local count=#LANGUAGE_ORDER
        local top=48
        local gap=5
        local bottom=11
        local normalHeight=32
        local desiredHeight=top+(count*normalHeight)+((count-1)*gap)+bottom
        local pickerHeight=math.min(desiredHeight,math.max(120,viewport.Y-12))
        local available=math.max(40,pickerHeight-top-bottom)
        local fitted=math.floor((available-((count-1)*gap))/count)
        local scrolling=fitted<26
        local rowHeight=scrolling and normalHeight or math.min(normalHeight,fitted)
        local contentHeight=(count*rowHeight)+((count-1)*gap)
        local picker=Instance.new("Frame")
        picker.Size=UDim2.fromOffset(math.min(340,math.max(240,viewport.X-24)),pickerHeight)
        picker.AnchorPoint=Vector2.new(0.5,0.5)
        picker.Position=UDim2.fromScale(0.5,0.5)
        picker.BackgroundColor3=Color3.fromRGB(16,16,21)
        picker.BorderSizePixel=0
        picker.Active=true
        picker.ClipsDescendants=true
        picker.ZIndex=51
        picker.Parent=overlay
        styleCorner(picker,11)
        local pickerStroke=styleStroke(picker,Color3.fromRGB(255,210,31))
        pickerStroke.Thickness=1.5
        local pickerHeading=label(picker,"🌐  Select Language",15,true)
        pickerHeading.Size=UDim2.new(1,-48,0,38)
        pickerHeading.Position=UDim2.fromOffset(16,8)
        pickerHeading.ZIndex=52
        local pickerClose=button(picker,"×",Color3.fromRGB(38,37,45))
        pickerClose.Size=UDim2.fromOffset(30,30)
        pickerClose.Position=UDim2.new(1,-39,0,9)
        pickerClose.TextSize=18
        pickerClose.ZIndex=52
        styleCorner(pickerClose,7)
        pickerClose.Activated:Connect(function() overlay:Destroy() end)
        local optionList=Instance.new(scrolling and "ScrollingFrame" or "Frame")
        optionList.Size=UDim2.new(1,-32,0,available)
        optionList.Position=UDim2.fromOffset(16,top)
        optionList.BackgroundTransparency=1
        optionList.BorderSizePixel=0
        optionList.ClipsDescendants=true
        optionList.ZIndex=52
        optionList.Parent=picker
        if scrolling then
            optionList.CanvasSize=UDim2.fromOffset(0,contentHeight)
            optionList.AutomaticCanvasSize=Enum.AutomaticSize.None
            optionList.ScrollingDirection=Enum.ScrollingDirection.Y
            optionList.ScrollBarThickness=3
            optionList.ScrollBarImageColor3=Color3.fromRGB(255,210,31)
            optionList.ElasticBehavior=Enum.ElasticBehavior.Never
        end
        for index,code in ipairs(LANGUAGE_ORDER) do
            local selected=code==languagePreference
            local option=button(optionList,"",selected and Color3.fromRGB(50,44,22) or Color3.fromRGB(27,26,32))
            option.Size=UDim2.new(1,scrolling and -7 or 0,0,rowHeight)
            option.Position=UDim2.fromOffset(0,(index-1)*(rowHeight+gap))
            local name=code=="Auto" and "Auto Detect" or (LANGUAGE_NAMES[code] or code)
            option.Text=(selected and "✓  " or "    ")..name
            if code=="Auto" then option.Text=option.Text.."  •  "..(LANGUAGE_NAMES[detectLanguage()] or "English") end
            option.TextColor3=selected and Color3.fromRGB(255,210,31) or Color3.fromRGB(240,240,244)
            option.TextSize=12
            option.Font=selected and Enum.Font.GothamBold or Enum.Font.GothamMedium
            option.TextXAlignment=Enum.TextXAlignment.Left
            option.AutoButtonColor=false
            option.ZIndex=52
            styleCorner(option,7)
            local optionPadding=Instance.new("UIPadding")
            optionPadding.PaddingLeft=UDim.new(0,12)
            optionPadding.Parent=option
            option.Activated:Connect(function()
                languagePreference=code
                writeFile(LANGUAGE_FILE,HttpService:JSONEncode({language=languagePreference}))
                overlay:Destroy()
                applyLanguage()
            end)
        end
        overlay.Activated:Connect(function() if overlay.Parent then overlay:Destroy() end end)
    end)
end

if blockedExecutor then showExecutorWarning(blockedExecutor) return end

local savedKey=trim(readFile(KEY_FILE))
if savedKey~="" then
    task.spawn(function()
        local notice=createLoadingNotice()
        local valid,message,delivery=authenticate(savedKey,function(seconds) notice.waiting(seconds) end)
        if not ownsStartup() then notice.cleanup() return end
        if valid then
            local function noStatus() end
            local started,startMessage=launchHandoff(savedKey,delivery,noStatus,notice)
            if not started and ownsStartup() then showKeyUi(savedKey,startMessage) end
        else
            notice.cleanup()
            showKeyUi(savedKey,message)
        end
    end)
else
    showKeyUi("",nil)
end

