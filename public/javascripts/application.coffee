POS = window.POS or {}
success = (position)->
  POS = 
    "lat" : position.coords.latitude
    "lng" : position.coords.longitude
    "url" : "/venues/search?position=#{position.coords.latitude},#{position.coords.longitude}"

error = (error)->
  throw error
    
if navigator.geolocation
  navigator.geolocation.getCurrentPosition success, error

Ext.regApplication {
  name: 'Food'
  icon: ''
  tableIcon: ''
  launch: ->
    @views.Viewport = new Food.views.Viewport()
}