#
# Copyright (c) 2019 Alexander Sporn. All rights reserved.
#

{EventEmitter} = require 'events'
SerialPort = require 'serialport'
EnoceanJS = require 'enocean-js'


module.exports = class Enocean extends EventEmitter
  constructor: (@options) ->
    super()
    @port = new SerialPort(@options.port, baudRate: 57600)
    @parser = @port.pipe new EnoceanJS.ESP3Parser()
    @transformer = @parser.pipe new EnoceanJS.ESP3Transformer()

    @port.on 'open', =>
      console.log 'Opened port ' + @options.port

    @port.on 'error', (error) =>
      @emit 'error', error

    @transformer.on 'data', (data) =>
      msg = data.decode "f6-02-01"

      unless msg? and msg.R2?
        return

      switch msg.R1.rawValue
        when 0 then button = "AI"
        when 1 then button = "A0"
        when 2 then button = "BI"
        when 3 then button = "B0"
        else return

      switch msg.EB.rawValue
        when 1 then @emit 'pressed', data.senderId, button
        else return

      
