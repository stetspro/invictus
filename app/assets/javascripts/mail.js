$( document ).on('turbolinks:load', function() {
  // Load dynamic mail if click on show button
  $('.show-mail-btn').on('click', function() {
    $.get('/mails/' + parseInt($(this).data('id')), function(data) {
      if ($('#mail-show-card').length) {
       $('#mail-show-card').remove(); 
      }
      $('.mails-card').after(data);
    });
  });
});

// Reload mails or display badge in navbar if actioncable received mail
function received_mail() {
  if ($('.mails-card').length) {
    Turbolinks.visit(window.location);
  } else if ($('#navbarColor02').length && !$('#mails-alert').length) {
    $('#navbarColor02 .nav-item').each(function() {
      if ($(this).find('a').attr('href') == "/mails") {
        $(this).find('a').append("<span class='badge badge-danger' id='mails-alert'><i class='fa fa-exclamation'></i></span>")
      }
    });
  }
}