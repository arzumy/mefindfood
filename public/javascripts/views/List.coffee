# List
Food.views.List = Ext.extend Ext.Panel, {
  fullscreen: true
  initComponent: ->
    # local declarations for items in component
    list =
      xtype: 'list'
      itemTpl: '<tpl for=".">{name} <tpl for="location">{distance}<br>{lat}<br>{lng}</tp></tpl>'
      grouped: false
      store: ''
      listeners:
        beforerender:->
          store = Food.stores.Locations
          store.proxy.url = window.POS.url
          store.load()
          @bindStore( store )

    toggleView =
      xtype: 'segmentedbutton'
      items: [ { text: 'Distance', pressed: true }, { text: 'Popularity' } ]
      listeners: {
        toggle: (container, button , pressed)->
      }

    toolbar =
      docked: top
      xtype: 'toolbar'
      title: 'List'
      items: [ { xtype: 'spacer' }, toggleView ]

    sheet =
      xtype: 'carousel'
      cardSwitchAnimation: 'fade'
      layout: 'fit'
      height: '100%'
      items: [ list ]

    Ext.apply @, {
      id: 'list-food'
      layout: 'fit'
      dockedItems: [ toolbar ]
      items: [ list ]
    }

    Food.views.List.superclass.initComponent.call @
}

Ext.reg('listfood', Food.views.List)