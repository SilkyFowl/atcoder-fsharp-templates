module StdIO =
    module Inner =
        let inline parse< ^a when ^a: (static member Parse : string -> ^a)> s =
            (^a: (static member Parse : string -> ^a) s)

    let inline parse () = stdin.ReadLine() |> Inner.parse

    let inline parseN n = Seq.init n (ignore >> parse)

    let inline parseArray< ^a when ^a: (static member Parse : string -> ^a)> separator =
        stdin.ReadLine().Split separator
        |> Array.map Inner.parse< ^a>

    let inline parseArrayN< ^a when ^a: (static member Parse : string -> ^a)> n separator =
        fun _ -> parseArray< ^a> separator
        |> Array.init n

    let inline tuple2 () =
        let arr = parseArray [| ' ' |]
        Array.head arr, Array.item 1 arr

    let inline tuple2N n =
        fun _ -> tuple2 ()
        |> Array.init n

[<AutoOpen>]
module Util =
    let inline fstMap mapper (f, s) = mapper f, s
    let inline sndMap mapper (f, s) = f, mapper s
    let inline tup2Map mapper1 mapper2 (a, b) = mapper1 a, mapper2 b
    let inline tup3Map mapper1 mapper2 mapper3 (a, b, c) = mapper1 a, mapper2 b, mapper3 c

let consoleAtcoderTask argv =
    ()

[<EntryPoint>]
let main argv =
    consoleAtcoderTask argv
    0
