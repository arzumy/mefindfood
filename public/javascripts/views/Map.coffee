# Map
Food.views.Map = Ext.extend Ext.Panel, {
  layout: 'auto'
  initComponent: ->
    loader = new Ext.LoadMask Ext.getBody(), { msg: 'Loading...' }

    searchbar = {
      xtype:  'searchfield'
      handler: @searchEvents
      scope: @
    }

    toolbar = {
      id: 'toolbar'
      xtype: 'toolbar'
      docked: 'top'
      title:  'Food My Ass'
      items: [{xtype: 'spacer'} ]
    }

    image = new google.maps.MarkerImage(
      '../../images/point.png',
      new google.maps.Size(32, 31),
      new google.maps.Point(0,0),
      new google.maps.Point(16, 31)
    )

    shadow = new google.maps.MarkerImage(
      '../../images/shadow.png',
      new google.maps.Size(64, 52),
      new google.maps.Point(0,0),
      new google.maps.Point(-5, 42)
    )

    userLocationLat = window.POS.lat   
    userLocationLng = window.POS.lng
    position = new google.maps.LatLng(userLocationLat, userLocationLng)

    location = new Ext.regModel 'location', {
      fields: [ 'name', 'location' ]
    }

    map =  new Ext.Map {
      useCurrentLocation: true
      mapOptions:
        center : position
        zoom : 15
        scaleControl: true
        mapTypeId : google.maps.MapTypeId.ROADMAP
        navigationControl: true
        navigationControlOptions:
          style: google.maps.NavigationControlStyle.DEFAULT
      
      plugins: [
        new Ext.plugin.GMap.Tracker {
          trackSuspended : true
          highAccuracy   : false
          marker : new google.maps.Marker {
              position: position
              title : 'My Current Location'
              # shadow: shadow
              # icon  : image
          }
        },
        new Ext.plugin.GMap.Traffic({ hidden : true })
      ]

      listeners:
        mapRender: (component, map)->
          store = Food.stores.Locations
          store.data.items.forEach( (item) ->
            m = new google.maps.LatLng(item.data.location.lat, item.data.location.lng)
            marker = new google.maps.Marker {
                 position: m
                 title : item.data.name
                 map: map
            }
            google.maps.event.addListener marker, 'click', ->
                 infowindow.open(map, marker)

            setTimeout( -> 
              map.panTo(m) 
            , 1000 )
          )
          
    }

    sheet = {
      id: 'carousel'
      xtype: 'carousel'
      cardSwitchAnimation: 'fade'
      layout: 'fit'
      height: '100%'
      items: [map]
    }

    Ext.apply this, {
      scroll: false
      centered: true
      dockedItems: [toolbar]
      items: [map]
    }

    Food.views.Map.superclass.initComponent.call @
}

Ext.reg('map', Food.views.Map);
