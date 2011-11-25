# Viewport

Food.views.Viewport = Ext.extend Ext.TabPanel, {
    id : 'food'
    cardSwitchAnimation : 'slide'
    fullscreen: true
    tabBar:
      dock: 'bottom'
      scroll: false
      layout:
        pack: 'center'
  
  initComponent: ()->
    @items = [
      {
        id: 'distance'
        iconMask: true
        iconCls: 'star'
        title: 'Map'
        xtype: 'map'
      }
      {
        id: 'list'
        iconMask: true
        iconCls: 'star'
        title: 'List View'
        xtype: 'listfood'
      }
    ]

    Food.views.Viewport.superclass.initComponent.call @
  
  navigate: (params) ->
    Ext.dispatch {
      controller: 'application'
      action: "goto(#{params})"
    }
  
  reveal: (target) ->
    direction = if target is 'dock' then 'right' else 'left'
    @setActiveItem Food.views[target], {
      type: 'slide'
      direction: direction
    }
}