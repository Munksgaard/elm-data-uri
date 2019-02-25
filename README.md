# elm-data-uri

![](https://travis-ci.org/Munksgaard/elm-data-uri.svg?branch=master)

`elm-data-uri` lets you parse and handle [data
URIs](https://en.wikipedia.org/wiki/Data_URI_scheme) like
`data:text/vnd-example+xyz;foo=bar;base64,R0lGODdh` and
`data:text/plain;charset=UTF-8;page=21,the%20data:1234,5678` in Elm.

Here is an example of how it works:

```elm
DataUri.fromString "data:text/vnd-example+xyz;foo=bar;base64,R0lGODdh"
  == Just
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
```
