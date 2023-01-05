<?php
  require (plugin_dir_path( __FILE__ ).'../helper.php');
  
  $query_image = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'empty_image'";
  $data_image  = $wpdb->get_results($query_image, OBJECT);

  if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    function uploadImage($file, $allowed_mimes = [], $max_size = null) {
      $uploads_url = WP_CONTENT_URL . '/uploads/revo/';
      $target_dir  = WP_CONTENT_DIR . '/uploads/revo/';
      $target_file = $target_dir . basename($file['name']);
      $image_file_type = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
      $newname = md5(date('Y-m-d H:i:s')) . '.' . $image_file_type;
      $is_upload_error = 0;

      if ($file['size'] > 0) {
        if ($file['size'] > $max_size) {
          $alert = array(
            'type' => 'error',
            'title' => 'Uploads Error !',
            'message' => 'your file is too large. max ' . size_format($max_size),
          );

          $is_upload_error = 1;
        }

        if (!in_array($image_file_type, $allowed_mimes)) {
          $alert = array(
            'type' => 'error',
            'title' => 'Uploads Error !',
            'message' => 'only ' . strtoupper(implode(', ', $allowed_mimes)) . ' files are allowed.',
          );

          $is_upload_error = 1;
        }

        if ($is_upload_error == 0) {
          if ($file['size'] > 500000) {
            compress($file['tmp_name'], $target_dir . $newname, 90);
          } else {
            move_uploaded_file($file['tmp_name'], $target_dir . $newname);
          }

          $alert = array(
            'type' => 'success',
            'title' => 'upload success',
            'message' => $uploads_url . $newname,
          );
        }
      }

      return $alert ?? [
        'type' => 'error',
        'title' => 'upload error',
        'message' => 'image not valid !',
      ];
    }

    function checkImage($image, $image_id, $allowed_mimes = [], $max_size = null) {
      $image_file_type = pathinfo($image, PATHINFO_EXTENSION);
      $image_data = wp_get_attachment_metadata($image_id);
      $is_upload_error = 0;

      if ($image_data['filesize'] > $max_size) {
        $alert = array(
          'type' => 'error',
          'title' => 'Uploads Error !',
          'message' => 'your file is too large. max ' . size_format($max_size),
        );

        $is_upload_error = 1;
      }

      if (!in_array($image_file_type, $allowed_mimes)) {
        $alert = array(
          'type' => 'error',
          'title' => 'Uploads Error Logo !',
          'message' => 'only ' . strtoupper(implode(', ', $allowed_mimes)) . ' files are allowed.',
        );

        $is_upload_error = 1;
      }

      if ($is_upload_error == 0) {
        $alert = array(
          'type' => 'success',
          'title' => 'upload success !',
          'message' => $image,
        );
      }

      return $alert ?? [
        'type' => 'error',
        'title' => 'upload error',
        'message' => 'image not valid !',
      ];
    }

    if ($_FILES["fileToUploadLogo"]["name"] || $_POST['fileUploadUrl']) {
      $query_data = array(
        'slug' => 'empty_image', 
        'title' => $_POST['title'], 
        'image' => '', 
        'description' => '', 
      );

      $alert = array(
        'type' => 'error', 
        'title' => 'Failed to Change !',
        'message' => 'Required Image', 
      );

      $max_size = 2 * 1024 * 1024; // 2mb
      $allowed_mimes = ['jpg', 'png', 'jpeg'];

      if (!empty($_FILES['fileToUploadLogo']['name'])) {
        $res_upload = uploadImage($_FILES['fileToUploadLogo'], $allowed_mimes, $max_size);
      } else if (!empty($_POST['fileUploadUrl'])) {
        $res_upload = checkImage($_POST['fileUploadUrl'], $_POST['fileUploadIds'], $allowed_mimes, $max_size);
      }

      if ($res_upload['type'] === 'success') {
        $query_data['image'] = $res_upload['message'];
      } else {
        $alert = $res_upload;
      }

      if ($query_data['image'] != '') {
        $where = ['id' => $_POST['id']];
        $wpdb->update('revo_mobile_variable',$query_data,$where);
        
        if (@$wpdb->show_errors == false) {
          $alert = array(
            'type' => 'success', 
            'title' => 'Success !',
            'message' => 'Data Updated Successfully', 
          );
        }
      }

      $_SESSION["alert"] = $alert;

      $data_image = $wpdb->get_results($query_image, OBJECT);
    }
  }
?>

<!DOCTYPE html>
<html class="fixed sidebar-light">
<?php include (plugin_dir_path( __FILE__ ).'partials/_css.php'); ?>
<body>
  <?php include (plugin_dir_path( __FILE__ ).'partials/_header.php'); ?>
  <div class="container-fluid">
    <?php include (plugin_dir_path( __FILE__ ).'partials/_alert.php'); ?>
    <section class="panel">
      <div class="inner-wrapper pt-0">
      <!-- start: sidebar -->
      <?php include (plugin_dir_path( __FILE__ ).'partials/_new_sidebar.php'); ?>
      <!-- end: sidebar -->

      <section role="main" class="content-body p-0">
        <section class="panel mb-3">
          <div class="panel-body">
            <div class="row mb-2">
              <div class="col-6 text-left">
                <h4 style="margin-bottom: 35px">
                  Setting Result Image
                </h4>
              </div>
            </div>

            <?php foreach ($data_image as $data_image):?>
              <?php $title = str_replace("_", " ", $data_image->title); ?>
              <div class="row border-bottom-primary">
                <form class="col-md-8 form-horizontal form-bordered" method="POST" action="#" enctype="multipart/form-data">
                    <div class="form-group">
                        <label class="col-md-4 control-label text-left" for="inputDefault">Image <?= $title ?></label>
                        <div class="col-md-8">
                            <!-- <input type="file" class="form-control" name="fileToUploadLogo" required> -->
                            <input class="form-control upload_file_button" placeholder="Select a Photo" required>
                            <input type="hidden" name="fileUploadUrl">
                            <input type="hidden" name="fileUploadIds">
                            <small class="text-danger">Best Size : <?= "450 x 450 px"; // echo $data_image->description ?></small>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-12 text-right">
                          <input type="hidden" name="id" value="<?= $data_image->id ?>">
                          <input type="hidden" name="title" value="<?= $data_image->title ?>">
                          <button type="submit" class="btn btn-primary" style="text-transform: capitalize;">Update <?= $title ?></button>
                        </div>
                    </div>
                </form>
                <div class="col-md-4 text-center">
                    <div class="thumbnail-gallery my-auto text-center">
                        <a class="img-thumbnail lightbox my-auto" style="border:unset;" href="<?=isset($data_image->image)? $data_image->image : get_logo() ?>" data-plugin-options='{ "type":"image" }'>
                          <img class="img-responsive" src="<?=isset($data_image->image) ? $data_image->image : get_logo() ?>" style="width: 100px">
                          <span class="zoom">
                            <i class="fa fa-search"></i>
                          </span>
                        </a>
                    </div>
                </div>
              </div>
            <?php endforeach; ?>
          </div>
        </section>
      </section>
    </div>
    </section>
  </div>
</body>
<?php include (plugin_dir_path( __FILE__ ).'partials/_js.php'); ?>
</html>