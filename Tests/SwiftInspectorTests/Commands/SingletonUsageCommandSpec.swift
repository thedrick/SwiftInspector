// Created by Francisco Diaz on 10/11/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Foundation
import Nimble
import Quick
@testable import SwiftInspectorKit

final class SingletonUsageCommanddSpec: QuickSpec {
  
  override func spec() {
    describe("run") {
      context("with no arguments") {
        it("fails") {
          let result = try? TestTask.run(withArguments: ["singleton"])
          expect(result?.didFail) == true
        }
      }
      
      context("with no --type-name argument") {
        it("fails") {
          let result = try? TestTask.run(withArguments: ["singleton", "--path", "."])
          expect(result?.didFail) == true
        }
      }
      
      context("with an empty --type-name argument") {
        it("fails") {
          let result = try? TestTask.run(withArguments: ["singleton", "--type-name", "", "--path", "/abc"])
          expect(result?.didFail) == true
        }
      }
      
      context("with no --member-name argument") {
        it("fails") {
          let result = try? TestTask.run(withArguments: ["singleton", "--type-name", "Some", "--path", "/abc"])
          expect(result?.didFail) == true
        }
      }
      
      context("with an empty --member-name argument") {
        it("fails") {
          let result = try? TestTask.run(withArguments: ["singleton", "--type-name", "Some", "--member-name", "shared", "", "/abc"])
          expect(result?.didFail) == true
        }
      }
      
      context("with no --path argument") {
        it("fails") {
          let result = try? TestTask.run(withArguments: ["singleton", "--type-name", "SomeType"])
          expect(result?.didFail) == true
        }
      }
      
      context("with an empty --path argument") {
        it("fails") {
          let result = try? TestTask.run(withArguments: ["singleton", "--type-name", "SomeType", "--path", ""])
          expect(result?.didFail) == true
        }
      }
      
      context("with all arguments") {
        context("when path doesn't exist") {
          it("fails") {
            let result = try? TestTask.run(withArguments: ["singleton", "--type-name", "SomeType", "--member-name", "shared", "--path", "/abc"])
            expect(result?.didFail) == true
          }
        }

        context("when path exists") {
          it("succeeds") {
            let fileURL = try? Temporary.makeSwiftFile(content: "")
            let result = try? TestTask.run(withArguments: ["singleton", "--type-name", "SomeType", "--member-name", "shared", "--path", fileURL?.path ?? ""])
            expect(result?.didSucceed) == true
          }
        }
      }
      
    }
  }
}