// SPDX-FileCopyrightText: 2024 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: GPL-3.0-or-later
#include <QtWaylandClient/private/qwaylandsurface_p.h>
#include <QtWaylandClient/private/qwaylandwindow_p.h>
#include <QGuiApplication>
#include <QFile>

#include <private/qguiapplication_p.h>
#include <private/qwaylandintegration_p.h>
#include <private/qwaylandwindow_p.h>
#include <qlogging.h>
#include <qnamespace.h>
#include <qobjectdefs.h>
#include <qt5/QtCore/qthread.h>
#include <qtimer.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <cstdint>
#include <sys/socket.h>
#include "treelandworker.h"
#include "operation/personalizationworker.h"
#include "qwayland-treeland-personalization-manager-v1.h"
#include "wayland-treeland-personalization-manager-v1-client-protocol.h"

TreeLandWorker::TreeLandWorker(PersonalizationModel *model, QObject *parent)
: PersonalizationWorker(model, parent)
{

}

void TreeLandWorker::setBackgroundForMonitor(const QString &monitorName, const QString &url)
{
    if (!m_wallpaperContext)
        return;

    QString dest = QUrl(url).toLocalFile();
    if (dest.isEmpty())
        return;

    QFile file(dest);
    if (file.open(QIODevice::ReadOnly)) {

        if (!m_wallpapers.contains(monitorName)) {
            m_wallpapers.insert(monitorName, new WallpaperMetaData);
        }

        auto meta_data = m_wallpapers.value(monitorName);

        if (meta_data != nullptr) {
            meta_data->isDark = false;
            meta_data->url = url;
            meta_data->monitorName = monitorName;

            m_wallpaperContext->set_on(PersonalizationWallpaperContext::options_background);
            m_wallpaperContext->set_isdark(false);

            QMapIterator<QString, WallpaperMetaData *> it(m_wallpapers);

            QJsonObject json;
            while (it.hasNext()) {
                it.next();
                QJsonObject content;
                content.insert("isDark", it.value()->isDark);
                content.insert("url", it.value()->url);
                content.insert("monitorName", it.value()->monitorName);

                json[it.key()] = content;
            }

            QJsonDocument json_doc(json);

            m_wallpaperContext->set_fd(file.handle(), json_doc.toJson(QJsonDocument::Compact));
            m_wallpaperContext->set_output(monitorName);
            m_wallpaperContext->commit();

            onWallpaperUrlsChanged();
        }

        file.close();
    }
}
QString TreeLandWorker::getBackgroundForMonitor(const QString &monitorName)
{
    if (m_wallpapers.contains(monitorName)) {
        return m_wallpapers.value(monitorName)->url;
    }
    return QString();
}

void TreeLandWorker::setDefault(const QJsonObject &value)
{
    const QString key = value.value("type").toString();
    const QString id = value.value("Id").toString();
    if (key == "standardfont") {
        setFontName(id);
    } else if (key == "monospacefont") {
        setMonoFontName(id);
    }
    PersonalizationWorker::setDefault(value);
}

void TreeLandWorker::setAppearanceTheme(const QString &id)
{
    qInfo() << "设置外观主题" << id;
    PersonalizationWorker::setAppearanceTheme(id);
    if (id == ".light") {
        m_appearanceTheme = PersonalizationAppearanceContext::theme_type::theme_type_light;
        m_appearanceContext->set_window_theme_type(PersonalizationAppearanceContext::theme_type::theme_type_light);
    } else if (id == ".dark") {
        m_appearanceTheme = PersonalizationAppearanceContext::theme_type::theme_type_dark;
        m_appearanceContext->set_window_theme_type(PersonalizationAppearanceContext::theme_type::theme_type_dark);
    } else if (id.isEmpty()) {
        m_appearanceTheme = PersonalizationAppearanceContext::theme_type::theme_type_auto;
        m_appearanceContext->set_window_theme_type(PersonalizationAppearanceContext::theme_type::theme_type_auto);
    } else {
        qWarning() << "error id" << id;
    }
}

void TreeLandWorker::setFontName(const QString& fontName)
{
    qInfo() << "设置字体" << fontName;
    m_fontName = fontName;
    m_fontContext->set_font(fontName);
}

void TreeLandWorker::setMonoFontName(const QString& monoFontName)
{
    qInfo() << "设置等宽字体" << monoFontName;
    m_monoFontName = monoFontName;
    m_fontContext->set_monospace_font(monoFontName);
}

void TreeLandWorker::setIconTheme(const QString &id)
{
    qInfo() << "设置图标主题" << id;
    m_iconTheme = id;
    PersonalizationWorker::setIconTheme(id);
    m_appearanceContext->set_icon_theme(id);
}

void TreeLandWorker::setCursorTheme(const QString &id)
{
    qInfo() << "设置光标主题" << id;
    m_cursorTheme = id;
    PersonalizationWorker::setCursorTheme(id);
    m_cursorContext->set_theme(id);
}

void TreeLandWorker::setActiveColor(const QString &hexColor)
{
    qInfo() << "设置活动颜色" << hexColor;
    m_activeColor = hexColor;
    PersonalizationWorker::setActiveColor(hexColor);
    m_appearanceContext->set_active_color(hexColor);
}

void TreeLandWorker::setFontSize(const int value) 
{
    qInfo() << "设置字体大小" << value;
    m_fontSize = value;
    PersonalizationWorker::setFontSize(value);
    m_fontContext->set_font_size(value);
}

void TreeLandWorker::setTitleBarHeight(int value)
{
    qInfo() << "设置标题栏高度" << value;
    m_titleBarHeight = value;
    PersonalizationWorker::setTitleBarHeight(value);
    // m_appearanceContext
}

void TreeLandWorker::setWindowRadius(int value)
{
    qInfo() << "设置窗口圆角" << value;
    m_windowRadius = value;
    PersonalizationWorker::setWindowRadius(value);
    m_appearanceContext->set_round_corner_radius(value);
}

void TreeLandWorker::setOpacity(int value)
{
    qInfo() << "设置透明度" << value / 100.0;
    m_opacity = value;
    PersonalizationWorker::setOpacity(value);
    m_appearanceContext->set_blur_opacity(value / 100.0);
}

void TreeLandWorker::onWallpaperUrlsChanged()
{
    QVariantMap wallpaperMap;

    for (auto it = m_wallpapers.begin(); it != m_wallpapers.end(); ++it) {
        wallpaperMap.insert(it.key(), it.value()->url);
    }

    if (!wallpaperMap.isEmpty()) {
        m_model->setWallpaperMap(wallpaperMap);
    }
}

void TreeLandWorker::init()
{
    if (m_wallpaperContext.isNull()) {
        m_wallpaperContext.reset(new PersonalizationWallpaperContext(m_personalizationManager->get_wallpaper_context()));
        connect(m_wallpaperContext.get(),
            &PersonalizationWallpaperContext::metadataChanged,
            this,
            &TreeLandWorker::wallpaperMetaDataChanged);
        m_wallpaperContext->get_metadata();
    }
    if (m_appearanceContext.isNull()) { 
        m_appearanceContext.reset(new PersonalizationAppearanceContext(m_personalizationManager->get_appearance_context(), this));
    }
    if (m_cursorContext.isNull()) {
        m_cursorContext.reset(new PersonalizationCursorContext(m_personalizationManager->get_cursor_context(), this));
    }
    if (m_fontContext.isNull()) {
        m_fontContext.reset(new PersonalizationFontContext(m_personalizationManager->get_font_context(), this));
    }
}

void TreeLandWorker::wallpaperMetaDataChanged(const QString &data)
{
    QJsonDocument json_doc = QJsonDocument::fromJson(data.toLocal8Bit());

    if (!json_doc.isNull()) {
        QJsonObject json = json_doc.object();

        for (auto it = json.begin(); it != json.end(); ++it) {
            QJsonObject context = it.value().toObject();
            if (context.isEmpty())
                continue;

            WallpaperMetaData *wallpaper = nullptr;
            if (m_wallpapers.contains(it.key())) {
                wallpaper = m_wallpapers.value(it.key());
            } else {
                wallpaper = new WallpaperMetaData();
                m_wallpapers.insert(it.key(), wallpaper);
            }
            wallpaper->isDark = context["isDark"].toBool();
            wallpaper->url = context["url"].toString();
            wallpaper->monitorName = context["monitorName"].toString();
        }
    }

    onWallpaperUrlsChanged();
}

void TreeLandWorker::active()
{
    if (m_personalizationManager.isNull()) {
        m_personalizationManager.reset(new PersonalizationManager(this));
        connect(m_personalizationManager.get(), &PersonalizationManager::activeChanged, this, [this]() {
            if (m_personalizationManager->isActive()) {
                init();
            } else {
                // clear();
            }
        });
    }
    PersonalizationWorker::active();
}

PersonalizationManager::PersonalizationManager(QObject *parent)
    : QWaylandClientExtensionTemplate<PersonalizationManager>(1)
{
    if (QGuiApplication::platformName() == QLatin1String("wayland")) {
        QtWaylandClient::QWaylandIntegration *waylandIntegration = static_cast<QtWaylandClient::QWaylandIntegration *>(QGuiApplicationPrivate::platformIntegration());
        if (!waylandIntegration) {
            qWarning() << "waylandIntegration is nullptr!!!";
            return;
        }
        m_waylandDisplay = waylandIntegration->display();
        if (!m_waylandDisplay) {
            qWarning() << "waylandDisplay is nullptr!!!";
            return;
        }

        addListener();
    }
    setParent(parent);
}

void PersonalizationManager::addListener()
{
    if (!m_waylandDisplay) {
        qWarning() << "waylandDisplay is nullptr!, skip addListener";
        return;
    }
    m_waylandDisplay->addRegistryListener(&handleListenerGlobal, this);
}

void PersonalizationManager::removeListener()
{
    if (!m_waylandDisplay) {
        qWarning() << "waylandDisplay is nullptr!, skip removeListener";
        return;
    }
    m_waylandDisplay->removeListener(&handleListenerGlobal, this);
}

void PersonalizationManager::handleListenerGlobal(void *data, wl_registry *registry, uint32_t id, const QString &interface, uint32_t version)
{
    if (interface == treeland_personalization_manager_v1_interface.name) {
        PersonalizationManager *integration = static_cast<PersonalizationManager *>(data);
        if (!integration) {
            qWarning() << "integration is nullptr!!!";
            return;
        }

        integration->init(registry, id, version);
    }
}

PersonalizationAppearanceContext::PersonalizationAppearanceContext(struct ::treeland_personalization_appearance_context_v1 *context, TreeLandWorker *worker)
    : QWaylandClientExtensionTemplate<PersonalizationAppearanceContext>(1)
    , QtWayland::treeland_personalization_appearance_context_v1(context)
    , m_work(worker)
{
    get_round_corner_radius();
    get_icon_theme();
    get_active_color();
    get_blur_opacity();
    get_window_theme_type();
}

void PersonalizationAppearanceContext::treeland_personalization_appearance_context_v1_round_corner_radius(int32_t radius)
{
    m_work->setWindowRadius(radius);
}

void PersonalizationAppearanceContext::treeland_personalization_appearance_context_v1_icon_theme(const QString &theme_name)
{
    m_work->setIconTheme(theme_name);
}

void PersonalizationAppearanceContext::treeland_personalization_appearance_context_v1_active_color(const QString &active_color)
{
    m_work->setActiveColor(active_color);
}

void PersonalizationAppearanceContext::treeland_personalization_appearance_context_v1_blur_opacity(uint32_t opacity)
{
    m_work->setOpacity(opacity);
}

void PersonalizationAppearanceContext::treeland_personalization_appearance_context_v1_window_theme_type(uint32_t type)
{
    if (type == theme_type_light) {
        m_work->setAppearanceTheme(".light");
    } else if (type == theme_type_dark) {
        m_work->setAppearanceTheme(".dark");
    } else if (type == theme_type_auto) {
        m_work->setAppearanceTheme("");
    }
}

PersonalizationWallpaperContext::PersonalizationWallpaperContext(struct ::treeland_personalization_wallpaper_context_v1 *context)
    : QWaylandClientExtensionTemplate<PersonalizationWallpaperContext>(1)
    , QtWayland::treeland_personalization_wallpaper_context_v1(context)
{

}

void PersonalizationWallpaperContext::treeland_personalization_wallpaper_context_v1_metadata(
    const QString &metadata)
{
    Q_EMIT metadataChanged(metadata);
}

PersonalizationCursorContext::PersonalizationCursorContext(struct ::treeland_personalization_cursor_context_v1 *context, TreeLandWorker *woker)
    : QWaylandClientExtensionTemplate<PersonalizationCursorContext>(1)
    , QtWayland::treeland_personalization_cursor_context_v1(context)
    , m_worker(woker)
{
    get_theme();
}

void PersonalizationCursorContext::treeland_personalization_cursor_context_v1_theme(const QString &name)
{
    m_worker->setCursorTheme(name);
}

PersonalizationFontContext::PersonalizationFontContext(struct ::treeland_personalization_font_context_v1 *context, TreeLandWorker *woker)
    : QWaylandClientExtensionTemplate<PersonalizationFontContext>(1)
    , QtWayland::treeland_personalization_font_context_v1(context)
    , m_worker(woker)
{
    // get_font();
    // get_monospace_font();
    // get_font_size();
}

void PersonalizationFontContext::treeland_personalization_font_context_v1_font(const QString &font_name)
{
    m_worker->setFontName(font_name);
}

void PersonalizationFontContext::treeland_personalization_font_context_v1_monospace_font(const QString &font_name)
{
    m_worker->setMonoFontName(font_name);
}

void PersonalizationFontContext::treeland_personalization_font_context_v1_font_size(uint32_t font_size)
{
    m_worker->setFontSize(font_size);
}
