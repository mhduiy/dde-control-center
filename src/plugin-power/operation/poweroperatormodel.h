#ifndef POWEROPERATORMODEL_H
#define POWEROPERATORMODEL_H

#include <qlist.h>
#include <qtypes.h>
#include <QAbstractListModel>

enum PowerOperatorRole 
{
    ValueRole = Qt::UserRole + 1,
    TextRole,
    VisibleRole,
    EnableRole,
};

struct PowerOperator
{
    quint8 value;
    QString text;
    bool visible;
    bool enable;
    PowerOperator(quint8 value, QString text, bool visible = true, bool enable = true)
        : value(value), text(text), visible(visible), enable(enable) {}
};

class PowerOperatorModel : public QAbstractListModel
{
    Q_OBJECT
public:
    PowerOperatorModel(QObject *parent = nullptr);
    ~PowerOperatorModel();
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    void appendRow(PowerOperator *info);
    int rowCount(const QModelIndex &parent= QModelIndex()) const override;;
    void setEnable(int index, bool enable);
    void setVisible(int index, bool visible);

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<PowerOperator *> m_powerOperatorList;
};

#endif // POWEROPERATORMODEL_H