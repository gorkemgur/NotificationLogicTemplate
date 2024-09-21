//
//  FirebaseRemoteConfigManager.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import Firebase
import UIKit

protocol FirebaseRemoteConfigProtocol: AnyObject {
    func onVersionForce(isWillForce: Bool)
}

private struct FirebaseRemoteConfigConstants {
     //     Declare your variables
     static let versionCodeKey = "ios_version_code"
     static let isVersionWillForce = "ios_will_force_version"
}

final class FirebaseRemoteConfigManager {
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    private var latestBuildNumberOnServer: String = ""
    
    weak var delegate: FirebaseRemoteConfigProtocol?
    
    init() {
        configureRemoteConfig()
        fetchRemoteConfigValues()
    }
    
    private func configureRemoteConfig() {
        let configSettings: RemoteConfigSettings = RemoteConfigSettings()
        #if DEBUG
            configSettings.fetchTimeout = 0
            configSettings.minimumFetchInterval = 0
        #else
            configSettings.fetchTimeout = 40
            configSettings.minimumFetchInterval = 20
        #endif
        remoteConfig.configSettings = configSettings
    }
    
    private func fetchRemoteConfigValues() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.remoteConfig.fetchAndActivate(completionHandler: { (status, error) in
                if status == .successFetchedFromRemote {
                    self.latestBuildNumberOnServer = self.remoteConfig.configValue(forKey: FirebaseRemoteConfigConstants.versionCodeKey).stringValue
                } else {
                    if let error = error {
                        ErrorHandler.shared.showError(error)
                    }
                }
            })
        }
    }
    
    private func getValue(for key: String) -> RemoteConfigValue {
        return remoteConfig.configValue(forKey: key)
    }
}

extension FirebaseRemoteConfigManager {
    func checkVersionForce() {
        let isVersionWillForce = getValue(for: FirebaseRemoteConfigConstants.isVersionWillForce).boolValue
        if (appBuildNumber > latestBuildNumberOnServer) {
            delegate?.onVersionForce(isWillForce: isVersionWillForce)
        }
    }
    
    var appBuildNumber: String {
        "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")"
    }
}
