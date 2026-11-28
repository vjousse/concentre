module News exposing (shouldShowBadge)

import SessionStatus exposing (SessionStatus(..))


{-| Whether to show the news badge on the heart icon.

  - `sessionStatus` is `Nothing` until the init data from Rust arrives: the
    config (and so `lastSeenVersion`) is still a placeholder at that point,
    so the badge stays hidden to avoid a flash at startup.
  - The badge is hidden while a session is running, to avoid distracting the user.
  - `appVersion` is "unknown" when the frontend runs outside Tauri (e.g. in a
    browser during development): there is no news to show in that case.

-}
shouldShowBadge : { appVersion : String, lastSeenVersion : Maybe String, sessionStatus : Maybe SessionStatus } -> Bool
shouldShowBadge { appVersion, lastSeenVersion, sessionStatus } =
    case sessionStatus of
        Just Running ->
            False

        Just _ ->
            appVersion /= "unknown" && lastSeenVersion /= Just appVersion

        Nothing ->
            False
