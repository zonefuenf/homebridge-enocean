#
# Copyright (c) 2019 Alexander Sporn. All rights reserved.
#

Enocean = require './Enocean'

Accessory = undefined
Service = undefined
Characteristic = undefined
UUIDGen = undefined

module.exports = (homebridge) ->
  Accessory = homebridge.platformAccessory
  Service = homebridge.hap.Service
  Characteristic = homebridge.hap.Characteristic
  UUIDGen = homebridge.hap.uuid

  homebridge.registerPlatform 'homebridge-enocean-zonefuenf', 'enocean-zonefuenf', EnoceanPlatform, true
  return

EnoceanPlatform = (@log, @config, @api) ->

  if !@config?
    @log "No configuration found!"
    return
  if !@config.port?
    @log "Property port in configuration has to be set!"
    return

  @accessories = {}
  @enocean = new Enocean(port: @config.port)

  @enocean.on 'pressed', (sender, button) =>
    @setSwitchEventValue(sender, button, Characteristic.ProgrammableSwitchEvent.SINGLE_PRESS)

  @api.on 'didFinishLaunching', =>
    for accessory in @config.accessories
      @addAccessory(accessory)
    return

  return

EnoceanPlatform::setSwitchEventValue = (sender, button, value, logOn) ->
  accessory = @accessories[sender]

  unless accessory?
    @log 'Unknown sender', sender

  for service in accessory.services
    if service.UUID == Service.StatelessProgrammableSwitch.UUID and service.subtype == button
      characteristic = service.getCharacteristic(Characteristic.ProgrammableSwitchEvent)
      characteristic.setValue(value)
      if logOn 
        @log accessory.displayName+':', 'Button', button, 'pressed'
      return
  @log 'Could not find button', button
  return

EnoceanPlatform::configureAccessory = (accessory) ->
  @log 'Configure accessory:', accessory.displayName

  accessory.reachable = true
  accessory.on 'identify', (paired, callback) =>
    @log accessory.displayName, 'identified'
    callback()
    return

  serial = accessory.getService(Service.AccessoryInformation).getCharacteristic(Characteristic.SerialNumber).value
  unless serial?
      @api.unregisterPlatformAccessories 'homebridge-enocean-zonefuenf', 'enocean-zonefuenf', [ accessory ]
      return
  @accessories[serial] = accessory

  @setSwitchEventValue(serial, 'A0', -1)
  @setSwitchEventValue(serial, 'AI', -1)
  @setSwitchEventValue(serial, 'B0', -1)
  @setSwitchEventValue(serial, 'BI', -1)

  return

EnoceanPlatform::createProgrammableSwitch = (name, model, serial) ->

  uuid = UUIDGen.generate(serial)

  accessory = new Accessory(name, uuid)
  accessory.on 'identify', (paired, callback) =>
    @log accessory.displayName, 'identfied'
    callback()
    return

  info = accessory.getService(Service.AccessoryInformation)
  info.updateCharacteristic(Characteristic.Manufacturer, "EnOcean")
    .updateCharacteristic(Characteristic.Model, model)
    .updateCharacteristic(Characteristic.SerialNumber, serial)
    .updateCharacteristic(Characteristic.FirmwareRevision, '1.0')

  label = new Service.ServiceLabel(accessory.displayName)
  label.getCharacteristic(Characteristic.ServiceLabelNamespace).updateValue(Characteristic.ServiceLabelNamespace.ARABIC_NUMERALS)

  accessory.addService(label)

  buttonAI = @createProgrammableSwitchButton(accessory.displayName, 1, 'AI')
  buttonA0 = @createProgrammableSwitchButton(accessory.displayName, 2, 'A0')
  buttonBI = @createProgrammableSwitchButton(accessory.displayName, 3, 'BI')
  buttonB0 = @createProgrammableSwitchButton(accessory.displayName, 4, 'B0')

  accessory.addService(buttonAI)
  accessory.addService(buttonA0)
  accessory.addService(buttonBI)
  accessory.addService(buttonB0)

  return accessory

EnoceanPlatform::createProgrammableSwitchButton = (accesoryName, buttonIndex, button) ->

  button = new Service.StatelessProgrammableSwitch(accesoryName + ' ' + button, button)
  singleButton =
    minValue: Characteristic.ProgrammableSwitchEvent.SINGLE_PRESS
    maxValue: Characteristic.ProgrammableSwitchEvent.SINGLE_PRESS
  button.getCharacteristic(Characteristic.ProgrammableSwitchEvent).setProps(singleButton)
  button.getCharacteristic(Characteristic.ServiceLabelIndex).setValue(buttonIndex)
  return button

EnoceanPlatform::addAccessory = (config) ->
  if @accessories[config.id]?
    return

  @log 'Add new accessory:', config.name
  
  accessory = @createProgrammableSwitch(config.name, config.eep, config.id)  

  @accessories[config.id] = accessory
  @api.registerPlatformAccessories 'homebridge-enocean-zonefuenf', 'enocean-zonefuenf', [ accessory ]
  return
