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

    const generateMultipleFiles = (text) => {
      // Divide file into smaller files by chunk size (set in csv_file_defaults.yml)
      for (let start = 0, i = 1; start < originalFile.size; start += chunkSize, i++) {
        // let end = start + chunkSize;
        // let charsToEndOfRow = 0;
        // // Ensure rows not divided between blobs
        // if (text[end - 1] !== "\n") {
        //   charsToEndOfRow = text.slice(end).indexOf("\n") + 1;
        //   end += charsToEndOfRow;
        // };
        const blob = originalFile.slice(start, start + chunkSize);
        const fileNumber = i.toString().padStart(2, '0');
        const fileName = fileNumber + "_" + originalFile.name;
        const newFile = new File([blob], fileName, { type: "text/plain" });
        processedFiles.push(newFile);
        // start += charsToEndOfRow;
      }
    };

    const submitUploadForms = async () => {
      const form = $("#new_upload")[0];
      const formData = new FormData(form, this);
      const statuses_list = $("#async-upload-statuses");
      for (let i = 0; i < processedFiles.length; i++) {
        // const status_message = `Uploading file ${i + 1} of ${processedFiles.length} . . .`;
        // const list_item = `<li id=async-upload-status-${i + 1}>${status_message}</li>`;
        // statuses_list.append(list_item);
        const file = processedFiles[i];
        formData.set("upload[upload_file]", file);
        formData.set("upload[multiple_file_upload]", i !== 0);
        // Include metadata to calculate when final file processed
        formData.append("upload[metadata][uploads][current]", i + 1);
        formData.append("upload[metadata][uploads][total]", processedFiles.length);
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
          // const upload_status = response["async_upload_status"];
          // const fileURL = URL.createObjectURL(file);
          // const fileLink = $("<a>").attr("href", fileURL).text(file.name);
          // $(`#async-upload-status-${i + 1}`).text("").append(fileLink)
    
          if (i < processedFiles.length - 1) {
            console.log(upload_status);
          } else {
            console.log("upload done!")
          }
          
        } catch (error) {
          console.error(error);
        }
      }
    };

    generateMultipleFiles(reader.result);
    await submitUploadForms();

    // const reader = new FileReader();
    // $(reader).on( "load", async () => {
    //   generateMultipleFiles(reader.result);
    //   await submitUploadForms();
    // });
    // reader.readAsText(originalFile, 'UTF-8');
  });
});
