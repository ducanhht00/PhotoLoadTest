//
//  StringExtension.swift
//  TestVNPay
//
//  Created by HoangDucAnh on 13/8/25.
//

import Foundation

extension String {
    func sanitizedEnglishOnly(maxLength: Int = 15) -> String {
        let noDiacritics = self.folding(options: .diacriticInsensitive,
                                        locale: Locale(identifier: "en_US"))
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%^&*():.,<>/\\[]?@ "
        let filtered = noDiacritics.filter { allowedChars.contains($0) }
        return String(filtered.prefix(maxLength))
    }
}
