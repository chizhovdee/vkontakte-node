_ = require('lodash')
Encryptor = require('simple-encryptor')

config = require('./config')
User = require('./user')
Api = require('./api')

class Middleware
  @VK_PARAMS_NAMES: ['api_url', 'api_id', 'user_id', 'sid', 'secret', 'group_id', 'viewer_id', 'viewer_type',
     'is_app_user', 'is_secure', 'auth_key', 'language', 'parent_language', 'api_result', 'api_settings',
     'access_token', 'hash', 'lc_name', 'ad_info', 'ads_app_id'
  ]

  #@EXCLUDED_PARAMS: []

  constructor: (@request, @response)->
    @config = _.clone(config.default())

    @params = {}
    _.assignIn(@params, @request.query) unless _.isEmpty(@request.query)
    _.assignIn(@params, @request.params) unless _.isEmpty(@request.params)
    _.assignIn(@params, @request.body) unless _.isEmpty(@request.body)

  setUp: ->
    @request['SIGNED-PARAMS'] = @request.get('SIGNED-PARAMS') || @params['signed_params']

    @request.vkontakte = {
      currentUser: @.fetchVkUser()
      isVkCanvas: @.isVkCanvas()
      apiClient: new Api()
      vkSignedParams: @.vkSignedParams()
    }

  vkParams: ->
    _.pick(@params, Middleware.VK_PARAMS_NAMES)

  paramsWithoutVkData: ->
    _.omit(@params, Middleware.VK_PARAMS_NAMES)

  vkSignedParams: ->
    vkParams = @.vkParams()

    if vkParams['access_token']?.length > 0
      @.encrypt(vkParams)
    else
      @request['SIGNED-PARAMS'] || @params['signed_params'] || @request.flash?('signed_params')

  encrypt: (params)->
    encryptor = new Encryptor("secret_key_#{ @config['appId'] }_#{ @config['appSecret'] }")

    encryptor.encrypt(params)

  decrypt: (encryptedParams)->
    encryptor = new Encryptor("secret_key_#{ @config['appId'] }_#{ @config['appSecret'] }")

    result = encryptor.decrypt(encryptedParams)

    unless result
      console.error new Error("\nError while decoding vkontakte params: \"#{ encryptedParams }\"")

    result

  fetchVkUser: ->
    vkParams = @.vkParams()

    paramsForUser = (
      if vkParams['access_token']?.length > 0
        vkParams
      else
        @.vkSignedParams()
    )

    User.fromVkParams(@config, paramsForUser)

  isVkCanvas: ->
    @.vkParams()['access_token']?.length > 0 || @request['SIGNED-PARAMS'] || @request.flash?('signed_params')?


module.exports = (req, res, next)->
  new Middleware(req, res).setUp() # extend request object

  next()