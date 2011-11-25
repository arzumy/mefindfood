Food.stores.Locations = new Ext.data.Store {
  model: 'location'
  proxy: 
    type: 'ajax'
    url: ''
    reader:
      type: 'json'
  listeners:
    beforeload: ->
}