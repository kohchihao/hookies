//
//  Logger.swift
//  Hookies
//
//  Created by Marcus Koh on 20/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum LogType {
    case success
    case error
    case warning
    case information
    case alert
}

fileprivate enum Emojis: String {
    case success = "✅"
    case error = "❌"
    case warning = "🚧"
    case information = "📣"
    case alert = "🚨"
}

class Logger {
    static let log = Logger()

    var traceableFileName: Bool = true
    var traceableLineNumber: Bool = false
    var traceableFunctionName: Bool = false

    var disabled: Bool = false

    var filteredLogs: [LogType] = []

    private let spacing = " "

    private init() {

    }

    func show(
        details: String,
        logType: LogType,
        fileName: String = #file,
        lineNumber: Int = #line,
        functionName: String = #function
    ) {
        guard !disabled else {
            return
        }
        guard filteredLogs.contains(logType) || filteredLogs.isEmpty else {
            return
        }
        print(logBuilder(
            details: details,
            logType: logType,
            fileName: fileName,
            lineNumber: lineNumber,
            functionName: functionName))
    }

    private func logBuilder(
        details: String,
        logType: LogType,
        fileName: String = #file,
        lineNumber: Int = #line,
        functionName: String = #function
    ) -> String {
        var log = ""
        log += logLevelBuilder(logType: logType)
        log += logFileNameBuilder(fileName: fileName)
        log += logLineNumberBuilder(lineNumber: lineNumber)
        log += logFunctionBuilder(functionName: functionName)
        log += "→ "
        log += details
        return log
    }

    private func logLevelBuilder(logType: LogType) -> String {
        var level = "["
        switch logType {
        case .success:
            level += "Success " + Emojis.success.rawValue
        case .error:
            level += "Error " + Emojis.error.rawValue
        case .warning:
            level += "Warning " + Emojis.warning.rawValue
        case .information:
            level += "Information " + Emojis.information.rawValue
        case .alert:
            level += "Alert " + Emojis.alert.rawValue
        }

        level += "]"
        level += spacing
        return level
    }

    private func logFileNameBuilder(fileName: String = #file) -> String {
        guard traceableFileName else {
            return ""
        }
        let fileName = "[" + getFileName(name: fileName) + "]" + spacing
        return fileName
    }

    private func logLineNumberBuilder(lineNumber: Int = #line) -> String {
        guard traceableLineNumber else {
            return ""
        }
        let line = "[Line \(lineNumber)]" + spacing
        return line
    }

    private func logFunctionBuilder(functionName: String = #function) -> String {
        guard traceableFunctionName else {
            return ""
        }
        let function = "[" + functionName + "()]" + spacing
        return function
    }

    private func getFileName(name: String) -> String {
        guard !name.isEmpty else {
            return ""
        }
        guard let fileName = name.components(separatedBy:  "/").last else {
            return ""
        }
        return fileName
    }
}
