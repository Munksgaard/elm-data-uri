module DataUri exposing
    ( DataUri, Data(..)
    , fromString, parser
    )

{-| Parse and handle data URIs in Elm.


# Types

@docs DataUri, Data


# Parsing

@docs fromString, parser

-}

import Base64
import Bytes exposing (Bytes)
import Dict
import MediaType exposing (MediaType)
import Parser
    exposing
        ( (|.)
        , (|=)
        , Parser
        , Step(..)
        , andThen
        , backtrackable
        , chompUntil
        , chompUntilEndOr
        , chompWhile
        , commit
        , getChompedString
        , keyword
        , loop
        , map
        , oneOf
        , problem
        , run
        , spaces
        , succeed
        , symbol
        , variable
        )
import Url


type Data
    = Base64 Bytes
    | Raw String


type alias DataUri =
    { mediaType : MediaType
    , data : Data
    }


{-| Media types can be a part of another data schema, like the [data URI scheme](https://en.wikipedia.org/wiki/Data_URI_scheme),
so it can be helpful to access the internal parser.
-}
parser : Parser DataUri
parser =
    succeed DataUri
        |. symbol "data:"
        |= oneOf
            [ MediaType.parser
            , succeed <|
                MediaType.MediaType MediaType.Text
                    Nothing
                    "plain"
                    Nothing
                    (Dict.fromList [ ( "charset", "US-ASCII" ) ])
            ]
        |= oneOf
            [ succeed identity
                |. symbol ";base64,"
                |= getChompedString (chompWhile (always True))
                |> andThen checkBase64
                |> map Base64
            , succeed identity
                |. symbol ","
                |= getChompedString (chompWhile (always True))
                |> andThen checkRaw
                |> map Raw
            ]


checkBase64 : String -> Parser Bytes
checkBase64 s =
    case Base64.toBytes s of
        Just b ->
            succeed b

        Nothing ->
            problem "Invalid base64"


checkRaw : String -> Parser String
checkRaw s =
    case Url.percentDecode s of
        Just b ->
            succeed b

        Nothing ->
            problem "Invalid url encoded string"


{-| Attempt to parse a string as a data URI.
-}
fromString : String -> Maybe DataUri
fromString s =
    Parser.run parser s
        |> Result.toMaybe
