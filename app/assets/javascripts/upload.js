$(function() {
  $( "[id^=api_fetch_]" ).on( "click", function() {
    this.parentElement.parentElement.innerHTML = (
      '<td colspan="7" class="text-center">' +
      'Fetching ' + '<i class="fa fa-gear fa-spin" style="font-size:24px"></i> '+ this.id.replace('api_fetch_', '') +
      '</td>'
    );
  });

  // Open dialog during initial async upload to disable page
  $("#async-upload-dialog").dialog({
    autoOpen: false,
    modal: true,
    width: "auto",
    resizable: false,
    open: () => {
      $(".ui-dialog-titlebar-close").hide(); 
    }
  });

  // POLL UPLOAD STATUS
  const ON_SCREEN_POLL_RATE = 5_000;
  const BACKGROUND_POLL_RATE = 10_000;

  const capitalize = (str, titlecase) => titlecase ? str.charAt(0).toUpperCase() + str.slice(1) : str;

  // CRUD methods for local storage
  const getUploadQueue = () => {
    try {
      const uploadQueue = JSON.parse(localStorage.getItem("uploadQueue"));
      if (Array.isArray(uploadQueue)) {
        return uploadQueue;
      }
      throw new TypeError()
    } catch(error) {
      localStorage.setItem("uploadQueue", "[]");
      return [];
    }
  };
  const addToQueue = (uploadId) => {
    const uploadQueue = getUploadQueue();
    uploadQueue.push(uploadId);
    localStorage.setItem("uploadQueue", JSON.stringify([...new Set(uploadQueue)]));
  };
  const removeFromQueue = (uploadId) => {
    const uploadQueue = getUploadQueue();
    const filteredQueue = uploadQueue.filter((id) => id !== uploadId);
    localStorage.setItem("uploadQueue", JSON.stringify([...new Set(filteredQueue)]));
  };

  // Cancel upload if still active
  const cancelUpload = async (icon, uploadId) => {
    $(icon).off("click mouseleave");
    try {
      await $.ajax({
        url: `/uploads/${uploadId}/cancel`,
        type: "PATCH",
        contentType: false,
        processData: false,
      });
      pollUploadStatus();
    } catch(error) {
      console.error(error);
      const uploadStatusDiv = $(`#async-upload-status-${uploadId}`)[0];
      const { titlecase } = uploadStatusDiv.dataset || false;
      $(uploadStatusDiv).html(capitalize("failed to cancel.", titlecase));
      await new Promise((resolve) => setTimeout(resolve, ON_SCREEN_POLL_RATE));
      pollUploadStatus();
    }
  };

  // Dialog and dialog display method for when async upload complete
  $("#async-upload-alert").dialog({
    autoOpen: false,
    modal: true,
    width: "auto",
    residable: false,
    open: function() {
      const { uploadId, csvType } = $(this).data();
      $(this).html(
        `<p>${csvType} file upload complete</p>` +
        '<p>Click ' + `<a href="/uploads/${uploadId}">here</a>` +
        ' for a more detailed report</p>'
      );
    }
  });
  const displayAlert = (uploadId, csvType) => {
    $("#async-upload-alert").data({"uploadId": uploadId, "csvType": csvType}).dialog("open");
  };

  // Grab active client-side uploads from local storage and poll each upload for status
  let consecutiveFails = 0;
  const pollUploadStatus = async () => {
    const uploadQueue = getUploadQueue();
    uploadQueue.forEach(async (uploadId) => {
      const uploadStatusDiv = $(`#async-upload-status-${uploadId}`)[0];
      const onScreen = typeof uploadStatusDiv !== "undefined";
      const pollRate = onScreen ? ON_SCREEN_POLL_RATE : BACKGROUND_POLL_RATE;
      const { titlecase } = uploadStatusDiv?.dataset || false;
      try {
        const xhr = new XMLHttpRequest();
        const getUploadStatus = () => {
          xhr.open("GET", `/uploads/${uploadId}/status`);
          xhr.send();
        };
        xhr.onload = function() {
          if (this.status === 200) {
            consecutiveFails = 0;
            const { message, active, ok, canceled, type } = JSON.parse(xhr.response).async_status;
            // If upload active and status currently visible on screen
            if (active) {
              if (onScreen) {
                // Update DOM
                $(uploadStatusDiv).html(
                  '<i class="fa fa-gear fa-spin upload-icon" style="font-size:16px"></i>' +
                  `<div>${capitalize(message, titlecase)}</div>`
                );
                const icon = $(uploadStatusDiv).find("i");
                // Enable cancel upload button
                $(icon).on({
                  mouseover: function(_event) {
                    clearInterval(pollingInterval);
                    $(this).removeClass("fa-gear fa-spin").addClass("fa-solid fa-times").css({color: "red", fontSize: "20px"});
                    $(this).on("click", (_event) => cancelUpload(this, uploadId));
                  },
                  mouseleave: function(_event) {
                    pollingInterval = setInterval(getUploadStatus, pollRate);
                    $(this).removeClass("fa-solid fa-times").addClass("fa-gear fa-spin").css({color: "#333", fontSize: "16px"});
                    $(this).off("click");
                  }
                });
              }
            // If upload completed, canceled, or dead
            } else{
              removeFromQueue(uploadId);
              clearInterval(pollingInterval);
              // If upload status currently visible on screen
              if (onScreen) {
                $(uploadStatusDiv).html(capitalize(ok ? "succeeded" : "failed", titlecase));
              }
              // If on upload#show page, reload page to render flash alerts
              if (window.location.pathname === `/uploads/${uploadId}`) {
                window.location.reload();
              // Otherwise render link to alerts in pop dialog
              } else if (!canceled) {
                displayAlert(uploadId, type);
              }
            }
          } else {
            consecutiveFails++;
            if (consecutiveFails === 5) {
            removeFromQueue(uploadId);
            clearInterval(pollingInterval);
            }
          }
        };
        getUploadStatus();
        let pollingInterval = setInterval(getUploadStatus, pollRate);
      } catch(error) {
        console.error(error);
      }
    });
  };
  $(document).ready(() => pollUploadStatus());

  // Reset active upload if for some reason stuck on "Loading . . ."
  // Not sure this is necessary, but technically someone could mess with local storage and
  // it would mess up queue
  $(".default-async-loading").on({
    mouseover: function(_event) {
      $(this).removeClass("fa-gear fa-spin").addClass("fa-solid fa-rotate").css({color: "green"});
      $(this).on("click", (_event) => {
        const { uploadId } = this.dataset;
        addToQueue(parseInt(uploadId));
        pollUploadStatus();
      });
    },
    mouseleave: function(_event) {
      $(this).removeClass("fa-solid fa-rotate").addClass("fa-gear fa-spin").css({color: "#333", fontSize: "16px"});
      $(this).off("click");
    }
  });

  // ASYNC SUBMIT ACTION
  // Submit logic for new upload form when async upload enabled
  $("#async-submit-btn").on("click", async function(event) {
    event.preventDefault();
    // Grab form data and validate file extension
    const form = $("#new_upload")[0];
    const formData = new FormData(form);
    const file = formData.get("upload[upload_file]");
    const ext = file.name !== '' ? file.name.slice(file.name.lastIndexOf(".")) : null;
    const fileInput = $("#upload_upload_file");
    const validExts = $(fileInput).attr("accept").split(", ");
    $(fileInput)[0].setCustomValidity('');
    if (ext !== null && !validExts.includes(ext)) {
      $(fileInput)[0].setCustomValidity(`${ext} is not a valid file format.`);
    }
    if (!form.reportValidity()) {
      return;
    }
    // Open dialog and disable page until client-side processing complete
    $("#async-upload-dialog").dialog("open");
    $(this).html(
      '<div id="async-submit-btn-div">' +
      '<i class="fa fa-gear fa-spin" style="font-size:16px"></i>' +
      'Submitting . . .' +
      '</div>'
    );
    const csvType = formData.get("upload[csv_type]");
    let uploadId = null;
    // Divide upload file into smaller files
    const blobs = [];
    const generateBlobs = async () => {
      const chunkSize = parseInt(this.dataset.chunkSize);
      for (let start = 0; start < file.size; start += chunkSize) {
        const blob = file.slice(start, start + chunkSize, "text/plain");
        blobs.push(blob);
      }
    };
    // Send individual POST request for each blob, simulating multiple file upload
    const submitBlobs = async () => {
      try {
        for (let i = 0; i < blobs.length; i++) {
          formData.set("upload[upload_file]", blobs[i], file.name);
          // Include metadata in payload to track upload progress across multiple requests
          formData.set("upload[metadata][upload_id]", uploadId);
          formData.set("upload[metadata][count][current]", i + 1);
          formData.set("upload[metadata][count][total]", blobs.length);
          const response = await $.ajax({
            url: "/uploads",
            type: "POST",
            data: formData,
            dataType: "json",
            contentType: false,
            processData: false,
          });
          uploadId = response.id;
        }
        // If successful, save upload ID in local storage to enable status polling
        addToQueue(uploadId);
        window.location.href = `/uploads/${uploadId}`;
      } catch(error) {
        console.error(error);
        window.location.href = `/uploads/new/${csvType}`;
      }
    };

    generateBlobs();
    submitBlobs();
  });
});
