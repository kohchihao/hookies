//
//  Logger.swift
//  Hookies
//
//  Created by Marcus Koh on 20/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import UIKit

/// Logger helps to log all the logs within the project.

enum LogType {
    case success
    case error
    case warning
    case information
    case alert
}

private enum Emojis: String {
    case success = "✅"
    case error = "❌"
    case warning = "🚧"
    case information = "📣"
    case alert = "🚨"
}

enum DisplayType {
    case toast
    case alert
}

class Logger {
    static let log = Logger()

    var traceableFileName: Bool = true
    var traceableLineNumber: Bool = false
    var traceableFunctionName: Bool = false

    var disabled: Bool = false

    var filteredLogs: [LogType] = []

    private let spacing = " "

    private var details = ""

    private init() {

    }

    // MARK: - Logger

    /// Show the message within the XCode logs.
    /// - Parameters:
    ///   - details: The details of the content to be logged
    ///   - logType: The type of logging level
    ///   - fileName: The file name to log
    ///   - lineNumber: The line number to log
    ///   - functionName: The function name to log
    @discardableResult func show(
        details: String,
        logType: LogType,
        fileName: String = #file,
        lineNumber: Int = #line,
        functionName: String = #function
    ) -> Logger {
        guard !disabled else {
            return self
        }
        guard filteredLogs.contains(logType) || filteredLogs.isEmpty else {
            return self
        }

        self.reset()
        self.details = details

        print(logBuilder(
            details: details,
            logType: logType,
            fileName: fileName,
            lineNumber: lineNumber,
            functionName: functionName))
        return self
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
        let function = "[" + functionName + "]" + spacing
        return function
    }

    private func getFileName(name: String) -> String {
        guard !name.isEmpty else {
            return ""
        }
        guard let fileName = name.components(separatedBy: "/").last else {
            return ""
        }
        return fileName
    }

    private func reset() {
        details = ""
    }

    // MARK: - Logger + Display

    /// Display the log as an error message on the user's display.
    /// - Parameter type: The type of alert to display
    func display(_ type: DisplayType = .alert) {
        switch type {
        case .alert:
            self.showErrorAlert(message: details)
        case .toast:
            self.showToast(message: details)
        }
    }

    // MARK: - Display Error

    private var rootWindow: UIWindow!

    /// Show the alert  on the display.
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - message: The message of the alert
    ///   - actionTitles: The action button titles
    ///   - actions: The actions
    func showAlert(
        title: String,
        message: String,
        actionTitles: [String],
        actions: [() -> Void]?
    ) {
        guard rootWindow == nil else {
            return
        }
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.clear
        window.rootViewController = UIViewController()
        rootWindow = UIApplication.shared.windows[0]
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for actionTitle in actionTitles {
            let action = UIAlertAction(title: actionTitle, style: .default, handler: { _ in
                if let actions = actions {
                    if actions.count >= actionTitles.count {
                        guard let index = actionTitles.firstIndex(of: actionTitle) else {
                            return
                        }
                        actions[index]()
                    }
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    alert.dismiss(animated: true, completion: nil)
                    window.isHidden = true
                    window.removeFromSuperview()
                    self.rootWindow = nil
                })
            })
            alert.addAction(action)
        }

        // Display window
        window.windowLevel = .alert
        window.isHidden = false
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }

    /// Show the error alert.
    /// - Parameter message: The message for the alert
    func showErrorAlert(message: String) {
        self.showAlert(title: "Error", message: message, actionTitles: ["Okay"], actions: nil)
    }

    /// Show the toast.
    /// - Parameter message: The message for the toast
    func showToast(message: String) {
        guard rootWindow == nil else {
            return
        }
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.clear
        window.rootViewController = UIViewController()
        rootWindow = UIApplication.shared.windows[0]
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)

        window.windowLevel = .alert
        window.isHidden = false
        window.rootViewController?.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
            window.isHidden = true
            window.removeFromSuperview()
            self.rootWindow = nil
        }
    }
}
