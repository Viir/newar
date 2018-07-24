module Visuals exposing (..)

import Point2d exposing (Point2d)
import LineSegment2d exposing (LineSegment2d)
import BoundingBox2d exposing (BoundingBox2d)
import Svg
import Svg.Attributes as SA
import Tuple2


type SvgPathConnectionFromPreviousElement = MoveTo | LineTo

type alias Float2 = (Float, Float)


svgTransformTranslate : Float2 -> String
svgTransformTranslate (x, y) =
  "translate(" ++ (x |> toString) ++ "," ++ (y |> toString) ++ ")"

svgLineSegmentWithStroke : (String, Float) -> LineSegment2d -> Svg.Svg event
svgLineSegmentWithStroke stroke lineSegment =
  svgPolylineWithStroke stroke (lineSegment |> LineSegment2d.endpoints |> Tuple2.toList)

svgPolylineWithStroke : (String, Float) -> List Point2d -> Svg.Svg event
svgPolylineWithStroke (stroke, strokeWidth) points =
    let
        pathData = points |> svgPathDataFromPolylineListPoint MoveTo
    in
        Svg.path [ SA.d pathData, SA.stroke stroke, SA.strokeWidth (strokeWidth |> toString), SA.fill "none" ] []

svgPathDataFromPolylineListPoint : SvgPathConnectionFromPreviousElement -> List Point2d -> String
svgPathDataFromPolylineListPoint connectionFromPreviousSubpath polygonListPoint =
  let
    pathDataFromPoint =
      Point2d.coordinates >> (\(x, y) -> [x, y]) >> List.map toString >> String.join " "
  in
    case (polygonListPoint |> List.head, polygonListPoint |> List.tail) of
    (Just head, Just tail) ->
      (connectionFromPreviousSubpath |> svgPathConnectionStringFromType) ++ " " ++ (pathDataFromPoint head) ++ " " ++
      ((tail |> List.map (\point -> "L " ++ (pathDataFromPoint point)) |> String.join " "))
    _ -> ""

svgPathConnectionStringFromType : SvgPathConnectionFromPreviousElement -> String
svgPathConnectionStringFromType connectionFromPreviousElement =
  case connectionFromPreviousElement of
  MoveTo -> "M"
  LineTo -> "L"

svgViewBoxFromBoundingBox : BoundingBox2d -> String
svgViewBoxFromBoundingBox boundingBox =
  [ (boundingBox |> BoundingBox2d.minX, boundingBox |> BoundingBox2d.minY), boundingBox |> BoundingBox2d.dimensions ]
  |> List.concatMap Tuple2.toList
  |> List.map toString
  |> String.join " "
