$(function() {
    $( "[id^=api_fetch_]" ).on( "click", function() {
      this.parentElement.parentElement.innerHTML = (
        '<td colspan="7" class="text-center">' +
        'Fetching ' + '<i class="fa fa-gear fa-spin" style="font-size:24px"></i> '+ this.id.replace('api_fetch_', '') +
        '</td>'
      );
    });

    $("#async-submit-btn").on("click", async function(event) {
      event.preventDefault();
      const form = $("#new_upload")[0];
      if (!form.reportValidity()) {
        return;
      }
      $(this).prop("disabled", true);
      const formData = new FormData(form);
      const file = formData.get("upload[upload_file]");
      const blobs = [];

      const generateBlobs = async () => {
        const chunkSize = parseInt(this.dataset.chunkSize);
        for (let start = 0; start < file.size; start += chunkSize) {
          const blob = file.slice(0, chunkSize, "text/plain");
          blobs.push(blob);
        }
      };

      const submitBlobs = async () => {
        let uploadId = null;
        for (let i = 0; i < blobs.length; i++) {
          try {
            formData.set("upload[upload_file", blobs[i], file.name);
            formData.set("upload[metadata][upload_id]", uploadId);
            formData.set("upload[metadata][count][current]", i + 1);
            formData.set("upload[metadata][count][current]", blobs.length + 1);
            const response = await $.ajax({
              url: "/uploads/create_async",
              type: "POST",
              data: formData,
              contentType: false,
              processData: false
            });
            console.log(response);
          } catch(error) {
            console.error(error);
          }
        }
      };

      generateBlobs();
      submitBlobs();
    });
});
