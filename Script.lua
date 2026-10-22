--[[
    HARIKA MM2 HALLOWEEN HUB v1.0.0 (Tam Entegre Sürüm)
    Tek dosyalık, kendi kendine yeten gelişmiş Luau uygulaması.
]]

local genv
do
    local ok, g = pcall(function() return getgenv() end)
    if ok and type(g) == "table" then genv = g else genv = _G end
end

if type(genv.__HarikaHub) == "table" and type(genv.__HarikaHub.Destroy) == "function" then
    pcall(genv.__HarikaHub.Destroy)
end
genv.__HarikaHub = nil

local H = { VERSION = "1.0.0", alive = true, genv = genv }

local function getService(name)
    local ok, s = pcall(function() return game:GetService(name) end)
    if ok then return s end
    return nil
end
H.S = {}
for _, n in ipairs({ "Players", "TweenService", "UserInputService", "RunService",
                     "HttpService", "GuiService", "ContentProvider", "Lighting" }) do
    H.S[n] = getService(n)
end

----------------------------------------------------------------------
-- 1. Util: genel yardımcılar, tarih/saat matematiği
----------------------------------------------------------------------
do
    local Util = {}
    H.Util = Util

    function Util.clamp(v, lo, hi)
        if v < lo then return lo elseif v > hi then return hi end
        return v
    end
    function Util.roundTo(v, step)
        if not step or step <= 0 then return v end
        return math.floor(v / step + 0.5) * step
    end
    function Util.trim(s)
        s = tostring(s or "")
        s = s:gsub("^%s+", "")
        s = s:gsub("%s+$", "")
        return s
    end
    function Util.ulen(s)
        local n = utf8.len(s)
        if n then return n end
        return #s
    end
    function Util.usub(s, n)
        local len = utf8.len(s)
        if not len then return string.sub(s, 1, n) end
        if len <= n then return s end
        local off = utf8.offset(s, n + 1)
        return string.sub(s, 1, off - 1)
    end
    function Util.truncate(s, n)
        if Util.ulen(s) <= n then return s end
        return Util.usub(s, n - 1) .. "…"
    end

    local FOLD = { ["ç"] = "c", ["Ç"] = "c", ["ğ"] = "g", ["Ğ"] = "g", ["ı"] = "i", ["İ"] = "i",
                   ["ö"] = "o", ["Ö"] = "o", ["ş"] = "s", ["Ş"] = "s", ["ü"] = "u", ["Ü"] = "u" }
    function Util.fold(s)
        s = tostring(s or "")
        for k, v in pairs(FOLD) do s = s:gsub(k, v) end
        return string.lower(s)
    end

    function Util.copy(t)
        local o = {}
        for k, v in pairs(t) do o[k] = v end
        return o
    end
    function Util.deepcopy(t)
        if type(t) ~= "table" then return t end
        local o = {}
        for k, v in pairs(t) do o[k] = Util.deepcopy(v) end
        return o
    end

    local idCounter = 0
    function Util.id(prefix)
        idCounter = idCounter + 1
        return string.format("%s%d_%d", prefix or "id", os.time(), idCounter)
    end

    local function daysFromCivil(y, m, d)
        if m <= 2 then y = y - 1 end
        local era = math.floor(y / 400)
        local yoe = y - era * 400
        local mp = (m + 9) % 12
        local doy = math.floor((153 * mp + 2) / 5) + d - 1
        local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
        return era * 146097 + doe - 719468
    end
    local function civilFromDays(z)
        z = z + 719468
        local era = math.floor(z / 146097)
        local doe = z - era * 146097
        local yoe = math.floor((doe - math.floor(doe / 1460) + math.floor(doe / 36524) - math.floor(doe / 146096)) / 365)
        local y = yoe + era * 400
        local doy = doe - (365 * yoe + math.floor(yoe / 4) - math.floor(yoe / 100))
        local mp = math.floor((5 * doy + 2) / 153)
        local d = doy - math.floor((153 * mp + 2) / 5) + 1
        local m
        if mp < 10 then m = mp + 3 else m = mp - 9 end
        if m <= 2 then y = y + 1 end
        return y, m, d
    end
    Util.daysFromCivil = daysFromCivil

    function Util.civilToEpoch(y, mo, d, h, mi, s)
        return daysFromCivil(y, mo, d) * 86400 + (h or 0) * 3600 + (mi or 0) * 60 + (s or 0)
    end
    function Util.epochToCivil(e)
        e = math.floor(e)
        local days = math.floor(e / 86400)
        local rem = e - days * 86400
        local y, m, d = civilFromDays(days)
        return { year = y, month = m, day = d, hour = math.floor(rem / 3600),
                 min = math.floor((rem % 3600) / 60), sec = math.floor(rem % 60), wday = (days + 3) % 7 }
    end

    function Util.tzOffset()
        local ok, off = pcall(function()
            local l, u = os.date("*t"), os.date("!*t")
            local a = Util.civilToEpoch(l.year, l.month, l.day, l.hour, l.min, l.sec)
            local b = Util.civilToEpoch(u.year, u.month, u.day, u.hour, u.min, u.sec)
            return math.floor((a - b) / 60 + 0.5) * 60
        end)
        if ok and type(off) == "number" then return off end
        return 0
    end
    function Util.localCivil(epoch) return Util.epochToCivil(epoch + Util.tzOffset()) end
    function Util.localToEpoch(y, mo, d, h, mi)
        return Util.civilToEpoch(y, mo, d, h, mi, 0) - Util.tzOffset()
    end
    function Util.daysInMonth(y, m)
        if m == 2 then
            if (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0 then return 29 end
            return 28
        end
        local t = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
        return t[m]
    end

    Util.MONTHS = { "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık" }
    Util.WEEKDAYS = { "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz" }
    Util.WEEKDAYS_LONG = { "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar" }

    function Util.fmtDate(epoch)
        local c = Util.localCivil(epoch)
        return string.format("%02d.%02d.%04d", c.day, c.month, c.year)
    end
    function Util.fmtTime(epoch)
        local c = Util.localCivil(epoch)
        return string.format("%02d:%02d", c.hour, c.min)
    end
    function Util.fmtDateTime(epoch) return Util.fmtDate(epoch) .. " " .. Util.fmtTime(epoch) end
    function Util.fmtClock(epoch)
        local c = Util.localCivil(epoch)
        return string.format("%02d:%02d:%02d", c.hour, c.min, c.sec)
    end
    function Util.fmtHMS(secs)
        secs = math.max(0, math.floor(secs))
        return string.format("%02d:%02d:%02d", math.floor(secs / 3600), math.floor(secs / 60) % 60, secs % 60)
    end
    function Util.fmtDuration(secs)
        secs = math.max(0, math.floor(secs))
        local d = math.floor(secs / 86400)
        local h = math.floor((secs % 86400) / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        if d > 0 then return string.format("%d gün %d sa", d, h) end
        if h > 0 then return string.format("%d sa %d dk", h, m) end
        if m > 0 then return string.format("%d dk %d sn", m, s) end
        return string.format("%d sn", s)
    end

    function Util.parseDate(s)
        s = Util.trim(s)
        local d, m, y = s:match("^(%d%d?)[%./%-](%d%d?)[%./%-](%d%d%d%d)$")
        if not d then return nil, "Tarih GG.AA.YYYY biçiminde olmalı." end
        d, m, y = tonumber(d), tonumber(m), tonumber(y)
        if y < 2000 or y > 2100 then return nil, "Yıl 2000–2100 arasında olmalı." end
        if m < 1 or m > 12 then return nil, "Ay 1–12 arasında olmalı." end
        if d < 1 or d > Util.daysInMonth(y, m) then return nil, "Bu ayda böyle bir gün yok." end
        return y, m, d
    end
    function Util.parseTime(s)
        local h, mi = Util.trim(s):match("^(%d%d?):(%d%d)$")
        if not h then return nil, "Saat SS:DD biçiminde olmalı." end
        h, mi = tonumber(h), tonumber(mi)
        if h > 23 or mi > 59 then return nil, "Saat 00:00–23:59 arasında olmalı." end
        return h, mi
    end
end

----------------------------------------------------------------------
-- 2. Maid & Signal
----------------------------------------------------------------------
do
    local Maid = {}
    Maid.__index = Maid
    function Maid.new() return setmetatable({ items = {} }, Maid) end
    function Maid:conn(c) self.items[#self.items + 1] = { "c", c }; return c end
    function Maid:inst(i) self.items[#self.items + 1] = { "i", i }; return i end
    function Maid:fn(f) self.items[#self.items + 1] = { "f", f }; return f end
    function Maid:clean()
        local items = self.items
        self.items = {}
        for i = #items, 1, -1 do
            local kind, x = items[i][1], items[i][2]
            pcall(function()
                if kind == "c" then x:Disconnect() elseif kind == "i" then x:Destroy() else x() end
            end)
        end
    end
    H.Maid = Maid
    H.maid = Maid.new()

    local Signal = {}
    Signal.__index = Signal
    function Signal.new() return setmetatable({ h = {}, n = 0 }, Signal) end
    function Signal:Connect(fn)
        local id = self.n + 1
        self.n = id
        self.h[id] = fn
        local handlers = self.h
        local conn = {}
        function conn.Disconnect() handlers[id] = nil end
        return conn
    end
    function Signal:Fire(...)
        local ids = {}
        for id in pairs(self.h) do ids[#ids + 1] = id end
        table.sort(ids)
        for _, id in ipairs(ids) do
            local fn = self.h[id]
            if fn then H.Safe.call("signal", fn, ...) end
        end
    end
    H.Signal = Signal
end

----------------------------------------------------------------------
-- 3. Diag, Safe, Metrics, Activity, Ticker
----------------------------------------------------------------------
do
    local Diag = { errors = {}, warnings = {}, steps = {}, stepIndex = {}, maxErrors = 40, errorCount = 0,
                   changed = H.Signal.new(), firing = false }
    H.Diag = Diag

    local function fire()
        if Diag.firing then return end
        Diag.firing = true
        Diag.changed:Fire()
        Diag.firing = false
    end

    function Diag.error(source, msg, trace)
        Diag.errorCount = Diag.errorCount + 1
        table.insert(Diag.errors, 1, { t = os.time(), source = tostring(source), msg = tostring(msg), trace = trace })
        while #Diag.errors > Diag.maxErrors do table.remove(Diag.errors) end
        fire()
    end
    function Diag.warn(source, msg)
        table.insert(Diag.warnings, 1, { t = os.time(), source = tostring(source), msg = tostring(msg) })
        while #Diag.warnings > 30 do table.remove(Diag.warnings) end
        fire()
    end

    local Safe = {}
    H.Safe = Safe
    local function handler(e)
        local t = ""
        if debug and debug.traceback then t = debug.traceback(tostring(e), 2) end
        return { msg = tostring(e), trace = t }
    end
    function Safe.call(source, fn, ...)
        local ok, a, b, c = xpcall(fn, handler, ...)
        if ok then return true, a, b, c end
        Diag.error(source, a.msg, a.trace)
        return false, a.msg
    end
    function Safe.wrap(source, fn)
        return function(...) return Safe.call(source, fn, ...) end
    end

    local Metrics = { actions = 0, byKind = {}, navs = 0, startTime = os.time(), state = "starting" }
    H.Metrics = Metrics
    function Metrics.action(kind)
        Metrics.actions = Metrics.actions + 1
        Metrics.byKind[kind] = (Metrics.byKind[kind] or 0) + 1
    end
    function Metrics.elapsed() return os.time() - Metrics.startTime end

    local Activity = { list = {}, changed = H.Signal.new() }
    H.Activity = Activity
    function Activity.add(kind, text)
        table.insert(Activity.list, 1, { t = os.time(), kind = kind, text = text })
        while #Activity.list > 50 do table.remove(Activity.list) end
        Activity.changed:Fire()
    end

    local Ticker = { subs = {}, running = false }
    H.Ticker = Ticker
    function Ticker.add(name, interval, fn) Ticker.subs[name] = { fn = fn, interval = interval, last = 0 } end
    function Ticker.start()
        if Ticker.running then return end
        Ticker.running = true
        task.spawn(function()
            while H.alive do
                local t = os.time()
                for name, s in pairs(Ticker.subs) do
                    if t - s.last >= s.interval then
                        s.last = t
                        H.Safe.call("ticker:" .. name, s.fn, t)
                    end
                end
                task.wait(1)
            end
            Ticker.running = false
        end)
    end
end

----------------------------------------------------------------------
-- 4. Sayfa Kimlikleri ve Cfg (Yapılandırma)
----------------------------------------------------------------------
H.PAGE_IDS = { "dashboard", "tracker", "calendar", "visuals", "customize", "stats",
               "notifications", "community", "settings", "diagnostics", "about" }

do
    local Util = H.Util
    local Cfg = { values = {}, schema = {}, order = {}, changed = H.Signal.new() }
    H.Cfg = Cfg

    local function def(key, spec)
        spec.key = key
        Cfg.schema[key] = spec
        Cfg.order[#Cfg.order + 1] = key
        if spec.kind == "list" then spec.default = {} end
        Cfg.values[key] = spec.default
    end

    def("theme", { kind = "enum", values = { "obsidyen", "komur", "gumus" }, default = "obsidyen", group = "ui" })
    def("accent", { kind = "enum", values = { "mor", "turuncu", "mavi", "yesil", "pembe" }, default = "mor", group = "ui" })
    def("panelOpacity", { kind = "number", min = 0.4, max = 1, step = 0.05, default = 0.85, group = "ui" })
    def("density", { kind = "enum", values = { "rahat", "kompakt" }, default = "rahat", group = "ui" })
    def("notifEnabled", { kind = "bool", default = true, group = "notif" })
    def("favorites", { kind = "list", max = 4, allowed = { dashboard = true, tracker = true, community = true }, group = "misc" })

    function Cfg.get(key) return Cfg.values[key] end
    function Cfg.set(key, v)
        Cfg.values[key] = v
        Cfg.changed:Fire(key, v)
        return true
    end
end

----------------------------------------------------------------------
-- 5. Caps, Store, Notify, Reminders, Assets, Links
----------------------------------------------------------------------
do
    local Caps = { current = {} }
    H.Caps = Caps
    function Caps.detect()
        Caps.current = {
            clipboard = type(setclipboard) == "function" or type(toclipboard) == "function",
            clipboardFn = setclipboard or tostring,
            browser = pcall(function() return H.S.GuiService.OpenBrowserWindow end)
        }
    end

    local Links = {}
    H.Links = Links
    Links.list = {
        { id = "discord", title = "Discord", desc = "Topluluğa katıl, destek al.", url = "https://discord.gg/JJmEGx9mN3", icon = "💬" },
        { id = "youtube", title = "YouTube", desc = "Videolar ve rehberler.", url = "https://youtube.com/@mm2_ultimatehub?si=gNBUraEOXxwsLSxo", icon = "▶" },
        { id = "website", title = "Web Sitesi", desc = "Resmî web sitemiz.", url = "https://harikascript1.ai.studio/", icon = "🌐" }
    }
    Links.byId = {}
    for _, l in ipairs(Links.list) do Links.byId[l.id] = l end

    function Links.open(id)
        local l = Links.byId[id]
        if l and setclipboard then
            pcall(setclipboard, l.url)
            H.Notify.push("success", l.title, "Bağlantı panoya kopyalandı!")
        end
    end

    local Notify = { history = {}, changed = H.Signal.new() }
    H.Notify = Notify
    function Notify.push(kind, title, text)
        table.insert(Notify.history, 1, { kind = kind, title = title, text = text, t = os.time() })
        Notify.changed:Fire()
    end
end

----------------------------------------------------------------------
-- 6. Style ve UI Bileşenleri
----------------------------------------------------------------------
do
    local Cfg, Util = H.Cfg, H.Util
    local Style = { tok = {}, M = {}, groups = {} }
    H.Style = Style
    for _, g in ipairs({ "color", "glass", "metric", "state" }) do Style.groups[g] = setmetatable({}, { __mode = "k" }) end

    local THEMES = {
        obsidyen = { bg = "0D0D12", panel = "14141C", card = "1C1C26", stroke = "3A3A4F", text = "FFFFFF", sub = "A0A0B2" },
    }
    local ACCENTS = { mor = "A855F7", turuncu = "FF8A24", mavi = "4DA3FF", yesil = "4ADE80", pembe = "F472B6" }

    function Style.recompute()
        local t = Style.tok
        t.bg, t.panel, t.card, t.stroke, t.text, t.sub = Color3.fromHex("0D0D12"), Color3.fromHex("14141C"), Color3.fromHex("1C1C26"), Color3.fromHex("3A3A4F"), Color3.fromHex("FFFFFF"), Color3.fromHex("A0A0B2")
        t.accent = Color3.fromHex(ACCENTS[Cfg.get("accent")] or "A855F7")
        t.accentText = Color3.fromRGB(255, 255, 255)
        t.err = Color3.fromHex("F87171")
        t.glassT = 1 - Cfg.get("panelOpacity")
        Style.M.pad, Style.M.btn = 12, 40
    end
    Style.recompute()

    function Style.set(inst, prop, src)
        local v = type(src) == "function" and src() or Style.tok[src]
        if v then pcall(function() inst[prop] = v end) end
    end
    function Style.bind(inst, prop, src, group)
        Style.set(inst, prop, src)
    end

    local Ui = {}
    H.Ui = Ui
    local function new(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        if parent then o.Parent = parent end
        return o
    end

    function Ui.corner(inst, r) return new("UICorner", { CornerRadius = UDim.new(0, r) }, inst) end
    function Ui.stroke(inst, tok, thick)
        local s = new("UIStroke", { Thickness = thick or 1, Color = Style.tok[tok] or Color3.new(1,1,1) }, inst)
        return s
    end
    function Ui.padding(inst, t, r, b, l) return new("UIPadding", { PaddingTop = UDim.new(0,t), PaddingRight = UDim.new(0,r), PaddingBottom = UDim.new(0,b), PaddingLeft = UDim.new(0,l) }, inst) end
    function Ui.vlist(inst, gap) return new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, gap or 8) }, inst) end
    function Ui.hlist(inst, gap) return new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, gap or 8) }, inst) end

    function Ui.button(parent, o)
        local b = new("TextButton", { Size = UDim2.new(1, 0, 0, 36), Text = o.text or "", Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false }, parent)
        Ui.corner(b, 8)
        if o.style == "primary" then
            b.BackgroundColor3 = Style.tok.accent
            b.TextColor3 = Color3.new(1,1,1)
        else
            b.BackgroundColor3 = Style.tok.card
            b.TextColor3 = Style.tok.text
            Ui.stroke(b, "stroke", 1)
        end
        if o.onClick then b.Activated:Connect(o.onClick) end
        return b
    end
end

----------------------------------------------------------------------
-- 7. ŞIK VE MODERN ARAYÜZ BAŞLATICISI (SHELL / ANA PENCERE)
----------------------------------------------------------------------
do
    H.Caps.detect()
    local parentGui = gethui and gethui() or game:GetService("CoreGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HarikaHub_MM2_Pro"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parentGui

    -- Ana Pencere Kutusu
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(600, 380)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -190)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = H.Style.tok.panel
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    H.Ui.corner(mainFrame, 14)
    H.Ui.stroke(mainFrame, "accent", 1.5)

    -- Sürükleme Mantığı
    local dragging, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    H.S.UserInputService.
