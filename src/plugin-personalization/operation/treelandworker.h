#pragma once

#include <QtWaylandClient/QWaylandClientExtension>
#include <cstdint>
#include "qwayland-treeland-personalization-manager-v1.h"
#include <dtkgui_global.h>
#include <qlogging.h>
#include <qpointer.h>
#include <qscopedpointer.h>
#include <qtclasshelpermacros.h>
#include <qwaylandclientextension.h>
#include <private/qwaylanddisplay_p.h>

#include "personalizationworker.h"
#include "wayland-treeland-personalization-manager-v1-client-protocol.h"

class PersonalizationManager;
class PersonalizationAppearanceContext;
class PersonalizationWindowContext;
class PersonalizationWallpaperContext;
class PersonalizationCursorContext;
class PersonalizationFontContext;

class TreeLandWorker : public PersonalizationWorker
{
Q_OBJECT
public:
    struct WallpaperMetaData
    {
        bool isDark;
        QString url;
        QString monitorName;
    };

    TreeLandWorker(PersonalizationModel *model, QObject *parent = nullptr);

    void setBackgroundForMonitor(const QString &monitorName, const QString &url) override;
    QString getBackgroundForMonitor(const QString &monitorName);

    void setDefault(const QJsonObject &value) override;

    void setAppearanceTheme(const QString &id) override;
    QString appearanceTheme() const { return m_appearanceTheme; }

    void setFontName(const QString& fontName);
    QString fontName() const { return m_fontName; }

    void setMonoFontName(const QString& monoFontName);
    QString monoFontName() const { return m_monoFontName; }

    void setIconTheme(const QString &id) override;
    QString iconTheme() const { return m_iconTheme; }

    void setCursorTheme(const QString &id) override;
    QString cursorTheme() const { return m_cursorTheme; }

    void setActiveColor(const QString &hexColor) override;
    QString activeColor() const { return m_activeColor; }

    void setFontSize(const int value) override;
    int fontSize() const { return m_fontSize; }

    void setTitleBarHeight(int value) override;
    int titleBarHeight() const { return m_titleBarHeight; }

    void setWindowRadius(int radius) override;
    int windowRadius() const { return m_windowRadius; }

    void setOpacity(const int value) override;
    int opacity() const { return m_opacity; }

    void active() override;
    void init();

public slots:
    void onWallpaperUrlsChanged() override;

signals:
    void wallpaperChanged();
    void ApppearanceThemeChanged(const QString &id);
    void IconThemeChanged(const QString &id);
    void CursorThemeChanged(const QString &id);

private:
    void wallpaperMetaDataChanged(const QString &data);

private:
    QScopedPointer<PersonalizationManager> m_personalizationManager;
    QScopedPointer<PersonalizationAppearanceContext> m_appearanceContext;
    QScopedPointer<PersonalizationWallpaperContext> m_wallpaperContext;
    QScopedPointer<PersonalizationCursorContext> m_cursorContext;
    QScopedPointer<PersonalizationFontContext> m_fontContext;
    QScopedPointer<PersonalizationWindowContext> m_windowContext;

    QMap<QString, WallpaperMetaData *> m_wallpapers;
    QString m_appearanceTheme;
    QString m_fontName;
    QString m_monoFontName;
    QString m_iconTheme;
    QString m_cursorTheme;
    QString m_activeColor;
    int m_fontSize;
    int m_titleBarHeight;
    int m_windowRadius;
    int m_opacity;
};

class PersonalizationManager: public QWaylandClientExtensionTemplate<PersonalizationManager>,
                              public QtWayland::treeland_personalization_manager_v1
{
    Q_OBJECT
public:
    explicit PersonalizationManager(QObject *parent = nullptr);

private:
    void addListener();
    void removeListener();

    static void handleListenerGlobal(void *data, wl_registry *registry, uint32_t id, const QString &interface, uint32_t version);

private:
    QtWaylandClient::QWaylandDisplay *m_waylandDisplay = nullptr;
};

class PersonalizationWindowContext : public QWaylandClientExtensionTemplate<PersonalizationWindowContext>,
                                     public QtWayland::treeland_personalization_window_context_v1
{
    Q_OBJECT
public:
    explicit PersonalizationWindowContext(struct ::treeland_personalization_window_context_v1 *context);

private:
    bool m_noTitlebar;
    int m_windowRadius;
};

class PersonalizationAppearanceContext : public QWaylandClientExtensionTemplate<PersonalizationAppearanceContext>,
                                         public QtWayland::treeland_personalization_appearance_context_v1
{
    Q_OBJECT

public:
    explicit PersonalizationAppearanceContext(struct ::treeland_personalization_appearance_context_v1 *context, TreeLandWorker *worker);

protected:
    void treeland_personalization_appearance_context_v1_round_corner_radius(int32_t radius) override;
    void treeland_personalization_appearance_context_v1_icon_theme(const QString &theme_name) override;
    void treeland_personalization_appearance_context_v1_active_color(const QString &active_color) override;
    void treeland_personalization_appearance_context_v1_blur_opacity(uint32_t opacity) override;
    void treeland_personalization_appearance_context_v1_window_theme_type(uint32_t type) override;
private:
    TreeLandWorker *m_work;
};

class PersonalizationWallpaperContext : public QWaylandClientExtensionTemplate<PersonalizationWallpaperContext>,
                                        public QtWayland::treeland_personalization_wallpaper_context_v1
{
    Q_OBJECT
public:
    explicit PersonalizationWallpaperContext(struct ::treeland_personalization_wallpaper_context_v1 *context);

Q_SIGNALS:
    void metadataChanged(const QString &meta);

protected:
    void treeland_personalization_wallpaper_context_v1_metadata(const QString &metadata) override;
};

class PersonalizationCursorContext : public QWaylandClientExtensionTemplate<PersonalizationCursorContext>,
                                     public QtWayland::treeland_personalization_cursor_context_v1
{
    Q_OBJECT
public:
    explicit PersonalizationCursorContext(struct ::treeland_personalization_cursor_context_v1 *context, TreeLandWorker *worker);

protected:
    void treeland_personalization_cursor_context_v1_theme(const QString &name) override;

private:
    TreeLandWorker *m_worker;
};

class PersonalizationFontContext : public QWaylandClientExtensionTemplate<PersonalizationFontContext>,
                                   public QtWayland::treeland_personalization_font_context_v1
{
    Q_OBJECT
public:
    explicit PersonalizationFontContext(struct ::treeland_personalization_font_context_v1 *context, TreeLandWorker *worker);

protected:
    void treeland_personalization_font_context_v1_font(const QString &font_name) override;
    void treeland_personalization_font_context_v1_monospace_font(const QString &font_name) override;
    void treeland_personalization_font_context_v1_font_size(uint32_t font_size) override;

private:
    TreeLandWorker *m_worker;
};
