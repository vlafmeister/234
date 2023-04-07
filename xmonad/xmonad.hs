-- IMPORT MODULES
import XMonad
import Data.Monoid
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import System.IO
-- Autostart:
import XMonad.Util.SpawnOnce
-- Module to run xmobar
import XMonad.Util.Run


-- TERMINAL EMULATOR
myTerminal      = "st"

-- WHETHER THE FOCUS FOLLOWS THE MOUSE CURSOR
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- WILL A CLICK ON THE WINDOW TO FOCUS ALSO CLICK ON THE WINDOW
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- FRAME THICKNESS IN PIXELS
myBorderWidth   = 1

-- MODIFIER KEY mod1Mask - LEFT ALT, mod3Mask - RIGHT ALT, mod4Mask - WIN
myModMask       = mod4Mask

-- VORKSPIES
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- WINDOW FRAME COLOR
myNormalBorderColor  = "#1e1e2e"
myFocusedBorderColor = "#d9e0ee"


------------------------------------------------------------------------
-- HOTKEY
------------------------------------------------------------------------
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- TERMINAL
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)

    -- DMENU
    , ((modm,               xK_d     ), spawn "dmenu_run")

    -- GMRUN
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- CLOSE THE ACTIVE WINDOW
    , ((modm,               xK_c     ), kill)

     -- ИЗМЕНИТЬ КОМПАНОВКУ ОКОН
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  TO PUT THE WINDOW LAYOUT BACK
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- WINDOW SWITCHING
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- SWITCH THE FOCUS TO THE NEXT WINDOW
    , ((modm,               xK_Left  ), windows W.focusDown)

    -- SWITCH THE FOCUS TO THE PREVIOUS WINDOW
    , ((modm,               xK_Right ), windows W.focusUp  )

    -- SWITCH THE FOCUS TO THE MASTER WINDOW
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- SWAP THE MASTER WINDOW AND THE CURRENT WINDOW
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)

    -- SWAP THE CURRENT WINDOW AND THE WINDOW THAT FOLLOWS IT
    , ((modm .|. shiftMask, xK_Left  ), windows W.swapDown  )

    -- SWAP THE CURRENT WINDOW AND THE WINDOW BEFORE IT
    , ((modm .|. shiftMask, xK_Right ), windows W.swapUp    )

    -- SHRINK THE MASTER WINDOW
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- ENLARGE THE MASTER WINDOW
    , ((modm,               xK_l     ), sendMessage Expand)

    -- MAKE THE WINDOW A TILE WINDOW IF IT WAS FLOATING
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- INCREASE THE NUMBER OF MASTER WINDOWS
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- REDUCE THE NUMBER OF MASTER WINDOWS
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))




    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)




    -- EXIT
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- FORWARD
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- SHOW HOTTKEYS HELP, IT DOESN'T WORK FOR ME, I HAVEN'T TRIED TO FIX IT.
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    -- MOD+1...9 SWITCH TO WORXPACE, MOD+SHIFT+1...9 TO MOVE THE WINDOW TO THE WORXPACE
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    -- MOD+W,E,R SWITCH TO THE 2ND OR 3RD MONITOR, MOD+SHIFT+W,E,R MOVE THE WINDOW TO THE 2ND OR 3RD MONITOR
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- MOUSE BUTTON SETUP
------------------------------------------------------------------------
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, MAKE THE WINDOW FLOAT
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, RAISE THE WINDOW TO THE TOP OF THE STACK
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, MAKE THE WINDOW FLOATING AND RESIZE IT
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]


------------------------------------------------------------------------
-- MAKETS
------------------------------------------------------------------------
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
     -- TAILING MODE
     tiled   = Tall nmaster delta ratio

     -- NUMBER OF MASTER WINDOWS BY DEFAULT
     nmaster = 1

     -- THE PROPORTIONS OF THE SCREEN BETWEEN THE MASTER WINDOW AND THE REST
     ratio   = 1/2

     -- PERCENTAGE STEP IN WINDOW RESIZE
     delta   = 3/100


------------------------------------------------------------------------
-- WINDOW RULES
------------------------------------------------------------------------
-- TO KNOW THE CLASS OF THE WINDOW TO DO xprop | grep WM_CLASS
-- MORE THE CLASS MAY BE 'title', 'className' AND 'resource'

myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]


------------------------------------------------------------------------
-- Event handling
------------------------------------------------------------------------
-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty


------------------------------------------------------------------------
-- Status bars and logging
------------------------------------------------------------------------
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()


------------------------------------------------------------------------
-- AUTO START
------------------------------------------------------------------------
myStartupHook = do
     spawnOnce "nitrogen --restore &"
     spawnOnce "firefox"


------------------------------------------------------------------------

-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
     xmproc0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc"
     xmonad $ docks defaults
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }


-- | THIS SEEMS TO BE THE ONE HELP THAT I COULDN'T GET UP AND RUNNING.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
