# Viewport

Food.views.Viewport = Ext.extend Ext.TabPanel, {
    id : 'food'
    cardSwitchAnimation : 'slide'
    fullscreen: true
    tabBar:
      centered: true
      dock: 'bottom'
      scroll: false
      iconMask: true
      ui: 'dark'
      layout:
        pack:'center'
      strech: true
  initComponent: ()->
    @items = [
      {
        cls: 'nav-map'
        title: 'Map'
        xtype: 'map'
        iconCls: 'compass2'
      }
      {
        cls: 'nav-list'
        title: 'List'
        xtype: 'listfood'
        iconCls: 'list'
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