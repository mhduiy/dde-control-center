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
        name: "themeGroup"
        parentName: "personalization"
        weight: 10
        pageType: DccObject.Item
        page: DccGroupView {}
        DccObject {
            name: "themeTitle"
            parentName: "personalization/themeGroup"
            displayName: qsTr("主题")
            weight: 1
            pageType: DccObject.Item
            page: ColumnLayout {
                Layout.fillHeight: true
                Layout.margins: 10
                RowLayout {
                    Layout.fillWidth: true
                    // Layout.rightMargin: 10
                    Label {
                        Layout.topMargin: 10
                        font: D.DTK.fontManager.t5
                        text: dccObj.displayName
                        Layout.leftMargin: 10
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    D.IconButton {
                        flat: true
                        enabled: themeSelectView.currentIndex !== 0
                        icon.name: "arrow_ordinary_left"
                        onClicked: {
                            themeSelectView.decrementCurrentIndex()
                        }
                    }
                    D.IconButton {
                        flat: true
                        enabled: themeSelectView.currentIndex !== themeSelectView.count - 1
                        icon.name: "arrow_ordinary_right"
                        onClicked: {
                            themeSelectView.incrementCurrentIndex()
                        }
                    }
                }
                ThemeSelectView {
                    id: themeSelectView
                    Layout.fillWidth: true
                    Layout.preferredHeight: 240
                }
            }
        }
        DccObject {
            name: "appearance"
            parentName: "personalization/themeGroup"
            displayName: qsTr("外观")
            description: qsTr("外观决定了主题显示浅色还是深色，或者自动切换")
            weight: 10
            pageType: DccObject.Editor
            icon: "personalization"
            page: D.ComboBox {
                flat: true
                model: [qsTr("自动"), qsTr("深色"), qsTr("浅色")]
            }
        }
    }

    DccObject {
        name: "wallpaper"
        parentName: "personalization"
        displayName: qsTr("桌面和任务栏")
        description: qsTr("设置桌面上图标的显示以及图标大小等")
        icon: "personalization"
        weight: 21
    }
    DccObject {
        name: "windowEffect"
        parentName: "personalization"
        displayName: qsTr("窗口效果")
        description: qsTr("设置界面效果以及图标大小等")
        icon: "personalization"
        weight: 21
        page: DccRightView {
            spacing: 5
        }
        WindowEffectPage {}
    }
    DccObject {
        name: "screensaver"
        parentName: "personalization"
        displayName: qsTr("壁纸和屏保")
        description: qsTr("个性化您的壁纸与屏保")
        icon: "personalization"
        weight: 31
    }
    DccObject {
        name: "colorAndIcons"
        parentName: "personalization"
        displayName: qsTr("颜色和图标")
        description: qsTr("调整喜好的活动用色和主题图标")
        icon: "personalization"
        weight: 51
        page: DccRightView {
            spacing: 10
        }
        ColorAndIcons {}
    }
    DccObject {
        name: "font"
        parentName: "personalization"
        displayName: qsTr("字体和字号")
        description: qsTr("修改系统字体与字号")
        icon: "personalization"
        weight: 51
    }
    DccObject {
        name: "lock"
        parentName: "personalization"
        displayName: qsTr("锁屏")
        description: qsTr("锁屏自定义")
        icon: "personalization"
        weight: 51
    }
}
