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
        name: "activeColorTitle"
        parentName: "personalization/colorAndIcons"
        displayName: qsTr("活动用色")
        weight: 1
        hasBackground: false
        pageType: DccObject.Item
        page: Label {
            font: DccUtils.copyFont(D.DTK.fontManager.t4, { "bold": true })
            text: dccObj.displayName
        }
    }

    DccObject {
        name: "roundedEffect"
        parentName: "personalization/colorAndIcons"
        weight: 100
        pageType: DccObject.Item
        hasBackground: true
        page: ListView {
            id: listview
            property var colors: ["red", "red", "red", "red", "red", "red", "red", "red", "red", "red", "red"]
            implicitWidth: 300
            implicitHeight: 80
            leftMargin: 10
            clip: true
            model: colors.length
            orientation: ListView.Horizontal
            layoutDirection: Qt.LeftToRight
            spacing: 12

            delegate: Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                color: listview.colors[index]
                radius: width / 2
            }
        }
    }


    DccObject {
        name: "iconSettingsTitle"
        parentName: "personalization/colorAndIcons"
        displayName: qsTr("图标设置")
        weight: 200
        hasBackground: false
        pageType: DccObject.Item
        page: Label {
            font: DccUtils.copyFont(D.DTK.fontManager.t4, { "bold": true })
            text: dccObj.displayName
        }
    }

    DccObject {
        name: "iconTheme"
        parentName: "personalization/colorAndIcons"
        displayName: qsTr("图标主题")
        description: qsTr("自定义您的主题图标")
        icon: "personalization"
        weight: 300
    }
    DccObject {
        name: "cursorTheme"
        parentName: "personalization/colorAndIcons"
        displayName: qsTr("光标主题")
        description: qsTr("自定义您的主题光标")
        icon: "personalization"
        weight: 400
    }
}
