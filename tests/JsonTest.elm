module JsonTest exposing (suite)

import Expect
import Json exposing (ExternalMessage(..), externalMessageDecoder)
import Json.Decode as Decode
import SessionStatus exposing (SessionStatus(..))
import SessionType exposing (SessionType(..))
import Test exposing (Test, describe, test)


decode : String -> Maybe ExternalMessage
decode json =
    Decode.decodeString externalMessageDecoder json
        |> Result.toMaybe


suite : Test
suite =
    describe "externalMessageDecoder"
        [ test "decodes an error message" <|
            \_ ->
                decode """{"error":"load_init_data: boom"}"""
                    |> Expect.equal (Just (ErrorMsg "load_init_data: boom"))
        , test "decodes a Rust pomodoro state" <|
            \_ ->
                decode """
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
                decode """{"session_type":"focus","file_path":"/tmp/bell.mp3"}"""
                    |> Expect.equal (Just (SoundFilePath Focus "/tmp/bell.mp3"))
        , test "rejects a sound file message with a null path" <|
            \_ ->
                decode """{"session_type":"focus","file_path":null}"""
                    |> Expect.equal Nothing
        , test "rejects an error field that is not a string" <|
            \_ ->
                decode """{"error":null}"""
                    |> Expect.equal Nothing
        , test "rejects an unknown message" <|
            \_ ->
                decode """{"foo":1}"""
                    |> Expect.equal Nothing
        ]
