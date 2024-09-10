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
        name: "screenAndSuspendTitle"
        parentName: "power/onPower"
        displayName: qsTr("Screen and Suspend")
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
        name: "turnOffTheMonitorAfterGroup"
        parentName: "power/onPower"
        weight: 100
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "turnOffTheMonitorAfter"
            parentName: "power/onPower/turnOffTheMonitorAfterGroup"
            displayName: qsTr("Lock screen after")
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
                        { "text": qsTr("Never"), "value": 0 }
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
        name: "computerSuspendsAfterGroup"
        parentName: "power/onPower"
        weight: 200
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "computerSuspendsAfter"
            parentName: "power/onPower/computerSuspendsAfterGroup"
            displayName: qsTr("Computer suspends after")
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
                        { "text": qsTr("Never"), "value": 0 }
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
        name: "lockScreenAfterGroup"
        parentName: "power/onPower"
        weight: 300
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "lockScreenAfter"
            parentName: "power/onPower/lockScreenAfterGroup"
            displayName: qsTr("Lock screen after")
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
                        { "text": qsTr("Never"), "value": 0 }
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
        parentName: "power/onPower"
        weight: 400
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "whenTheLidIsClosed"
            parentName: "power/onPower/powerButtonGroup"
            displayName: qsTr("When the lid is closed")
            visible: dccData.model.lidPresent
            weight: 1
            pageType: DccObject.Editor
            page: CustomComboBox {
                textRole: "text"
                enableRole: "enable"
                visibleRole: "visible"
                width: 100
                model: dccData.powerLidModel
                currentIndex: model.indexOfKey(dccData.model.linePowerLidClosedAction)

                onCurrentIndexChanged: {
                    dccData.worker.setLinePowerLidClosedAction(model.keyOfIndex(currentIndex))
                }
            }
        }
        DccObject {
            name: "whenThePowerButtonIsPressed"
            parentName: "power/onPower/powerButtonGroup"
            displayName: qsTr("When the power button is pressed")
            weight: 2
            pageType: DccObject.Editor
            page: CustomComboBox {
                textRole: "text"
                enableRole: "enable"
                visibleRole: "visible"
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
