//
//  URL+Cookies.swift
//  iAsync_network
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright © 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension URL {

    func logCookies() {

        var cookiesLog = "Cookies for url: \(self)\n"

        HTTPCookieStorage.shared.cookies(for: self)?.forEach {
            cookiesLog += "Name: '\($0.name)'; Value: '\($0.value)'\n"
        }

        print(cookiesLog)
    }

    func removeCookies() {

        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: self)

        cookies?.forEach { cookieStorage.deleteCookie($0 as HTTPCookie) }
    }
}
