// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.3

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

DccObject {
    DccObject {
        name: "general"
        parentName: "power"
        displayName: qsTr("通用")
        description: "性能模式切换、节能设置、唤醒设置、关机设置"
        icon: "power"
        weight: 10
        page: DccRightView {
            spacing: 5
        }
        GeneralPage {}
    }
    DccObject {
        name: "onPower"
        parentName: "power"
        displayName: qsTr("电源")
        description: "屏幕和待机管理"
        icon: "power"
        weight: 100
        page: DccRightView {
            spacing: 5
        }
        PowerPage {}
    }
    DccObject {
        name: "onBattery"
        parentName: "power"
        displayName: qsTr("电池")
        description: "屏幕和待机管、低电量管理、电池管理"
        icon: "power"
        weight: 200
        // visible: dccData.model.haveBettary
        page: DccRightView {
            spacing: 5
        }
        BatteryPage {}
    }
}
