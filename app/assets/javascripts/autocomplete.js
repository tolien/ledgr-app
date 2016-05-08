$(function() {
  $( "#quick_entry #item_name" ).autocomplete({
    source: "/autocomplete",
    minLength: 2,
    select: function( event, ui ) {
      
    }
  });
});
