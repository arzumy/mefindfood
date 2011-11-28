# List
Food.views.List = Ext.extend Ext.Panel, {
  fullscreen: true
  initComponent: ->
    # local declarations for items in component
    tmpl = new Ext.XTemplate('''
      <tpl for=".">
        <div class="title">
          {name}
        </div>
        <tpl for="location">
          <div class="like"><span>{distance:this.toKM}</span> </div>
        </tpl>
        <tpl for="stats">
          <div class="popular"><span>{checkinsCount} Likes</span></div>
        </tpl>
      </tpl>'''
      , { toKM: (str)-> (str.toPrecision(3)).toString().replace('e+3', '').replace('e+4', '') + 'KM' }
    )

    list =
      xtype: 'list'
      itemTpl: tmpl
      grouped: false
      store: ''
      height: '100%'
      plugins: [ new Ext.ux.touch.ListOptions({
        enableSoundEffects: true
        allowMultiple: true
        hideOnScroll: true
        menuOptions: [
          {
            id: 'Team Icon Tapped'
            cls: 'team'
            html: 'team'
            enabled: true
          }
          {
            id: 'Favourite Icon Tapped'
            cls: 'favourite'
            text: 'favourites'
          }
          {
            id: 'Cart Icon Tapped'
            cls: 'shop'
          }
          {
            id: 'Share Icon Tapped'
            cls: 'share'
          }
        ]
      })]
      listeners:
        beforerender:->
          store = Food.stores.Locations
          store.proxy.url = window.POS.url
          store.load()
          @bindStore( store )
        menuoptiontap: (data, record)->
          Ext.Msg.alert('List Option Tapped', data.id + ' for ' + record.data.name + ' ' + record.data.location.distance, Ext.emptyFn)

    toggleView =
      xtype: 'segmentedbutton'
      items: [ { text: 'Distance', pressed: true }, { text: 'Popularity' } ]
      listeners: {
        toggle: (container, button , pressed)->
          list.store = Food.stores.Locations
          list.store.proxy.url = window.POS.url
          switch button.text
            when 'Distance' then list.store.sort('distance', 'DESC');
            when 'Popularity' then list.store.sort('popularity', 'DESC')
          list.store.load()
      }

    toolbar =
      dock: 'top'
      xtype: 'toolbar'
      defaults:
        iconMask: true
        ui: 'plain'
      layout:
        pack: 'center'
      items: [ {text: 'Sort by'}, toggleView ]
    
    searchbar =
      xtype:  'searchfield'
      name: 'search'
      label: 'search'
      handler: @searchEvents
      scope: @

    Ext.apply @, {
      cls: 'list-panel'
      centered: true
      layout: 'fit'
      dockedItems: [ toolbar ]
      items: [ list ]
    }

    Food.views.List.superclass.initComponent.call @
}

Ext.reg('listfood', Food.views.List)