
$.ajax({
       url: "/api/countries/",
       type: "GET",
       contentType: "application/json; charset=utf-8"
       }).then(function (response) {
                var previousCountry = $("#locationCountry").val();
                if (previousCountry != "Select Country") {
               		$("#locationCountry").empty();
               		//$("#locationState").empty();
               }
               
               var dataToReturn = [];
               for (var i=0; i < response.length; i++) {
               var tagToTransform = response[i];
               var newTag = {
               id: tagToTransform["id"],
               text: tagToTransform["name"]
               };
               dataToReturn.push(newTag);
               }
               $("#locationCountry").select2({
                                           placeholder: "Select Country",
                                           tags: true,
                                           tokenSeparators: [','],
                                           data: dataToReturn
                                           });
                                           if (previousCountry != "Select Country") {
$('#locationCountry').val(previousCountry); // Select the option with a value of '1'
$('#locationCountry').trigger('change'); // Notify any JS components that the value changed
}
               });



$(document).ready(function()
                  {
                  $( function() {
    $( "#startDate" ).datepicker();
  } );
  
  $( function() {
    $( "#endDate" ).datepicker();
  } );
  
                  $("#logo").change(function () {
    readURL(this);
});

                  $("#locationCountry").change(function()
                                       {
                                       var id=$(this).val();
                                       var dataString = id;
                                       
                                       $.ajax({
                                              url: "/api/countries/"+id+/zones/,
                                              type: "GET",
                                              contentType: "application/json; charset=utf-8"
                                              }).then(function (response) {
                                              		
                                                      $("#locationState").empty();
                                                      var dataToReturn = [];
                                                      for (var i=0; i < response.length; i++) {
                                                      var tagToTransform = response[i];
                                                      var newTag = {
                                                      id: tagToTransform["id"],
                                                      text: tagToTransform["name"]
                                                      };
                                                      dataToReturn.push(newTag);
                                                      }
                                                      $("#locationState").select2({
                                                                          placeholder: "Select Region for the Country",
                                                                          tags: true,
                                                                          tokenSeparators: [','],
                                                                          data: dataToReturn
                                                                          });
                                                      $("#locationStateBox").removeClass("hidden");
                                                    	$('#locationState').trigger('change');
var previousState = $("#previousLocationState").val();
                                                      if (previousState != "") {
                                                      	$('#locationState').val(previousState);
                                                      	$("#previousLocationState").val("");
														$('#locationState').trigger('change');

                                                      }
                                                      });
                                       
                                       });
                  });
                  
function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            $('#imagePreview').css('background-image', 'url('+e.target.result +')');
            $('#imagePreview').hide();
            $('#imagePreview').fadeIn(650);
        }
        reader.readAsDataURL(input.files[0]);
    }
}

                  
