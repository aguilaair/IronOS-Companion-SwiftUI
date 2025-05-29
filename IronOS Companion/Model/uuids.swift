//
//  uuids.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

import Foundation
import CoreBluetooth

struct IronCharacteristicUUIDs {
    // Live Data Characteristics
    static let liveTemp = UUID(uuidString: "d85ef001-168e-4a71-aa55-33e27f9bc533")!
    static let setpointTemp = UUID(uuidString: "d85ef002-168e-4a71-aa55-33e27f9bc533")!
    static let dcInput = UUID(uuidString: "d85ef003-168e-4a71-aa55-33e27f9bc533")!
    static let handleTemp = UUID(uuidString: "d85ef004-168e-4a71-aa55-33e27f9bc533")!
    static let powerLevel = UUID(uuidString: "d85ef005-168e-4a71-aa55-33e27f9bc533")!
    static let powerSrc = UUID(uuidString: "d85ef006-168e-4a71-aa55-33e27f9bc533")!
    static let tipRes = UUID(uuidString: "d85ef007-168e-4a71-aa55-33e27f9bc533")!
    static let uptime = UUID(uuidString: "d85ef008-168e-4a71-aa55-33e27f9bc533")!
    static let movement = UUID(uuidString: "d85ef009-168e-4a71-aa55-33e27f9bc533")!
    static let maxTemp = UUID(uuidString: "d85ef00a-168e-4a71-aa55-33e27f9bc533")!
    static let rawTip = UUID(uuidString: "d85ef00b-168e-4a71-aa55-33e27f9bc533")!
    static let hallSensor = UUID(uuidString: "d85ef00c-168e-4a71-aa55-33e27f9bc533")!
    static let opMode = UUID(uuidString: "d85ef00d-168e-4a71-aa55-33e27f9bc533")!
    static let estWatts = UUID(uuidString: "d85ef00e-168e-4a71-aa55-33e27f9bc533")!

    // Bulk Data Characteristics
    static let bulkLiveData = UUID(uuidString: "9eae1001-9d0d-48c5-aa55-33e27f9bc533")!
    static let accelName = UUID(uuidString: "9eae1002-9d0d-48c5-aa55-33e27f9bc533")!
    static let build = UUID(uuidString: "9eae1003-9d0d-48c5-aa55-33e27f9bc533")!
    static let devSN = UUID(uuidString: "9eae1004-9d0d-48c5-aa55-33e27f9bc533")!
    static let devID = UUID(uuidString: "9eae1005-9d0d-48c5-aa55-33e27f9bc533")!

    // Settings Characteristics
    static let setTemperature = UUID(uuidString: "f6d70000-5a10-4eba-aa55-33e27f9bc533")!
    static let sleepTemperature = UUID(uuidString: "f6d70001-5a10-4eba-aa55-33e27f9bc533")!
    static let sleepTimeout = UUID(uuidString: "f6d70002-5a10-4eba-aa55-33e27f9bc533")!
    static let dCInCutoff = UUID(uuidString: "f6d70003-5a10-4eba-aa55-33e27f9bc533")!
    static let minVolCell = UUID(uuidString: "f6d70004-5a10-4eba-aa55-33e27f9bc533")!
    static let qCMaxVoltage = UUID(uuidString: "f6d70005-5a10-4eba-aa55-33e27f9bc533")!
    static let displayRotation = UUID(uuidString: "f6d70006-5a10-4eba-aa55-33e27f9bc533")!
    static let motionSensitivity = UUID(uuidString: "f6d70007-5a10-4eba-aa55-33e27f9bc533")!
    static let animLoop = UUID(uuidString: "f6d70008-5a10-4eba-aa55-33e27f9bc533")!
    static let animSpeed = UUID(uuidString: "f6d70009-5a10-4eba-aa55-33e27f9bc533")!
    static let autoStart = UUID(uuidString: "f6d7000a-5a10-4eba-aa55-33e27f9bc533")!
    static let shutdownTimeout = UUID(uuidString: "f6d7000b-5a10-4eba-aa55-33e27f9bc533")!
    static let cooldownBlink = UUID(uuidString: "f6d7000c-5a10-4eba-aa55-33e27f9bc533")!
    static let advancedIdle = UUID(uuidString: "f6d7000d-5a10-4eba-aa55-33e27f9bc533")!
    static let advancedSoldering = UUID(uuidString: "f6d7000e-5a10-4eba-aa55-33e27f9bc533")!
    static let temperatureUnit = UUID(uuidString: "f6d7000f-5a10-4eba-aa55-33e27f9bc533")!
    static let scrollingSpeed = UUID(uuidString: "f6d70010-5a10-4eba-aa55-33e27f9bc533")!
    static let lockingMode = UUID(uuidString: "f6d70011-5a10-4eba-aa55-33e27f9bc533")!
    static let powerPulsePower = UUID(uuidString: "f6d70012-5a10-4eba-aa55-33e27f9bc533")!
    static let powerPulseWait = UUID(uuidString: "f6d70013-5a10-4eba-aa55-33e27f9bc533")!
    static let powerPulseDuration = UUID(uuidString: "f6d70014-5a10-4eba-aa55-33e27f9bc533")!
    static let voltageCalibration = UUID(uuidString: "f6d70015-5a10-4eba-aa55-33e27f9bc533")!
    static let boostTemperature = UUID(uuidString: "f6d70016-5a10-4eba-aa55-33e27f9bc533")!
    static let calibrationOffset = UUID(uuidString: "f6d70017-5a10-4eba-aa55-33e27f9bc533")!
    static let powerLimit = UUID(uuidString: "f6d70018-5a10-4eba-aa55-33e27f9bc533")!
    static let reverseButtonTempChange = UUID(uuidString: "f6d70019-5a10-4eba-aa55-33e27f9bc533")!
    static let tempChangeLongStep = UUID(uuidString: "f6d7001a-5a10-4eba-aa55-33e27f9bc533")!
    static let tempChangeShortStep = UUID(uuidString: "f6d7001b-5a10-4eba-aa55-33e27f9bc533")!
    static let hallEffectSensitivity = UUID(uuidString: "f6d7001c-5a10-4eba-aa55-33e27f9bc533")!
    static let accelMissingWarningCounter = UUID(uuidString: "f6d7001d-5a10-4eba-aa55-33e27f9bc533")!
    static let pdMissingWarningCounter = UUID(uuidString: "f6d7001e-5a10-4eba-aa55-33e27f9bc533")!
    static let uiLanguage = UUID(uuidString: "f6d7001f-5a10-4eba-aa55-33e27f9bc533")!
    static let pdNegTimeout = UUID(uuidString: "f6d70020-5a10-4eba-aa55-33e27f9bc533")!
    static let colourInversion = UUID(uuidString: "f6d70021-5a10-4eba-aa55-33e27f9bc533")!
    static let brightness = UUID(uuidString: "f6d70022-5a10-4eba-aa55-33e27f9bc533")!
    static let logoTime = UUID(uuidString: "f6d70023-5a10-4eba-aa55-33e27f9bc533")!
    static let calibrateCJC = UUID(uuidString: "f6d70024-5a10-4eba-aa55-33e27f9bc533")!
    static let bleEnabled = UUID(uuidString: "f6d70025-5a10-4eba-aa55-33e27f9bc533")!
    static let pdVpdoEnabled = UUID(uuidString: "f6d70026-5a10-4eba-aa55-33e27f9bc533")!
    static let saveToFlash = UUID(uuidString: "f6d7ffff-5a10-4eba-aa55-33e27f9bc533")!
    static let settingsReset = UUID(uuidString: "f6d7fffe-5a10-4eba-aa55-33e27f9bc533")!
}

struct IronServices {
    static let liveData = CBUUID(string: "d85ef000-168e-4a71-aa55-33e27f9bc533")
    static let settings = CBUUID(string: "f6d80000-5a10-4eba-aa55-33e27f9bc533")
    static let bulk = CBUUID(string: "9eae1000-9d0d-48c5-aa55-33e27f9bc533")
}
