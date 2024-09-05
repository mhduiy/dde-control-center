//SPDX-FileCopyrightText: 2018 - 2023 UnionTech Software Technology Co., Ltd.
//
//SPDX-License-Identifier: GPL-3.0-or-later
#ifndef POWERWORKER_H
#define POWERWORKER_H

#include "powerdbusproxy.h"
#include <qtmetamacros.h>
#include <QObject>

class PowerModel;
class PowerWorker : public QObject
{
    Q_OBJECT

public:
    explicit PowerWorker(PowerModel *model, QObject *parent = 0);

    void active();
    void deactive();

public Q_SLOTS:
    Q_INVOKABLE void setScreenBlackLock(const bool lock);
    void setSleepLock(const bool lock);
    void setSleepOnLidOnPowerClosed(const bool sleep);
    Q_INVOKABLE void setSleepDelayOnPower(const int delay);
    void setSleepDelayOnBattery(const int delay);
    Q_INVOKABLE void setScreenBlackDelayOnPower(const int delay);
    void setScreenBlackDelayOnBattery(const int delay);
    void setSleepDelayToModelOnPower(const int delay);
    void setScreenBlackDelayToModelOnPower(const int delay);
    void setSleepDelayToModelOnBattery(const int delay);
    void setScreenBlackDelayToModelOnBattery(const int delay);
    void setLockScreenDelayOnBattery(const int delay);
    Q_INVOKABLE void setLockScreenDelayOnPower(const int delay);
    void setResponseBatteryLockScreenDelay(const int delay);
    void setResponsePowerLockScreenDelay(const int delay);
    void setHighPerformanceSupported(bool state);
    void setBalancePerformanceSupported(bool state);
    //------------sp2 add-----------------------
    Q_INVOKABLE void setPowerSavingModeAutoWhenQuantifyLow(bool bLowBatteryAutoIntoSaveEnergyMode);
    void setPowerSavingModeAuto(bool bAutoIntoSaveEnergyMode);
    void setPowerSavingModeLowerBrightnessThreshold(uint dPowerSavingModeLowerBrightnessThreshold);
    void setPowerSavingModeAutoBatteryPercentage(uint dPowerSavingModebatteryPentage);
    void setLinePowerPressPowerBtnAction(int nLinePowerPressPowerBtnAction);
    Q_INVOKABLE void setLinePowerLidClosedAction(int nLinePowerLidClosedAction);
    void setBatteryPressPowerBtnAction(int nBatteryPressPowerBtnAction);
    void setBatteryLidClosedAction(int nBatteryLidClosedAction);
    void setLowPowerNotifyEnable(bool bLowPowerNotifyEnable);
    void setLowPowerNotifyThreshold(int dLowPowerNotifyThreshold);
    void setLowPowerAutoSleepThreshold(int dLowPowerAutoSleepThreshold);
    //------------------------------------------
    Q_INVOKABLE void setPowerPlan(const QString &powerPlan);

    bool getCurCanSuspend();
    bool getCurCanHibernate();

    void setEnablePowerSave(const bool isEnable);

    double getBatteryCapacity();
    int getMaxBacklightBrightness();

private:
    int converToDelayModel(int value);
    int converToDelayDBus(int value);

private:
    PowerModel *m_powerModel;
    PowerDBusProxy *m_powerDBusProxy;
};

#endif // POWERWORKER_H
