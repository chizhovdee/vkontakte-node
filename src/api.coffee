_ = require('lodash')
rp = require('request-promise')

config = require('./config')

class Api
  @REST_API_URL: "https://api.vk.com/method/"
  @OAUTH_URL: "https://oauth.vk.com/access_token"

  accessToken: null

  @canvasPageUrl: (protocol)->
    conf = config.default()

    "#{ protocol }www.vk.com/app#{ conf['appId'] }"

  @callbackUrl: (protocol)->
    conf = config.default()

    protocol + conf['callbackDomain']

  @iframeRedirectHtmlCode: (targetUrl, customCode)->
    """<html><head>
        <script type="text/javascript">
          window.top.location.href = "#{ targetUrl }";
        </script>
        <noscript>
          <meta http-equiv="refresh" content="0;url=#{ targetUrl }" />
          <meta http-equiv="window-target" content="_top" />
        </noscript>
        #{ customCode }
        </head></html>
    """

  # return Promise object
  @getAppAccessToken: ->
    conf = config.default()

    options = {
      uri: Api.OAUTH_URL
      qs: {
        client_id: conf['appId']
        client_secret: conf['appSecret']
        v: conf['apiVersion']
        grant_type: 'client_credentials'
      }
      json: true
    }

    rp(options) # return Request object as Promise

  constructor: (@accessToken)->

  # return Promise object
  call: (method, specificParams = {}, withAccessToken = true)->
    options = {
      uri: Api.REST_API_URL + method
      qs: @.signedCallParams(method, specificParams)
      json: true
    }

    if !withAccessToken || @accessToken?
      rp(options)
    else
      Api.getAppAccessToken()
      .then((data)=>
        @accessToken = data['access_token']

        rp(options)
      )

  signedCallParams: (method, specificParams = {})->
    conf = config.default()

    params = _.clone(specificParams)
    params['v'] = conf['apiVersion'] if conf['apiVersion']?
    params['access_token'] = @accessToken if @accessToken?
    params['client_secret'] = conf['appSecret'] if method.split('.')[0] == 'secure'

    params

  canvasPageUrl: (protocol)->
    Api.canvasPageUrl(protocol)

  callbackUrl: (protocol)->
    Api.callbackUrl(protocol)

  iframeRedirectHtmlCode: (targetUrl, customCode)->
    Api.iframeRedirectHtmlCode(targetUrl, customCode)

module.exports = Api