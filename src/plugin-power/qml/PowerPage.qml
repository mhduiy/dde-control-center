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
        name: "screenAndStandbyMode"
        parentName: "powerManage/power"
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
        name: "turnOffMonitorGroup"
        parentName: "powerManage/power"
        weight: 100
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "turnOffMonitor"
            parentName: "powerManage/power/turnOffMonitorGroup"
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
                    slider.to: dataMap.length - 1
                    slider.live: true
                    slider.stepSize: 1
                    slider.snapMode: Slider.SnapAlways
                    slider.value: dccData.indexByValueOnMap(dataMap, dccData.model.screenBlackDelayOnPower)
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
                        dccData.worker.setScreenBlackDelayOnPower(dataMap[slider.value].value)
                    }
                }
            }
        }
    }

    DccObject {
        name: "enterStandbyGroup"
        parentName: "powerManage/power"
        weight: 200
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "saveModeReduceBrightness"
            parentName: "powerManage/power/enterStandbyGroup"
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
                    slider.to: dataMap.length - 1
                    slider.live: true
                    slider.stepSize: 1
                    slider.snapMode: Slider.SnapAlways
                    slider.value: dccData.indexByValueOnMap(dataMap, dccData.model.sleepDelayOnPower)
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
                        dccData.worker.setSleepDelayOnPower(dataMap[slider.value].value)
                    }
                }
            }
        }
    }

    DccObject {
        name: "autoLockGroup"
        parentName: "powerManage/power"
        weight: 300
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "saveModeReduceBrightness"
            parentName: "powerManage/power/autoLockGroup"
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
                    slider.to: dataMap.length - 1
                    slider.live: true
                    slider.stepSize: 1
                    slider.snapMode: Slider.SnapAlways
                    slider.value: dccData.indexByValueOnMap(dataMap, dccData.model.powerLockScreenDelay)
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
                        dccData.worker.setLockScreenDelayOnPower(dataMap[slider.value].value)
                    }
                }
            }
        }
    }

    DccObject {
        name: "powerButtonGroup"
        parentName: "powerManage/power"
        weight: 400
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "closeTheLid"
            parentName: "powerManage/power/powerButtonGroup"
            displayName: qsTr("合盖时")
            weight: 1
            pageType: DccObject.Editor
            page: CustomComboBox {
                textRole: "text"
                valueRole: "value"
                visibleRole: "visible"
                enableRole: "enable"
                width: 100
                model: dccData.powerLidModel
                currentIndex: model.indexOfKey(dccData.model.linePowerLidClosedAction)

                onCurrentIndexChanged: {
                    dccData.worker.setLinePowerLidClosedAction(model.keyOfIndex(currentIndex))
                }
            }
        }
        DccObject {
            name: "pressPowerButton"
            parentName: "powerManage/power/powerButtonGroup"
            displayName: qsTr("按下电源键时")
            weight: 2
            pageType: DccObject.Editor
            page: CustomComboBox {
                textRole: "text"
                enableRole: "enable"
                width: 100
                model: dccData.powerPressModel
                currentIndex: model.indexOfKey(dccData.model.linePowerPressPowerBtnAction)

                onCurrentIndexChanged: {
                    dccData.worker.setLinePowerPressPowerBtnAction(model.keyOfIndex(currentIndex))
                }
            }
        }
    }
}
