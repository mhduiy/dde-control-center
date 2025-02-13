// SPDX-FileCopyrightText: 2025 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

DccObject {
    DccTitleObject {
        name: "screenSaverTitle"
        weight: 10
        parentName: "personalization/screenSaver"
        displayName: qsTr("屏幕保护")
    }
    DccObject {
        name: "screenSaverStatusGroup"
        parentName: "personalization/screenSaver"
        weight: 100
        pageType: DccObject.Item
        page: DccRowView { }
    }

    DccObject {
        name: "screenSaverDisplayArea"
        parentName: "personalization/screenSaver/screenSaverStatusGroup"
        weight: 200
        pageType: DccObject.Item
        page: RowLayout {
            Item {
                implicitWidth: 197
                implicitHeight: 110

                Image {
                    id: image
                    anchors.fill: parent
                    source: dccData.model.screenSaverModel.getThumbnailByUrl(dccData.model.currentScreenSaver)
                    mipmap: true
                    visible: false
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                OpacityMask {
                    anchors.fill: parent
                    source: image
                    maskSource: Rectangle {
                        implicitWidth: image.width
                        implicitHeight: image.height
                        radius: 6
                    }
                }
            }
        }
    }
    DccObject {
        name: "screenSaverSetGroup"
        parentName: "personalization/screenSaver/screenSaverStatusGroup"
        weight: 300
        pageType: DccObject.Item
        page: DccGroupView { isGroup: false }

        DccObject {
            name: "screenSaverSetItemGroup"
            parentName: "personalization/screenSaver/screenSaverStatusGroup/screenSaverSetGroup"
            weight: 10
            pageType: DccObject.Item
            page: DccGroupView { }

            DccObject {
                name: "whenTheLidIsClosed"
                parentName: "personalization/screenSaver/screenSaverStatusGroup/screenSaverSetGroup/screenSaverSetItemGroup"
                displayName: qsTr("图片轮播屏保")
                weight: 10
                pageType: DccObject.Editor
                page: D.ComboBox {
                    flat: true
                    implicitWidth: 150
                    implicitHeight: 30
                    model: dccData.model.screens
                    onCurrentTextChanged: {
                        dccData.model.currentSelectScreen = currentText
                    }
                }
            }
            DccObject {
                name: "whenTheLidIsClosed1"
                parentName: "personalization/screenSaver/screenSaverStatusGroup/screenSaverSetGroup/screenSaverSetItemGroup"
                displayName: qsTr("闲置时间")
                weight: 100
                pageType: DccObject.Editor
                page: D.ComboBox {
                    width: 100
                    flat: true
                    textRole: "text"
                    model: ListModel {
                        ListElement { text: "1分钟"; value: "" }
                        ListElement { text: "5分钟"; value: "30" }
                        ListElement { text: "10分钟"; value: "60" }
                        ListElement { text: "15分钟"; value: "300" }
                        ListElement { text: "30分钟"; value: "600" }
                        ListElement { text: "1小时"; value: "900" }
                        ListElement { text: "从不"; value: "1800" }
                    }
                }
            }
            DccObject {
                name: "whenTheLidIsClosed2"
                parentName: "personalization/screenSaver/screenSaverStatusGroup/screenSaverSetGroup/screenSaverSetItemGroup"
                displayName: qsTr("恢复时需要密码")
                weight: 200
                pageType: DccObject.Editor
                page: D.Switch {
                }
            }
        }
    }

    DccObject {
        parentName: "personalization/screenSaver"
        displayName: qsTr("系统屏保")
        weight: 400
        backgroundType: DccObject.Normal
        pageType: DccObject.Item
        page: WallpaperSelectView {
            model: dccData.model.screenSaverModel
            currentItem: dccData.model.currentScreenSaver
            onWallpaperSelected: (url, isDark, isLock) => {
                                    // 防止调用两次
                                    if (isLock) {
                                        dccData.worker.setScreenSaver(url)
                                    }
                                 }
        }
    }
}
