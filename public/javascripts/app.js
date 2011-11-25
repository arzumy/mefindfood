var POS, error, success;
POS = window.POS || {};
success = function(position) {
  return POS = {
    "lat": position.coords.latitude,
    "lng": position.coords.longitude,
    "url": "/venues/search?position=" + position.coords.latitude + "," + position.coords.longitude
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
Food.models.Location = Ext.regModel('location', {
  fields: ['name', 'location']
});
Food.stores.Locations = new Ext.data.Store({
  model: 'location',
  proxy: {
    type: 'ajax',
    url: '',
    reader: {
      type: 'json'
    }
  },
  listeners: {
    beforeload: function() {}
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
Food.views.List = Ext.extend(Ext.Panel, {
  fullscreen: true,
  initComponent: function() {
    var list, sheet, toggleView, toolbar;
    list = {
      xtype: 'list',
      itemTpl: '<tpl for=".">{name} <tpl for="location">{distance}<br>{lat}<br>{lng}</tp></tpl>',
      grouped: false,
      store: '',
      listeners: {
        beforerender: function() {
          var store;
          store = Food.stores.Locations;
          store.proxy.url = window.POS.url;
          store.load();
          return this.bindStore(store);
        }
      }
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
      listeners: {
        toggle: function(container, button, pressed) {}
      }
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
    var image, loader, map, position, searchbar, shadow, sheet, toolbar;
    loader = new Ext.LoadMask(Ext.getBody(), {
      msg: 'Loading...'
    });
    image = new google.maps.MarkerImage('../../images/point.png', new google.maps.Size(32, 31), new google.maps.Point(0, 0), new google.maps.Point(16, 31));
    shadow = new google.maps.MarkerImage('../../images/shadow.png', new google.maps.Size(64, 52), new google.maps.Point(0, 0), new google.maps.Point(-5, 42));
    position = new google.maps.LatLng(window.POS.lat, window.POS.lng);
    map = new Ext.Map({
      useCurrentLocation: true,
      mapOptions: {
        center: position,
        zoom: 12,
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
            title: 'My Current Location',
            shadow: shadow,
            icon: image
          })
        }, new Ext.plugin.GMap.Traffic({
          hidden: true
        }))
      ],
      listeners: {
        mapRender: function(component, map) {
          var store;
          store = Food.stores.Locations;
          store.proxy.url = window.POS.url;
          return store.load(function(records, error) {
            return records.forEach(function(record) {
              var m, marker;
              m = new google.maps.LatLng(record.data.location.lat, record.data.location.lng);
              marker = new google.maps.Marker({
                position: m,
                title: record.data.name,
                map: map
              });
              return google.maps.event.addListener(marker, 'click', function() {
                return new google.maps.infowindow.open(map, marker);
              });
            });
          });
        }
      }
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