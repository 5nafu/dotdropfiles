#!/bin/sh
AC_BLANK=$(xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac)
AC_OFF=$(xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off)
AC_SLEEP=$(xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep)
revert () {
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s $AC_BLANK
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s $AC_OFF
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -s $AC_SLEEP
}
trap revert HUP INT TERM

xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 1
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0
i3lock -f -n -c 000000 
revert

# make xflock4 use this script with the following setting:
# xfconf-query -c xfce4-session -p /general/LockCommand -s "/path/to/lock_screen.sh" --create -t string
