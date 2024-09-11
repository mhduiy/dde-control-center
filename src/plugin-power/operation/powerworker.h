//SPDX-FileCopyrightText: 2018 - 2023 UnionTech Software Technology Co., Ltd.
//
//SPDX-License-Identifier: GPL-3.0-or-later
#ifndef POWERWORKER_H
#define POWERWORKER_H

#include "powerdbusproxy.h"
#include <qcontainerfwd.h>
#include <QObject>
#include <DConfig>

enum DelayControlType {
    DCT_BatteryLockDelay = 0,
    DCT_BatterySleepDelay,
    DCT_BatteryScreenBlackDelay,
    DCT_LinePowerLockDelay,
    DCT_LinePowerSleepDelay,
    DCT_LinePowerScreenBlackDelay
};

class PowerModel;
class PowerWorker : public QObject
{
    Q_OBJECT

public:
    explicit PowerWorker(PowerModel *model, QObject *parent = 0);

    void active();
    void deactive();

public Q_SLOTS:
    void setScreenBlackLock(const bool lock);
    void setSleepLock(const bool lock);
    void setSleepOnLidOnPowerClosed(const bool sleep);
    void setSleepDelayOnPower(const int delay);
    void setSleepDelayOnBattery(const int delay);
    void setScreenBlackDelayOnPower(const int delay);
    void setScreenBlackDelayOnBattery(const int delay);
    void setSleepDelayToModelOnPower(const int delay);
    void setScreenBlackDelayToModelOnPower(const int delay);
    void setSleepDelayToModelOnBattery(const int delay);
    void setScreenBlackDelayToModelOnBattery(const int delay);
    void setLockScreenDelayOnBattery(const int delay);
    void setLockScreenDelayOnPower(const int delay);
    void setResponseBatteryLockScreenDelay(const int delay);
    void setResponsePowerLockScreenDelay(const int delay);
    void setHighPerformanceSupported(bool state);
    void setBalancePerformanceSupported(bool state);
    //------------sp2 add-----------------------
    void setPowerSavingModeAutoWhenQuantifyLow(bool bLowBatteryAutoIntoSaveEnergyMode);
    void setPowerSavingModeAuto(bool bAutoIntoSaveEnergyMode);
    void setPowerSavingModeLowerBrightnessThreshold(uint dPowerSavingModeLowerBrightnessThreshold);
    void setPowerSavingModeAutoBatteryPercentage(uint dPowerSavingModebatteryPentage);
    void setLinePowerPressPowerBtnAction(int nLinePowerPressPowerBtnAction);
    void setLinePowerLidClosedAction(int nLinePowerLidClosedAction);
    void setBatteryPressPowerBtnAction(int nBatteryPressPowerBtnAction);
    void setBatteryLidClosedAction(int nBatteryLidClosedAction);
    void setLowPowerNotifyEnable(bool bLowPowerNotifyEnable);
    void setLowPowerNotifyThreshold(int dLowPowerNotifyThreshold);
    void setLowPowerAutoSleepThreshold(int dLowPowerAutoSleepThreshold);
    //------------------------------------------
    void setPowerPlan(const QString &powerPlan);
    void setShowBatteryTimeToFull(bool value);

    bool getCurCanSuspend();
    bool getCurCanHibernate();

    void setEnablePowerSave(const bool isEnable);

    int getMaxBacklightBrightness();

    QStringList getConfigList() {
        return {"1m", "10m", "30m", "4m", "5m", "6m", "6h"};
    }

private:
    void readDelayConfig(DelayControlType type);
    QVariantList converToDataMap(const QStringList& conf);

private:
    PowerModel *m_powerModel;
    PowerDBusProxy *m_powerDBusProxy;

    Dtk::Core::DConfig *m_cfgDock;
    Dtk::Core::DConfig *m_cfgPower;
};

#endif // POWERWORKER_H
