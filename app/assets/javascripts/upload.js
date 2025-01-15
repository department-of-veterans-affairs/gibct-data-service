$(function() {
    $( "[id^=api_fetch_]" ).on( "click", function() {
      this.parentElement.parentElement.innerHTML = (
        '<td colspan="7" class="text-center">' +
        'Fetching ' + '<i class="fa fa-gear fa-spin" style="font-size:24px"></i> '+ this.id.replace('api_fetch_', '') +
        '</td>'
      );
    });

    let csvType;
    // Alternative submit logic for when async upload enabled
    $("#async-submit-btn").on("click", async function(event) {
      event.preventDefault();
      const form = $("#new_upload")[0];
      if (!form.reportValidity()) {
        return;
      }
      $(this).prop("disabled", true);
      $(this).html(
        '<div id="async-submit-btn-div">' +
        '<i class="fa fa-gear fa-spin" style="font-size:16px"></i>' +
        'Submitting . . .' +
        '</div>'
      );
      const formData = new FormData(form);
      const file = formData.get("upload[upload_file]");
      csvType = formData.get("upload[csv_type]");
      const blobs = [];
      let uploadId = null;
      // Divide upload file into smaller files
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
          window.location.href = `/uploads/${uploadId}`;
        } catch(error) {
          console.error(error);
          window.location.href = `/uploads/new/${csvType}`;
        }
      };

      generateBlobs();
      submitBlobs();
    });

    // Cancel active upload
    const cancelUpload = async (icon, uploadId) => {
      $(icon).off("click mouseleave");
      try {
        const response = await $.ajax({
          url: `/uploads/${uploadId}/cancel`,
          type: "PATCH",
          contentType: false,
          processData: false,
        });
      } catch(error) {
        console.error(error);
      }
    };

    // Poll backend to track progress as rows are processed and ingested into database
    const pollUploadStatus = async () => {
      // Set polling interval delay
      const DELAY = 5_000;
      const uploadStatuses = $(".async-upload-status-div");
      // Multiple upload statuses to be polled on /uploads page
      for (let i = 0; i < uploadStatuses.length; i++) {
        const uploadStatus = uploadStatuses[i];
        const { uploadId, titlecase } = uploadStatus.dataset;
        const capitalize = (str) => titlecase ? str.charAt(0).toUpperCase() + str.slice(1) : str;
        try {
          const xhr = new XMLHttpRequest();
          xhr.onload = function() {
            if (this.status === 200) {
              const { message, active, ok } = JSON.parse(xhr.response).async_status;
              let asyncStatusHtml;
              const iconId = `upload-icon-${uploadId}`;
              const iconHtml = `<i id=${iconId} class="fa fa-gear fa-spin upload-icon" style="font-size:16px"></i>`
              if (true) {
                // If upload active (not completed, dead, or canceled), report status at intervals
                asyncStatusHtml = iconHtml + `<div id="active-status-${uploadId}">${capitalize(message || "loading . . .")}</div>`
              } else {
                clearInterval(pollingInterval);
                // Otherwise clear interval and report whether success or failure
                const asyncStatus = ok ? "succeeded" :"failed";
                asyncStatusHtml = `<div>${capitalize(asyncStatus)}</div>`;
              }
              $(`#async-upload-status-${uploadId}`).html(asyncStatusHtml);
              if (true) {
                // If upload active, enable upload cancellation by hovering over gear icon
                const activeStatusId = `#active-status-${uploadId}`
                $(`#${iconId}`).on({
                  mouseenter: function(_event) {
                    clearInterval(pollingInterval);
                    $(this).removeClass("fa-gear fa-spin").addClass("fa-times").css({color: "red", fontSize: "18px"});
                    $(activeStatusId).css({color: "red", fontWeight: "bold"}).text("cancel upload");
                    $(this).on("click", (_event) => cancelUpload(this, uploadId));
                  },
                  mouseleave: function(_event) {
                    pollingInterval = setInterval(getUploadStatus, DELAY);
                    $(this).removeClass("fa-times").addClass("fa-gear fa-spin").css("color", "#333");
                    $(activeStatusId).css({color: "#333", fontWeight: "normal"}).text(capitalize(message || "loading . . ."));
                    $(this).off("click");
                  }
                });
              }
            }
          }
          const getUploadStatus = () => {
            xhr.open("GET", `/uploads/${uploadId}/status`);
            xhr.send();
          };
          getUploadStatus();
          let pollingInterval = setInterval(getUploadStatus, DELAY);
        } catch(error) {
          console.error(error);
        }
      }
    };
    pollUploadStatus();
});
