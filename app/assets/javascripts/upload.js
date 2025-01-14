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
      $(this).html(
        '<div id="async-submit-btn-div">' +
        '<i class="fa fa-gear fa-spin" style="font-size:16px"></i>' +
        'Submitting . . .' +
        '</div>'
      );
      const formData = new FormData(form);
      const file = formData.get("upload[upload_file]");
      const blobs = [];
      let uploadId = null;

      const generateBlobs = async () => {
        const chunkSize = parseInt(this.dataset.chunkSize);
        for (let start = 0; start < file.size; start += chunkSize) {
          const blob = file.slice(start, start + chunkSize, "text/plain");
          blobs.push(blob);
        }
      };

      const submitBlobs = async () => {
        for (let i = 0; i < blobs.length; i++) {
          try {
            formData.set("upload[upload_file]", blobs[i], file.name);
            formData.set("upload[metadata][upload_id]", uploadId);
            formData.set("upload[metadata][count][current]", i + 1);
            formData.set("upload[metadata][count][total]", blobs.length);
            const response = await $.ajax({
              url: "/uploads/create_async",
              type: "POST",
              data: formData,
              dataType: "json",
              contentType: false,
              processData: false,
            });
            uploadId = response.id;
          } catch(error) {
            console.error(error);
          }
        }
        window.location.href = `/uploads/${uploadId}`;
      };

      generateBlobs();
      await submitBlobs();
    });

    const pollUploadStatus = async () => {
      const uploadStatuses = $(".async-upload-status-div");
      for (let i = 0; i < uploadStatuses.length; i++) {
        const uploadStatus = uploadStatuses[i];
        const { uploadId, titlecase } = uploadStatus.dataset;
        const capitalize = (str) => titlecase ? str.charAt(0).toUpperCase() + str.slice(1) : str;
        try {
          const xhr = new XMLHttpRequest();
          xhr.onload = function() {
            if (this.status === 200) {
              const { message, ok, completed } = JSON.parse(xhr.response).async_status;
              let asyncStatusHtml;
              if (completed) {
                clearInterval(pollingInterval);
                const asyncStatus = ok ? "succeeded" : "failed";
                asyncStatusHtml = `<div>${capitalize(asyncStatus)}</div>`;
              } else {
                asyncStatusHtml = '<i class="fa fa-gear fa-spin" style="font-size:16px"></i>' +
                                  `<div>${capitalize(message)}</div>`
              }
              $(`#async-upload-status-${uploadId}`).html(asyncStatusHtml);
            }
          }
          const getUploadStatus = () => {
            xhr.open("GET", `/uploads/${uploadId}/async_status`);
            xhr.send();
          };
          getUploadStatus();
          const pollingInterval = setInterval(getUploadStatus, 10_000);
        } catch(error) {
          console.error(error);
        }
      }
    };
    pollUploadStatus();
});
