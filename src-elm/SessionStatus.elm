module SessionStatus exposing
    ( SessionStatus(..)
    , toString
    )


type SessionStatus
    = NotStarted
    | Paused
    | Running


toString : SessionStatus -> String
toString sessionStatus =
    case sessionStatus of
        NotStarted ->
            "not_started"

        Paused ->
            "paused"

        Running ->
            "running"
