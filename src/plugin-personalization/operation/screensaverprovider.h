// SPDX-FileCopyrightText: 2025 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QObject>
#include "operation/model/wallpapermodel.h"
#include "personalizationdbusproxy.h"
#include "personalizationmodel.h"

class ScreensaverWorker : public QObject
{
    Q_OBJECT
public:
    explicit ScreensaverWorker(PersonalizationDBusProxy *proxy, QObject *parent = nullptr);
    void terminate();
signals:
    void pushScreensaver(const QList<WallpaperItemPtr> &items);
    void pushThumbnail(const QString &item, const QPixmap &pix);
public slots:
    void list();
    void generateThumbnail(const QMap<QString, QString> &paths);
private:
    PersonalizationDBusProxy *m_proxy = nullptr;
    volatile bool running = false;
};

class ScreensaverProvider : public QObject
{
    Q_OBJECT
public:
    explicit ScreensaverProvider(PersonalizationDBusProxy *proxy, PersonalizationModel *model, QObject *parent = nullptr);
    ~ScreensaverProvider() override;
    void fecthData();
    bool waitScreensaver(int ms) const;
    // inline QList<ItemNodePtr> allScreensaver() {
    //     return screensavers;
    // }
signals:
    void imageChanged(const QString &item);
public slots:
    int getCurrentIdle();
    void setCurrentIdle(int sec);
    bool getIsLock();
    void setIsLock(bool l);
    QString current();
    void setCurrent(const QString &name);
    void configure(const QString &name);
    void startPreview(const QString &name);
    void stopPreview();
private slots:
    void setScreensaver(const QList<WallpaperItemPtr> &items);
    void setThumbnail(const QString &item, const QPixmap &pix);
private:
    QThread *workThread = nullptr;
    ScreensaverWorker *worker = nullptr;
    PersonalizationModel *m_model = nullptr;
    PersonalizationDBusProxy *m_proxy = nullptr;
    // ScreenSaverIfs *screensaverIfs = nullptr;
    // mutable QMutex screensaverMtx;
    // QList<ItemNodePtr> screensavers;
};
