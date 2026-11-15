-- Hyprland 0.57+ config (migrado desde hyprland.conf y modules/*.conf)
-- https://wiki.hypr.land/configuring/

local scripts = "~/.config/hypr/scripts/"

-- Generado por matugen (dofile para releer en cada reload)
local colors = dofile(os.getenv("HOME") .. "/.config/hypr/colors.lua")

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "eDP-2",    mode = "1920x1080@60", position = "0x0",    scale = 1, bitdepth = 10 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "1920x0", scale = 1 })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "wofi --show drun --allow-images --conf ~/.config/wofi/config --style ~/.config/wofi/style.css"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function ()
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland &")
    hl.exec_cmd("bash -c 'sleep 1 && /usr/lib/xdg-desktop-portal --replace'")

    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("waybar")
    hl.exec_cmd("eww daemon")
    hl.exec_cmd("bash -c 'sleep 1 && eww open system-widget'")
    hl.exec_cmd("bash -c 'sleep 1 && systemd-run --user --no-block bash ~/.config/eww/scripts/music-monitor.sh'")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")

hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")

-- Waydroid
hl.env("XDG_SESSION_TYPE", "wayland")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 3,

        border_size = 2,

        col = colors,

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 8,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled  = true,
            size     = 2,
            passes   = 1,
            vibrancy = 0.1,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
        -- No robes el foco de un fullscreen por apps que piden activate debajo
        on_focus_under_fullscreen = 0,
    },
})

-- curvas más suaves
hl.curve("easeOut",   { type = "bezier", points = { {0.16, 1},    {0.3, 1}  } })
hl.curve("easeInOut", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })

-- ventanas (más naturales)
hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "easeOut" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4, bezier = "easeOut" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "easeInOut" })

-- fade suave
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "easeInOut" })

-- workspaces tipo "deslizamiento"
hl.animation({ leaf = "workspaces", enabled = true, speed = 8, bezier = "easeOut" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(scripts .. "close_window.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(scripts .. "toggle_lock.sh"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(scripts .. "reload.sh"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle

-- cortar y pegar ventanas
hl.bind(mainMod .. " + CTRL + X", hl.dsp.exec_cmd(scripts .. "win_cut.sh"))
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd(scripts .. "win_paste.sh"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("brave"))

-- cambiador de wallpaper
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(scripts .. "wallpaper.sh"))

-- abrir notificaciones
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))

-- abrir hyprlock
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- abrir wofi
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))

-- activar/desactivar historial del portapapeles
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(scripts .. "clipboard-toggle.sh"))

-- entrar/salir del scratchpad (ventanas se quedan dentro)
hl.bind(mainMod .. " + G", hl.dsp.workspace.toggle_special("scratch"))
-- meter/sacar ventana activa del scratchpad
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(scripts .. "scratchpad.sh"))

-- abrir/ocultar gapless (special workspace)
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(scripts .. "start-gapless.sh"))

-- Mover foco y reordenar ventanas en el layout
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + " .. dir,         hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

-- Workspaces relativos al monitor activo (1-9 en eDP-2, 10-18 en HDMI-A-1)
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,       hl.dsp.exec_cmd(scripts .. "workspace-switch.sh " .. i))
    hl.bind(mainMod .. " + ALT + " .. i, hl.dsp.exec_cmd(scripts .. "workspace-move.sh " .. i))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(scripts .. "volume.sh up"),                       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(scripts .. "volume.sh down"),                     { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(scripts .. "volume.sh mute"),                     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(scripts .. "brightness.sh up"),                   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scripts .. "brightness.sh down"),                 { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- eww
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("bash " .. scripts .. "restart-eww.sh"))

-- Capturas de pantalla
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -o ~/Imagenes/Capturas/"))
hl.bind("Print",                   hl.dsp.exec_cmd("hyprshot -m output -o ~/Imagenes/Capturas/"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("hyprshot -m window -o ~/Imagenes/Capturas/"))
hl.bind(mainMod .. " + Print",     hl.dsp.exec_cmd([[bash -c 'F=~/Imagenes/Capturas/$(date +%Y%m%d_%H%M%S)_all.png && grim "$F" && wl-copy --type image/png < "$F" && notify-send "Screenshot" "Ambas pantallas guardadas y copiadas"']]))

-- Pantalla completa
hl.bind(mainMod .. " + F11", hl.dsp.window.fullscreen({ action = "toggle" }))


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    -- Ignore maximize requests from all apps.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- G4Music: iniciar en special workspace sin mostrarse en pantalla
hl.window_rule({
    name  = "g4music-silent-start",
    match = { class = "^(com\\.github\\.neithern\\.g4music)$" },

    workspace = "special:g4music silent",
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Waydroid
hl.window_rule({
    name  = "waydroid-float",
    match = { class = "^(Waydroid)$" },

    fullscreen = true,
})

-- Workspaces fijos: 1-9 en el laptop, 10-18 en HDMI
for i = 1, 18 do
    hl.workspace_rule({
        workspace  = tostring(i),
        monitor    = i <= 9 and "eDP-2" or "HDMI-A-1",
        persistent = true,
    })
end


----------------
---- GAMING ----
----------------

-- Solo juegos reales (Proton/Steam vía Lutris u otro launcher).
hl.window_rule({
    name  = "game-steam-proton",
    match = { class = "^(steam_app_.*)$" },

    content         = "game",
    sync_fullscreen = true,
    idle_inhibit    = "fullscreen",
})

-- Si el juego ya está a pantalla completa, confina el cursor
hl.window_rule({
    name  = "game-confine-pointer",
    match = { content = "game", fullscreen = true },

    confine_pointer = true,
})
