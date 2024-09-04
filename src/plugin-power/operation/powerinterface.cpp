#include "powerinterface.h"
#include "powermodel.h"
#include "dccfactory.h"

#include "utils.h"

PowerInterface::PowerInterface(QObject *parent) 
: QObject(parent)
, m_model(new PowerModel(this))
, m_worker(new PowerWorker(m_model, this))
{
    m_model->setSuspend(!IsServerSystem && true);
    m_model->setHibernate(!IsServerSystem && true);
    m_model->setShutdown(true);
}

DCC_FACTORY_CLASS(PowerInterface)

#include "powerinterface.moc"