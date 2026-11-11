module SessionType exposing
    ( SessionType(..)
    , fromString
    , toString
    )


type SessionType
    = Focus
    | LongBreak
    | ShortBreak


toString : SessionType -> String
toString sessionType =
    case sessionType of
        Focus ->
            "Focus"

        LongBreak ->
            "LongBreak"

        ShortBreak ->
            "ShortBreak"


fromString : String -> Maybe SessionType
fromString string =
    case String.toLower string of
        "focus" ->
            Just Focus

        "shortbreak" ->
            Just ShortBreak

        "longbreak" ->
            Just LongBreak

        _ ->
            Nothing
