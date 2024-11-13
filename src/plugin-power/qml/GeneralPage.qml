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
        name: "powerPlansTitle"
        parentName: "power/general"
        displayName: qsTr("Power Plans")
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
        name: "powerPlans"
        parentName: "power/general"
        weight: 100
        pageType: DccObject.Item
        page: PowerPlansListview {
        }
    }

    DccObject {
        name: "powerSavingSettingsTitle"
        parentName: "power/general"
        displayName: qsTr("Power Saving Settings")
        weight: 200
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
        name: "powerSavingSettingsGroup"
        parentName: "power/general"
        weight: 300
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "autoPowerSavingOnLowBattery"
            parentName: "power/general/powerSavingSettingsGroup"
            displayName: qsTr("Auto power saving on low battery")
            weight: 1
            visible: dccData.model.haveBettary
            pageType: DccObject.Editor
            page: D.Switch {
                checked: dccData.model.powerSavingModeAutoWhenQuantifyLow
                onCheckedChanged: {
                    dccData.worker.setPowerSavingModeAutoWhenQuantifyLow(checked)
                }
            }
        }

        DccObject {
            name: "lowPowerThreshold"
            parentName: "power/general/powerSavingSettingsGroup"
            displayName: qsTr("Low battery threshold")
            weight: 2
            visible: dccData.model.haveBettary
            pageType: DccObject.Editor
            page: D.ComboBox {
                width: 100
                model: [ "10%", "20%", "30%", "40%", "50%" ]
                flat: true
                currentIndex: dccData.model.powerSavingModeAutoBatteryPercentage / 10 - 1

                onCurrentIndexChanged: {
                    dccData.worker.setPowerSavingModeAutoBatteryPercentage((currentIndex + 1) * 10)
                }
            }
        }
    }

    DccObject {
        name: "savePowerGroup"
        parentName: "power/general"
        weight: 400
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "autoPowerSavingOnBattery"
            parentName: "power/general/savePowerGroup"
            displayName: qsTr("Auto power saving on battery")
            weight: 1
            visible: dccData.model.haveBettary
            pageType: DccObject.Editor
            page: D.Switch {
                checked: dccData.model.autoPowerSaveMode
                onCheckedChanged: {
                    dccData.worker.setPowerSavingModeAuto(checked)
                }
            }
        }

        DccObject {
            name: "decreaseBrightness"
            parentName: "power/general/savePowerGroup"
            displayName: qsTr("Auto reduce screen brightness during power saving")
            weight: 2
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
                    id: scrollSlider
                    readonly property var tips: [("10%"), ("20%"), ("30%"), ("40%"), ("50%")]
                    Layout.preferredHeight: 80
                    Layout.alignment: Qt.AlignCenter
                    Layout.margins: 10
                    Layout.fillWidth: true
                    slider.handleType: Slider.HandleType.ArrowBottom
                    slider.from: 10
                    slider.to: ticks.length * 10
                    slider.live: true
                    slider.stepSize: 10
                    slider.snapMode: Slider.SnapAlways
                    slider.value: dccData.model.powerSavingModeLowerBrightnessThreshold
                    ticks: [
                        D.SliderTipItem { text: scrollSlider.tips[0]; highlight: scrollSlider.slider.value === 10 },
                        D.SliderTipItem { text: scrollSlider.tips[1]; highlight: scrollSlider.slider.value === 20 },
                        D.SliderTipItem { text: scrollSlider.tips[2]; highlight: scrollSlider.slider.value === 30 },
                        D.SliderTipItem { text: scrollSlider.tips[3]; highlight: scrollSlider.slider.value === 40 },
                        D.SliderTipItem { text: scrollSlider.tips[4]; highlight: scrollSlider.slider.value === 50 }
                    ]

                    slider.onValueChanged: {
                        dccData.worker.setPowerSavingModeLowerBrightnessThreshold(slider.value)
                    }
                }
            }
        }
    }

    DccObject {
        name: "wakeupSettingsTitle"
        parentName: "power/general"
        displayName: qsTr("Wakeup Settings")
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
        name: "wakeupSettingsGroup"
        parentName: "power/general"
        weight: 600
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "passwordIsRequiredToWakeUpTheComputer"
            parentName: "power/general/wakeupSettingsGroup"
            displayName: qsTr("Password is required to wake up the computer")
            weight: 1
            visible: dccData.model.canSuspend && dccData.model.isSuspend
            pageType: DccObject.Editor
            page: D.Switch {
                checked: dccData.model.sleepLock && !dccData.model.isNoPasswdLogin
                enabled: !dccData.model.isNoPasswdLogin
                onCheckedChanged: {
                    dccData.worker.setSleepLock(checked)
                }
            }
        }

        DccObject {
            name: "passwordIsRequiredToWakeUpTheMonitor"
            parentName: "power/general/wakeupSettingsGroup"
            displayName: qsTr("Password is required to wake up the monitor")
            weight: 2
            pageType: DccObject.Editor
            page: D.Switch {
                checked: dccData.model.screenBlackLock && !dccData.model.isNoPasswdLogin
                enabled: !dccData.model.isNoPasswdLogin
                onCheckedChanged: {
                    dccData.worker.setScreenBlackLock(checked)
                }
            }
        }
    }

    DccObject {
        name: "shutdownSettingTitle"
        parentName: "power/general"
        displayName: qsTr("Shutdown Settings")
        weight: 700
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
        name: "shutdownGroup"
        parentName: "power/general"
        weight: 800
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "timedPoweroff"
            parentName: "power/general/shutdownGroup"
            displayName: qsTr("Scheduled Shutdown")
            weight: 1
            pageType: DccObject.Editor
            page: D.Switch {
                checked: dccData.model.scheduledShutdownState
                onCheckedChanged: {
                    dccData.worker.setScheduledShutdownState(checked)
                }
            }
        }

        DccObject {
            name: "poweroffTime"
            parentName: "power/general/shutdownGroup"
            visible: dccData.model.scheduledShutdownState
            displayName: qsTr("Time")
            weight: 2
            pageType: DccObject.Editor
            page: RowLayout {
                DccTimeRange {
                    Layout.preferredWidth: 100
                    hour: dccData.model.shutdownTime.split(':')[0]
                    minute: dccData.model.shutdownTime.split(':')[1]
                    property string timeStr: `${hour}:${minute}`
                    onTimeStrChanged: {
                        console.warn("--timeStr--", timeStr)
                        dccData.worker.setShutdownTime(timeStr)
                    }
                }
            }
        }

        DccObject {
            name: "repeatDays"
            parentName: "power/general/shutdownGroup"
            visible: dccData.model.scheduledShutdownState
            displayName: qsTr("Repeat")
            weight: 3
            pageType: DccObject.Editor
            page: D.ComboBox {
                width: 100
                model: [ qsTr("Once"), qsTr("Every day"), qsTr("Working days"), qsTr("Custom Time") ]
                flat: true
                currentIndex: dccData.model.shutdownRepetition
                onCurrentIndexChanged: {
                    dccData.worker.setShutdownRepetition(currentIndex)
                    if (currentIndex === model.length - 1 && dccData.model.customShutdownWeekDays.length === 0) {
                        repeatDaysEditObject.requestShowSelectDialog()
                    }
                }
            }
        }
        DccObject {
            id: repeatDaysEditObject
            name: "repeatDaysEdit"
            parentName: "power/general/shutdownGroup"
            visible: dccData.model.scheduledShutdownState && dccData.model.shutdownRepetition === 3
            weight: 4
            pageType: DccObject.Editor
            signal requestShowSelectDialog()
            page: RowLayout {
                Connections {
                    target: repeatDaysEditObject
                    function onRequestShowSelectDialog() {
                        selectDayDialog.show()
                    }
                }

                Label {
                    text: {
                        var str = ""
                        var days = dccData.model.customShutdownWeekDays
                        for (var i = 0; i < days.length; i++) {
                            str += selectDayDialog.dateStr[days[i] - 1] + ", "
                        }
                        if (str.length > 1) {
                            str = str.slice(0, -2)
                        }
                        return str;
                    }
                }
                D.ToolButton {
                    icon.name: "action_edit"
                    icon.width: 12
                    icon.height: 12
                    implicitWidth: 24
                    implicitHeight: 24
                    background: Rectangle {
                        color: "transparent"
                        border.color: "transparent"
                        border.width: 0
                    }

                    onClicked: {
                        selectDayDialog.show()
                    }
                }
                D.DialogWindow {
                    id: selectDayDialog
                    width: 330
                    height: 420

                    // Copy is used here to prevent contamination of data in the original model when selecting items
                    property var selectedDays: dccData.model.customShutdownWeekDays.length === 0 ? [1, 2, 3, 4, 5] : dccData.model.customShutdownWeekDays.slice()
                    property var dateStr: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                    property var dayModel: generateDayModel()

                    function generateDayModel() {
                        var array = []
                        let weekBegin = dccData.model.weekBegins
                        if (weekBegin < 1 || weekBegin > 7) {
                            // default is monday
                            weekBegin = 1
                        }
                        for (var i = dccData.model.weekBegins; i <= 7; i++) {
                            array.push(i)
                        }
                        for (i = 1; i < dccData.model.weekBegins; i++) {
                            array.push(i)
                        }
                        return array
                    }

                    // only accept close event , the app can quit normally
                    onClosing: function(close) {
                        close.accepted = true
                    }

                    ColumnLayout {
                        implicitWidth: parent.width
                        clip: true
                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            text: "自定义重复时间"
                        }
                        ListView {
                            Layout.fillWidth: true
                            height: contentHeight
                            clip: true
                            model: selectDayDialog.dayModel
                            spacing: 2
                            delegate: D.ItemDelegate {
                                width: ListView.view.width
                                leftPadding: 10
                                rightPadding: 10
                                implicitHeight: 40
                                checkable: false
                                corners: getCornersForBackground(index, 7)
                                cascadeSelected: true
                                text: selectDayDialog.dateStr[modelData - 1]
                                onClicked: handleSelected(modelData)
                                content: DccCheckIcon {
                                    checked: selectDayDialog.selectedDays.indexOf(modelData) !== -1
                                    onClicked: handleSelected(modelData)
                                }
                                background: DccItemBackground {
                                    separatorVisible: true
                                    highlightEnable: false
                                }

                                function handleSelected(index) {
                                    if (selectDayDialog.selectedDays.indexOf(index) === -1) {
                                        selectDayDialog.selectedDays.push(index);
                                    } else {
                                        selectDayDialog.selectedDays.splice(selectDayDialog.selectedDays.indexOf(index), 1);
                                    }
                                    selectDayDialog.selectedDays = selectDayDialog.selectedDays.slice();
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 10
                            D.Button {
                                text: qsTr("Cancel")
                                onClicked: {
                                    selectDayDialog.close()
                                }
                            }
                            D.Button {
                                text: qsTr("Save")
                                onClicked: {
                                    var days = selectDayDialog.selectedDays.sort()
                                    console.log("Selected days: " + days);
                                    dccData.worker.setCustomShutdownWeekDays(days)
                                    selectDayDialog.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
