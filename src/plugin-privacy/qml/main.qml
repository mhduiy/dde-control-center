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
        name: "camera"
        parentName: "privacy"
        displayName: qsTr("摄像头")
        description: qsTr("选择应用是否有摄像头的访问权限")
        icon: "window_effect"
        weight: 10
        Camera {}
    }

    DccObject {
        name: "filefolder"
        parentName: "privacy"
        displayName: qsTr("文件和文件夹")
        description: qsTr("选择应用是否有文件和文件夹的访问权限")
        icon: "window_effect"
        weight: 100
        FileAndFolder {}
    }
}
