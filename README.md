# @zonefuenf/homebridge-enocean

This is a fork of ![homebridge-enocean](https://github.com/alexsporn/homebridge-enocean) by Alexander Sporn I use to add bugfixes and changes relevant to my local use of this plugin. Feel free to use this any way you want.

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
      "platform": "enocean",
      "port": "/dev/ttyUSB0",       // port to your USB300 or TCM310 module
      "accessories": [
        {
          "id": "aabbccdd",         // sender id in lowercase. See sticker on the back
          "eep": "f6-02-01",        // rocker switch profile
          "name": "Kitchen switch"  // name for this switch
        }
      ]
    }
  ]
}

```
