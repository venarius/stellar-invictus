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
  PIXI.utils.skipHello()
  
  var app = new PIXI.Application(270, 87, { antialias: true, autoResize: true }); 
  $('.player-space-ship').empty().append(app.view);
  
  // create a texture from an image path
  var bg = PIXI.Texture.from('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/bg_space_seamless.png');
  
  function randomBetween(min, max) {
    return Math.random() * (max - min) + min;
  }
  
  // Background Layer 0
  var tilingSprite = new PIXI.extras.TilingSprite(
    bg,
    app.screen.width,
    app.screen.height
  );
  app.stage.addChild(tilingSprite);

  var stars_back = new PIXI.particles.ParticleContainer(10000, {
    scale: true,
    position: true,
    rotation: true,
    uvs: true,
    alpha: true
  });
  app.stage.addChild(stars_back);

  var stars_01 = [],
      stars_02 = [],
      star_min_scale = 0.2,
      star_max_scale = 0.6,
      star_max_speed = 2.0,
      star_min_speed = 0.1,   // The idea here is there should be less stars rendering in front of the ship.
      stars_back_count = 50, // Further down, in the createStars call for the front stars, I make sure they
      stars_front_count = 25; // are smaller than background stars, on average.
      // You could also use these variables to adjust the star density as the player gets further out from
      // the primary systems. If you felt so inclined, you could even have it gradually change each frame to
      // cause a huge rush of stars flying by your ship when you go into warp. Stuff like that.
  
  // Mining Laser
  if ($('.enemy-space-ship').data("asteroid-image")) {
    var mining_laser = PIXI.Sprite.from('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/mining/mining-laser-ship.png');
    mining_laser.anchor.set(0.5, 0.9);
    mining_laser.alpha = 1;
    app.stage.addChild(mining_laser);
    mining_laser.rotation += 1.5708;
  }
  
  // Ship
  if ($('.player-space-ship').data("ship-image")) {
    var ship = PIXI.Sprite.from($('.player-space-ship').data("ship-image"));
    ship.anchor.set(0.5);
    ship.x = app.screen.width / 2;
    ship.y = app.screen.height / 2;
    ship.scale.y = ship.scale.x = 0.45;
    app.stage.addChild(ship);
    ship.rotation += 1.5708; 
  }
  
  // Explosion
  var frames = [];
  for (var i = 0; i < 6; i++) {
      frames.push(PIXI.Texture.from('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/explosion/explosion-' + i + '.png'));
  }
  
  var stars_front = new PIXI.particles.ParticleContainer(10000, {
    scale: true,
    position: true,
    rotation: true,
    uvs: true,
    alpha: true
  });
  app.stage.addChild(stars_front);

  // Stars Stuff
  function createStars(img, minScale, maxScale, minSpeed, maxSpeed, starArray, count, s){
    for(var i = 0; i < count; i++) {
      var star = PIXI.Sprite.fromImage(img);
      star.anchor.set(0.5);
      var scale = randomBetween(minScale, maxScale);
      star.scale.x = star.scale.y = scale
      star.rotation = randomBetween(0, Math.PI * 2);
      star.x = Math.random() * app.screen.width;
      star.y = Math.random() * app.screen.height;
      var tints = ['0x637a9a', '0xdee1f2', '0xffe8bf', '0xffffff'];
      star.tint = tints[Math.floor(Math.random()*tints.length)];
      star.speed = randomBetween(minSpeed, maxSpeed);
      starArray.push(star);
      s.addChild(star);
    }
  }

  createStars("https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/star-big.png",
              star_min_scale,
              star_max_scale,
              star_min_speed / 2,
              star_max_speed / 2,
              stars_01,
              stars_back_count,
              stars_back);
              
  createStars("https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/star-big.png",
              star_min_scale / 2,
              star_max_scale / 2,
              star_min_speed * 2,
              star_max_speed * 2,
              stars_02,
              stars_back_count,
              stars_front);

  
              
  var tick = 0;
  function addStarTickers (s) {
    for (var i = 0; i < s.length; i++){
      var star = s[i];
      star.x -= star.speed * pixi_background_speed;
      if (star.x < 0) {
        star.y = Math.random() * app.screen.height;
        star.x = app.screen.width;
        star.rotation = randomBetween(0, Math.PI * 2);
      }
    }
  }

  // Moving Background
  app.ticker.add(function() {
    addStarTickers(stars_01);
    addStarTickers(stars_02);
    tick += 0.1;
  });
  
  // Resize
  
  // Resize function window
  function resize() {
  
  	// Get the p
  	const parent = app.view.parentNode;
     
  	// Resize the renderer
  	app.renderer.resize(parent.clientWidth-5, 87);
  	
  	// Resize ship
  	ship.x = app.screen.width / 2;
  	
  	// Recenter Mininglaser
  	if (mining_laser) {
  	  mining_laser.x = app.screen.width / 2;
      mining_laser.y = app.screen.height / 2; 
  	}
  }
  
  resize();
  
  // Functions
  this.player_got_hit = function() {
    let explosion = new PIXI.extras.AnimatedSprite(frames);
    explosion.x = app.screen.width / (1.5 + Math.random()); 
    explosion.y = app.screen.height / (1.5 + Math.random());
    explosion.anchor.set(0.5);
    explosion.animationSpeed = 0.25;
    explosion.loop = false;
    explosion.scale.x = explosion.scale.y = 1.5;
    explosion.gotoAndPlay(0);
    app.stage.addChild(explosion);
    
    setTimeout(function() { app.stage.removeChild(explosion); }, 380)
  }
  
  this.stop_mining = function() {
    if (mining_laser) {
      mining_laser.alpha = 0; 
    }
  }
}

function enemy_player_ship() {
  // Vars
  var countdown;
  
  PIXI.utils.skipHello()
  
  var app = new PIXI.Application(269, 87, { antialias: true, autoResize: true });
  $('.enemy-space-ship').empty().append(app.view);
  
  // create a texture from an image path
  var bg = PIXI.Texture.from('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/bg_space_seamless.png');
  
  // Explosion
  var frames = [];
  for (var i = 0; i < 6; i++) {
      frames.push(PIXI.Texture.from('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/explosion/explosion-' + i + '.png'));
  }
  
  function randomBetween(min, max) {
    return Math.random() * (max - min) + min;
  }
  
  // Background Layer 0
  var tilingSprite = new PIXI.extras.TilingSprite(
    bg,
    app.screen.width,
    app.screen.height
  );
  app.stage.addChild(tilingSprite);

  var stars_back = new PIXI.particles.ParticleContainer(10000, {
    scale: true,
    position: true,
    rotation: true,
    uvs: true,
    alpha: true
  });
  app.stage.addChild(stars_back);

  var stars_01 = [],
      stars_02 = [],
      star_min_scale = 0.2,
      star_max_scale = 0.6,
      star_max_speed = 2.0,
      star_min_speed = 0.1,   // The idea here is there should be less stars rendering in front of the ship.
      stars_back_count = 50, // Further down, in the createStars call for the front stars, I make sure they
      stars_front_count = 25; // are smaller than background stars, on average.
      // You could also use these variables to adjust the star density as the player gets further out from
      // the primary systems. If you felt so inclined, you could even have it gradually change each frame to
      // cause a huge rush of stars flying by your ship when you go into warp. Stuff like that.
  
  // Ship
  if ($('.enemy-space-ship').data("ship-image")) {
    var ship = PIXI.Sprite.from($('.enemy-space-ship').data("ship-image"));
    ship.anchor.set(0.5);
    ship.x = app.screen.width / 2;
    ship.y = app.screen.height / 2;
    ship.scale.y = ship.scale.x = 0.45;
    app.stage.addChild(ship);
    ship.rotation += 1.5708; 
  }
  
  // Asteroid + Mining Laser
  if ($('.enemy-space-ship').data("asteroid-image")) {
    var mining_laser = PIXI.Sprite.from('https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/mining/mining-laser-ship.png');
    mining_laser.anchor.set(0.5, 0);
    app.stage.addChild(mining_laser);
    mining_laser.rotation += 1.5708;
    
    var asteroid = PIXI.Sprite.from($('.enemy-space-ship').data("asteroid-image"));
    asteroid.anchor.set(0.5);
    asteroid.x = app.screen.width / 2;
    asteroid.y = app.screen.height / 2;
    asteroid.scale.y = asteroid.scale.x = 0.4;
    app.stage.addChild(asteroid);
  }
  
  var stars_front = new PIXI.particles.ParticleContainer(10000, {
    scale: true,
    position: true,
    rotation: true,
    uvs: true,
    alpha: true
  });
  app.stage.addChild(stars_front);
  
  // Stars Stuff
  function createStars(img, minScale, maxScale, minSpeed, maxSpeed, starArray, count, s){
    for(var i = 0; i < count; i++) {
      var star = PIXI.Sprite.fromImage(img);
      star.anchor.set(0.5);
      var scale = randomBetween(minScale, maxScale);
      star.scale.x = star.scale.y = scale
      star.rotation = randomBetween(0, Math.PI * 2);
      star.x = Math.random() * app.screen.width;
      star.y = Math.random() * app.screen.height;
      var tints = ['0x637a9a', '0xdee1f2', '0xffe8bf', '0xffffff'];
      star.tint = tints[Math.floor(Math.random()*tints.length)];
      star.speed = randomBetween(minSpeed, maxSpeed);
      starArray.push(star);
      s.addChild(star);
    }
  }

  createStars("https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/star-big.png",
              star_min_scale,
              star_max_scale,
              star_min_speed / 2,
              star_max_speed / 2,
              stars_01,
              stars_back_count,
              stars_back);
              
  createStars("https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/animations/star-big.png",
              star_min_scale / 2,
              star_max_scale / 2,
              star_min_speed * 2,
              star_max_speed * 2,
              stars_02,
              stars_back_count,
              stars_front);

  
              
  var tick = 0;
  function addStarTickers (s) {
    for (var i = 0; i < s.length; i++){
      var star = s[i];
      star.x -= star.speed * pixi_background_speed;
      if (star.x < 0) {
        star.y = Math.random() * app.screen.height;
        star.x = app.screen.width;
        star.rotation = randomBetween(0, Math.PI * 2);
      }
    }
  }

  // Moving Background
  app.ticker.add(function() {
    addStarTickers(stars_01);
    addStarTickers(stars_02);
    tick += 0.1;
  });
  
  // Resize
  
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
    
    // Recenter Mininglaser
  	if (mining_laser) {
  	  mining_laser.x = app.screen.width / 2;
      mining_laser.y = app.screen.height / 2; 
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
    if (mining_laser) {
      app.stage.removeChild(mining_laser);
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
  
  this.enemy_got_hit = function() {
    let explosion = new PIXI.extras.AnimatedSprite(frames);
    explosion.x = app.screen.width / (1.5 + Math.random()); 
    explosion.y = app.screen.height / (1.5 + Math.random());
    explosion.anchor.set(0.5);
    explosion.animationSpeed = 0.25;
    explosion.loop = false;
    explosion.scale.x = explosion.scale.y = 1.5;
    explosion.gotoAndPlay(0);
    app.stage.addChild(explosion);
    
    setTimeout(function() { app.stage.removeChild(explosion); }, 380)
  }
  
  // Clear Target
  setTimeout(function() {
    if ($('.enemy-space-ship').length && $('.enemy-space-ship').next().is(':empty')) {
      animation_remove_target();
    }
  }, 500)
}