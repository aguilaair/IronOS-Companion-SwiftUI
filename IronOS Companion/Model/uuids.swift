//
//  CBUUIDs.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

import Foundation
import CoreBluetooth

struct IronCharacteristicUUIDs {
    // Live Data Characteristics
    static let liveTemp = CBUUID( string: "d85ef001-168e-4a71-aa55-33e27f9bc533")
    static let setpointTemp = CBUUID( string: "d85ef002-168e-4a71-aa55-33e27f9bc533")
    static let dcInput = CBUUID( string: "d85ef003-168e-4a71-aa55-33e27f9bc533")
    static let handleTemp = CBUUID( string: "d85ef004-168e-4a71-aa55-33e27f9bc533")
    static let powerLevel = CBUUID( string: "d85ef005-168e-4a71-aa55-33e27f9bc533")
    static let powerSrc = CBUUID( string: "d85ef006-168e-4a71-aa55-33e27f9bc533")
    static let tipRes = CBUUID( string: "d85ef007-168e-4a71-aa55-33e27f9bc533")
    static let uptime = CBUUID( string: "d85ef008-168e-4a71-aa55-33e27f9bc533")
    static let movement = CBUUID( string: "d85ef009-168e-4a71-aa55-33e27f9bc533")
    static let maxTemp = CBUUID( string: "d85ef00a-168e-4a71-aa55-33e27f9bc533")
    static let rawTip = CBUUID( string: "d85ef00b-168e-4a71-aa55-33e27f9bc533")
    static let hallSensor = CBUUID( string: "d85ef00c-168e-4a71-aa55-33e27f9bc533")
    static let opMode = CBUUID( string: "d85ef00d-168e-4a71-aa55-33e27f9bc533")
    static let estWatts = CBUUID( string: "d85ef00e-168e-4a71-aa55-33e27f9bc533")

    // Bulk Data Characteristics
    static let bulkLiveData = CBUUID( string: "9eae1001-9d0d-48c5-aa55-33e27f9bc533")
    static let accelName = CBUUID( string: "9eae1002-9d0d-48c5-aa55-33e27f9bc533")
    static let build = CBUUID( string: "9eae1003-9d0d-48c5-aa55-33e27f9bc533")
    static let devSN = CBUUID( string: "9eae1004-9d0d-48c5-aa55-33e27f9bc533")
    static let devID = CBUUID( string: "9eae1005-9d0d-48c5-aa55-33e27f9bc533")

    // Settings Characteristics
    static let setTemperature = CBUUID( string: "f6d70000-5a10-4eba-aa55-33e27f9bc533")
    static let sleepTemperature = CBUUID( string: "f6d70001-5a10-4eba-aa55-33e27f9bc533")
    static let sleepTimeout = CBUUID( string: "f6d70002-5a10-4eba-aa55-33e27f9bc533")
    static let dCInCutoff = CBUUID( string: "f6d70003-5a10-4eba-aa55-33e27f9bc533")
    static let minVolCell = CBUUID( string: "f6d70004-5a10-4eba-aa55-33e27f9bc533")
    static let qCMaxVoltage = CBUUID( string: "f6d70005-5a10-4eba-aa55-33e27f9bc533")
    static let displayRotation = CBUUID( string: "f6d70006-5a10-4eba-aa55-33e27f9bc533")
    static let motionSensitivity = CBUUID( string: "f6d70007-5a10-4eba-aa55-33e27f9bc533")
    static let animLoop = CBUUID( string: "f6d70008-5a10-4eba-aa55-33e27f9bc533")
    static let animSpeed = CBUUID( string: "f6d70009-5a10-4eba-aa55-33e27f9bc533")
    static let autoStart = CBUUID( string: "f6d7000a-5a10-4eba-aa55-33e27f9bc533")
    static let shutdownTimeout = CBUUID( string: "f6d7000b-5a10-4eba-aa55-33e27f9bc533")
    static let cooldownBlink = CBUUID( string: "f6d7000c-5a10-4eba-aa55-33e27f9bc533")
    static let advancedIdle = CBUUID( string: "f6d7000d-5a10-4eba-aa55-33e27f9bc533")
    static let advancedSoldering = CBUUID( string: "f6d7000e-5a10-4eba-aa55-33e27f9bc533")
    static let temperatureUnit = CBUUID( string: "f6d7000f-5a10-4eba-aa55-33e27f9bc533")
    static let scrollingSpeed = CBUUID( string: "f6d70010-5a10-4eba-aa55-33e27f9bc533")
    static let lockingMode = CBUUID( string: "f6d70011-5a10-4eba-aa55-33e27f9bc533")
    static let powerPulsePower = CBUUID( string: "f6d70012-5a10-4eba-aa55-33e27f9bc533")
    static let powerPulseWait = CBUUID( string: "f6d70013-5a10-4eba-aa55-33e27f9bc533")
    static let powerPulseDuration = CBUUID( string: "f6d70014-5a10-4eba-aa55-33e27f9bc533")
    static let voltageCalibration = CBUUID( string: "f6d70015-5a10-4eba-aa55-33e27f9bc533")
    static let boostTemperature = CBUUID( string: "f6d70016-5a10-4eba-aa55-33e27f9bc533")
    static let calibrationOffset = CBUUID( string: "f6d70017-5a10-4eba-aa55-33e27f9bc533")
    static let powerLimit = CBUUID( string: "f6d70018-5a10-4eba-aa55-33e27f9bc533")
    static let reverseButtonTempChange = CBUUID( string: "f6d70019-5a10-4eba-aa55-33e27f9bc533")
    static let tempChangeLongStep = CBUUID( string: "f6d7001a-5a10-4eba-aa55-33e27f9bc533")
    static let tempChangeShortStep = CBUUID( string: "f6d7001b-5a10-4eba-aa55-33e27f9bc533")
    static let hallEffectSensitivity = CBUUID( string: "f6d7001c-5a10-4eba-aa55-33e27f9bc533")
    static let accelMissingWarningCounter = CBUUID( string: "f6d7001d-5a10-4eba-aa55-33e27f9bc533")
    static let pdMissingWarningCounter = CBUUID( string: "f6d7001e-5a10-4eba-aa55-33e27f9bc533")
    static let uiLanguage = CBUUID( string: "f6d7001f-5a10-4eba-aa55-33e27f9bc533")
    static let pdNegTimeout = CBUUID( string: "f6d70020-5a10-4eba-aa55-33e27f9bc533")
    static let colourInversion = CBUUID( string: "f6d70021-5a10-4eba-aa55-33e27f9bc533")
    static let brightness = CBUUID( string: "f6d70022-5a10-4eba-aa55-33e27f9bc533")
    static let logoTime = CBUUID( string: "f6d70023-5a10-4eba-aa55-33e27f9bc533")
    static let calibrateCJC = CBUUID( string: "f6d70024-5a10-4eba-aa55-33e27f9bc533")
    static let bleEnabled = CBUUID( string: "f6d70025-5a10-4eba-aa55-33e27f9bc533")
    static let pdVpdoEnabled = CBUUID( string: "f6d70026-5a10-4eba-aa55-33e27f9bc533")
    static let saveToFlash = CBUUID( string: "f6d7ffff-5a10-4eba-aa55-33e27f9bc533")
    static let settingsReset = CBUUID( string: "f6d7fffe-5a10-4eba-aa55-33e27f9bc533")
}

struct IronServices {
    static let liveData = CBUUID(string: "d85ef000-168e-4a71-aa55-33e27f9bc533")
    static let settings = CBUUID(string: "f6d80000-5a10-4eba-aa55-33e27f9bc533")
    static let bulk = CBUUID(string: "9eae1000-9d0d-48c5-aa55-33e27f9bc533")
}
