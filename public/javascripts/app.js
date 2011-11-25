var POS, error, success;
POS = window.POS || {};
success = function(position) {
  return POS = {
    "lat": position.coords.latitude,
    "lng": position.coords.longitude
  };
};
error = function(error) {
  throw error;
};
if (navigator.geolocation) {
  navigator.geolocation.getCurrentPosition(success, error);
}
Ext.regApplication({
  name: 'Food',
  icon: '',
  tableIcon: '',
  launch: function() {
    return this.views.Viewport = new Food.views.Viewport();
  }
});
Food.views.Viewport = Ext.extend(Ext.TabPanel, {
  id: 'food',
  cardSwitchAnimation: 'slide',
  fullscreen: true,
  tabBar: {
    dock: 'bottom',
    scroll: false,
    layout: {
      pack: 'center'
    }
  },
  initComponent: function() {
    this.items = [
      {
        id: 'distance',
        iconMask: true,
        iconCls: 'star',
        title: 'Map',
        xtype: 'map'
      }, {
        id: 'list',
        iconMask: true,
        iconCls: 'star',
        title: 'List View',
        xtype: 'listfood'
      }
    ];
    return Food.views.Viewport.superclass.initComponent.call(this);
  },
  navigate: function(params) {
    return Ext.dispatch({
      controller: 'application',
      action: "goto(" + params + ")"
    });
  },
  reveal: function(target) {
    var direction;
    direction = target === 'dock' ? 'right' : 'left';
    return this.setActiveItem(Food.views[target], {
      type: 'slide',
      direction: direction
    });
  }
});
Food.models.Location = Ext.regModel('Food.model.Location', {
  fields: ['name', 'location']
});
Food.stores.Locations = new Ext.data.Store({
  model: Food.models.Location,
  autoLoad: true,
  proxy: {
    type: 'ajax',
    url: "/venues/search?position=" + window.POS.lat + "," + window.POS.lng,
    reader: {
      type: 'json'
    }
  }
});
Food.views.List = Ext.extend(Ext.Panel, {
  fullscreen: true,
  initComponent: function() {
    var list, sheet, toggleView, toolbar;
    list = {
      xtype: 'list',
      itemTpl: '<tpl for=".">{name} <tpl for="location">{distance}<br>{lat}<br>{lng}</tp></tpl>',
      store: Food.stores.Locations,
      grouped: false
    };
    toggleView = {
      xtype: 'segmentedbutton',
      items: [
        {
          text: 'Distance',
          pressed: true
        }, {
          text: 'Popularity'
        }
      ],
      listeners: {}
    };
    toolbar = {
      docked: top,
      xtype: 'toolbar',
      title: 'List',
      items: [
        {
          xtype: 'spacer'
        }, toggleView
      ]
    };
    sheet = {
      xtype: 'carousel',
      cardSwitchAnimation: 'fade',
      layout: 'fit',
      height: '100%',
      items: [list]
    };
    Ext.apply(this, {
      id: 'list-food',
      layout: 'fit',
      dockedItems: [toolbar],
      items: [list]
    });
    return Food.views.List.superclass.initComponent.call(this);
  }
});
Ext.reg('listfood', Food.views.List);
Food.views.Map = Ext.extend(Ext.Panel, {
  layout: 'auto',
  initComponent: function() {
    var image, loader, location, map, position, searchbar, shadow, sheet, toolbar, userLocationLat, userLocationLng;
    loader = new Ext.LoadMask(Ext.getBody(), {
      msg: 'Loading...'
    });
    searchbar = {
      xtype: 'searchfield',
      handler: this.searchEvents,
      scope: this
    };
    toolbar = {
      id: 'toolbar',
      xtype: 'toolbar',
      docked: 'top',
      title: 'Food My Ass',
      items: [
        {
          xtype: 'spacer'
        }
      ]
    };
    image = new google.maps.MarkerImage('../../images/point.png', new google.maps.Size(32, 31), new google.maps.Point(0, 0), new google.maps.Point(16, 31));
    shadow = new google.maps.MarkerImage('../../images/shadow.png', new google.maps.Size(64, 52), new google.maps.Point(0, 0), new google.maps.Point(-5, 42));
    userLocationLat = window.POS.lat;
    userLocationLng = window.POS.lng;
    position = new google.maps.LatLng(userLocationLat, userLocationLng);
    location = new Ext.regModel('location', {
      fields: ['name', 'location']
    });
    map = new Ext.Map({
      useCurrentLocation: true,
      mapOptions: {
        center: position,
        zoom: 15,
        scaleControl: true,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        navigationControl: true,
        navigationControlOptions: {
          style: google.maps.NavigationControlStyle.DEFAULT
        }
      },
      plugins: [
        new Ext.plugin.GMap.Tracker({
          trackSuspended: true,
          highAccuracy: false,
          marker: new google.maps.Marker({
            position: position,
            title: 'My Current Location'
          })
        }, new Ext.plugin.GMap.Traffic({
          hidden: true
        }))
      ],
      listeners: {
        mapRender: function(component, map) {
          var store;
          store = Food.stores.Locations;
          return store.data.items.forEach(function(item) {
            var m, marker;
            m = new google.maps.LatLng(item.data.location.lat, item.data.location.lng);
            marker = new google.maps.Marker({
              position: m,
              title: item.data.name,
              map: map
            });
            google.maps.event.addListener(marker, 'click', function() {
              return infowindow.open(map, marker);
            });
            return setTimeout(function() {
              return map.panTo(m);
            }, 1000);
          });
        }
      }
    });
    sheet = {
      id: 'carousel',
      xtype: 'carousel',
      cardSwitchAnimation: 'fade',
      layout: 'fit',
      height: '100%',
      items: [map]
    };
    Ext.apply(this, {
      scroll: false,
      centered: true,
      dockedItems: [toolbar],
      items: [map]
    });
    return Food.views.Map.superclass.initComponent.call(this);
  }
});
Ext.reg('map', Food.views.Map);