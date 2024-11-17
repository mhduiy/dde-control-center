// SPDX-FileCopyrightText: 2024 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later

#include "privacysecurityexport.h"
#include "dccfactory.h"
#include <qt6/QtCore/qobject.h>

PrivacySecurityExport::PrivacySecurityExport(QObject *parent)
:QObject(parent)
{

}

DCC_FACTORY_CLASS(PrivacySecurityExport)

#include "privacysecurityexport.moc"