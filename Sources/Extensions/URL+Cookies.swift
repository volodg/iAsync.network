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

        if let cookies = HTTPCookieStorage.shared.cookies(for: self) {
            for cookie in cookies {
                cookiesLog += "Name: '\(cookie.name)'; Value: '\(cookie.value)'\n"
            }
        }

        print(cookiesLog)
    }

    func removeCookies() {

        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: self)

        if let cookies = cookies {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie as HTTPCookie)
            }
        }
    }
}
