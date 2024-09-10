// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

DccObject {
    DccObject {
        name: "screenAndStandbyOnBattery"
        parentName: "powerManage/battery"
        displayName: qsTr("屏幕和待机")
        weight: 10
        hasBackground: false
        pageType: DccObject.Item
        page: ColumnLayout {
            Label {
                Layout.leftMargin: 10
                font: D.DTK.fontManager.t4
                text: dccObj.displayName
            }
        }
    }

    DccObject {
        name: "turnOffMonitorGroupOnBattery"
        parentName: "powerManage/battery"
        weight: 100
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "turnOffMonitorOnBattery"
            parentName: "powerManage/battery/turnOffMonitorGroupOnBattery"
            displayName: qsTr("关闭显示器")
            weight: 1
            pageType: DccObject.Item
            page: ColumnLayout {
                Layout.fillHeight: true
                Label {
                    id: speedText
                    Layout.topMargin: 10
                    font: D.DTK.fontManager.t7
                    text: dccObj.displayName
                    Layout.leftMargin: 10
                }
                D.TipsSlider {
                    readonly property var dataMap: [
                        { "text": "1m", "value": 60 },
                        { "text": "5m", "value": 300 },
                        { "text": "10m", "value": 600 },
                        { "text": "15m", "value": 900 },
                        { "text": "30m", "value": 1800 },
                        { "text": "1h", "value": 3600 },
                        { "text": "从不", "value": 0 }
                    ]
                    Layout.preferredHeight: 80
                    Layout.alignment: Qt.AlignCenter
                    Layout.margins: 10
                    Layout.fillWidth: true
                    slider.handleType: Slider.HandleType.ArrowBottom
                    slider.from: 0
                    slider.to: ticks.length - 1
                    slider.live: true
                    slider.stepSize: 1
                    slider.snapMode: Slider.SnapAlways
                    slider.value: dccData.indexByValueOnMap(dataMap, dccData.model.screenBlackDelayOnBattery)
                    ticks: [
                        D.SliderTipItem { text: parent.parent.dataMap[0].text; highlight: parent.parent.slider.value === 0 },
                        D.SliderTipItem { text: parent.parent.dataMap[1].text; highlight: parent.parent.slider.value === 1 },
                        D.SliderTipItem { text: parent.parent.dataMap[2].text; highlight: parent.parent.slider.value === 2 },
                        D.SliderTipItem { text: parent.parent.dataMap[3].text; highlight: parent.parent.slider.value === 3 },
                        D.SliderTipItem { text: parent.parent.dataMap[4].text; highlight: parent.parent.slider.value === 4 },
                        D.SliderTipItem { text: parent.parent.dataMap[5].text; highlight: parent.parent.slider.value === 5 },
                        D.SliderTipItem { text: parent.parent.dataMap[6].text; highlight: parent.parent.slider.value === 6 }
                    ]

                    slider.onValueChanged: {
                        dccData.worker.setScreenBlackDelayOnBattery(dataMap[slider.value].value)
                    }
                }
            }
        }
    }

    DccObject {
        name: "autoLockGroupOnBattery"
        parentName: "powerManage/battery"
        weight: 200
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "autoLockOnBattery"
            parentName: "powerManage/battery/autoLockGroupOnBattery"
            displayName: qsTr("自动锁屏")
            weight: 1
            pageType: DccObject.Item
            page: ColumnLayout {
                Layout.fillHeight: true
                Label {
                    id: speedText
                    Layout.topMargin: 10
                    font: D.DTK.fontManager.t7
                    text: dccObj.displayName
                    Layout.leftMargin: 10
                }
                D.TipsSlider {
                    readonly property var dataMap: [
                        { "text": "1m", "value": 60 },
                        { "text": "5m", "value": 300 },
                        { "text": "10m", "value": 600 },
                        { "text": "15m", "value": 900 },
                        { "text": "30m", "value": 1800 },
                        { "text": "1h", "value": 3600 },
                        { "text": "从不", "value": 0 }
                    ]
                    Layout.preferredHeight: 80
                    Layout.alignment: Qt.AlignCenter
                    Layout.margins: 10
                    Layout.fillWidth: true
                    slider.handleType: Slider.HandleType.ArrowBottom
                    slider.from: 0
                    slider.to: ticks.length - 1
                    slider.live: true
                    slider.stepSize: 1
                    slider.snapMode: Slider.SnapAlways
                    slider.value: dccData.indexByValueOnMap(dataMap, dccData.model.batteryLockScreenDelay)
                    ticks: [
                        D.SliderTipItem { text: parent.parent.dataMap[0].text; highlight: parent.parent.slider.value === 0 },
                        D.SliderTipItem { text: parent.parent.dataMap[1].text; highlight: parent.parent.slider.value === 1 },
                        D.SliderTipItem { text: parent.parent.dataMap[2].text; highlight: parent.parent.slider.value === 2 },
                        D.SliderTipItem { text: parent.parent.dataMap[3].text; highlight: parent.parent.slider.value === 3 },
                        D.SliderTipItem { text: parent.parent.dataMap[4].text; highlight: parent.parent.slider.value === 4 },
                        D.SliderTipItem { text: parent.parent.dataMap[5].text; highlight: parent.parent.slider.value === 5 },
                        D.SliderTipItem { text: parent.parent.dataMap[6].text; highlight: parent.parent.slider.value === 6 }
                    ]

                    slider.onValueChanged: {
                        dccData.worker.setLockScreenDelayOnBattery(dataMap[slider.value].value)
                    }
                }
            }
        }
    }

    DccObject {
        name: "enterStandbyGroupOnBattry"
        parentName: "powerManage/battery"
        weight: 300
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "enterStandbyOnBattery"
            parentName: "powerManage/battery/enterStandbyGroupOnBattry"
            displayName: qsTr("进入待机")
            weight: 1
            pageType: DccObject.Item
            page: ColumnLayout {
                Layout.fillHeight: true
                Label {
                    id: speedText
                    Layout.topMargin: 10
                    font: D.DTK.fontManager.t7
                    text: dccObj.displayName
                    Layout.leftMargin: 10
                }
                D.TipsSlider {
                    readonly property var dataMap: [
                        { "text": "10m", "value": 600 },
                        { "text": "15m", "value": 900 },
                        { "text": "30m", "value": 1800 },
                        { "text": "1h", "value": 3600 },
                        { "text": "2h", "value": 7200 },
                        { "text": "3h", "value": 10800 },
                        { "text": "从不", "value": 0 }
                    ]
                    Layout.preferredHeight: 80
                    Layout.alignment: Qt.AlignCenter
                    Layout.margins: 10
                    Layout.fillWidth: true
                    slider.handleType: Slider.HandleType.ArrowBottom
                    slider.from: 0
                    slider.to: ticks.length - 1
                    slider.live: true
                    slider.stepSize: 1
                    slider.snapMode: Slider.SnapAlways
                    slider.value: dccData.indexByValueOnMap(dataMap, dccData.model.sleepDelayOnBattery)
                    ticks: [
                        D.SliderTipItem { text: parent.parent.dataMap[0].text; highlight: parent.parent.slider.value === 0 },
                        D.SliderTipItem { text: parent.parent.dataMap[1].text; highlight: parent.parent.slider.value === 1 },
                        D.SliderTipItem { text: parent.parent.dataMap[2].text; highlight: parent.parent.slider.value === 2 },
                        D.SliderTipItem { text: parent.parent.dataMap[3].text; highlight: parent.parent.slider.value === 3 },
                        D.SliderTipItem { text: parent.parent.dataMap[4].text; highlight: parent.parent.slider.value === 4 },
                        D.SliderTipItem { text: parent.parent.dataMap[5].text; highlight: parent.parent.slider.value === 5 },
                        D.SliderTipItem { text: parent.parent.dataMap[6].text; highlight: parent.parent.slider.value === 6 }
                    ]

                    slider.onValueChanged: {
                        dccData.worker.setSleepDelayOnBattery(dataMap[slider.value].value)
                    }
                }
            }
        }
    }

    DccObject {
        name: "powerButtonGroup"
        parentName: "powerManage/battery"
        weight: 400
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "closeTheLid"
            parentName: "powerManage/battery/powerButtonGroup"
            displayName: qsTr("合盖时")
            weight: 1
            pageType: DccObject.Editor
            page: CustomComboBox {
                textRole: "text"
                enableRole: "enable"
                width: 100
                model: dccData.batteryLidModel
                currentIndex: model.indexOfKey(dccData.model.batteryLidClosedAction)

                onCurrentIndexChanged: {
                    dccData.worker.setBatteryLidClosedAction(model.keyOfIndex(currentIndex))
                }
            }
        }
        DccObject {
            name: "pressPowerButton"
            parentName: "powerManage/battery/powerButtonGroup"
            displayName: qsTr("按下电源键时")
            weight: 2
            pageType: DccObject.Editor
            page: CustomComboBox {
                textRole: "text"
                enableRole: "enable"
                width: 100
                model: dccData.batteryPressModel
                currentIndex: model.indexOfKey(dccData.model.batteryPressPowerBtnAction)

                onCurrentIndexChanged: {
                    dccData.worker.setBatteryPressPowerBtnAction(model.keyOfIndex(currentIndex))
                }
            }
        }
    }

    DccObject {
        name: "lowPowerTitle"
        parentName: "powerManage/battery"
        displayName: qsTr("低电量管理")
        weight: 500
        hasBackground: false
        pageType: DccObject.Item
        page: ColumnLayout {
            Label {
                Layout.leftMargin: 10
                font: D.DTK.fontManager.t4
                text: dccObj.displayName
            }
        }
    }

    DccObject {
        name: "lowPowerManageGroup"
        parentName: "powerManage/battery"
        weight: 600
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "lowPowerNotification"
            parentName: "powerManage/battery/lowPowerManageGroup"
            displayName: qsTr("低电量通知")
            weight: 1
            pageType: DccObject.Editor
            page: D.ComboBox {
                width: 100
                textRole: "text"
                flat: true
                currentIndex: dccData.indexByValueOnModel(model, dccData.model.lowPowerNotifyThreshold)
                model: ListModel {
                    ListElement { text: "10%"; value: 10 }
                    ListElement { text: "15%"; value: 15 }
                    ListElement { text: "20%"; value: 20 }
                    ListElement { text: "25%"; value: 25 }
                }

                onCurrentIndexChanged: {
                    var selectedValue = model.get(currentIndex).value;
                    dccData.worker.setLowPowerNotifyThreshold(selectedValue)
                }
            }
        }
    }

    DccObject {
        name: "lowPowerManageGroup2"
        parentName: "powerManage/battery"
        weight: 700
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "lowPowerOperator"
            parentName: "powerManage/battery/lowPowerManageGroup2"
            displayName: qsTr("低电量操作")
            weight: 1
            pageType: DccObject.Editor
            page: D.ComboBox {
                width: 100
                model: [ "自动休眠", "自动待机"]
                flat: true
            }
        }
        DccObject {
            name: "lowBatteryThreshold"
            parentName: "powerManage/battery/lowPowerManageGroup2"
            displayName: qsTr("低电量阈值")
            weight: 2
            pageType: DccObject.Editor
            page: D.ComboBox {
                textRole: "text"
                width: 100
                model: ListModel {
                    ListElement { text: "1%"; value: 1 }
                    ListElement { text: "2%"; value: 2 }
                    ListElement { text: "3%"; value: 3 }
                    ListElement { text: "4%"; value: 4 }
                    ListElement { text: "5%"; value: 5 }
                    ListElement { text: "6%"; value: 6 }
                    ListElement { text: "7%"; value: 7 }
                    ListElement { text: "8%"; value: 8 }
                    ListElement { text: "9%"; value: 9 }
                }
                flat: true
            }
        }
    }

    DccObject {
        name: "batteryManagerTitle"
        parentName: "powerManage/battery"
        displayName: qsTr("电池管理")
        weight: 800
        hasBackground: false
        pageType: DccObject.Item
        page: ColumnLayout {
            Label {
                Layout.leftMargin: 10
                font: D.DTK.fontManager.t4
                text: dccObj.displayName
            }
        }
    }

    DccObject {
        name: "batteryManageGroup"
        parentName: "powerManage/battery"
        weight: 900
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "displayTime"
            parentName: "powerManage/battery/batteryManageGroup"
            displayName: qsTr("显示剩余使用时间及剩余充电时间")
            weight: 1
            pageType: DccObject.Editor
            page: D.Switch {
                checked: dccData.model.showBatteryTimeToFull
                onCheckedChanged: {
                    dccData.worker.setShowBatteryTimeToFull(checked)
                }
            }
        }
        DccObject {
            name: "maximumCapacity"
            parentName: "powerManage/battery/batteryManageGroup"
            displayName: qsTr("最大容量")
            weight: 2
            pageType: DccObject.Editor
            page: Label {
                    Layout.leftMargin: 10
                    text: dccData.model.batteryCapacity
                }

            DccObject {
                name: "optimizeChargingTime"
                parentName: "powerManage/battery/batteryManageGroup"
                displayName: qsTr("优化电池充电")
                weight: 3
                pageType: DccObject.Editor
                page: D.Switch {

                }
            }
            DccObject {
                name: "maximumChargingCapacity"
                parentName: "powerManage/battery/batteryManageGroup"
                displayName: qsTr("最大充电量")
                description: "不常使用电池时, 可以限制电池最大充电量, 减缓电池老化"
                weight: 4
                pageType: DccObject.Editor
                page: D.ComboBox {
                    width: 100
                    model: [ "90%", "85%", "80%" ]
                    flat: true
                }
            }
        }
    }
}
