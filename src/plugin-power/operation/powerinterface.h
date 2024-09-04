#ifndef POWERINTERFACE_H
#define POWERINTERFACE_H

#include <qobject.h>
#include <QObject>
#include "powermodel.h"
#include "powerworker.h"

class PowerInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PowerModel *model READ getModel NOTIFY powerModelChanged)
    Q_PROPERTY(PowerWorker *worker READ getWorker NOTIFY powerWorkerChanged)
public:
    explicit PowerInterface(QObject *parent = nullptr);
    PowerModel *getModel() const { return m_model; };
    PowerWorker *getWorker() const { return m_worker; };
signals:
    void powerModelChanged(PowerModel *model);
    void powerWorkerChanged(PowerWorker *worker);

private:
    PowerModel *m_model;
    PowerWorker *m_worker;
};

#endif // POWERINTERFACE_H