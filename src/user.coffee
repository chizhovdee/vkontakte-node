_ = require('lodash')
Encryptor = require('simple-encryptor')
md5 = require('md5')
Api = require('./api')

class User
  @fromVkParams: (config, params)->
    params = @.decrypt(config, params) if _.isString(params)

    return unless params && params['viewer_id'] && @.isSignatureValid(config, params)

    new @(params)

  @decrypt: (config, encryptedParams)->
    encryptor = new Encryptor("secret_key_#{ config['appId'] }_#{ config['appSecret'] }")

    result = encryptor.decrypt(encryptedParams)

    unless result?
      throw new Error("\nError while decoding vkontakte params: \"#{ encryptedParams }\"")

    result

  @isSignatureValid: (config, params)->
    params['auth_key'] == @.calculateSignature(config, params)

  @calculateSignature: (config, params)->
    md5([config['appId'], params['viewer_id'], config['appSecret']].join('_'))

  constructor: (@options = {})->

  uid: ->
    @options['viewer_id']

  accessToken: ->
    @options['access_token']

  sid: ->
    @options['sid']

  isAuthenticated: ->
    @.accessToken()? && @.accessToken().length > 0

  secret: ->
    @options['secret']

  referrer: ->
    @options['referrer']

  apiClient: ->
    @_apiClient ?= new Api(@.accessToken())

module.exports = User