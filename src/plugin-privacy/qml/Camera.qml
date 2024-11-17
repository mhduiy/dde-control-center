// SPDX-FileCopyrightText: 2024 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

DccObject {
    DccObject {
        name: "cameraAppViewGroup"
        parentName: "privacy/camera"
        weight: 100
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "title"
            weight: 1
            parentName: "privacy/camera/cameraAppViewGroup"
            pageType: DccObject.Editor
            displayName: "允许下面的应用使用您的摄像头"
        }

        DccRepeater {
            model: 18
            delegate: DccObject {
                name: "plugin" + model.itemKey
                property real iconSize: 16
                parentName: "privacy/camera/cameraAppViewGroup"
                weight: 10 + index * 10
                hasBackground: true
                icon: "deepin-app-store"
                displayName: "应用商店"
                pageType: DccObject.Editor
                page: DccCheckIcon {
                }
            }
        }
    }
}