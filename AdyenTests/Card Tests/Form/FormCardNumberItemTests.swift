//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class FormCardNumberItemTests: XCTestCase {
    
    let supportedCardTypes: [CardType] = [.visa, .masterCard, .americanExpress, .chinaUnionPay, .maestro]
    lazy var binLookupService = BinLookupService(supportedCardTypes: supportedCardTypes,
                                                 environment: Environment.test,
                                                 publicKey: "",
                                                 clientKey: "")
    
    func testInternalBinLookup() {
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes, environment: .test)
        XCTAssertEqual(item.cardTypeLogos.count, 5)
        
        let visa = item.cardTypeLogos[0]
        let mc = item.cardTypeLogos[1]
        let amex = item.cardTypeLogos[2]
        let cup = item.cardTypeLogos[3]
        let maestro = item.cardTypeLogos[4]
        
        // Initially, all card type logos should be visible.
        XCTAssertEqual(visa.isHidden, false)
        XCTAssertEqual(mc.isHidden, false)
        XCTAssertEqual(amex.isHidden, false)
        XCTAssertEqual(cup.isHidden, false)
        XCTAssertEqual(maestro.isHidden, false)
        
        // When typing unknown combination, all logos should be hidden.
        item.value = "5"
        binLookupService.requestCardType(for: item.value) { response in
            item.detectedCardsDidChange(detectedCards: response.brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When typing Maestro pattern, only Maestro should be visible.
        item.value = "56"
        binLookupService.requestCardType(for: item.value) { response in
            item.detectedCardsDidChange(detectedCards: response.brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, false)
        }
        
        // When typing Mastercard pattern, only Mastercard should be visible.
        item.value = "55"
        binLookupService.requestCardType(for: item.value) { response in
            item.detectedCardsDidChange(detectedCards: response.brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, false)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When continuing to type, Mastercard should remain visible.
        item.value = "5555"
        binLookupService.requestCardType(for: item.value) { response in
            item.detectedCardsDidChange(detectedCards: response.brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, false)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // Clearing the field should bring back both logos.
        item.value = ""
        
        XCTAssertEqual(visa.isHidden, false)
        XCTAssertEqual(mc.isHidden, false)
        XCTAssertEqual(amex.isHidden, false)
        XCTAssertEqual(cup.isHidden, false)
        XCTAssertEqual(maestro.isHidden, false)
        
        // When typing VISA pattern, only VISA should be visible.
        item.value = "4"
        binLookupService.requestCardType(for: item.value) { response in
            item.detectedCardsDidChange(detectedCards: response.brands)
            XCTAssertEqual(visa.isHidden, false)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When typing Amex pattern, only Amex should be visible.
        item.value = "34"
        binLookupService.requestCardType(for: item.value) { response in
            item.detectedCardsDidChange(detectedCards: response.brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, false)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When typing common pattern, all matching cards should be visible.
        item.value = "62"
        binLookupService.requestCardType(for: item.value) { response in
            item.detectedCardsDidChange(detectedCards: response.brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, false)
            XCTAssertEqual(maestro.isHidden, false)
        }
    }

    func testExternalBinLookup() {
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes, environment: .test)
        XCTAssertEqual(item.cardTypeLogos.count, 5)

        let visa = item.cardTypeLogos[0]
        let mc = item.cardTypeLogos[1]
        let amex = item.cardTypeLogos[2]
        let cup = item.cardTypeLogos[3]
        let maestro = item.cardTypeLogos[4]

        // When entering PAN, Mastercard should remain visible.
        item.value = "5577000055770004"
        binLookupService.requestCardType(for: item.value) { response in
            item.detectedCardsDidChange(detectedCards: response.brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, false)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }

        // When entering too long PAN, all logos should be hidden.
        item.value = "55770000557700040"
        binLookupService.requestCardType(for: item.value) { response in
            item.detectedCardsDidChange(detectedCards: response.brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
    }
    
    func testLocalizationWithCustomTableName() {
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let sut = FormCardNumberItem(supportedCardTypes: [.visa, .masterCard], environment: .test, localizationParameters: expectedLocalizationParameters)
        
        XCTAssertEqual(sut.title, ADYLocalizedString("adyen.card.numberItem.title", expectedLocalizationParameters))
        XCTAssertEqual(sut.placeholder, ADYLocalizedString("adyen.card.numberItem.placeholder", expectedLocalizationParameters))
        XCTAssertEqual(sut.validationFailureMessage, ADYLocalizedString("adyen.card.numberItem.invalid", expectedLocalizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let sut = FormCardNumberItem(supportedCardTypes: [.visa, .masterCard], environment: .test, localizationParameters: expectedLocalizationParameters)
        
        XCTAssertEqual(sut.title, ADYLocalizedString("adyen_card_numberItem_title", expectedLocalizationParameters))
        XCTAssertEqual(sut.placeholder, ADYLocalizedString("adyen_card_numberItem_placeholder", expectedLocalizationParameters))
        XCTAssertEqual(sut.validationFailureMessage, ADYLocalizedString("adyen_card_numberItem_invalid", expectedLocalizationParameters))
    }
    
}
