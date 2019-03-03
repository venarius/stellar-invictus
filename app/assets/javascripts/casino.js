$( document ).on('turbolinks:load', function() {
  
  // Dice Casino
  $('#app-container').on('input', '#diceRange', function() {
    $('#diceRollOver').text($(this).val());
    $('#dicePayout').text((95 / parseInt($(this).val())).toFixed(2) + "x");
    $('#diceProfit').val(parseInt(parseFloat($('#diceBet').val()) * parseFloat($('#dicePayout').text().replace('x', ''))));
  });
  
  $('#app-container').on('keyup', '#diceBet', function() {
    $('#diceProfit').val(parseInt(parseFloat($('#diceBet').val()) * parseFloat($('#dicePayout').text().replace('x', ''))));
  });
  
  $('#app-container').on('click', '#diceMax', function() {
    $('#diceBet').val(parseInt($(this).data('max')));
    if (parseInt($('#diceBet').val()) > 100000) { $('#diceBet').val("100000") }
    $('#diceProfit').val(parseInt(parseFloat($('#diceBet').val()) * parseFloat($('#dicePayout').text().replace('x', ''))));
  });
  
  $('#app-container').on('click', '#diceDouble', function() {
    $('#diceBet').val(parseInt($('#diceBet').val() * 2));
    
    if (parseInt($('#diceBet').val()) > parseInt($('#diceMax').data('max'))) {
      $('#diceBet').val(parseInt($('#diceMax').data('max')));
    }
    
    if (parseInt($('#diceBet').val()) > 100000) { $('#diceBet').val("100000") }
    $('#diceProfit').val(parseInt(parseFloat($('#diceBet').val()) * parseFloat($('#dicePayout').text().replace('x', ''))));
  });
  
  $('#app-container').on('click', '#diceRoll', function() {
    var bet = $('#diceBet').val();
    var roll_under = $('#diceRollOver').text();
    
    if (bet && roll_under) {
      $.post('/stations/dice_roll', {bet: bet, roll_under: roll_under}, function(data) {
        if (data.win) {
          $('#diceHistory').append("<tr class='color-highgreen'><td>"+data.time+"</td><td>"+data.bet+"</td><td>"+data.roll+"</td><td>"+data.payout+"</td></tr>"); 
        } else {
          $('#diceHistory').append("<tr class='text-danger'><td>"+data.time+"</td><td>"+data.bet+"</td><td>"+data.roll+"</td><td>"+data.payout+"</td></tr>");
        }
        
        $.notify(data.message, {style: 'info'});
        $('.player-info-card').find('.fa-dollar-sign').parent().html("<i class='fa fa-dollar-sign'></i>&nbsp;&nbsp;" + data.units);
        $('#diceMax').data('max', data.units);
        
        var body = $('.diceHistoryDiv');
        body.scrollTop(body.get(0).scrollHeight);

      }).fail(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
    }
  });
  
})