# @zonefuenf/homebridge-enocean-zonefuenf

This is a fork of [homebridge-enocean](https://github.com/alexsporn/homebridge-enocean) by Alexander Sporn I use to add bugfixes and changes relevant to my local use of this plugin. Feel free to use this any way you want.

## Instructions

A simple way to bridge your EnOcean switches to Homekit

Currently only rocker switches PTM210 and PTM215 (in normal mode) are supported.
This corresponds to the EnOcean EEP F6-02-01.

To use this you need a USB300 or TCM310 module connected to your homebridge computer.

To use it add this to your `config.json`:

```code
{
  "platforms": [
    {
      "name": "EnOcean",
      "port": "/dev/ttyUSB0",
      "logPresses": true,
      "accessories": [
        {
          "name": "Switch 1",
          "id": "abcdef",
          "eep": "f6-02-01"
        }
      ],
      "platform": "enocean-zonefuenf"
    }
  ]
}

```

The plugin supports the graphical settings functionality of homebridge-config-ui-x, so you can use that to manage your switch settings as well.
