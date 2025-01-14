#include "privacysecuritymodel.h"
#include "operation/applicationitem.h"
#include <qabstractitemmodel.h>
#include <qabstractproxymodel.h>
#include <qlogging.h>
#include <qrandom.h>
#include <qt5/QtCore/qvariant.h>
#include "privacysecuritydataproxy.h"
#include <QStandardPaths>

AppsModel::AppsModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

QVariant AppsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    switch (role) {
        case NameRole: {
            return m_appItems.at(index.row())->name();
        }
        case IconNameRole: {
            return m_appItems.at(index.row())->icon();
        }
        case CameraRole: {
            return m_appItems.at(index.row())->isPremissionEnabled(PermissionType::CameraPermission);
        }
        case DocumentRole: {
            return m_appItems.at(index.row())->isPremissionEnabled(PermissionType::DocumentFoldersPermission);
        }
        case PictureRole: {
            return m_appItems.at(index.row())->isPremissionEnabled(PermissionType::PictureFoldersPermission);
        }
        case DesktopRole: {
            return m_appItems.at(index.row())->isPremissionEnabled(PermissionType::DesktopFoldersPermission);
        }
        case VideoRole: {
            return m_appItems.at(index.row())->isPremissionEnabled(PermissionType::VideoFoldersPermission);
        }
        case MusicRole: {
            return m_appItems.at(index.row())->isPremissionEnabled(PermissionType::MusicFoldersPermission);
        }
        case DownloadRole: {
            return m_appItems.at(index.row())->isPremissionEnabled(PermissionType::DownloadFoldersPermission);
        }
    }
    return QVariant();
}

QVariant AppsModel::data(const QModelIndex &index, const QString propertyName) const
{
    const auto roleNames = this->roleNames();
    for (auto it = roleNames.cbegin(); it != roleNames.cend(); ++it) {
        if (propertyName == it.value()) {
            return data(index, it.key());
        }
    }
    return QVariant();
}

int AppsModel::rowCount(const QModelIndex &) const
{
    return m_appItems.size();
}

QHash<int, QByteArray> AppsModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames[NameRole] = "name";
    roleNames[IconNameRole] = "iconName";
    roleNames[CameraRole] = "cameraPermission";
    roleNames[DocumentRole] = "documentPermission";
    roleNames[PictureRole] = "picturePermission";
    roleNames[DesktopRole] = "desktopPermission";
    roleNames[VideoRole] = "videoPermission";
    roleNames[MusicRole] = "musicPermission";
    roleNames[DownloadRole] = "downloadPermission";
    return roleNames;
}

void AppsModel::reset(ApplicationItemListPtr appList)
{
    beginResetModel();
    m_appItems =  appList;
    endResetModel();
}

void AppsModel::appendItem(ApplicationItem *appItem)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_appItems.append(appItem);
    endInsertRows();
}

void AppsModel::removeItem(ApplicationItem *appItem)
{
    for (int index = 0; index < m_appItems.size(); index++) {
        if (m_appItems.at(index) == appItem) {
            beginRemoveRows(QModelIndex(), index, index);
            m_appItems.removeAt(index);
            endRemoveRows();
            return;
        }
    }
}

PrivacySecurityModel::PrivacySecurityModel(QObject *parent)
    : QObject(parent)
    // , m_worker(new PrivacySecurityWorker(this))
    , m_appModel(new AppsModel(this))
    , m_uniqueID(1)
    , m_updating(true)
{
    // QThread *thread = new QThread(m_worker);
    // m_worker->moveToThread(thread);
    // thread->start();
    // connect(m_worker, &PrivacySecurityWorker::checkAuthorization, this, &PrivacySecurityModel::checkAuthorization);
    // connect(m_worker, &PrivacySecurityWorker::serviceExistsChanged, this, &PrivacySecurityModel::serviceExistsChanged);
}

PrivacySecurityModel::~PrivacySecurityModel()
{
    // QThread *thread = m_worker->thread();
    // if (thread) {
    //     thread->quit();
    //     thread->wait();
    // }
    // delete m_worker;
    qDeleteAll(m_appItems);
}

// TODO
bool PrivacySecurityModel::existsService() const
{
    // return m_worker->existsService();
    return false;
}

bool PrivacySecurityModel::isPremissionEnabled(int premission) const
{
    switch (premission) {
    case PermissionType::FoldersPermission:
        return isPremissionEnabled(PermissionType::DocumentFoldersPermission) 
            && isPremissionEnabled(PermissionType::PictureFoldersPermission)
            && isPremissionEnabled(PermissionType::DesktopFoldersPermission)
            && isPremissionEnabled(PermissionType::VideoFoldersPermission)
            && isPremissionEnabled(PermissionType::MusicFoldersPermission)
            && isPremissionEnabled(PermissionType::DownloadFoldersPermission);
    default:
        return m_premissionMap.value(premission, PrivacySecurityDataProxy::AllEnable) != PrivacySecurityDataProxy::AllDisabled;
    }
}

void PrivacySecurityModel::setPremissionEnabled(int premission, bool enabled)
{
    // worker 实现
    if (enabled) {
        if (!m_appItems.isEmpty()) {
            auto &&item = m_appItems.first();
            qCInfo(DCC_PRIVACY) << "Set premission enabled: true, item: " << item << ", premission: " << premission;
            // 触发设置信号
            switch (premission) {
            case PermissionType::CameraPermission:
                item->setPremissionEnabled(PermissionType::CameraPermission, item->isPremissionEnabled(PermissionType::CameraPermission));
                break;
            case PermissionType::FoldersPermission:
                item->setPremissionEnabled(PermissionType::DocumentFoldersPermission, item->isPremissionEnabled(PermissionType::DocumentFoldersPermission));
                item->setPremissionEnabled(PermissionType::PictureFoldersPermission, item->isPremissionEnabled(PermissionType::PictureFoldersPermission));
                item->setPremissionEnabled(PermissionType::DesktopFoldersPermission, item->isPremissionEnabled(PermissionType::DesktopFoldersPermission));
                item->setPremissionEnabled(PermissionType::VideoFoldersPermission, item->isPremissionEnabled(PermissionType::VideoFoldersPermission));
                item->setPremissionEnabled(PermissionType::MusicFoldersPermission, item->isPremissionEnabled(PermissionType::MusicFoldersPermission));
                item->setPremissionEnabled(PermissionType::DownloadFoldersPermission, item->isPremissionEnabled(PermissionType::DownloadFoldersPermission));
                break;
            }
        }
    } else {
        Q_EMIT requestSetPremissionMode(premission, PrivacySecurityDataProxy::AllDisabled);
    }
}

bool PrivacySecurityModel::addApplictionItem(ApplicationItem *item)
{
    m_appModel->appendItem(item);
    return true;
    // auto it = std::find_if(m_appItems.begin(), m_appItems.end(), [item](ApplicationItem *appItem) {
    //     return appItem->id() == item->id();
    // });
    // if (it == m_appItems.end()) {
    //     // 排序添加
    //     auto before = std::find_if(m_appItems.begin(), m_appItems.end(), [item](ApplicationItem *appItem) {
    //         return appItem->sortField() > item->sortField();
    //     });
    //     item->setUniqueID(createUniqueID());
    //     connect(item, &ApplicationItem::dataChanged, this, &PrivacySecurityModel::onItemDataChanged);
    //     connect(item, &ApplicationItem::appPathChanged, this, &PrivacySecurityModel::onItemPermissionChanged);
    //     Q_EMIT itemAboutToBeAdded(before - m_appItems.begin());
    //     m_appItems.insert(before, item);
    //     Q_EMIT itemAdded();
    //     return true;
    // }
    // return false;
}

void PrivacySecurityModel::removeApplictionItem(const QString &id)
{
    auto it = std::find_if(m_appItems.begin(), m_appItems.end(), [id](ApplicationItem *appItem) {
        return appItem->id() == id;
    });
    if (it != m_appItems.end()) {
        Q_EMIT itemAboutToBeRemoved(it - m_appItems.begin());
        delete *it;
        m_appItems.erase(it);
        Q_EMIT itemRemoved();
    }
}

void PrivacySecurityModel::dataUpdateFinished(bool updating)
{
    m_updating = updating;
    if (m_updating) {
        Q_EMIT itemDataUpdate(m_updating);
        blockSignals(m_updating);
    } else {
        blockSignals(m_updating);
        Q_EMIT itemDataUpdate(m_updating);
    }
}

ApplicationItem *PrivacySecurityModel::applictionItem(unsigned uniqueID)
{
    auto it = std::find_if(m_appItems.begin(), m_appItems.end(), [uniqueID](ApplicationItem *item) {
        return item->getUniqueID() == uniqueID;
    });
    return it == m_appItems.end() ? nullptr : *it;
}

int PrivacySecurityModel::getAppIndex(unsigned uniqueID) const
{
    auto it = std::find_if(m_appItems.begin(), m_appItems.end(), [uniqueID](ApplicationItem *item) {
        return item->getUniqueID() == uniqueID;
    });
    return it == m_appItems.end() ? -1 : it - m_appItems.begin();
}

void PrivacySecurityModel::updatePermission()
{
    for (auto &&item : m_appItems) {
        updatePermission(item);
    }
}

void PrivacySecurityModel::updatePermission(ApplicationItem *item)
{
    item->onPremissionEnabledChanged(PermissionType::DocumentFoldersPermission, !m_blacklist[premissiontoPath(PermissionType::DocumentFoldersPermission)].contains(item->appPath()));
    item->onPremissionEnabledChanged(PermissionType::PictureFoldersPermission, !m_blacklist[premissiontoPath(PermissionType::PictureFoldersPermission)].contains(item->appPath()));
    item->onPremissionEnabledChanged(PermissionType::DesktopFoldersPermission, !m_blacklist[premissiontoPath(PermissionType::DesktopFoldersPermission)].contains(item->appPath()));
    item->onPremissionEnabledChanged(PermissionType::VideoFoldersPermission, !m_blacklist[premissiontoPath(PermissionType::VideoFoldersPermission)].contains(item->appPath()));
    item->onPremissionEnabledChanged(PermissionType::MusicFoldersPermission, !m_blacklist[premissiontoPath(PermissionType::MusicFoldersPermission)].contains(item->appPath()));
    item->onPremissionEnabledChanged(PermissionType::DownloadFoldersPermission, !m_blacklist[premissiontoPath(PermissionType::DownloadFoldersPermission)].contains(item->appPath()));
}

const QSet<QString> PrivacySecurityModel::blacklist(const QString &file) const
{
    return m_blacklist.value(file);
}

const QString PrivacySecurityModel::premissiontoPath(int premission) const
{
    // mhduiy
    switch (premission) {
    case PermissionType::CameraPermission:
        return "camera";
    case PermissionType::DocumentFoldersPermission:
        return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    case PermissionType::PictureFoldersPermission:
        return QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    case PermissionType::DesktopFoldersPermission:
        return QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    case PermissionType::VideoFoldersPermission:
        return QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
    case PermissionType::MusicFoldersPermission:
        return QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
    case PermissionType::DownloadFoldersPermission:
        return QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    }
    
    return QString();
}

int PrivacySecurityModel::pathtoPremission(const QString &path, bool mainPremission) const
{
    if (path == "camera") {
        return PermissionType::CameraPermission;
    } else if (path == QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)) {
        return mainPremission ? PermissionType::FoldersPermission : PermissionType::DocumentFoldersPermission;
    } else if (path == QStandardPaths::writableLocation(QStandardPaths::PicturesLocation)) {
        return mainPremission ? PermissionType::FoldersPermission : PermissionType::PictureFoldersPermission;
    } else if (path == QStandardPaths::writableLocation(QStandardPaths::DesktopLocation)) {
        return mainPremission ? PermissionType::FoldersPermission : PermissionType::DesktopFoldersPermission;
    } else if (path == QStandardPaths::writableLocation(QStandardPaths::MoviesLocation)) {
        return mainPremission ? PermissionType::FoldersPermission : PermissionType::VideoFoldersPermission;
    } else if (path == QStandardPaths::writableLocation(QStandardPaths::MusicLocation)) {
        return mainPremission ? PermissionType::FoldersPermission : PermissionType::MusicFoldersPermission;
    } else if (path == QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)) {
        return mainPremission ? PermissionType::FoldersPermission : PermissionType::DownloadFoldersPermission;
    }
    return 0;
}

void PrivacySecurityModel::checkAuthorizationCancel()
{
    // m_worker->checkAuthorizationCancel();
}

void PrivacySecurityModel::onPremissionModeChanged(int premission, int mode)
{
    int groupPremisson = premission & PermissionType::GroupPermissionMask;
    m_premissionMap[groupPremisson] = mode;
    emitPremissionModeChanged(groupPremisson);
}

void PrivacySecurityModel::emitPremissionModeChanged(int premission)
{
    int groupPremisson = premission & PermissionType::GroupPermissionMask;
    Q_EMIT premissionEnabledChanged(groupPremisson, isPremissionEnabled(groupPremisson));
}

void PrivacySecurityModel::onAppPremissionEnabledChanged(const QString &file, const QSet<QString> &apps)
{
    qWarning() << "-----m_blacklist-----" << m_blacklist;
    if (isPremissionEnabled(pathtoPremission(file, true))) {
        m_blacklist[file] = apps;
        if (m_cacheBlacklist[file] != apps) {
            m_cacheBlacklist[file] = apps;
            Q_EMIT requestUpdateCacheBlacklist(m_cacheBlacklist);
        }
    } else {
        m_blacklist[file] = m_cacheBlacklist[file];
    }
    updatePermission();
}

void PrivacySecurityModel::onItemPermissionChanged()
{
    ApplicationItem *item = qobject_cast<ApplicationItem *>(sender());
    if (item)
        updatePermission(item);
}

void PrivacySecurityModel::onItemDataChanged()
{
    ApplicationItem *item = qobject_cast<ApplicationItem *>(sender());
    Q_EMIT itemDataChanged(item);
}

void PrivacySecurityModel::onCacheBlacklistChanged(const QMap<QString, QSet<QString>> &cacheBlacklist)
{
    m_cacheBlacklist = cacheBlacklist;
}

unsigned PrivacySecurityModel::createUniqueID()
{
    return m_uniqueID++;
}
