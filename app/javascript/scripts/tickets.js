$(document).ready(function(){
  $('.ticket input[type="checkbox"]').on('change', function(){
    $(this).parents('.ticket').toggleClass('highlight');
  });
  
  $('[data-toggle-all]').on('change', function(){
    var checked = this.checked ? true : false;
    $('[data-toggle-check]').each(function(){
      if(checked && !this.checked || !checked && this.checked){
        $(this).click();
      }
    });
  });

  function keepLock() {
    $.ajax({
      url: $('[data-lock-path]').data('lock-path'),
      type: 'post'
    });
  }
  keepLock();
  /* renew lock every 4 minutes */
  setInterval(keepLock, 1000 * 60 * 4);
});