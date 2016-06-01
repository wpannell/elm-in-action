module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.App
import String
import Task
import Http


type alias Msg =
    { operation : String, data : String }


type alias Model =
    { photos : List { url : String }, selectedId : Int }


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ h1 [] [ text "Photo Groove" ]
        , div [ id "thumbnails" ]
            (List.map (viewThumbnail model.selectedUrl) model.photos)
        ]


viewThumbnail : String -> Photo -> Html Msg
viewThumbnail selectedUrl thumbnail =
    img
        [ src thumbnail.url
        , classList [ ( "selected", selectedUrl == thumbnail.url ) ]
        , onClick { operation = "SELECT_PHOTO", data = thumbnail.url }
        ]
        []


type alias PhotoId =
    Int


type alias Photo =
    { id : PhotoId
    , url : String
    }


model : { photos : List { url : String }, selectedUrl : String }
model =
    { photos = [], selectedUrl = "" }


update msg model =
    if msg.operation == "SELECT_PHOTO" then
        ( { model | selectedUrl = msg.data }, Cmd.none )
    else if msg.operation == "LOAD_PHOTOS" then
        let
            urls =
                String.split "\n" msg.data

            photos =
                List.map (\url -> { url = url }) urls
        in
            ( { model | photos = photos }, Cmd.none )
    else
        ( model, Cmd.none )


selectFirstId : List Photo -> PhotoId
selectFirstId photos =
    case List.head photos of
        Just photo ->
            photo.id

        Nothing ->
            -1


handleLoadSuccess : String -> Msg
handleLoadSuccess data =
    { operation = "LOAD_PHOTOS", data = data }


handleLoadFailure _ =
    { operation = "REPORT_ERROR"
    , data = "HTTP error! (Have you tried turning it off and on again?)"
    }


photoListUrl : String
photoListUrl =
    "http://elm-in-action.com/list-photos"


initialTask =
    Http.getString photoListUrl


initialCmd =
    Task.perform handleLoadFailure handleLoadSuccess initialTask


main =
    Html.App.program
        { view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , init = ( model, initialCmd )
        }
