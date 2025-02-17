// SPDX-FileCopyrightText: 2023 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "screensaverprovider.h"
#include "operation/model/wallpapermodel.h"
#include "operation/personalizationdbusproxy.h"
#include "utils.hpp"
#include <qsize.h>

#include <QThread>
#include <QSet>
#include <QScreen>
#include <QImageReader>
#include <QPainter>

ScreensaverWorker::ScreensaverWorker(PersonalizationDBusProxy *proxy, QObject *parent)
    : QObject(parent)
    , m_proxy(proxy)
{
    
}

void ScreensaverWorker::terminate()
{
    running = false;
}

void ScreensaverWorker::list()
{
    running = true;
    QStringList saverNameList = m_proxy->getAllscreensaver();
    QStringList configurable = m_proxy->ConfigurableItems();

    // Supports parameter setting for multiple screensavers

    int deepin = 0;
    for (const QString &name : saverNameList) {
        // The screensaver with the parameter configuration is placed first
        if (name.startsWith("deepin")) {
            saverNameList.move(saverNameList.indexOf(name), deepin);
            deepin++;
        }
    }

    if (!running)
        return;

    QList<WallpaperItemPtr> items;
    QMap<QString, QString> imgs;

    for (const QString &name : saverNameList) {
        // remove
        if ("flurry" == name)
            continue;

        if (!running)
            return;

        auto temp = WallpaperItemPtr(new WallpaperItem);
        items.append(temp);

        QString coverPath = m_proxy->GetScreenSaverCover(name);
        temp->url = name;
        temp->configurable = configurable.contains(name);
        temp->deleteAble = false;
        temp->picPath = coverPath;
        temp->thumbnail = generateThumbnail(coverPath, QSize(THUMBNAIL_ICON_WIDTH, THUMBNAIL_ICON_HEIGHT));

        imgs.insert(name, coverPath);
    }

    emit pushScreensaver(items);
    running = false;
}

void ScreensaverProvider::setScreensaver(const QList<WallpaperItemPtr> &items)
{
    qDebug() << "get screensaver list" << items.size() << "current thread" << QThread::currentThread() << "main:" << qApp->thread();
    m_model->getScreenSaverModel()->resetData(items);
    // screensaverMtx.unlock();
}

void ScreensaverProvider::setThumbnail(const QString &item, const QPixmap &pix)
{
    // auto it = std::find_if(screensavers.begin(), screensavers.end(), [item](const ItemNodePtr &node){
    //     return node->item == item;
    // });

    // if (it == screensavers.end())
    //     return;
    // (*it)->pixmap = pix;

    // emit imageChanged(item);
}

ScreensaverProvider::ScreensaverProvider(PersonalizationDBusProxy *proxy, PersonalizationModel *model, QObject *parent)
    : QObject(parent)
    , m_proxy(proxy)
    , m_model(model)
{
    workThread = new QThread(this);
    worker = new ScreensaverWorker(proxy);
    worker->moveToThread(workThread);
    workThread->start();

    const static QStringList picScreenSaverModes { "default" };
    QList<WallpaperItemPtr> items;

    for (const auto picMode : picScreenSaverModes) {
        auto temp = WallpaperItemPtr(new WallpaperItem);
        items.append(temp);
        temp->url = picMode;
        temp->deleteAble = false;
        temp->thumbnail = "screensaver";
    }

    m_model->getPicScreenSaverModel()->resetData(items);

    connect(worker, &ScreensaverWorker::pushScreensaver, this, &ScreensaverProvider::setScreensaver, Qt::DirectConnection);
    // connect(worker, &ScreensaverWorker::pushThumbnail, this, &ScreensaverProvider::setThumbnail, Qt::QueuedConnection);
}

ScreensaverProvider::~ScreensaverProvider()
{
    worker->terminate();
    workThread->quit();
    workThread->wait(1000);

    if (workThread->isRunning())
        workThread->terminate();

    delete worker;
    worker = nullptr;
}

void ScreensaverProvider::fecthData()
{
    // get picture
    // if (screensaverMtx.tryLock(1)) {
    qWarning() << "**********";
    QMetaObject::invokeMethod(worker, "list", Qt::QueuedConnection);
    // } else {
    //     qWarning() << "screensaver is locked...";
    // }
}

int ScreensaverProvider::getCurrentIdle()
{
    // return screensaverIfs->linePowerScreenSaverTimeout();
}

void ScreensaverProvider::setCurrentIdle(int sec)
{
    // screensaverIfs->setLinePowerScreenSaverTimeout(sec);
    // screensaverIfs->setBatteryScreenSaverTimeout(sec);
}

bool ScreensaverProvider::getIsLock()
{
    // return screensaverIfs->lockScreenAtAwake();
}

void ScreensaverProvider::setIsLock(bool l)
{
    // screensaverIfs->setLockScreenAtAwake(l);
}

QString ScreensaverProvider::current()
{
    // return screensaverIfs->currentScreenSaver();
}

void ScreensaverProvider::setCurrent(const QString &name)
{
    // qInfo() << "set current screensaver" << name;
    // if (name.isEmpty())
    //     return;

    // screensaverIfs->setCurrentScreenSaver(name);
}

void ScreensaverProvider::configure(const QString &name)
{
    // qInfo() << "configure screensaver" << name;
    // if (name.isEmpty())
    //     return;

    // screensaverIfs->StartCustomConfig(name);
}

void ScreensaverProvider::startPreview(const QString &name)
{
    // qDebug() << "preview screensaver" << name;
    // screensaverIfs->Preview(name, 1);
}

void ScreensaverProvider::stopPreview()
{
    // qDebug() << "stop preview screensaver";
    // screensaverIfs->Stop();
}

bool ScreensaverProvider::waitScreensaver(int ms) const
{
    // bool ret = screensaverMtx.tryLock(ms);
    // if (ret)
    //     screensaverMtx.unlock();
    // return ret;
}
