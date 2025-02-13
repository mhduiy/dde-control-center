// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

DccObject {
    DccTitleObject {
        name: "wallpaperTitle"
        weight: 10
        parentName: "personalization/wallpaper"
        displayName: qsTr("wallpaper")
    }


    DccObject {
        parentName: "personalization/wallpaper"
        weight: 50
        pageType: DccObject.Item
        page: ScreenTab {
            id: screemTab
            model: dccData.model.screens
            screen: dccData.model.currentSelectScreen
            onScreenChanged: {
                if (screen !== dccData.model.currentSelectScreen) {
                    dccData.model.currentSelectScreen = screen
                    if (true) {
                        indicator.createObject(this, {
                                                "screen": getQtScreen(screemTab.screen)
                                            }).show()
                    }
                }
            }

            Component {
                id: indicator
                ScreenIndicator {}
            }

            function getQtScreen(screen) {
                for (var s of Qt.application.screens) {
                    if (s.virtualX === screen.x && s.virtualY === screen.y && s.width === screen.currentResolution.width && s.height === screen.currentResolution.height) {
                        return s
                    }
                }
                return null
            }
        }
    }

    DccObject {
        name: "wallpaperStatusGroup"
        parentName: "personalization/wallpaper"
        weight: 100
        pageType: DccObject.Item
        page: DccRowView { }
    }

    DccObject {
        name: "wallpaparDisplayArea"
        parentName: "personalization/wallpaper/wallpaperStatusGroup"
        weight: 200
        pageType: DccObject.Item
        page: RowLayout {
            Item {
                implicitWidth: 197
                implicitHeight: 110

                Image {
                    id: image
                    anchors.fill: parent
                    source: dccData.model.wallpaperMap[dccData.model.currentSelectScreen]
                    mipmap: true
                    visible: false
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    retainWhileLoading: true
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
        name: "wallpaperSetGroup"
        parentName: "personalization/wallpaper/wallpaperStatusGroup"
        weight: 300
        pageType: DccObject.Item
        page: DccGroupView { isGroup: false }

        DccObject {
            name: "wallpaperSetItemGroup"
            parentName: "personalization/wallpaper/wallpaperStatusGroup/wallpaperSetGroup"
            displayName: qsTr("Window rounded corners")
            weight: 10
            pageType: DccObject.Item
            page: DccGroupView { }

            DccObject {
                name: "whenTheLidIsClosed"
                parentName: "personalization/wallpaper/wallpaperStatusGroup/wallpaperSetGroup/wallpaperSetItemGroup"
                displayName: {
                    let cutUrl = dccData.model.wallpaperMap[dccData.model.currentSelectScreen]
                    if (dccData.model.customWallpaperModel.hasWallpaper(cutUrl)) {
                        return qsTr("我的图片")
                    } else if (dccData.model.sysWallpaperModel.hasWallpaper(cutUrl)) {
                        return qsTr("系统壁纸")
                    } else if (dccData.model.solidWallpaperModel.hasWallpaper(cutUrl)) {
                        return qsTr("纯色壁纸")
                    } else {
                        return qsTr("自定义壁纸")
                    }
                }
                pageType: DccObject.Editor
                weight: 10
            }
            DccObject {
                name: "whenTheLidIsClosed"
                parentName: "personalization/wallpaper/wallpaperStatusGroup/wallpaperSetGroup/wallpaperSetItemGroup"
                displayName: qsTr("填充方式")
                visible: false
                weight: 100
                pageType: DccObject.Editor
                page: D.ComboBox {
                    width: 100
                    flat: true
                    model: ["适应"]
                }
            }
            DccObject {
                name: "whenTheLidIsClosed"
                parentName: "personalization/wallpaper/wallpaperStatusGroup/wallpaperSetGroup/wallpaperSetItemGroup"
                displayName: qsTr("自动更换壁纸")
                weight: 200
                pageType: DccObject.Editor
                page: CustomComboBox {
                    width: 100
                    flat: true
                    textRole: "text"
                    model: ListModel {
                        ListElement { text: "从不"; value: "" }
                        ListElement { text: "30秒"; value: "30" }
                        ListElement { text: "1分钟"; value: "60" }
                        ListElement { text: "5分钟"; value: "300" }
                        ListElement { text: "10分钟"; value: "600" }
                        ListElement { text: "15分钟"; value: "900" }
                        ListElement { text: "30分钟"; value: "1800" }
                        ListElement { text: "1小时"; value: "3600" }
                        ListElement { text: "登录时"; value: "login" }
                        ListElement { text: "唤醒时"; value: "wakeup" }
                    }
                }
            }
        }
    }

    DccObject {
        name: "screenAndSuspendTitle"
        parentName: "personalization/wallpaper"
        displayName: qsTr("我的图片")
        weight: 400
        backgroundType: DccObject.Normal
        pageType: DccObject.Item
        page: WallpaperSelectView {
            firstItemImgSource: "wallpaper_add"
            model: dccData.model.customWallpaperModel
            currentItem: dccData.model.wallpaperMap[dccData.model.currentSelectScreen]
            onFirstItemClicked: {
                customWallpaperFileDialog.open()
            }
            onWallpaperSelected: (url, isDark, isLock) => {
                                     if (isLock) {
                                         dccData.worker.setLockBackForMonitor(dccData.model.currentSelectScreen, url, isDark)
                                     } else {
                                         dccData.worker.setBackgroundForMonitor(dccData.model.currentSelectScreen, url, isDark)
                                     }
                                 }
            
            onWallpaperDeleteClicked: (url) => {
                dccData.worker.deleteWallpaper(url)
            }

            FileDialog {
                id: customWallpaperFileDialog
                title: "Choose an Image File"
                nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp *.gif *.svg)", "All files (*)"]
                fileMode: FileDialog.OpenFiles
                onSelectedFilesChanged: {
                    dccData.worker.addCutomWallpaper(customWallpaperFileDialog.selectedFiles)
                }
            }
        }
    }

    DccObject {
        name: "screenAndSuspendTitle"
        parentName: "personalization/wallpaper"
        displayName: qsTr("System Wallapers")
        weight: 500
        backgroundType: DccObject.Normal
        pageType: DccObject.Item
        page: WallpaperSelectView {
            model: dccData.model.sysWallpaperModel
            currentItem: dccData.model.wallpaperMap[dccData.model.currentSelectScreen]
            onWallpaperSelected: (url, isDark, isLock) => {
                                     if (isLock) {
                                         dccData.worker.setLockBackForMonitor(dccData.model.currentSelectScreen, url, isDark)
                                     } else {
                                         dccData.worker.setBackgroundForMonitor(dccData.model.currentSelectScreen, url, isDark)
                                     }
                                 }
        }
    }

    DccObject {
        name: "screenAndSuspendTitle"
        parentName: "personalization/wallpaper"
        visible: false
        displayName: qsTr("动态壁纸")
        weight: 600
        backgroundType: DccObject.Normal
        pageType: DccObject.Item
        page: WallpaperSelectView {
            // model: dccData.model.wallpaperModel
        }
    }

    DccObject {
        name: "screenAndSuspendTitle"
        parentName: "personalization/wallpaper"
        displayName: qsTr("纯色壁纸")
        weight: 600
        backgroundType: DccObject.Normal
        pageType: DccObject.Item
        page: WallpaperSelectView {
            firstItemImgSource: "wallpaper_addcolor"
            model: dccData.model.solidWallpaperModel
            currentItem: dccData.model.wallpaperMap[dccData.model.currentSelectScreen]
            onWallpaperSelected: (url, isDark, isLock) => {
                                     if (isLock) {
                                         dccData.worker.setLockBackForMonitor(dccData.model.currentSelectScreen, url, isDark)
                                     } else {
                                         dccData.worker.setBackgroundForMonitor(dccData.model.currentSelectScreen, url, isDark)
                                     }
                                 }
            onFirstItemClicked: {
                colorDialog.open()
            }
            onWallpaperDeleteClicked: (url) => {
                dccData.worker.deleteWallpaper(url)
            }
            DccColorDialog {
                id: colorDialog
                anchors.centerIn: Overlay.overlay
                popupType: Popup.Item
                width: 300
                height: 300
                onAccepted: {
                    dccData.worker.addSolidWallpaper(colorDialog.color)
                }
            }
        }
    }
}
