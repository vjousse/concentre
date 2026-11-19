module JsonTest exposing (suite)

import Config exposing (Config)
import Expect
import Json exposing (ExternalMessage(..), configDecoder, configEncoder, externalMessageDecoder)
import Json.Decode as Decode
import SessionStatus exposing (SessionStatus(..))
import SessionType exposing (SessionType(..))
import Test exposing (Test, describe, test)


decodeExternalMessage : String -> Maybe ExternalMessage
decodeExternalMessage json =
    Decode.decodeString externalMessageDecoder json
        |> Result.toMaybe


testConfig : Config
testConfig =
    { alwaysOnTop = True
    , autoQuit = Nothing
    , autoStartBreakTimer = True
    , autoStartOnAppStartup = True
    , autoStartWorkTimer = True
    , defaultFocusLabel = "Focus"
    , defaultLongBreakLabel = "Long break"
    , defaultShortBreakLabel = "Short break"
    , desktopNotifications = True
    , focusAudio = Just "audio_test.mp3"
    , focusDuration = 1500
    , longBreakAudio = Nothing
    , longBreakDuration = 1200
    , maxRoundNumber = 4
    , maxSessionDuration = 90 * 60
    , minimizeToTray = True
    , minimizeToTrayOnClose = True
    , muted = False
    , shortBreakAudio = Nothing
    , shortBreakDuration = 300
    , startMinimized = True
    , systemStartupAutoStart = False
    , theme = "pomodorolm"
    , tickSoundsDuringBreak = True
    , tickSoundsDuringWork = True
    , volume = Just 100
    }


testConfigJson : String
testConfigJson =
    """{
  "always_on_top": true
  , "auto_start_break_timer": true
  , "auto_start_on_app_startup": true
  , "auto_start_work_timer": true
  , "default_focus_label": "Focus"
  , "default_long_break_label": "Long break"
  , "default_short_break_label": "Short break"
  , "desktop_notifications": true
  , "focus_audio": "audio_test.mp3"
  , "focus_duration": 1500
  , "long_break_duration": 1200
  , "max_round_number": 4
  , "max_session_duration": 5400
  , "minimize_to_tray": true
  , "minimize_to_tray_on_close": true
  , "muted": false
  , "short_break_duration": 300
  , "start_minimized": true
  , "system_startup_auto_start": false
  , "theme": "pomodorolm"
  , "tick_sounds_during_break": true
  , "tick_sounds_during_work": true
  , "volume": 100
}
"""


suite : Test
suite =
    describe "Json parsers"
        [ describe "should be indempotent"
            [ test "encode then decode" <|
                \_ ->
                    configEncoder testConfig
                        |> Decode.decodeValue configDecoder
                        |> Expect.equal (Ok testConfig)
            , test "decode then encode" <|
                \_ ->
                    Decode.decodeString configDecoder testConfigJson
                        |> Result.map configEncoder
                        |> Result.andThen (Decode.decodeValue configDecoder)
                        |> Expect.equal (Ok testConfig)
            ]
        , describe "externalMessageDecoder"
            [ test "decodes an error message" <|
                \_ ->
                    decodeExternalMessage """{"error":"load_init_data: boom"}"""
                        |> Expect.equal (Just (ErrorMsg "load_init_data: boom"))
            , test "decodes a Rust pomodoro state" <|
                \_ ->
                    decodeExternalMessage """
                {
                  "current_session": {
                    "current_time": 42,
                    "session_type": "Focus",
                    "status": "Running"
                  },
                  "current_work_round_number": 2
                }
                """
                        |> Expect.equal
                            (Just
                                (RustStateMsg
                                    { currentSession =
                                        { currentTime = 42
                                        , sessionType = Focus
                                        , status = Running
                                        }
                                    , currentWorkRoundNumber = 2
                                    }
                                )
                            )
            , test "decodes a sound file path" <|
                \_ ->
                    decodeExternalMessage """{"session_type":"focus","file_path":"/tmp/bell.mp3"}"""
                        |> Expect.equal (Just (SoundFilePath Focus "/tmp/bell.mp3"))
            , test "rejects a sound file message with a null path" <|
                \_ ->
                    decodeExternalMessage """{"session_type":"focus","file_path":null}"""
                        |> Expect.equal Nothing
            , test "rejects an error field that is not a string" <|
                \_ ->
                    decodeExternalMessage """{"error":null}"""
                        |> Expect.equal Nothing
            , test "rejects an unknown message" <|
                \_ ->
                    decodeExternalMessage """{"foo":1}"""
                        |> Expect.equal Nothing
            ]
        ]
