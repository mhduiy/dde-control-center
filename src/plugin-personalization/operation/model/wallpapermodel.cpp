// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later

#include "wallpapermodel.h"
#include <qlogging.h>
#include <qnamespace.h>
#include <qtypes.h>

WallpaperModel::WallpaperModel(QObject *parent) : QAbstractItemModel(parent)
{

}

QModelIndex WallpaperModel::index(int row, int column, const QModelIndex &parent) const
{
    if (row < 0 || row >= rowCount() || parent.isValid() || column != 0)
        return QModelIndex();

    return createIndex(row, 0);
}

QModelIndex WallpaperModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child)
    return QModelIndex();
}

int WallpaperModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return items.size();
}

int WallpaperModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 1;
}

QVariant WallpaperModel::data(const QModelIndex &index, int role) const
{
    auto node = itemNode(index);
    QVariant ret;
    if (!node)
        return ret;

    switch (role) {
    case Item_Url_Role:
        ret = node->url;
        break;
    case Item_deleteAble_Role:
        ret = node->deleteAble;
        break;
    case Item_lastModifiedTime_Role:
        ret = node->lastModifiedTime;
        break;
    default:
        break;
    }
    return ret;
}

Qt::ItemFlags WallpaperModel::flags(const QModelIndex &index) const
{
    Qt::ItemFlags flg = Qt::NoItemFlags;
    if (auto node = itemNode(index)) {
        flg |= Qt::ItemIsEnabled;
    }

    return flg;
}

void WallpaperModel::insertItem(int pos, WallpaperItemPtr it)
{
    if (pos < 0 || pos > rowCount() || it.isNull())
        pos = rowCount();

    beginInsertRows(QModelIndex(), pos, pos);
    items.insert(pos, it);
    endInsertRows();
}

void WallpaperModel::removeItem(const QString &item)
{
    auto idx = itemIndex(item);
    if (!idx.isValid())
        return;

    beginRemoveRows(QModelIndex(), idx.row(), idx.row());
    items.removeAt(idx.row());
    endRemoveRows();
}

WallpaperItemPtr WallpaperModel::itemNode(const QModelIndex &idx) const
{
    auto row = idx.row();
    if (row < 0 || row > rowCount())
        return {};

    return items.at(row);
}

QModelIndex WallpaperModel::itemIndex(const QString &item) const
{
    auto it = std::find_if(items.begin(), items.end(), [item](const WallpaperItemPtr &ptr) {
        return ptr->url == item;
    });

    if (it == items.end())
        return QModelIndex();
    auto row = items.indexOf(*it);
    return index(row, 0);
}

void WallpaperModel::resetData(const QList<WallpaperItemPtr> &list)
{
    beginResetModel();
    items = list;
    endResetModel();
}

QHash<int, QByteArray> WallpaperModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractItemModel::roleNames();;
    roles[Item_Url_Role] = "url";
    roles[Item_deleteAble_Role] = "deleteAble";
    roles[Item_lastModifiedTime_Role] = "lastModifiedTime";
    return roles;
}
