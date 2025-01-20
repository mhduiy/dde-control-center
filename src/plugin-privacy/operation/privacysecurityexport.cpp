// SPDX-FileCopyrightText: 2024 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "privacysecurityexport.h"
#include "dccfactory.h"
#include <qlogging.h>
#include <qt6/QtCore/qobject.h>
#include "operation/applicationitem.h"
#include "operation/privacysecuritymodel.h"
#include "operation/privacysecurityworker.h"
#include <QtQml>


PrivacySecurityExport::PrivacySecurityExport(QObject *parent)
    : QObject(parent)
    , m_privacyModel(new PrivacySecurityModel(this))
    , m_woker(new PrivacySecurityWorker(m_privacyModel, this))
{
    m_appsModel = m_privacyModel->appModel();

    qmlRegisterType<ApplicationItem>("org.deepin.dcc.privacy", 1, 0, "ApplicationItem");
}


void PrivacySecurityExport::initData()
{

}

DCC_FACTORY_CLASS(PrivacySecurityExport)

#include "privacysecurityexport.moc"
