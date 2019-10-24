// Created by Francisco Diaz on 10/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Commandant
import Foundation
import SwiftInspectorKit

/// A type that represents a CLI command to check for usage of a singleton
final class SingletonUsageCommand: CommandProtocol {
  init() { }

  /// The verb that's used in the command line to invoke this command
  let verb: String = "singleton"
  /// A description of the usage of this command
  let function: String = "Finds information related to the usage of a specific singleton"

  /// Runs the command
  ///
  /// - Parameter options: The available options for this command
  /// - Returns: An Result with an error
  func run(_ options: SingletonUsageOptions) -> Result<(), Error> {
    let singleton = Singleton(typeName: options.typeName, memberName: options.memberName)
    let analyzer = SingletonUsageAnalyzer(singleton: singleton)

    return Result {
      let fileURL = URL(fileURLWithPath: options.path)
      let results: RawJSON = try analyzer.analyze(fileURL: fileURL)
      print(results) // Print to standard output
      return ()
    }
  }

}

/// A type that represents parameters that can be passed to the SingletonUsageCommand command
struct SingletonUsageOptions: OptionsProtocol {
  fileprivate let typeName: String
  fileprivate let memberName: String
  fileprivate let path: String

  /// Evaluates the arguments passed through the CommandMode and converts them into a valid SingletonUsageOptions
  ///
  /// - Parameter m: The `CommandMode` that's used to parse the command line arguments into a strongly typed `SingletonUsageOptions`
  /// - Returns: A valid SingletonUsageOptions or an error
  static func evaluate(_ m: CommandMode) -> Result<SingletonUsageOptions, CommandantError<Error>> {
    let result: Result<SingletonUsageOptions, CommandantError<Error>> = create
      <*> m <| Option(key: "type-name", defaultValue: "", usage: "the name of the type")
      <*> m <| Option(key: "member-name", defaultValue: "", usage: "the name of the member that access the singleton")
      <*> m <| Option(key: "path", defaultValue: "", usage: "the path to the Swift file to inspect")

    return result.flatMap { return validate($0) }
  }

  private static func create(_ typeName: String) -> (String) -> (String) -> SingletonUsageOptions {
    return { memberName in { path in SingletonUsageOptions(typeName: typeName, memberName: memberName, path: path) } }
  }

  private static func validate(_ options: SingletonUsageOptions) -> Result<SingletonUsageOptions, CommandantError<Error>> {
    guard !options.typeName.isEmpty else { return .failure(.usageError(description: "Please provide a --type-name")) }
    guard !options.memberName.isEmpty else { return .failure(.usageError(description: "Please provide a --member-name")) }
    guard !options.path.isEmpty else { return .failure(.usageError(description: "Please provide a --path")) }
    guard FileManager.default.fileExists(atPath: options.path) else { return .failure(.usageError(description: "The provided --path \(options.path) does not exist")) }

    return .success(options)
  }
}