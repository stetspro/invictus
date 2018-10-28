$( document ).on('turbolinks:load', function() {
  $('.warp-btn').off('click').on('click', function(e) {
    e.preventDefault();
    var target = $(this).data("id");
    if (target) {
      $.post( "game/warp", { id: target }, function( data ) {
        doWarp('WARPING', 10);
      });
    }
  });
  
  $('.jumpgate-jump-btn').on('click', function(e) {
    e.preventDefault();
    var time = parseInt($(this).data('time'))
    $.post( "game/jump", function() {
      doWarp('JUMPING', time);
    })
  });
});

function doWarp(type, warpTime) {
  $('.game-card-row').empty();
  $('.game-card-row').append(
    "<div class='col-md-12'><div class='card black-card card-body'><h2 class='flexbox-vert-center'>"+type+"</h2><h4 class='flexbox-vert-center'>"+warpTime+"</div></div>"
  );
  var interval = setInterval(function() {
    warpTime = warpTime - 1;
    $('.game-card-row').empty().append(
      "<div class='col-md-12'><div class='card black-card card-body'><h2 class='flexbox-vert-center'>"+type+"</h2><h4 class='flexbox-vert-center'>"+warpTime+"</div></div>"
    );
    if (warpTime <= 0) {
      App.local.reload();
      Turbolinks.visit(window.location);
      clearInterval(interval);
    }
  },1000);
}

function player_warp_out(name) {
  if ($('.players-card')) {
    $('.players-card-name-td').each(function() {
      if ($(this).html() == name) {
        $(this).closest('tr').fadeOut('fast', 
          function(){ 
            $(this).remove();                    
          }
        );
      }
    });
  }
}

function reload_players_card() {
  if ($('#players-card')) {
    $.get("game/local_players", function(data) {
      $('#players-card').replaceWith(data);
    });
  }
}