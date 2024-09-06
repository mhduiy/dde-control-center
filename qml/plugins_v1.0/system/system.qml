// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.0
import QtQuick.Controls 2.0

import org.deepin.dtk 1.0 as D

import org.deepin.dcc 1.0

DccObject {
    id: root
    name: "system"
    parentName: "root"
    displayName: qsTr("system")
    icon: "commoninfo"
    weight: 20

    DccObject {
        name: "common"
        parentName: "system"
        displayName: qsTr("Common settings")
        weight: 5
        pageType: DccObject.Item
        page: Label {
            font: DccUtils.copyFont(D.DTK.fontManager.t4, {
                                        "bold": true
                                    })
            text: dccObj.displayName
        }
        onParentItemChanged: {
            if (parentItem) {
                parentItem.topPadding = 10
                parentItem.leftPadding = 10
            }
        }
    }
}
