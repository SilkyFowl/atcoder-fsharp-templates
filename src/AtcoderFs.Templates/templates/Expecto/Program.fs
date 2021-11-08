open Expecto

[<EntryPoint>]
let main argv =
  // CLIArguments.Sequenced

  // Invoke Expecto:
  runTestsInAssemblyWithCLIArgs [Sequenced] argv