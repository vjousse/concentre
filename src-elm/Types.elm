module Types exposing
    ( CurrentState
    , ResetType(..)
    , Setting(..)
    , SettingTab(..)
    , SettingType(..)
    )

import Color exposing (RGB)
import SessionStatus exposing (SessionStatus)
import SessionType exposing (SessionType)


type ResetType
    = CurrentRound
    | EntireSession


type alias CurrentState =
    { color : RGB, paused : Bool, percentage : Float, sessionStatus : SessionStatus }


type SettingTab
    = AboutTab
    | SettingsTab
    | SoundsTab
    | TextTab
    | ThemeTab
    | TimerTab


type Setting
    = AlwaysOnTop
    | AutoStartBreakTimer
    | AutoStartOnAppStartup
    | AutoStartWorkTimer
    | DesktopNotifications
    | MinimizeToTray
    | MinimizeToTrayOnClose
    | StartMinimized
    | SystemStartupAutoStart
    | TickSoundsDuringBreak
    | TickSoundsDuringWork


type SettingType
    = AutoQuit String
    | FocusTime String
    | Label SessionType String
    | LongBreakTime String
    | MaxSessionDuration String
    | Rounds String
    | SaveMaxSessionDuration
    | ShortBreakTime String
    | Toggle Setting
