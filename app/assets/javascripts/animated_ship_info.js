var pixi_background_speed = 1;
var target_interval;

$( document ).on('turbolinks:load', function() {
  load_ship_info_animations();
});

function load_ship_info_animations() {
  if ($('.player-space-ship').length) {
    app_player_ship();
  }
  if ($('.enemy-space-ship').length) {
    enemy_player_ship();
  }
}

function app_player_ship() {
  var app = new PIXI.Application(270, 87, { antialias: true, autoResize: true }); 
  $('.player-space-ship').empty().append(app.view);
  
  // create a texture from an image path
  var bg = PIXI.Texture.fromImage('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/bg_space_seamless.png');
  var f1 = PIXI.Texture.fromImage('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/bg_space_seamless_fl1.png');
  var f2 = PIXI.Texture.fromImage('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/bg_space_seamless_fl2.png');
  
  // Background Layer 0
  var tilingSprite = new PIXI.extras.TilingSprite(
    bg,
    app.screen.width,
    app.screen.height
  );
  app.stage.addChild(tilingSprite);
  
  // Background Layer 1
  var layer1 = new PIXI.extras.TilingSprite(
    f1,
    app.screen.width,
    app.screen.height
  );
  app.stage.addChild(layer1);
  
  // Ship
  if ($('.player-space-ship').data("ship-image")) {
    var ship = PIXI.Sprite.fromImage($('.player-space-ship').data("ship-image"));
    ship.anchor.set(0.5);
    ship.x = app.screen.width / 2;
    ship.y = app.screen.height / 2;
    ship.scale.y = ship.scale.x = 0.75;
    app.stage.addChild(ship);
    ship.rotation += 1.5708; 
  }
  
  // Background Layer 2
  var layer2 = new PIXI.extras.TilingSprite(
    f2,
    app.screen.width,
    app.screen.height
  );
  app.stage.addChild(layer2);
  
  // Moving Background
  app.ticker.add(function() {
    tilingSprite.tilePosition.x -= pixi_background_speed / 4;
    layer1.tilePosition.x -= pixi_background_speed / 2;
    layer2.tilePosition.x -= pixi_background_speed;
  });
  
  // Resize
  // Listen for window resize events
  window.addEventListener('resize', resize);
  
  // Resize function window
  function resize() {
  
  	// Get the p
  	const parent = app.view.parentNode;
     
  	// Resize the renderer
  	app.renderer.resize(parent.clientWidth-5, 87);
  	
  	// Resize ship
  	ship.x = app.screen.width / 2;
  }
  
  resize();
}

function enemy_player_ship() {
  // Vars
  var countdown;
  
  var app = new PIXI.Application(269, 87, { antialias: true, autoResize: true }); 
  $('.enemy-space-ship').empty().append(app.view);
  
  // create a texture from an image path
  var bg = PIXI.Texture.fromImage('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/bg_space_seamless.png');
  var f1 = PIXI.Texture.fromImage('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/bg_space_seamless_fl1.png');
  var f2 = PIXI.Texture.fromImage('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/bg_space_seamless_fl2.png');
  
  // Background Layer 0
  var tilingSprite = new PIXI.extras.TilingSprite(
    bg,
    app.screen.width,
    app.screen.height
  );
  app.stage.addChild(tilingSprite);
  
  // Background Layer 1
  var layer1 = new PIXI.extras.TilingSprite(
    f1,
    app.screen.width,
    app.screen.height
  );
  app.stage.addChild(layer1);
  
  // Ship
  if ($('.enemy-space-ship').data("ship-image")) {
    var ship = PIXI.Sprite.fromImage($('.enemy-space-ship').data("ship-image"));
    ship.anchor.set(0.5);
    ship.x = app.screen.width / 2;
    ship.y = app.screen.height / 2;
    ship.scale.y = ship.scale.x = 0.75;
    app.stage.addChild(ship);
    ship.rotation += 1.5708; 
  }
  
  // Asteroid
  if ($('.enemy-space-ship').data("asteroid-image")) {
    var asteroid = PIXI.Sprite.fromImage($('.enemy-space-ship').data("asteroid-image"));
    asteroid.anchor.set(0.5);
    asteroid.x = app.screen.width / 2;
    asteroid.y = app.screen.height / 2;
    asteroid.scale.y = asteroid.scale.x = 0.4;
    app.stage.addChild(asteroid);
  }
  
  // Background Layer 2
  var layer2 = new PIXI.extras.TilingSprite(
    f2,
    app.screen.width,
    app.screen.height
  );
  app.stage.addChild(layer2);
  
  // Moving Background
  app.ticker.add(function(delta) {
    tilingSprite.tilePosition.x -= pixi_background_speed / 4;
    layer1.tilePosition.x -= pixi_background_speed / 2;
    layer2.tilePosition.x -= pixi_background_speed;
    if (asteroid) {
      asteroid.rotation += 0.001 * delta;
    }
  });
  
  // Resize
  // Listen for window resize events
  window.addEventListener('resize', resize);
  
  // Resize function window
  function resize() {
  
  	// Get the p
  	const parent = app.view.parentNode;
     
  	// Resize the renderer
  	app.renderer.resize(parent.clientWidth-5, 87);
  	
  	// Resize objects
  	if (ship) {
  	  ship.x = app.screen.width / 2; 
  	}
  	if (countdown) {
      countdown.x = app.screen.width / 2; 
    }
    if (asteroid) {
      asteroid.x = app.screen.width / 2; 
    }
  }
  
  resize();
  
  // Functions
  this.animation_remove_target = function() {
    if (ship) {
      app.stage.removeChild(ship);
    }
    if (countdown) {
      app.stage.removeChild(countdown);
    }
    if (asteroid) {
      app.stage.removeChild(asteroid);
    }
  }
  
  this.animation_target_counter = function(time) {
    countdown = new PIXI.Text(time, new PIXI.TextStyle({fill: '#ffffff'}));
    countdown.anchor.set(0.5);
    countdown.x = app.screen.width / 2;
    countdown.y = app.screen.height / 2;
    app.stage.addChild(countdown);
    target_interval = setInterval(function() {
      time = time-1;
      countdown.text = time
      if (time <= 0) {
        app.stage.removeChild(countdown);
        countdown = null;
        clearInterval(target_interval);
      }
    }, 1000);
  }
  
  // Clear Target
  setTimeout(function() {
    if ($('.enemy-space-ship').length && $('.enemy-space-ship').next().is(':empty')) {
      animation_remove_target();
    }
  }, 500)
}