$(function() {
  $( "[id^=api_fetch_]" ).on( "click", function() {
    this.parentElement.parentElement.innerHTML = (
      '<td colspan="7" class="text-center">' +
      'Fetching ' + '<i class="fa fa-gear fa-spin" style="font-size:24px"></i> '+ this.id.replace('api_fetch_', '') +
      '</td>'
    );
  });

  // In case where file is too large (e.g. Program upload), break file into smaller files
  // Upload each file async via ajax to simulate multifile upload
  $( "#async-submit-btn" ).on( "click", function(event) {
    event.preventDefault();
    const originalFile = $("#upload_upload_file")[0].files[0];
    const processedFiles = [];
    const chunkSize = parseInt(this.dataset.chunkSize);
    const uploads_url = this.dataset.url;

    const generateFiles = (text) => {
      const header = text.slice(0, text.indexOf('\n') + 1);
      // Divide file into smaller files by chunk size
      for (let start = 0, i = 1; start < originalFile.size; start += chunkSize, i++) {
        let end = start + chunkSize;
        let charsToEndOfRow = 0;
        // Ensure rows not divided between blobs
        if (text[end - 1] !== "\n") {
          charsToEndOfRow = text.slice(end).indexOf("\n") + 1;
          end += charsToEndOfRow;
        };
        const blob = originalFile.slice(start, end);
        const fileNumber = i.toString().padStart(2, '0');
        const fileName = fileNumber + "_" + originalFile.name;
        // Add header if not already present
        const fileBits = start === 0 ? [blob] : [header, blob];
        const newFile = new File(fileBits, fileName, { type: "text/plain" });
        processedFiles.push(newFile);
        start += charsToEndOfRow;
      }
    };

    const submitUploadForms = async () => {
      const form = $("#new_upload")[0];
      const formData = new FormData(form, this);
      for (let i = 0; i < processedFiles.length; i++) {
        const file = processedFiles[i];
        formData.set("upload[upload_file]", file);
        formData.set("upload[multiple_file_upload]", i !== 0)
        // Include metadata to calculate when last file processed
        formData.append("upload[metadata][file_number]", i + 1);
        formData.append("upload[metadata][count]", processedFiles.length);
        let result;
        try {
          result = await $.ajax({
            type: "POST",
            url: uploads_url,
            data: formData,
            dataType: "json",
            processData: false,
            contentType: false
          });
          console.log(JSON.parse(result));
        } catch (error) {
          console.error(error);
        }
      }
    };

    const reader = new FileReader();
    $(reader).on( "load", async () => {
      generateFiles(reader.result);
      await submitUploadForms();
    });
    reader.readAsText(originalFile, 'UTF-8');
  });
});
