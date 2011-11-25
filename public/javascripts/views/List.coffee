# List

Food.models.Location = Ext.regModel 'Food.model.Location', {
  fields: [ 'name', 'location']
}

Food.stores.Locations = new Ext.data.Store {
  model: Food.models.Location
  autoLoad: true
  proxy: 
    type: 'ajax'
    url: "/venues/search?position="+ window.POS.lat+","+ window.POS.lng
    reader:
      type: 'json'
}

Food.views.List = Ext.extend Ext.Panel, {
  fullscreen: true
  initComponent: ->

    list = {
      xtype: 'list'
      itemTpl: '<tpl for=".">{name} <tpl for="location">{distance}<br>{lat}<br>{lng}</tp></tpl>'
      store: Food.stores.Locations
      grouped: false
    }

    toggleView = {
      xtype: 'segmentedbutton'
      items: [
        {
          text: 'Distance'
          pressed: true
        }
        {
          text: 'Popularity'
        }
      ]
      listeners: {
        # toggle: (container, button , pressed)->
        #   if button.text is 'Map'
        #     Ext.getCmp('carousel').setActiveItem(0)
        #   else
        #     Ext.getCmp('carousel').setActiveItem(1)
      }
    }

    toolbar = {
      docked: top
      xtype: 'toolbar'
      title: 'List'
      items: [
        {
          xtype: 'spacer'
        }, toggleView
      ]
    }

    sheet = {
      xtype: 'carousel'
      cardSwitchAnimation: 'fade'
      layout: 'fit'
      height: '100%'
      items: [list]
    }

    Ext.apply @, {
      id: 'list-food'
      layout: 'fit'
      dockedItems: [toolbar]
      items: [list]
    }

    Food.views.List.superclass.initComponent.call @
}

Ext.reg('listfood', Food.views.List)