#include "privacysecurityworker.h"
#include "operation/privacysecuritydataproxy.h"
#include <dsglobal.h>
#include <qlogging.h>
#include <qobject.h>
#include <QJsonDocument>
#include <QJsonValue>
#include <QJsonArray>
#include <QJsonObject>
#include "applicationitem.h"
#include <QDir>
#include <QTimer>
#include <QProcessEnvironment>

#include "applet.h"
#include "pluginloader.h"
#include "containment.h"
#include <appletbridge.h>


#include <polkit-qt6-1/PolkitQt1/Authority>
#include <qtpreprocessorsupport.h>
#include "dde-apps.h"

const QString DataVersion = "1.0";
static QList<int> s_systemPrem = { PermissionType::CameraPermission };

PrivacySecurityWorker::PrivacySecurityWorker(PrivacySecurityModel *appsModel, QObject *parent)
    : QObject(parent)
    , m_model(appsModel)
    , m_dataProxy(new PrivacySecurityDataProxy(this))
{
    connect(m_model, &PrivacySecurityModel::requestSetPremissionMode, this, &PrivacySecurityWorker::setPermissionMode);
    connect(m_model, &PrivacySecurityModel::requestUpdateCacheBlacklist, this, &PrivacySecurityWorker::updateCacheBlacklist);

    connect(m_dataProxy, &PrivacySecurityDataProxy::serviceExistsChanged, this, &PrivacySecurityWorker::serviceExistsChanged);
    init();
}

PrivacySecurityWorker::~PrivacySecurityWorker()
{
    if (!m_pathList.isEmpty())
        return;
    m_dataProxy->init();
}

void PrivacySecurityWorker::init()
{
    if (!m_pathList.isEmpty())
        return;
    m_dataProxy->init();
    initApp();

    // 连接设置接口
    connect(m_model, &PrivacySecurityModel::requestSetPremissionMode, this, &PrivacySecurityWorker::setPermissionMode);
    connect(m_model, &PrivacySecurityModel::requestUpdateCacheBlacklist, this, &PrivacySecurityWorker::updateCacheBlacklist);

    connect(m_dataProxy, &PrivacySecurityDataProxy::ModeChanged, this, &PrivacySecurityWorker::onModeChanged, Qt::QueuedConnection);
    connect(m_dataProxy, &PrivacySecurityDataProxy::EntityChanged, this, &PrivacySecurityWorker::onEntityChanged, Qt::QueuedConnection);
    connect(m_dataProxy, &PrivacySecurityDataProxy::PolicyChanged, this, &PrivacySecurityWorker::onPolicyChanged, Qt::QueuedConnection);

    QString envPath = QProcessEnvironment::systemEnvironment().value("PATH");
    m_pathList = envPath.split(':');

    m_dataProxy->listEntity();
    QStringList folders = { 
        "camera",
        m_model->premissiontoPath(PermissionType::DocumentFoldersPermission),
        m_model->premissiontoPath(PermissionType::PictureFoldersPermission),
        m_model->premissiontoPath(PermissionType::DesktopFoldersPermission),
        m_model->premissiontoPath(PermissionType::VideoFoldersPermission),
        m_model->premissiontoPath(PermissionType::MusicFoldersPermission),
        m_model->premissiontoPath(PermissionType::DownloadFoldersPermission)
    };
    for (const auto &folder : folders) {
        m_dataProxy->getMode(folder);
        m_dataProxy->getPolicy(folder);
    }
    m_model->onCacheBlacklistChanged(m_dataProxy->getCacheBlacklist());
}

void PrivacySecurityWorker::initApp()
{
    auto rootApplet = qobject_cast<DS_NAMESPACE::DContainment *>(DS_NAMESPACE::DPluginLoader::instance()->rootApplet());
    auto applet = rootApplet->createApplet(DS_NAMESPACE::DAppletData{"org.deepin.ds.dde-apps"});
    applet->load();
    applet->init();

    DS_NAMESPACE::DAppletBridge bridge("org.deepin.ds.dde-apps");
    DS_NAMESPACE::DAppletProxy * amAppsProxy = bridge.applet();

    if (amAppsProxy) {
        QAbstractItemModel * model = amAppsProxy->property("appModel").value<QAbstractItemModel *>();
        m_ddeAmModel = model;

        connect(model, &QAbstractItemModel::rowsInserted, this, [this](const QModelIndex &parent, int first, int last)
        {
            Q_UNUSED(parent)
            for (int i = first; i <= last; i++) {
                addAppItem(i);
            }
        });
    }
}

void PrivacySecurityWorker::setPremissionEnabled(int appItemIndex, int premission, bool enabled)
{
    qWarning() << "设置权限: " << appItemIndex << premission << enabled;
    auto item = m_model->appModel()->appList().value(appItemIndex);
    qWarning() << "现在设置的是: " << item->name();
    item->setPremissionEnabled(PermissionType::DocumentFoldersPermission, false);
}
QString PrivacySecurityWorker::getAppPath(const QString &filePath)
{
    static QStringList s_excludeBin = { "gio", "dbus-send", "python", "KboxAppLauncher", "/usr/bin/uengine-launch.sh" };
    QString appPath;
    QFile file(filePath);
    if (file.open(QFile::ReadOnly | QFile::Text)) {
        while (!file.atEnd()) {
            QString line = file.readLine();
            if (line.startsWith("X-Created-By=")) {
                if (line.contains("Deepin WINE Team")) {
                    qCInfo(DCC_PRIVACY) << "Remove by WINE:" << filePath;
                    appPath.clear();
                    break;
                }
            }
            if (line.startsWith("Exec=")) {
                QString app;
                if (line.startsWith("Exec=\"")) {
                    app = line.split("\"").at(1).trimmed();
                } else {
                    app = line.split(' ').first().mid(5).trimmed().remove("\"");
                }
                if (s_excludeBin.contains(app)) {
                    break;
                } else if (QFile::exists(app)) {
                    appPath = app;
                } else {
                    for (const auto &binDir : m_pathList) {
                        QDir bin(binDir);
                        if (bin.exists(app)) {
                            appPath = bin.absolutePath() + "/" + app;
                            break;
                        }
                    }
                }
            }
        }
    }
    file.close();
    if (!appPath.isEmpty()) {
        while (true) {
            QFileInfo info(appPath);
            if (info.isSymLink()) {
                appPath = info.symLinkTarget();
            } else if (!info.exists()) {
                appPath.clear();
                break;
            } else {
                break;
            }
        }
    }
    return appPath;
}

void PrivacySecurityWorker::updateCheckAuthorizationing(bool checking)
{
    if (m_checkAuthorizationing != checking) {
        m_checkAuthorizationing = checking;
        if (m_checkAuthorizationing) {
            // true情况延时发信号，防止界面频繁禁用
            QTimer::singleShot(100, this, [this]() {
                if (m_checkAuthorizationing) {
                    Q_EMIT checkAuthorization(m_checkAuthorizationing);
                }
            });
        } else {
            Q_EMIT checkAuthorization(m_checkAuthorizationing);
        }
    }
}

// 刷新所有状态
void PrivacySecurityWorker::updateAllPermission()
{
    for (auto &&it = m_blacklistByPackage.begin(); it != m_blacklistByPackage.end(); ++it) {
        QSet<QString> files;
        for (const auto &package : it.value()) {
            for (const auto &file : m_entityMap.value(package)) {
                files.insert(file);
            }
        }
        m_model->onAppPremissionEnabledChanged(it.key(), files);
    }
}

QString PrivacySecurityWorker::getEntityJson(const QString &name, bool isFile)
{
    QJsonObject obj;
    QJsonObject attrs;
    attrs.insert("bus_type", QString()); // 此处空项没有接口调用会报错
    attrs.insert("exes", QJsonArray());
    attrs.insert("interface", QString());
    attrs.insert("methods", QJsonArray());
    attrs.insert("object_path", QString());
    attrs.insert("service_name", QString());
    obj.insert("attrs", attrs);
    obj.insert("description", QString());
    obj.insert("description_zh_CN", QString());
    obj.insert("level", QString());
    obj.insert("owner", QString());
    obj.insert("sensitivity", QString());

    QJsonArray available_operations;
    available_operations.append("allow");
    available_operations.append("deny");
    obj.insert("name", name);
    obj.insert("available_operations", available_operations);
    obj.insert("subtype", isFile ? "file" : "");
    obj.insert("version", DataVersion);
    QJsonArray tags;
    tags.append("system");
    obj.insert("tags", tags);
    obj.insert("type", "object");
    QJsonDocument doc(obj);
    return doc.toJson(QJsonDocument::Compact);
}

QString PrivacySecurityWorker::getAppEntityJson(const ApplicationItem *item)
{
    QJsonObject obj;
    QJsonObject attrs;
    attrs.insert("bus_type", QString()); // 此处空项没有接口调用会报错
    attrs.insert("interface", QString());
    attrs.insert("methods", QJsonArray());
    attrs.insert("object_path", QString());
    attrs.insert("service_name", QString());
    obj.insert("description", item->name()); //
    obj.insert("description_zh_CN", item->name()); //
    obj.insert("level", QString());
    obj.insert("owner", QString());
    obj.insert("sensitivity", QString());

    QJsonArray exes = QJsonArray::fromStringList(item->executablePaths());  // 可执行文件名
    attrs.insert("exes", exes);
    obj.insert("attrs", attrs);
    obj.insert("name", item->package()); //
    QJsonArray available_operations;
    obj.insert("available_operations", available_operations);
    obj.insert("subtype", "package");
    obj.insert("version", DataVersion);
    QJsonArray tags;
    tags.append("system");
    obj.insert("tags", tags);
    obj.insert("type", "subject");
    QJsonDocument doc(obj);
    return doc.toJson(QJsonDocument::Compact);
}

QString PrivacySecurityWorker::getSubjectModeJson(const QString &name, bool isBlacklist)
{
    QJsonObject obj;
    obj.insert("mode", isBlacklist ? "blacklist" : "whitelist");
    obj.insert("object", name);
    obj.insert("version", DataVersion);
    QJsonDocument doc(obj);
    return doc.toJson(QJsonDocument::Compact);
}

QString PrivacySecurityWorker::getObjectPolicyJson(const ApplicationItem *item, int premission, bool enabled)
{
    QJsonObject obj;
    QJsonArray policies;
    QJsonObject policy;
    QJsonArray objects;

    QJsonObject object;
    object.insert("timestamp", 0);
    object.insert("valid_period", 0);
    object.insert("object", m_model->premissiontoPath(premission)); // 需要设置的路径
    object.insert("operations", enabled ? QJsonArray::fromStringList({ "allow" }) : QJsonArray::fromStringList({ "deny" }));
    objects.append(object);

    QJsonObject subject;
    subject.insert("name", item->package());    // 包名
    policy.insert("objects", objects);
    policy.insert("subject", subject);
    policies.append(policy);
    obj.insert("policies", policies);
    obj.insert("version", DataVersion);
    QJsonDocument doc(obj);
    return doc.toJson(QJsonDocument::Compact);
}

void PrivacySecurityWorker::updateAppPath(ApplicationItem *item)
{
    if (!item)
        return;

    QString path = getAppPath(item->id());
    if (path.isEmpty()) {
        QMetaObject::invokeMethod(m_model, "removeApplictionItem", Qt::QueuedConnection, Q_ARG(QString, item->id()));
    } else {
        item->onAppPathChanged(path);
    }
}

void PrivacySecurityWorker::updateAllAppPath()
{
    qCDebug(DCC_PRIVACY) << "Update appPath begin";
    unsigned maxUniqueID = m_model->lastUniqueID() + 1;
    while (--maxUniqueID) {
        updateAppPath(m_model->applictionItem(maxUniqueID));
    }
    qCDebug(DCC_PRIVACY) << "Update appPath end";
}

// void PrivacySecurityWorker::onItemInfosChanged(const AppItemInfoList &itemList)
// {
//     // 批量加数据，先阻塞信号，再给出完成信号
//     qCDebug(DCC_PRIVACY) << "Update item begin";
//     m_model->dataUpdateFinished(true);
//     for (const auto &item : itemList) {
//         addAppItem(item);
//     }
//     m_model->dataUpdateFinished(false);
//     // 延时获取appPath
//     QMetaObject::invokeMethod(this, "updateAllAppPath", Qt::QueuedConnection);
//     qCDebug(DCC_PRIVACY) << "Update item end";
// }

ApplicationItem *PrivacySecurityWorker::addAppItem(int dataIndex)
{
    // 不展示的应用
    static QStringList s_excludeApp = {
        "/uengine.", "/dde-computer.desktop", "/dde-control-center.desktop", "/dde-file-manager.desktop", "/dde-trash.desktop", "/deepin-manual.desktop", "/deepin-terminal.desktop", "/uos-recovery-gui.desktop",
    };

    // TODO 排除应用
    // for (const auto &path : s_excludeApp) {
    //     if (itemInfo.Path.contains(path)) {
    //         qCInfo(DCC_PRIVACY) << "Exclude app path: " << itemInfo.Path << ", name: " << itemInfo.Name;
    //         return nullptr;
    //     }
    // }

    ApplicationItem *appItem = new ApplicationItem();

    const auto &NoDisplay = m_ddeAmModel->data(m_ddeAmModel->index(dataIndex, 0), DS_NAMESPACE::AppItemModel::NoDisplayRole).toBool();

    if (NoDisplay) {
        return nullptr;
    }

    const auto &name = m_ddeAmModel->data(m_ddeAmModel->index(dataIndex, 0), DS_NAMESPACE::AppItemModel::NameRole).toString();
    const auto &iconName = m_ddeAmModel->data(m_ddeAmModel->index(dataIndex, 0), DS_NAMESPACE::AppItemModel::IconNameRole).toString();
    const auto &desktopFile = m_ddeAmModel->data(m_ddeAmModel->index(dataIndex, 0), DS_NAMESPACE::AppItemModel::DesktopFileRole).toString();

    appItem->onIdChanged(desktopFile);
    appItem->onNameChanged(name);
    if (m_model->addApplictionItem(appItem)) {
        appItem->onIconChanged(iconName);
        m_model->updatePermission(appItem);
        connect(appItem, &ApplicationItem::requestSetPremissionEnabled, this, &PrivacySecurityWorker::setAppPermissionEnable);
    } else {
        delete appItem;
        appItem = nullptr;
    }
    return appItem;
}

void PrivacySecurityWorker::onModeChanged(const QString &mode, const QString &type)
{
    if (type != "add" && type != "modify")
        return;
    QJsonParseError jsonError;
    QJsonDocument doc = QJsonDocument::fromJson(mode.toLatin1(), &jsonError);
    if (doc.isNull() || jsonError.error != QJsonParseError::NoError) {
        qCWarning(DCC_PRIVACY) << "mode changed :json parse error:" << jsonError.errorString();
        return;
    }
    QJsonObject obj = doc.object();
    if (obj.value("version").toString() != DataVersion) {
        qCWarning(DCC_PRIVACY) << "mode changed :version error: current version:" << DataVersion << "json version:" << obj.value("version").toString();
        return;
    }
    QString object = obj.value("object").toString();
    QString objMode = obj.value("mode").toString();
    int modeType = PrivacySecurityDataProxy::AllEnable;
    if (objMode == "blacklist") {
        modeType = PrivacySecurityDataProxy::ByCustom;
    } else if (objMode == "allallow") {
        modeType = PrivacySecurityDataProxy::AllEnable;
    }
    int premission = m_model->pathtoPremission(object, false);
    if (premission != 0)
        m_model->onPremissionModeChanged(premission, modeType);
}

void PrivacySecurityWorker::onEntityChanged(const QString &entity, const QString &type)
{
    if (type != "add" && type != "modify")
        return;
    QJsonParseError jsonError;
    QJsonDocument doc = QJsonDocument::fromJson(entity.toLatin1(), &jsonError);
    if (doc.isNull() || jsonError.error != QJsonParseError::NoError) {
        qCWarning(DCC_PRIVACY) << "entity changed :json parse error:" << jsonError.errorString();
        return;
    }
    QJsonObject obj = doc.object();
    if (obj.value("version").toString() != DataVersion) {
        qCWarning(DCC_PRIVACY) << "entity changed :version error: current version:" << DataVersion << "json version:" << obj.value("version").toString();
        return;
    }
    QString name = obj.value("name").toString();
    QSet<QString> exes;
    if (name.isEmpty()) {
        qCWarning(DCC_PRIVACY) << "entity changed :name is empty";
        return;
    }
    QJsonObject attrs = obj.value("attrs").toObject();
    if (!attrs.isEmpty()) {
        QJsonArray exesJson = attrs.value("exes").toArray();
        for (const auto it : exesJson) {
            exes.insert(it.toString());
        }
    }
    m_entityMap.insert(name, exes);
    updateAllPermission();
}

void PrivacySecurityWorker::onPolicyChanged(const QString &policy, const QString &type)
{
    if (type != "add" && type != "modify")
        return;
    QJsonParseError jsonError;
    QJsonDocument doc = QJsonDocument::fromJson(policy.toLatin1(), &jsonError);
    if (doc.isNull() || jsonError.error != QJsonParseError::NoError) {
        qCWarning(DCC_PRIVACY) << "policy changed :json parse error:" << jsonError.errorString();
        return;
    }
    QJsonObject obj = doc.object();
    if (obj.value("version").toString() != DataVersion) {
        qCWarning(DCC_PRIVACY) << "policy changed :version error: current version:" << DataVersion << "json version:" << obj.value("version").toString();
        return;
    }
    QJsonArray policies = obj.value("policies").toArray();
    for (const auto policy : policies) {
        QJsonObject policyObj = policy.toObject();
        QString package = policyObj.value("subject").toObject().value("name").toString();
        QJsonArray objects = policyObj.value("objects").toArray();
        for (const auto object : objects) {
            QJsonObject objectObj = object.toObject();
            QString objectName = objectObj.value("object").toString();
            QVariantList operations = objectObj.value("operations").toArray().toVariantList();
            if (operations.contains("deny")) {
                m_blacklistByPackage[objectName].insert(package);
            } else {
                m_blacklistByPackage[objectName].remove(package);
            }
        }
    }
    updateAllPermission();
}

void PrivacySecurityWorker::setAppPermissionEnableByCheck(bool ok)
{
    qWarning() << "**setAppPermissionEnableByCheck**" << m_cacheAppPermission.size() << ok;
    while (!m_cacheAppPermission.isEmpty()) {   // 提前设置好了要设置权限的列表
        const auto &&it = m_cacheAppPermission.takeFirst();
        ApplicationItem *item = it.first;   // 要设置的程序
        int premission = it.second.first;   // 要申请哪些权限
        bool enabled = it.second.second;    // 开启还是关闭
        if (ok) {
            // 设置App权限
            QString file = m_model->premissiontoPath(premission); // 根据当前要设置的权限，获取要读取的目录，比如文档就是Document目录
            qWarning() << "可执行文件路径" << file;
            if (file.isEmpty()) {
                item->emitDataChanged(); // 触发信号
                m_model->emitPremissionModeChanged(premission);
                continue;
            }
            QSet<QString> blacklist = m_model->blacklist(file); // todo 这个是什么
            QStringList executablePaths = item->executablePaths(); // 可执行文件路径
            qWarning() << "可执行文件列表1" << item->appPath() << item->name();
            if (executablePaths.isEmpty()) { // 如果可执行文件路径为空
                QString path = item->appPath(); // app路径
                if (path.isEmpty()) {
                    path = getAppPath(item->id()); // desktop 名，获取app的path，（传入desktop文件获取该文件的EXEC字段下的文件？）
                    item->onAppPathChanged(path);
                }
                QString package;
                executablePaths = m_dataProxy->getExecutable(path, &package);   // 获取exec可执行文件下对应包的所有文件
                item->onPackageChanged(package);
                qWarning() << "exec 的名字" << executablePaths << package;
                item->onExecutablePathsChanged(executablePaths);
            }
            if (item->package().isEmpty()) {    // 如果包名为空
                qCWarning(DCC_PRIVACY) << "get package error: path:" << item->appPath() << "app name:" << item->name();
                item->emitDataChanged(); // 触发信号
                m_model->emitPremissionModeChanged(premission);
                continue;
            }

            // 设置camera Entity   m_entityMap？是什么
            if (!m_entityMap.contains(file)) {  
                // 具体设置部分（传入当前需要设置的目录（文档、下载））
                m_dataProxy->setEntity(getEntityJson(file, premission != PermissionType::CameraPermission)); // ??
                // qWarning() << "-----" << getEntityJson(file, premission != PermissionType::CameraPermission);
            }
            // 设置deepin-camera Entity
            if (!m_entityMap.contains(item->package())) {
                m_dataProxy->setEntity(getAppEntityJson(item)); // ??
                // qWarning() << "-----" << getAppEntityJson(item);

            }
            // 设置camera Mode
            m_dataProxy->setMode(getSubjectModeJson(file, true));   // 设置黑名单模式, 设置客体模式
            // 设备deepin-camera Policy
            m_dataProxy->setPolicy(getObjectPolicyJson(item, premission, enabled)); // ??
                // qWarning() << "-----" << getObjectPolicyJson(item, premission, enabled);

        } else {
            item->emitDataChanged(); // 触发信号
            m_model->emitPremissionModeChanged(premission);
        }
    }
}

void PrivacySecurityWorker::setPermissionEnableByCheck(bool ok)
{
    while (!m_cachePermission.isEmpty()) {
        const auto &&it = m_cachePermission.takeFirst();
        int premission = it.first;
        int mode = it.second;
        if (!ok) {
            m_model->emitPremissionModeChanged(premission);
            continue;
        }
        // 设置总权限
        switch (premission) {
        case PermissionType::FoldersPermission: {
            QList<int> folders = {
                PermissionType::DocumentFoldersPermission,
                PermissionType::PictureFoldersPermission,
                PermissionType::DesktopFoldersPermission,
                PermissionType::VideoFoldersPermission,
                PermissionType::MusicFoldersPermission,
                PermissionType::DownloadFoldersPermission,
            };
            for (const auto &folder : folders) {
                QString file = m_model->premissiontoPath(folder);
                if (!m_entityMap.contains(file)) {
                    m_dataProxy->setEntity(getEntityJson(file, true));
                }
                QString subjectMode = getSubjectModeJson(file, mode == PrivacySecurityDataProxy::ByCustom);
                m_dataProxy->setMode(subjectMode);
            }
        } break;
        case PermissionType::CameraPermission: {
            QString file = m_model->premissiontoPath(PermissionType::CameraPermission);
            // 设置camera Entity
            if (!m_entityMap.contains(file)) {
                m_dataProxy->setEntity(getEntityJson(file, false));
            }
            // 设置camera Mode
            QString subjectMode = getSubjectModeJson(file, mode == PrivacySecurityDataProxy::ByCustom);
            m_dataProxy->setMode(subjectMode);
        } break;
        default:
            m_model->emitPremissionModeChanged(premission);
            break;
        }
    }
}

void PrivacySecurityWorker::setPermissionMode(int premission, int mode)
{
    m_cachePermission.append({ premission, mode });
    if (!s_systemPrem.contains(premission)) {
        setPermissionEnableByCheck(true);
        return;
    }
    if (m_checkAuthorizationing)
        return;
    connect(PolkitQt1::Authority::instance(), &PolkitQt1::Authority::checkAuthorizationFinished, this, [this](PolkitQt1::Authority::Result authenticationResult) {
        disconnect(PolkitQt1::Authority::instance(), nullptr, this, nullptr);
        updateCheckAuthorizationing(false);
        setPermissionEnableByCheck(PolkitQt1::Authority::Result::Yes == authenticationResult);
    });
    updateCheckAuthorizationing(true);
    PolkitQt1::Authority::instance()->checkAuthorization("com.deepin.FileArmor1", PolkitQt1::UnixProcessSubject(getpid()), PolkitQt1::Authority::AllowUserInteraction);
}

void PrivacySecurityWorker::setAppPermissionEnable(int premission, bool enabled, ApplicationItem *item)
{
    qWarning() << "设置权限:" << premission << enabled << item->name();
    m_cacheAppPermission.append({ item, { premission, enabled } }); // 存入缓存
    if (!s_systemPrem.contains(premission)) { // 如果申请的权限不包括列表中的权限（比如相机以外的权限）
        setAppPermissionEnableByCheck(true);
        return;
    }

    if (m_checkAuthorizationing)
        return;
    connect(PolkitQt1::Authority::instance(), &PolkitQt1::Authority::checkAuthorizationFinished, this, [this](PolkitQt1::Authority::Result authenticationResult) {
        disconnect(PolkitQt1::Authority::instance(), nullptr, this, nullptr);
        updateCheckAuthorizationing(false);
        setAppPermissionEnableByCheck(PolkitQt1::Authority::Result::Yes == authenticationResult);
    });
    updateCheckAuthorizationing(true);
    PolkitQt1::Authority::instance()->checkAuthorization("com.deepin.FileArmor1", PolkitQt1::UnixProcessSubject(getpid()), PolkitQt1::Authority::AllowUserInteraction);
}

void PrivacySecurityWorker::checkAuthorizationCancel()
{
    if (m_checkAuthorizationing) {
        //        PolkitQt1::Authority::instance()->checkAuthorizationCancel(); // 取消后不能再拉起
        disconnect(PolkitQt1::Authority::instance(), nullptr, this, nullptr);
        updateCheckAuthorizationing(false);
    }
}

void PrivacySecurityWorker::updateCacheBlacklist(const QMap<QString, QSet<QString>> &cacheBlacklist)
{
    m_dataProxy->setCacheBlacklist(cacheBlacklist);
}
