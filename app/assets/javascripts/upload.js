$(function() {
  $( "[id^=api_fetch_]" ).on( "click", function() {
    this.parentElement.parentElement.innerHTML = (
      '<td colspan="7" class="text-center">' +
      'Fetching ' + '<i class="fa fa-gear fa-spin" style="font-size:24px"></i> '+ this.id.replace('api_fetch_', '') +
      '</td>'
    );
  });

  // Break file into smaller files on client side to simulate multifile upload
  // and ajaxify file upload to enable GIDS to process row data asynchronously
  $( "#async-submit-btn" ).on( "click", async function(event) {
    event.preventDefault();
    // Disable upload button
    $(this).prop("disabled", true);
    const originalFile = $("#upload_upload_file")[0].files[0];
    const processedFiles = [];
    const chunkSize = parseInt(this.dataset.chunkSize);
    const uploads_url = this.dataset.url;

    const generateMultipleFiles = () => {
      // Divide file into smaller files by chunk size (set in csv_file_defaults.yml)
      for (let start = 0, i = 1; start < originalFile.size; start += chunkSize, i++) {
        const blob = originalFile.slice(start, start + chunkSize);
        const newFile = new File([blob], originalFile.name, { type: "text/plain" });
        processedFiles.push(newFile);
      }
    };

    const submitUploadForms = async () => {
      let uploadId = null;
      const form = $("#new_upload")[0];
      const formData = new FormData(form, this);
      for (let i = 0; i < processedFiles.length; i++) {
        const file = processedFiles[i];
        formData.set("upload[upload_file]", file);
        formData.set("upload[multiple_file_upload]", i !== 0);
        // Include metadata to track upload ID and calculate when final file processed
        formData.append("upload[async][count][current]", i + 1);
        formData.append("upload[async][count][total]", processedFiles.length);
        formData.append("upload[async][upload_id]", uploadId)
        let response;
        try {
          response = await $.ajax({
            type: "POST",
            url: uploads_url,
            data: formData,
            dataType: "json",
            processData: false,
            contentType: false
          });
          uploadId = response.upload_id;
        } catch (error) {
          console.error(error);
        }
      }
      window.location.href = `/uploads/${uploadId}`;
    };

    generateMultipleFiles();
    await submitUploadForms();
  });
});
