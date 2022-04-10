//
//  DontUseHogePlugin.swift
//  
//
//  Created by fuziki on 2022/04/10.
//

import Foundation
import PackagePlugin

@main struct DontUseHogePlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let tool = try! context.tool(named: "dont-use-hoge")
        let target = target as! SwiftSourceModuleTarget
        let pathListt = target.sourceFiles.map { $0.path }
        return [
            .buildCommand(displayName: "Run dont-use-hoge",
                          executable: tool.path,
                          arguments: pathListt)
        ]
    }
}
