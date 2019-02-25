module Tests exposing (suite)

import Base64
import Bytes.Encode
import DataUri
import Dict
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import MediaType
import Test exposing (..)


suite : Test
suite =
    describe "The DataUri module"
        [ describe "DataUri.fromString"
            [ test "data:text/vnd-example+xyz;foo=bar;base64,R0lGODdh" <|
                \_ ->
                    DataUri.fromString "data:text/vnd-example+xyz;foo=bar;base64,R0lGODdh"
                        |> Expect.equal
                            (Just
                                { mediaType =
                                    { parameters = Dict.fromList [ ( "foo", "bar" ) ]
                                    , registrationTree = Nothing
                                    , subtype = "vnd-example"
                                    , suffix = Just "xyz"
                                    , type_ = MediaType.Text
                                    }
                                , data =
                                    Bytes.Encode.string "GIF87"
                                        |> Bytes.Encode.encode
                                        |> DataUri.Base64
                                }
                            )
            , test "data:," <|
                \_ ->
                    DataUri.fromString "data:,"
                        |> Expect.equal
                            (Just
                                { mediaType =
                                    { parameters = Dict.fromList [ ( "charset", "US-ASCII" ) ]
                                    , registrationTree = Nothing
                                    , subtype = "plain"
                                    , suffix = Nothing
                                    , type_ = MediaType.Text
                                    }
                                , data = DataUri.Raw ""
                                }
                            )
            , test "data:text/plain;charset=UTF-8;page=21,the%20data:1234,5678" <|
                \_ ->
                    DataUri.fromString "data:text/plain;charset=UTF-8;page=21,the%20data:1234,5678"
                        |> Expect.equal
                            (Just
                                { mediaType =
                                    { parameters =
                                        Dict.fromList
                                            [ ( "charset", "UTF-8" )
                                            , ( "page", "21" )
                                            ]
                                    , registrationTree = Nothing
                                    , subtype = "plain"
                                    , suffix = Nothing
                                    , type_ = MediaType.Text
                                    }
                                , data = DataUri.Raw "the data:1234,5678"
                                }
                            )
            ]
        ]
