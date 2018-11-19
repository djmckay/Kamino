
$.ajax({
       url: "/api/countries/",
       type: "GET",
       contentType: "application/json; charset=utf-8"
       }).then(function (response) {
               		$("#locationCountry").empty();
               
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
               });





                  
