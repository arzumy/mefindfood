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
  fields: ['name', 'popularity', 'location', 'stats']
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
    centered: true,
    dock: 'bottom',
    scroll: false,
    iconMask: true,
    ui: 'dark',
    layout: {
      pack: 'center'
    },
    strech: true
  },
  initComponent: function() {
    this.items = [
      {
        cls: 'nav-map',
        title: 'Map',
        xtype: 'map',
        iconCls: 'compass2'
      }, {
        cls: 'nav-list',
        title: 'List',
        xtype: 'listfood',
        iconCls: 'list'
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
    var list, searchbar, tmpl, toggleView, toolbar;
    tmpl = new Ext.XTemplate('<tpl for=".">\n  <div class="title">\n    {name}\n  </div>\n  <tpl for="location">\n    <div class="like"><span>{distance:this.toKM}</span> </div>\n  </tpl>\n  <tpl for="stats">\n    <div class="popular"><span>{checkinsCount} Likes</span></div>\n  </tpl>\n</tpl>', {
      toKM: function(str) {
        return (str.toPrecision(3)).toString().replace('e+3', '').replace('e+4', '') + 'KM';
      }
    });
    list = {
      xtype: 'list',
      itemTpl: tmpl,
      grouped: false,
      store: '',
      height: '100%',
      plugins: [
        new Ext.ux.touch.ListOptions({
          enableSoundEffects: true,
          allowMultiple: true,
          hideOnScroll: true,
          menuOptions: [
            {
              id: 'Team Icon Tapped',
              cls: 'team',
              html: 'team',
              enabled: true
            }, {
              id: 'Favourite Icon Tapped',
              cls: 'favourite',
              text: 'favourites'
            }, {
              id: 'Cart Icon Tapped',
              cls: 'shop'
            }, {
              id: 'Share Icon Tapped',
              cls: 'share'
            }
          ]
        })
      ],
      listeners: {
        beforerender: function() {
          var store;
          store = Food.stores.Locations;
          store.proxy.url = window.POS.url;
          store.load();
          return this.bindStore(store);
        },
        menuoptiontap: function(data, record) {
          return Ext.Msg.alert('List Option Tapped', data.id + ' for ' + record.data.name + ' ' + record.data.location.distance, Ext.emptyFn);
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
        toggle: function(container, button, pressed) {
          list.store = Food.stores.Locations;
          list.store.proxy.url = window.POS.url;
          switch (button.text) {
            case 'Distance':
              list.store.sort('distance', 'DESC');
              break;
            case 'Popularity':
              list.store.sort('popularity', 'DESC');
          }
          return list.store.load();
        }
      }
    };
    toolbar = {
      dock: 'top',
      xtype: 'toolbar',
      defaults: {
        iconMask: true,
        ui: 'plain'
      },
      layout: {
        pack: 'center'
      },
      items: [
        {
          text: 'Sort by'
        }, toggleView
      ]
    };
    searchbar = {
      xtype: 'searchfield',
      name: 'search',
      label: 'search',
      handler: this.searchEvents,
      scope: this
    };
    Ext.apply(this, {
      cls: 'list-panel',
      centered: true,
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
    var image, loader, map, position, shadow, toolbar;
    loader = new Ext.LoadMask(Ext.getBody(), {
      msg: 'Loading...'
    });
    image = new google.maps.MarkerImage('../../images/icons/pin1.png', new google.maps.Size(40, 52), new google.maps.Point(0, 0), new google.maps.Point(16, 52));
    shadow = new google.maps.MarkerImage('../../images/shadow.png', new google.maps.Size(64, 52), new google.maps.Point(0, 0), new google.maps.Point(-5, 42));
    position = new google.maps.LatLng(window.POS.lat, window.POS.lng);
    map = new Ext.Map({
      useCurrentLocation: true,
      mapOptions: {
        center: position,
        zoom: 13,
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
              var c, i, m, marker, p;
              c = "<div class='p'> " + record.data.name + " </div>";
              p = {
                maxWidth: 300,
                content: c,
                minHeight: 80,
                arrowPosition: 30,
                arrowStyle: 2,
                borderRadius: 3,
                borderWidth: 1
              };
              m = new google.maps.LatLng(record.data.location.lat, record.data.location.lng);
              i = new InfoBubble(p);
              marker = new google.maps.Marker({
                position: m,
                title: record.data.name,
                map: map,
                icon: new google.maps.MarkerImage('../../images/icons/pin2.png', new google.maps.Size(40, 52), new google.maps.Point(0, 0), new google.maps.Point(16, 52))
              });
              return google.maps.event.addListener(marker, 'click', function() {
                return i.open(map, marker);
              });
            });
          });
        }
      }
    });
    toolbar = {
      id: 'toolbar',
      xtype: 'toolbar',
      docked: 'top',
      title: 'Food My Ass',
      items: [
        {
          xtype: 'spacer'
        }, {
          iconCls: 'star',
          ui: 'plain'
        }
      ]
    };
    Ext.apply(this, {
      scroll: false,
      centered: true,
      items: [map]
    });
    return Food.views.Map.superclass.initComponent.call(this);
  },
  searchEvents: function(e) {
    var value;
    value = e.currentTarget.value();
    return console.log(new RegExt(value || '.*', 'i'));
  }
});
Ext.reg('map', Food.views.Map);