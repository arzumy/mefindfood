# Map
Food.views.Map = Ext.extend Ext.Panel, {
  layout: 'auto'
  initComponent: ->
    loader = new Ext.LoadMask Ext.getBody(), { msg: 'Loading...' }
    image = new google.maps.MarkerImage(
      '../../images/icons/pin1.png',
      new google.maps.Size(40, 52),
      new google.maps.Point(0,0),
      new google.maps.Point(16, 52)
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
        zoom : 13
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
              c = "<div class='p'> #{record.data.name} </div>"
              p =
                maxWidth      : 300
                content       : c
                minHeight        : 80
                arrowPosition : 30
                arrowStyle    : 2
                borderRadius  : 3
                borderWidth   : 1
                # arrowStyle    : 2 
                # arrowSize     : 10,
                # backgroundClassName: 'phoney',
                # shadowStyle: 1,
                # padding: 0,
                # backgroundColor: 'rgb(57,57,57)',
                # borderRadius: 4,
                # borderWidth: 1,
                # borderColor: '#2c2c2c',
                # disableAutoPan: true,
                # hideCloseButton: false,
                # arrowPosition: 30,
                # maxWidth: 300
              m = new google.maps.LatLng( record.data.location.lat, record.data.location.lng )
              i = new InfoBubble p

              marker = new google.maps.Marker {
                position: m
                title : record.data.name
                map: map
                icon: new google.maps.MarkerImage(
                  '../../images/icons/pin2.png',
                  new google.maps.Size(40, 52),
                  new google.maps.Point(0,0),
                  new google.maps.Point(16, 52)
                  )
              }
              google.maps.event.addListener marker, 'click', -> i.open(map, marker)

              # setTimeout( -> map.panTo(m) ,300)
          )
    }

    toolbar =
      id: 'toolbar'
      xtype: 'toolbar'
      docked: 'top'
      title:  'Food My Ass'
      items: [ {xtype: 'spacer'}, {iconCls: 'star', ui: 'plain'} ]

    Ext.apply this, {
      scroll: false
      centered: true
      items: [ map ]
    }

    Food.views.Map.superclass.initComponent.call @

  searchEvents: (e)->
    value = e.currentTarget.value()
    console.log new RegExt(value or '.*', 'i')
}

Ext.reg('map', Food.views.Map);
