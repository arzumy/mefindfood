# Map
Food.views.Map = Ext.extend Ext.Panel, {
  layout: 'auto'
  initComponent: ->
    loader = new Ext.LoadMask Ext.getBody(), { msg: 'Loading...' }
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

    # current user position
    position = new google.maps.LatLng( window.POS.lat , window.POS.lng )

    map =  new Ext.Map {
      useCurrentLocation: true

      mapOptions:
        center : position
        zoom : 12
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
              shadow: shadow
              icon  : image
          }
        },
        new Ext.plugin.GMap.Traffic({ hidden : true })
      ]

      listeners:
        mapRender: (component, map)->
          store = Food.stores.Locations
          store.proxy.url = window.POS.url
          store.load( (records, error)-> 
            records.forEach (record)->
              m = new google.maps.LatLng( record.data.location.lat, record.data.location.lng )
              marker = new google.maps.Marker {
                   position: m
                   title : record.data.name
                   map: map
              }
              google.maps.event.addListener marker, 'click', ->
                   new google.maps.infowindow.open(map, marker)

              # setTimeout( -> map.panTo(m) ,300)
          )
    }

    searchbar =
      xtype:  'searchfield'
      handler: @searchEvents
      scope: @

    toolbar =
      id: 'toolbar'
      xtype: 'toolbar'
      docked: 'top'
      title:  'Food My Ass'
      items: [ {xtype: 'spacer'} ]


    sheet =
      id: 'carousel'
      xtype: 'carousel'
      cardSwitchAnimation: 'fade'
      layout: 'fit'
      height: '100%'
      items: [ map ]

    Ext.apply this, {
      scroll: false
      centered: true
      dockedItems: [ toolbar ]
      items: [ map ]
    }

    Food.views.Map.superclass.initComponent.call @
}

Ext.reg('map', Food.views.Map);
