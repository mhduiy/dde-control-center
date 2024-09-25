// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

DccObject {
    DccObject {
        name: "fontSize"
        parentName: "personalization/font"
        displayName: qsTr("字号")
        hasBackground: true
        weight: 20
        pageType: DccObject.Item
        page: ColumnLayout {
            Layout.fillHeight: true
            Label {
                Layout.topMargin: 10
                font: D.DTK.fontManager.t7
                text: dccObj.displayName
                Layout.leftMargin: 10
            }
            D.TipsSlider {
                id: scrollSlider
                readonly property var tips: [("11"), ("12"), ("13"), ("14"), ("15"), ("16"), ("18"), ("20")]
                Layout.preferredHeight: 90
                Layout.alignment: Qt.AlignCenter
                Layout.margins: 10
                Layout.fillWidth: true
                tickDirection: D.TipsSlider.TickDirection.Back
                slider.handleType: Slider.HandleType.ArrowBottom
                slider.value: dccData.model.fontSizeModel.size
                slider.from: 0
                slider.to: ticks.length -1
                slider.live: true
                slider.stepSize: 1
                slider.snapMode: Slider.SnapAlways
                ticks: [
                    D.SliderTipItem {
                        text: scrollSlider.tips[0]
                        highlight: scrollSlider.slider.value === 11
                    },
                    D.SliderTipItem {
                        text: scrollSlider.tips[1]
                        highlight: scrollSlider.slider.value === 12
                    },
                    D.SliderTipItem {
                        text: scrollSlider.tips[2]
                        highlight: scrollSlider.slider.value === 13
                    },
                    D.SliderTipItem {
                        text: scrollSlider.tips[3]
                        highlight: scrollSlider.slider.value === 14
                    },
                    D.SliderTipItem {
                        text: scrollSlider.tips[4]
                        highlight: scrollSlider.slider.value === 15
                    },
                    D.SliderTipItem {
                        text: scrollSlider.tips[5]
                        highlight: scrollSlider.slider.value === 16
                    },
                    D.SliderTipItem {
                        text: scrollSlider.tips[6]
                        highlight: scrollSlider.slider.value === 18
                    },
                    D.SliderTipItem {
                        text: scrollSlider.tips[7]
                        highlight: scrollSlider.slider.value === 20
                    }
                ]
                slider.onValueChanged: {
                    console.warn("---------", slider.value)
                    dccData.worker.setFontSize(slider.value)
                }
            }
        }
    }

    DccObject {
        name: "scrollBar"
        parentName: "personalization/font"
        displayName: qsTr("标准字体")
        weight: 100
        hasBackground: true
        pageType: DccObject.Editor
        page: FontCombobox {
            flat: true
            model: dccData.model.standardFontModel.fontList
            textRole: "Name"
            fontRole: textRole
            valueRole: "Id"
            currentIndex: indexOfValue(dccData.model.standardFontModel.fontName)
            onCurrentIndexChanged: {
                dccData.worker.setDefault(model[currentIndex]);
            }

            function indexOfValue(value) {
                for (var i = 0; i < model.length; i++) {
                    if (model[i][valueRole] === value) {
                        return i
                    }
                }
                return -1
            }
        }
    }

    DccObject {
        name: "scrollBar"
        parentName: "personalization/font"
        displayName: qsTr("等宽字体")
        weight: 200
        hasBackground: true
        pageType: DccObject.Editor
        page: FontCombobox {
            flat: true
            model: dccData.model.monoFontModel.fontList
            textRole: "Name"
            fontRole: textRole
            valueRole: "Id"
            currentIndex: indexOfValue(dccData.model.monoFontModel.fontName)
            onCurrentIndexChanged: {
                dccData.worker.setDefault(model[currentIndex]);
            }

            function indexOfValue(value) {
                for (var i = 0; i < model.length; i++) {
                    if (model[i][valueRole] === value) {
                        return i
                    }
                }
                return -1
            }
        }
    }
}
