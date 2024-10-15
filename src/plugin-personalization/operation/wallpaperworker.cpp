// SPDX-FileCopyrightText: 2023 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "wallpaperworker.h"
#include "operation/personalizationdbusproxy.h"
#include "operation/personalizationworker.h"
#include <qlogging.h>
#include <qtypes.h>

#include <QThread>
#include <QScreen>
#include <QImageReader>
#include <QPainter>
#include <QJsonDocument>
#include <QJsonArray>
#include <QImage>

static inline QString covertUrlToLocalPath(const QString &url)
{
    if (url.startsWith("/"))
        return url;
    else
        return QUrl(QUrl::fromPercentEncoding(url.toUtf8())).toLocalFile();
}

WallpaperWorker::WallpaperWorker(PersonalizationDBusProxy *PersonalizationDBusProxy, WallpaperModel *wallPaperModel, QObject *parent) : QObject(parent)
{
    m_workThread = new QThread(this);

    m_personalizationProxy = PersonalizationDBusProxy;
    m_worker = new InterfaceWorker(PersonalizationDBusProxy);
    m_model = wallPaperModel;
    m_worker->moveToThread(m_workThread);
    m_workThread->start();

    // DirectConnection to set datas
    connect(m_worker, &InterfaceWorker::pushBackground, this, &WallpaperWorker::setWallpaper, Qt::DirectConnection);

    //queue
    connect(m_worker, &InterfaceWorker::pushThumbnail, this, &WallpaperWorker::setThumbnail, Qt::QueuedConnection);
    connect(m_worker, &InterfaceWorker::pushBackgroundStat, this, &WallpaperWorker::updateWallpaper, Qt::QueuedConnection);

    // listen to wallpaper signals
    connect(m_personalizationProxy, &PersonalizationDBusProxy::Changed, this, &WallpaperWorker::onAppearanceChanged);
}

WallpaperWorker::~WallpaperWorker()
{
    m_worker->terminate();
    m_workThread->quit();
    m_workThread->wait(1000);

    if (m_workThread->isRunning()) {
        m_workThread->terminate();
    }

    delete m_worker;
    m_worker = nullptr;
}

void WallpaperWorker::fecthData()
{
    // get picture
    if (m_wallpaperMtx.tryLock(1)) {
        fecthing = true;
        QMetaObject::invokeMethod(m_worker, "onListBackground", Qt::QueuedConnection);
    } else {
        qWarning() << "wallpaper is locked...";
    }
}

bool WallpaperWorker::waitWallpaper(int ms) const
{
    bool ret = m_wallpaperMtx.tryLock(ms);
    if (ret)
        m_wallpaperMtx.unlock();
    return ret;
}

QList<ItemNodePtr> WallpaperWorker::pictures() const
{
    QList<ItemNodePtr> list;
    for (const ItemNodePtr & ptr : m_wallpaper) {
        if (!isColor(ptr->item))
            list.append(ptr);
    }
    return list;
}

QList<ItemNodePtr> WallpaperWorker::colors() const
{
    QList<ItemNodePtr> list;
    for (const ItemNodePtr & ptr : m_wallpaper) {
        if (isColor(ptr->item))
            list.append(ptr);
    }
    return list;
}

bool WallpaperWorker::isColor(const QString &path)
{
    // these dirs save solid color wallpapers.
    return path.startsWith("/usr/share/wallpapers/custom-solidwallpapers")
            || path.startsWith("/usr/share/wallpapers/deepin-solidwallpapers");
}

QString WallpaperWorker::getSlideshow(const QString &screen)
{
    // TODO delete
    if (screen.isEmpty())
        return QString();

    QList<QVariant> argumentList;
    argumentList << QVariant::fromValue(screen);

    

    // com::deepin::daemon::Appearance do not export GetWallpaperSlideShow.
    // QString wallpaperSlideShow = QDBusPendingReply<QString>(appearanceIfs->asyncCallWithArgumentList(
    //                                                             QStringLiteral("GetWallpaperSlideShow"), argumentList));

    // qDebug() << "Appearance GetWallpaperSlideShow : " << wallpaperSlideShow;
    // return wallpaperSlideShow;
    return {};
}

void WallpaperWorker::setSlideshow(const QString &screen, const QString &value)
{
    // TODO delete
    qInfo() << "set wallpaper slideshow" << screen << value;
    if (screen.isEmpty())
        return;

    QList<QVariant> argumentList;
    argumentList << QVariant::fromValue(screen) << QVariant::fromValue(value);
    // appearanceIfs->asyncCallWithArgumentList(QStringLiteral("SetWallpaperSlideShow"), argumentList);
}

void WallpaperWorker::setBackgroundForMonitor(const QString &screenName, const QString &path)
{
    // TODO delete
    qInfo() << "Appearance SetMonitorBackground " << screenName << path;
    if (screenName.isEmpty() || path.isEmpty())
        return;

    QList<QVariant> argumentList;
    argumentList << QVariant::fromValue(screenName) << QVariant::fromValue(path);
    // auto reply = appearanceIfs->asyncCallWithArgumentList(QStringLiteral("SetMonitorBackground"), argumentList);
    // reply.waitForFinished();
    // qDebug() << "Appearance SetMonitorBackground end" << !reply.isError();
}

QString WallpaperWorker::getBackgroundForMonitor(const QString &screenName)
{
    // TODO delete
    QString ret;
    if (screenName.isEmpty())
        return ret;

    // ret = wmInter->GetCurrentWorkspaceBackgroundForMonitor(screenName);
    return covertUrlToLocalPath(ret);
}

bool WallpaperWorker::deleteBackground(const ItemNodePtr &ptr)
{
    // TODO delete
    if (!ptr)
        return false;

    qInfo() << "try to delete wallpaper" << ptr->item;

    // auto reply = appearanceIfs->Delete("background", ptr->item);
    // reply.waitForFinished();
    // if (reply.isError()) {
    //     qWarning() << "can not delete " << ptr->item;
    //     return false;
    // }

    qDebug() << "wallpaper is deleted";
    m_wallpaperMap.remove(ptr->item);
    m_wallpaper.removeOne(ptr);
    return true;
}

void WallpaperWorker::setBackgroundToGreeter(const QString &path)
{
    // TODO delete
    qInfo() << "Appearance set greeterbackground " << path;
    // appearanceIfs->Set("greeterbackground", path);
}

void WallpaperWorker::updateBackgroundStat()
{
    // TODO delete
    QMetaObject::invokeMethod(m_worker, "onUpdateStat", Qt::QueuedConnection);
}

void WallpaperWorker::onAppearanceChanged(const QString &key, const QString &value)
{
    if (fecthing)// 
        return;

    if (QStringLiteral("background") == key) {
        updateBackgroundStat();
        emit currentWallaperChanged();
    } else if (QStringLiteral("background-add") == key) {
        // find new
        QStringList list = value.split(';');
        for (QString it : list) {
            it = covertUrlToLocalPath(it);
            if (it.isEmpty())
                continue;
            if (m_wallpaperMap.contains(it))
                emit wallpaperActived(it);
            else
                addNewItem(it);
        }
    } else if (QStringLiteral("background-delete") == key) {
        QStringList list = value.split(';');
        for (QString it : list) {
            it = covertUrlToLocalPath(it);
            if (it.isEmpty() || !m_wallpaperMap.contains(it))
                continue;

            removeItem(it);
        }
    }
}

void WallpaperWorker::addNewItem(const QString &path)
{
    qInfo() << "add new wallpaper" << path;
    auto it = createItem(path, false);
    if (it.isNull())
        return;

    m_wallpaper.prepend(it);
    m_wallpaperMap.insert(path, it);

    updateItem(path);

    emit wallpaperAdded(it);
}

void WallpaperWorker::removeItem(const QString &path)
{
    qInfo() << "wallpaper was deleted" << path;
    auto it = m_wallpaperMap.value(path);

    m_wallpaperMap.remove(path);
    m_wallpaper.removeOne(it);

    emit wallpaperRemoved(path);
}

void WallpaperWorker::updateItem(const QString &path)
{
    auto it = m_wallpaperMap.value(path);
    if (!it.isNull()) {
        // const qreal ratio = qApp->primaryScreen()->devicePixelRatio();
        const qreal ratio = 1.0; // TODO
        const QSize size; // TODO
        bool pic;
        QVariant val;
        if (InterfaceWorker::generateThumbnail(path, size, pic, val)) {
            if (pic) {
                auto pix = val.value<QPixmap>();
                pix.setDevicePixelRatio(ratio);
                it->pixmap = pix;
            } else {
                it->color = val.value<QColor>();
            }
        }
    }
}

void WallpaperWorker::setWallpaper(const QList<ItemNodePtr> &items)
{
    qDebug() << "get wallpaper list" << items.size() << "current thread" << QThread::currentThread() << "main:" << qApp->thread();
    m_wallpaper = items;
    m_wallpaperMap.clear();
    for(auto it : items) {
        m_wallpaperMap.insert(it->item, it);
    }

    m_wallpaperMtx.unlock();
    fecthing = false;

    

    m_model->resetData(m_wallpaper);
}

void WallpaperWorker::updateWallpaper(const QMap<QString, bool> &stat)
{
    qDebug() << "update background stat" << stat.size();
    for (auto it = stat.begin(); it != stat.end(); ++it) {
        if (auto ptr = m_wallpaperMap.value(it.key()))
            ptr->deletable = it.value();
    }
}

void WallpaperWorker::setThumbnail(const QString &item, bool pic, const QVariant &val)
{
    auto node = m_wallpaperMap.value(item);
    if (node.isNull())
        return;

    if (pic)
        node->pixmap = val.value<QPixmap>();
    else
        node->color = val.value<QColor>();

    emit imageChanged(item);
}

ItemNodePtr WallpaperWorker::createItem(const QString &id, bool del)
{
    ItemNodePtr ret;
    if (id.isEmpty())
        return ret;

    ret = ItemNodePtr(new ItemNode{id, QPixmap(), QColor("#777777"), true, del});
    return ret;
}

QList<ItemNodePtr> InterfaceWorker::processListReply(const QString &reply)
{
    QList<ItemNodePtr> result;
    QJsonDocument doc = QJsonDocument::fromJson(reply.toUtf8());
    if (doc.isArray()) {
        QJsonArray arr = doc.array();
        foreach (QJsonValue val, arr) {

            if (!m_running)
                return result;

            QJsonObject obj = val.toObject();
            QString id = obj["Id"].toString(); //url
            // id = covertUrlToLocalPath(id);
            if (auto ptr = WallpaperWorker::createItem(id, obj["Deletable"].toBool()))
                result.append(ptr);
        }
    }

    return result;
}

InterfaceWorker::InterfaceWorker(PersonalizationDBusProxy *proxy, QObject *parent)
    : QObject(parent)
    , m_proxy(proxy)
{

}

void InterfaceWorker::terminate()
{
    m_running = false;
}

bool InterfaceWorker::generateThumbnail(const QString &path, const QSize &size, bool &pic, QVariant &val)
{
    bool ret = true;

    QImage image(path);
    if (WallpaperWorker::isColor(path)) {
        pic = false;
        if (image.sizeInBytes() > 0)
            val = QVariant::fromValue(image.pixelColor(0, 0));
        else
            ret = false;
    } else {
        QPixmap pix = QPixmap::fromImage(image.scaled(size, Qt::KeepAspectRatioByExpanding, Qt::SmoothTransformation));
        const QRect r(QPoint(0, 0), size);

        if (pix.width() > size.width() || pix.height() > size.height())
            pix = pix.copy(QRect(pix.rect().center() - r.center(), size));

        pic = true;
        val = QVariant::fromValue(pix);
    }

    return ret;
}

void InterfaceWorker::onListBackground()
{
    m_running = true;

    QList<ItemNodePtr> result = processListReply(m_proxy->List("background"));
    if (m_running) {
        emit pushBackground(result);

        QStringList paths;
        for (const ItemNodePtr &it : result)
            paths.append(it->item);
    }

    m_running = false;
}

void InterfaceWorker::onUpdateStat()
{
    // qDebug() << "update background stat";
    // QDBusPendingCall call = appearanceIfs->List("background");
    // call.waitForFinished();

    // if (call.isError()) {
    //     qWarning() << "failed to get all background stat: " << call.error().message();
    // } else {
    //     QDBusReply<QString> reply = call.reply();
    //     QString value = reply.value();
    //     QJsonDocument doc = QJsonDocument::fromJson(value.toUtf8());
    //     if (doc.isArray()) {
    //         QJsonArray arr = doc.array();
    //         QMap<QString, bool> del;
    //         foreach (QJsonValue val, arr) {
    //             QJsonObject obj = val.toObject();
    //             QString id = obj["Id"].toString(); //url
    //             id = covertUrlToLocalPath(id);
    //             del.insert(id, obj["Deletable"].toBool());
    //         }

    //         emit pushBackgroundStat(del);
    //     }
    // }
}
