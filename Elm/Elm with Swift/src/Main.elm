port module Main exposing (main)

{-| Interop sample: Elm driving a compiled Swift program.

Elm has no way to start a process, so this program uses **ports**: it sends the
numbers out to a thin Node host (`main.js`), which runs the Swift helper and
sends the average back in. Elm formats the result and reports it out again.

See README.md for build and run instructions.

-}
import Json.Encode as Encode


{-| Ask the host to run the Swift helper on these numbers. -}
port calculate : List Float -> Cmd msg


{-| The host tells us what the helper computed. -}
port calculated : (Float -> msg) -> Sub msg


{-| Hand a finished line back to the host so it can print it. -}
port report : String -> Cmd msg


type Msg
    = GotAverage Float


type alias Model =
    { count : Int
    }


init : List Float -> ( Model, Cmd Msg )
init numbers =
    ( { count = List.length numbers }
    , calculate numbers
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotAverage average ->
            ( model
            , report
                ("The average of "
                    ++ String.fromInt model.count
                    ++ " value(s) is: "
                    ++ format average
                )
            )


{-| Render a float with exactly two decimals. -}
format : Float -> String
format value =
    let
        scaled =
            round (value * 100)

        sign =
            if scaled < 0 then
                "-"

            else
                ""

        magnitude =
            abs scaled

        whole =
            magnitude // 100

        fraction =
            modBy 100 magnitude
    in
    sign
        ++ String.fromInt whole
        ++ "."
        ++ String.padLeft 2 '0' (String.fromInt fraction)


subscriptions : Model -> Sub Msg
subscriptions _ =
    calculated GotAverage


main : Program (List Float) Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
