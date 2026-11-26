module NewsTest exposing (suite)

import Expect
import News
import SessionStatus exposing (SessionStatus(..))
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "News.shouldShowBadge"
        [ test "shows the badge when the news of this version was never seen" <|
            \_ ->
                News.shouldShowBadge { appVersion = "1.0.0", lastSeenVersion = Nothing, sessionStatus = Just NotStarted }
                    |> Expect.equal True
        , test "shows the badge after an update" <|
            \_ ->
                News.shouldShowBadge { appVersion = "1.1.0", lastSeenVersion = Just "1.0.0", sessionStatus = Just Paused }
                    |> Expect.equal True
        , test "hides the badge when the news of this version was seen" <|
            \_ ->
                News.shouldShowBadge { appVersion = "1.0.0", lastSeenVersion = Just "1.0.0", sessionStatus = Just NotStarted }
                    |> Expect.equal False
        , test "hides the badge while a session is running" <|
            \_ ->
                News.shouldShowBadge { appVersion = "1.0.0", lastSeenVersion = Nothing, sessionStatus = Just Running }
                    |> Expect.equal False
        , test "hides the badge until the init data is loaded" <|
            \_ ->
                News.shouldShowBadge { appVersion = "1.0.0", lastSeenVersion = Nothing, sessionStatus = Nothing }
                    |> Expect.equal False
        , test "hides the badge when the app version is unknown" <|
            \_ ->
                News.shouldShowBadge { appVersion = "unknown", lastSeenVersion = Just "1.0.0", sessionStatus = Just NotStarted }
                    |> Expect.equal False
        ]
