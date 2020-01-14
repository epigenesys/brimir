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
});
