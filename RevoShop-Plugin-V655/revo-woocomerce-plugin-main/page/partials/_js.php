<?php 
  wp_enqueue_media(); 
?>

<!-- Vendor -->
 <script src="<?php echo revo_url() ?>assets/vendor/jquery/jquery.js"></script>
 <script src="<?php echo revo_url() ?>assets/vendor/jquery-browser-mobile/jquery.browser.mobile.js"></script>
 <script src="<?php echo revo_url() ?>assets/vendor/bootstrap/js/bootstrap.js"></script>
 <script src="<?php echo revo_url() ?>assets/vendor/nanoscroller/nanoscroller.js"></script>
 <script src="<?php echo revo_url() ?>assets/vendor/bootstrap-datepicker/js/bootstrap-datepicker.js"></script>
 <script src="<?php echo revo_url() ?>assets/vendor/magnific-popup/jquery.magnific-popup.js"></script>
 <script src="<?php echo revo_url() ?>assets/vendor/jquery-placeholder/jquery-placeholder.js"></script>

 <!-- Specific Page Vendor -->
 <script src="<?php echo revo_url() ?>assets/vendor/select2/js/select2.js"></script>
 <script src="<?php echo revo_url() ?>assets/vendor/jquery-datatables/media/js/jquery.dataTables.js"></script>
 <script src="<?php echo revo_url() ?>assets/vendor/jquery-datatables/extras/TableTools/js/dataTables.tableTools.min.js"></script>
 <script src="<?php echo revo_url() ?>assets/vendor/jquery-datatables-bs3/assets/js/datatables.js"></script>

 <!-- Theme Base, Components and Settings -->
 <script src="<?php echo revo_url() ?>assets/javascripts/theme.js"></script>

 <!-- Theme Custom -->
 <script src="<?php echo revo_url() ?>assets/javascripts/theme.custom.js"></script>

 <!-- Theme Initialization Files -->
 <script src="<?php echo revo_url() ?>assets/javascripts/theme.init.js"></script>

 <!-- Examples -->
 <script src="<?php echo revo_url() ?>assets/javascripts/tables/examples.datatables.default.js"></script>
 <script src="<?php echo revo_url() ?>assets/javascripts/tables/examples.datatables.row.with.details.js"></script>
 <script src="<?php echo revo_url() ?>assets/javascripts/tables/examples.datatables.tabletools.js"></script>

 <script src="https://cdn.jsdelivr.net/npm/sweetalert2@10"></script>

 <script>
	// $(document).ready(function() {
      $('.typeInsert').change(function(e) {
        console.log('as');
        e.preventDefault();
        modalEl = $(e.target).parents('.modal');
        const fdId = modalEl.attr('fd-id') ?? '';

          if (this.value == 'file') {
            $('#linkInput').css("display", "none");
            $('#linkInput').removeAttr("required");
            $('#fileinput').css("display", "block");
            $('#fileinput').attr("required","");
            $(`#fileinput .upload_file_button`).prop("required", true);
          }
          else if (this.value == 'link') {
            $('#linkInput').css("display", "block");
            $('#linkInput').attr("required", "");
            $('#fileinput').css("display", "none");
            $('#fileinput').removeAttr("required");
            $(`#fileinput .upload_file_button`).prop("required", false);
          }
      });

      $('.updateFile').change(function() {
         var id = $(this).attr("BannerID");
          if (this.value == 'file') {
              $('#linkInput' + id).css("display", "none");
              $('#linkInput' + id).removeAttr("required");
              $('#fileinput' + id).css("display", "block");
              $('#fileinput' + id).attr("required","");
              $(`#fileinput${id} .upload_file_button`).prop("required", true);
          }
          else if (this.value == 'link') {
              $('#linkInput' + id).css("display", "block");
              $('#linkInput' + id).attr("required", "");
              $('#fileinput' + id).css("display", "none");
              $('#fileinput' + id).removeAttr("required");
              $(`#fileinput${id} .upload_file_button`).prop("required", false);
          }
      });

      $('.typeInsertLinkTo, input[type=radio][name=directtype]').change(function() {
          if (this.value == 'URL') {
              $('#linkInputLinkTo').css("display", "block");
              $('#linkInputLinkTo').attr("required", "");
              if (document.getElementById("divselect")) {
                document.getElementById("divselect").style.display = 'none';
              }
          }
          else {
              $('#linkInputLinkTo').css("display", "none");
              $('#linkInputLinkTo').removeAttr("required");
              if (document.getElementById("divselect")) {
                document.getElementById("divselect").style.display = 'block';
              }
          }
      });

      $('.updateFileLinkTo, input[type=radio][name=directtype]').change(function() {
        var id = $(this).attr("BannerID");
          if (this.value == 'URL') {
              $('#updateLinkTo' + id).css("display", "block");
              $('#updateLinkTo' + id).attr("required", "");
              if (document.getElementById("divselectupdate" + id)) {
                document.getElementById("divselectupdate" + id).style.display = 'none';
              }
          }
          else {
              $('#updateLinkTo' + id).css("display", "none");
              $('#updateLinkTo' + id).removeAttr("required");
              if (document.getElementById("divselectupdate" + id)) {
                document.getElementById("divselectupdate" + id).style.display = 'block';
              }
          }
      });

      // Uploading files
      let file_frame;

      // Uploading files Event
      jQuery(document).on('click', '.upload_file_button', function(event) {
        event.preventDefault();

        const inputButton = $(this);

        // If the media frame already exists, reopen it.
        if (file_frame) {
          file_frame.open();
        } else { // Create the media frame.
          file_frame = wp.media({
            title: 'Choose file',
            button: {
              text: 'Use file'
            },
            multiple: false
          });
        }

        // When an popup media is open, run a callback.
        file_frame.on('open', function() {
          const selection = file_frame.state().get('selection');
          const ids_value = $('*[name="fileUploadIds"]').val();

          if (ids_value.length > 0) {
            let ids = ids_value.split(',');

            ids.forEach(function(id) {
              attachment = wp.media.attachment(id);
              attachment.fetch();
              selection.add(attachment ? [attachment] : []);
            });
          }
        });

        // When an image is selected, run a callback.
        file_frame.on('select', function() {
          const attachment = file_frame.state().get('selection').first().toJSON();

          $('*[name="fileUploadUrl"]').val(attachment.url);
          $('*[name="fileUploadIds"]').val(attachment.id);

          $(inputButton).val(attachment.filename);
        });

        // Finally, open the modal.
        file_frame.open();
      });
    // });
 </script>