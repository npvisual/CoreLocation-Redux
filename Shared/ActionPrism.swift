//
//  ActionPrism.swift
//  TurboPool
//
//  Created by Nicolas Philippe on 8/20/20.
//  Copyright © 2020 NPVTech. All rights reserved.
//
//  See : https://github.com/SwiftRex/SwiftRex/blob/develop/docs/markdown/ActionEnumProperties.md

import Foundation

// TODO: Use code-generation

// MARK: - PRISM

extension AppAction {
    public var appLifecycle: AppLifecycleAction? {
        get {
            guard case let .appLifecycle(value) = self else { return nil }
            return value
        }
        set {
            guard case .appLifecycle = self, let newValue = newValue else { return }
            self = .appLifecycle(newValue)
        }
    }

    public var isAppLifecycle: Bool {
        self.appLifecycle != nil
    }
}

extension AppAction {
    public var location: CoreLocationAction? {
        get {
            guard case let .location(value) = self else { return nil }
            return value
        }
        set {
            guard case .location = self, let newValue = newValue else { return }
            self = .location(newValue)
        }
    }

    public var isCoreLocation: Bool {
        self.location != nil
    }
}
