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
                    readonly property var tips: [("1m"), ("5m"), ("10m"), ("15h"), ("30h"), ("1h"), ("从不")]
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
                    slider.value: dccData.model.powerSavingModeLowerBrightnessThreshold
                    ticks: [
                        D.SliderTipItem { text: parent.parent.tips[0]; highlight: parent.parent.slider.value === 0 },
                        D.SliderTipItem { text: parent.parent.tips[1]; highlight: parent.parent.slider.value === 1 },
                        D.SliderTipItem { text: parent.parent.tips[2]; highlight: parent.parent.slider.value === 2 },
                        D.SliderTipItem { text: parent.parent.tips[3]; highlight: parent.parent.slider.value === 3 },
                        D.SliderTipItem { text: parent.parent.tips[4]; highlight: parent.parent.slider.value === 4 },
                        D.SliderTipItem { text: parent.parent.tips[5]; highlight: parent.parent.slider.value === 5 },
                        D.SliderTipItem { text: parent.parent.tips[6]; highlight: parent.parent.slider.value === 6 }
                    ]
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
                    readonly property var tips: [("10m"), ("15m"), ("30m"), ("1h"), ("2h"), ("3h"), ("从不")]
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
                    slider.value: dccData.model.powerSavingModeLowerBrightnessThreshold
                    ticks: [
                        D.SliderTipItem { text: parent.parent.tips[0]; highlight: parent.parent.slider.value === 0 },
                        D.SliderTipItem { text: parent.parent.tips[1]; highlight: parent.parent.slider.value === 1 },
                        D.SliderTipItem { text: parent.parent.tips[2]; highlight: parent.parent.slider.value === 2 },
                        D.SliderTipItem { text: parent.parent.tips[3]; highlight: parent.parent.slider.value === 3 },
                        D.SliderTipItem { text: parent.parent.tips[4]; highlight: parent.parent.slider.value === 4 },
                        D.SliderTipItem { text: parent.parent.tips[5]; highlight: parent.parent.slider.value === 5 },
                        D.SliderTipItem { text: parent.parent.tips[6]; highlight: parent.parent.slider.value === 6 }
                    ]
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
                    readonly property var tips: [("10m"), ("15m"), ("30m"), ("1h"), ("2h"), ("3h"), ("从不")]
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
                    slider.value: dccData.model.powerSavingModeLowerBrightnessThreshold
                    ticks: [
                        D.SliderTipItem { text: parent.parent.tips[0]; highlight: parent.parent.slider.value === 0 },
                        D.SliderTipItem { text: parent.parent.tips[1]; highlight: parent.parent.slider.value === 1 },
                        D.SliderTipItem { text: parent.parent.tips[2]; highlight: parent.parent.slider.value === 2 },
                        D.SliderTipItem { text: parent.parent.tips[3]; highlight: parent.parent.slider.value === 3 },
                        D.SliderTipItem { text: parent.parent.tips[4]; highlight: parent.parent.slider.value === 4 },
                        D.SliderTipItem { text: parent.parent.tips[5]; highlight: parent.parent.slider.value === 5 },
                        D.SliderTipItem { text: parent.parent.tips[6]; highlight: parent.parent.slider.value === 6 }
                    ]
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
            page: D.ComboBox {
                width: 100
                model: [ "待机", "休眠", "关闭显示器", "进入关机界面", "无任何操作" ]
                flat: true
            }
        }
        DccObject {
            name: "pressPowerButton"
            parentName: "powerManage/power/powerButtonGroup"
            displayName: qsTr("按下电源键时")
            weight: 2
            pageType: DccObject.Editor
            page: D.ComboBox {
                width: 100
                model: [ "关机", "待机", "休眠", "关闭显示器", "进入关机界面", "无任何操作" ]
                flat: true
            }
        }
    }
}
