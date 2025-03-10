$(function() {
  $( "[id^=api_fetch_]" ).on( "click", function() {
    this.parentElement.parentElement.innerHTML = (
      '<td colspan="7" class="text-center">' +
      'Fetching ' + '<i class="fa fa-gear fa-spin" style="font-size:24px"></i> '+ this.id.replace('api_fetch_', '') +
      '</td>'
    );
  });

  // SEQUENTIAL UPLOAD LOGIC
  // Simulates multiple file upload by breaking file down and submitting sequence of uploads

  // Allow for multiple file upload checkbox to override sequential submit
  $("#upload_multiple_file_upload").on("change", function(_event) {
    $("#seq-submit-btn").css("display", this.checked ? "none" : "inline-block");
    $("#default-submit-upload-btn").css("display", this.checked ? "inline-block" : "none");
  });

  // Handle path for different environments
  const getPathPrefix = () => {
    const hostname = window.location.hostname
    const subdomain = hostname.split('.')[0];
    return subdomain === 'localhost' ? '' : '/gids'
  };
  const PATH_PREFIX = getPathPrefix();;

  // Open dialog during sequential upload to disable page
  $("#sequential-upload-dialog").dialog({
    autoOpen: false,
    modal: true,
    width: "auto",
    resizable: false,
    open: () => {
      $(".ui-dialog-titlebar-close").hide(); 
    }
  });
  
  // const updateProgress = (completed, total) => {
    
  // };

  // Submit logic for new upload form when sequential upload enabled
  $("#seq-submit-btn").on("click", async function(event) {
    event.preventDefault();
    // Grab form data and validate file selected
    const form = $("#new_upload")[0];
    if (!form.reportValidity()) {
      return;
    }
    const formData = new FormData(form);
    const file = formData.get("upload[upload_file]");

    // Open dialog and disable page until client-side processing complete
    $("#sequential-upload-dialog").dialog("open");
    $(this).html(
      '<div id="sequential-submit-btn-div">' +
      '<i class="fa fa-gear fa-spin" style="font-size:16px"></i>' +
      'Submitting . . .' +
      '</div>'
    );

    // Divide upload file into smaller files
    const blobs = [];

    const generateBlobs = async () => {
      const chunkSize = parseInt(this.dataset.chunkSize);
      const text = await file.text();
      const header = text.slice(0, text.indexOf('\n') + 1);

      for (let start = 0; start < file.size; start += chunkSize) {
        let end = start + chunkSize;
        let charsToEndOfRow = 0;
        // Ensure rows not divided between blobs
        if (text[end - 1] !== "\n") {
          charsToEndOfRow = text.slice(end).indexOf("\n") + 1;
          end += charsToEndOfRow;
        };
        const blob = file.slice(start, end, "text/plain");
        // Add header if not already present
        const fileBits = start === 0 ? [blob] : [header, blob]
        const newFile = new File(fileBits, { type: "text/plain" });
        blobs.push(newFile);
        start += charsToEndOfRow;
      }
    };

    // Send individual POST request for each blob, simulating multiple file upload
    const MAX_RETRIES = 5
    const DELAY = 500;
    const sleep = () => new Promise((res) => setTimeout(res, DELAY));

    const submitBlobs = async () => {
      const total = blobs.length;
      const idx = file.name.lastIndexOf(".");
      const [basename, ext] = [file.name.slice(0, idx), file.name.slice(idx)];
      let uploadId;

      // Iterate through blobs and submit each to /uploads in sequential order
      try {
        for (let i = 0; i < blobs.length; i++) {
          const current = i + 1;
          const filePosition = `${current.toString().padStart(2, '0')}_of_${total.toString().padStart(2, '0')}`;
          const filename = `${basename}_${filePosition}${ext}`;
          formData.set("upload[upload_file]", blobs[i], filename);
          // Set multiple_file_upload to true after first upload
          if (i > 0) {
            formData.set("upload[multiple_file_upload]", true);
          }
          // Include metadata in payload to track upload progress across multiple requests
          formData.set("upload[sequence][current]", current);
          formData.set("upload[sequence][total]", total);

          // Try each upload five times
          let response;
          let attempts = MAX_RETRIES
          while(!response?.ok && attempts > 0) {
            try {
              attempts--;
              console.log(`Uploading ${filename}, attempt: ${MAX_RETRIES - attempts}/${MAX_RETRIES}`);
              formData.set("upload[sequence][retry]", attempts < MAX_RETRIES);
              response = await fetch(`${PATH_PREFIX}/uploads`, {
                method: "POST",
                body: formData
              });
            } catch(error) {
              console.error(error);
              sleep();
            }
          }

          // Throw error if all retries fail
          if (!response.ok) {
            throw new Error(`Upload failed with status ${response.status}`);
          }
          console.log(`Upload successful: ${filename}`);
          const data = await response.json();
          if (data.final) {
            uploadId = data.upload.id;
          }
        }
        window.location.href = `${PATH_PREFIX}/uploads/${uploadId}`;
      } catch(error) {
        console.error(error);
        const csvType = formData.get("upload[csv_type]");
        window.location.href = `${PATH_PREFIX}/uploads/new/${csvType}`;
      }
    };

    await generateBlobs();
    submitBlobs();
  });
});
