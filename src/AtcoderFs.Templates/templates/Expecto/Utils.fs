module Utils

open System
open System.IO
open System.Text.RegularExpressions
open Expecto

let (==?) actual expected = Expect.equal actual expected ""

type TaskInfo =
    { Title: string
      FolderName: string
      Memory: int
      Timeout: TimeSpan }

type SampleFileInfo =
    { Parent: TaskInfo
      InFile: FileInfo
      OutFile: FileInfo }

let parentDirectory =
    __SOURCE_DIRECTORY__ |> Directory.GetParent

let replace pattern replacement input =
    Regex.Replace(input, pattern, replacement = replacement)

let getBaseName (file: FileInfo) = file.Name |> replace "\..+$" ""

let isMatchFileName name (file: FileInfo) = Regex.IsMatch(file.Name, name)

let findByFileName name files =
    files |> Seq.find (isMatchFileName name)

let getTestDirectoryInfo folderName =
    [| parentDirectory.FullName
       folderName
       "test" |]
    |> Path.Combine
    |> DirectoryInfo

let getSampleFiles info =
    let folderInfo = getTestDirectoryInfo info.FolderName

    folderInfo.EnumerateFiles()
    |> Seq.groupBy getBaseName
    |> Seq.map
        (fun (_, v) ->
            let inFile = v |> findByFileName "in$"
            let outFile = v |> findByFileName "out$"

            { Parent = info
              InFile = inFile
              OutFile = outFile })

let generateSampleFileTestCase f sampleInfo =
    let label =
        sampleInfo.Parent.Title
        + " "
        + getBaseName sampleInfo.InFile

    let infoMessage = sprintf "%A\n\n" sampleInfo

    test label {
        use reader =
            new StreamReader(path = sampleInfo.InFile.FullName)

        use writer = new StringWriter()
        Console.SetIn reader
        Console.SetOut writer

        let expected =
            File.ReadAllText(sampleInfo.OutFile.FullName)

        let sw = Diagnostics.Stopwatch()

        sw.Start()
        f Array.empty
        sw.Stop()

        sprintf "WA:%s" infoMessage
        |> Expect.equal (writer.ToString()) expected

        sprintf "\nTimeout:\n%A\n\n%s\n\n" sw.Elapsed infoMessage
        |> Expect.isLessThan sw.Elapsed sampleInfo.Parent.Timeout
    }

let sampleFileTests info f =
    getSampleFiles info
    |> Seq.map (generateSampleFileTestCase f)
    |> Seq.toList
