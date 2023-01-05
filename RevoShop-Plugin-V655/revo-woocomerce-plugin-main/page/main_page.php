<?php
  require(plugin_dir_path(__FILE__) . '../helper.php');

  $query_logo = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'logo' LIMIT 1";
  $query_splash = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'splashscreen' LIMIT 1";
  $query_kontak = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'kontak' LIMIT 3 ";
  $query_sk = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'term_condition'";
  $query_pp = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'privacy_policy'";
  $query_about = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'about'";

  $data_logo = $wpdb->get_row($query_logo, OBJECT);
  $data_splash = $wpdb->get_row($query_splash, OBJECT);
  $data_sk = $wpdb->get_row($query_sk, OBJECT);
  $data_pp = $wpdb->get_row($query_pp, OBJECT);
  $data_about = $wpdb->get_row($query_about, OBJECT);
  $data_kontak = $wpdb->get_results($query_kontak, OBJECT);

  if ($_SERVER['REQUEST_METHOD'] == 'POST') {
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

    if ($_POST["typeQuery"] === "fileToUploadLogo") {
      $query_data = array(
        'slug' => 'logo',
        'title' => $_POST['title'],
        'image' => '',
        'description' => 'logo',
      );

      $alert = array(
        'type' => 'error',
        'title' => 'Failed to Change Logo !',
        'message' => 'Required Image',
      );

      $max_size = 2 * 1024 * 1024; //2mb
      $allowed_mimes = ['jpg', 'png', 'jpeg'];

      if (!empty($_FILES['fileToUploadLogo']['name'])) {
        $res_upload = uploadImage($_FILES['fileToUploadLogo'], $allowed_mimes, $max_size);
      } else if (!empty($_POST['fileUploadUrl'])) {
        $res_upload = checkImage($_POST['fileUploadUrl'], $_POST['fileUploadIds'], $allowed_mimes, $max_size);
      }

      if ($res_upload['type'] === 'success') {
        $query_data['image'] = $res_upload['message'];

        if ($query_data['image'] != '') {
          if ($data_logo == NULL || empty($data_logo)) {

            $wpdb->insert('revo_mobile_variable', $query_data);

            if (@$wpdb->insert_id > 0) {
              $alert = array(
                'type' => 'success',
                'title' => 'Success !',
                'message' => 'Logo Updated Successfully',
              );
            }
          } else {

            $where = ['id' => $data_logo->id];
            $wpdb->update('revo_mobile_variable', $query_data, $where);

            if (@$wpdb->show_errors == false) {
              $alert = array(
                'type' => 'success',
                'title' => 'Success !',
                'message' => 'Logo Updated Successfully',
              );
            }
          }
        }
      } else {
        $alert = $res_upload;
      }

      $_SESSION["alert"] = $alert;

      $data_logo = $wpdb->get_row($query_logo, OBJECT);
    }

    if ($_POST['typeQuery'] === 'fileToUploadSplash') {
      $query_data = array(
        'slug' => 'splashscreen',
        'image' => '',
        'description' => $_POST['description'],
      );

      $alert = array(
        'type' => 'error',
        'title' => 'Failed to Change SplashScreen !',
        'message' => 'Required Image',
      );

      $max_size = 1024 * 500; //500kb
      $allowed_mimes = ['jpg', 'jpeg', 'gif', 'mp4', 'png'];

      if (!empty($_FILES['fileToUploadSplash']['name'])) {
        $res_upload = uploadImage($_FILES['fileToUploadSplash'], $allowed_mimes, $max_size);
      } else if (!empty($_POST['fileUploadUrl'])) {
        $res_upload = checkImage($_POST['fileUploadUrl'], $_POST['fileUploadIds'], $allowed_mimes, $max_size);
      }

      if ($res_upload['type'] === 'success') {
        $query_data['image'] = $res_upload['message'];

        if ($query_data['image'] != '') {
          if ($data_splash == NULL || empty($data_splash)) {
            $wpdb->insert('revo_mobile_variable', $query_data);

            if (@$wpdb->insert_id > 0) {
              $alert = array(
                'type' => 'success',
                'title' => 'Success !',
                'message' => 'Splashscreen Updated Successfully',
              );
            }
          } else {
            $where = ['id' => $data_splash->id];
            $wpdb->update('revo_mobile_variable', $query_data, $where);

            if (@$wpdb->show_errors == false) {
              $alert = array(
                'type' => 'success',
                'title' => 'Success !',
                'message' => 'Splashscreen Updated Successfully',
              );
            }
          }
        }
      } else {
        $alert = $res_upload;
      }

      $_SESSION["alert"] = $alert;

      $data_splash = $wpdb->get_row($query_splash, OBJECT);
    }

    if (@$_POST['slug']) {
      if ($_POST['slug'] == 'kontak') {

        $success = 0;
        $where_wa = array(
          'slug' => 'kontak',
          'title' => 'wa',
        );

        $success = insert_update_MV($where_wa, $_POST['id_wa'], $_POST['number_wa']);

        $where_phone = array(
          'slug' => 'kontak',
          'title' => 'phone',
        );

        $success = insert_update_MV($where_phone, $_POST['id_tel'], $_POST['number_tel']);

        $where_sms = array(
          'slug' => 'kontak',
          'title' => 'sms',
        );

        $success = insert_update_MV($where_sms, $_POST['id_sms'], $_POST['number_sms']);

        if ($success > 0) {
          $data_kontak = $wpdb->get_results($query_kontak, OBJECT);
          $alert = array(
            'type' => 'success',
            'title' => 'Success !',
            'message' => 'Contact Updated Successfully',
          );
        } else {
          $alert = array(
            'type' => 'error',
            'title' => 'error !',
            'message' => 'Contact Failed to Update',
          );
        }

        $_SESSION["alert"] = $alert;
      }

      if ($_POST['slug'] == 'url') {
        $success = 0;

        for ($i = 1; $i < 4; $i++) {
          $query_data = array(
            'slug' => $_POST['slug' . $i],
            'title' => $_POST['title' . $i],
            'description' => $_POST['description' . $i],
          );

          if ($_POST['id' . $i] != 0) {
            $where = ['id' => $_POST['id' . $i]];
            $wpdb->update('revo_mobile_variable', $query_data, $where);

            if (@$wpdb->show_errors == false) {
              $success = 1;
            }
          } else {
            $wpdb->insert('revo_mobile_variable', $query_data);
            if (@$wpdb->insert_id > 0) {
              $success = 1;
            }
          }
        }

        if ($success) {
          $data_sk = $wpdb->get_row($query_sk, OBJECT);
          $data_about = $wpdb->get_row($query_about, OBJECT);
          $data_pp = $wpdb->get_row($query_pp, OBJECT);

          $alert = array(
            'type' => 'success',
            'title' => 'Success !',
            'message' => $_POST['title'] . ' Success to Update',
          );
        } else {
          $alert = array(
            'type' => 'error',
            'title' => 'error !',
            'message' => $_POST['title'] . ' Failed to Update',
          );
        }

        $_SESSION["alert"] = $alert;
      }
    }
  }
?>

<!DOCTYPE html>
  <html class="fixed sidebar-light">
  <?php include(plugin_dir_path(__FILE__) . 'partials/_css.php'); ?>
  <body>
    <?php include(plugin_dir_path(__FILE__) . 'partials/_header.php'); ?>
    <div class="container-fluid">
      <?php include(plugin_dir_path(__FILE__) . 'partials/_alert.php'); ?>
      <section class="panel">
        <div class="inner-wrapper pt-0">
          <!-- start: sidebar -->
          <?php include(plugin_dir_path(__FILE__) . 'partials/_new_sidebar.php'); ?>
          <!-- end: sidebar -->

          <section role="main" class="content-body p-0 pl-0">
            <section class="panel mb-3">
              <div class="panel-body">
                <div class="row border-bottom-primary">
                  <div class="col-md-12">
                    <h4 style="margin-bottom: 35px">App Title and Logo</h4>
                  </div>

                  <form class="col-md-8 form-horizontal form-bordered" method="POST" action="#" enctype="multipart/form-data">
                    <div class="form-group">
                      <label class="col-md-3 control-label text-left" for="inputDefault">Title Apps</label>
                      <div class="col-md-9">
                        <input type="text" class="form-control" name="title" value="<?php echo $data_logo->title ?>" required>
                      </div>
                    </div>

                    <div class="form-group">
                      <label class="col-md-3 control-label text-left" for="inputDefault">Image</label>
                      <div class="col-md-9">
                        <input class="form-control upload_file_button" placeholder="Select a Photo" required>
                        <div class="small text-danger pt-2">Best Size : 100 x 100 px</div>
                        <input type="hidden" name="fileUploadUrl">
                        <input type="hidden" name="fileUploadIds">
                        <!-- <input type="file" class="form-control" name="fileToUploadLogo" required> -->
                      </div>
                    </div>

                    <div class="form-group">
                      <div class="col-md-12 text-right">
                        <input type="hidden" name="typeQuery" value="fileToUploadLogo">
                        <button type="submit" class="btn btn-primary">Update Logo Apps</button>
                      </div>
                    </div>
                  </form>

                  <div class="col-md-4 text-center">
                    <h5 class="mb-2" style="margin-bottom: 15px">Preview</h5>
                    <div class="thumbnail-gallery my-auto text-center">
                      <a class="img-thumbnail lightbox my-auto" style="border:unset;" href="<?= isset($data_logo->image) ? $data_logo->image : get_logo() ?>" data-plugin-options='{ "type":"image" }'>
                        <img class="img-responsive" src="<?= isset($data_logo->image) ? $data_logo->image : get_logo() ?>" style="width: 150px">
                        <span class="zoom">
                          <i class="fa fa-search"></i>
                        </span>
                      </a>
                    </div>
                  </div>
                </div>

                <div class="row border-bottom-primary">
                  <div class="col-md-12">
                    <h4 style="margin-bottom: 35px">General Settings</h4>
                  </div>
                  <form class=" col-md-5 form-horizontal form-bordered" method="POST" action="#" enctype="multipart/form-data">
                    <h5 style="margin-bottom: 25px">Contact Setting</h5>
                    <div class="form-group">
                      <label class="col-md-4 control-label text-left" for="inputDefault">WhatsApp</label>
                      <div class="col-md-8">
                        <?php
                        $id = 0;
                        $value = '';
                        if ($data_kontak) {
                          foreach ($data_kontak as $key) {
                            if ($key->title == 'wa') {
                              $id = $key->id;
                              $value = $key->description;
                            }
                          }
                        }
                        ?>
                        <input type="number" class="form-control" name="number_wa" placeholder="ex: 628XXXXXXX" value="<?= $value ?>" required>
                        <input type="hidden" name="id_wa" value="<?php echo $id  ?>">
                        <?php

                        ?>
                      </div>
                    </div>
                    <div class="form-group">
                      <label class="col-md-4 control-label text-left" for="inputDefault">No Telp</label>
                      <div class="col-md-8">
                        <?php
                        $id = 0;
                        $value = '';
                        if ($data_kontak) {
                          foreach ($data_kontak as $key) {
                            if ($key->title == 'phone') {
                              $id = $key->id;
                              $value = $key->description;
                            }
                          }
                        }
                        ?>
                        <input type="number" class="form-control" name="number_tel" placeholder="ex: 628XXXXXXX" value="<?= $value ?>" required>
                        <input type="hidden" name="id_tel" value="<?php echo $id ?>">
                      </div>
                    </div>
                    <div class="form-group">
                      <label class="col-md-4 control-label text-left" for="inputDefault">SMS</label>
                      <div class="col-md-8">
                        <?php
                        $id = 0;
                        $value = '';
                        if ($data_kontak) {
                          foreach ($data_kontak as $key) {
                            if ($key->title == 'sms') {
                              $id = $key->id;
                              $value = $key->description;
                            }
                          }
                        }
                        ?>
                        <input type="number" class="form-control" name="number_sms" placeholder="ex: 628XXXXXXX" value="<?= $value ?>" required>
                        <input type="hidden" name="id_sms" value="<?php echo $id  ?>">
                      </div>
                    </div>
                    <div class="form-group">
                      <div class="col-md-12 text-right">
                        <input type="hidden" name="slug" value="kontak">
                        <button type="submit" class="btn btn-primary">Update Contact</button>
                      </div>
                    </div>
                  </form>
                  <form class=" col-md-7 form-horizontal form-bordered" method="POST" action="#" enctype="multipart/form-data">
                    <h5 style="margin-bottom: 25px">URL Setting</h5>
                    <div class="form-group">
                      <label class="col-md-4 control-label text-left" for="inputDefault">Link to About</label>
                      <div class="col-md-8">
                        <input type="text" class="form-control" name="description1" placeholder="ex: https://revoapps.id/about" value="<?= isset($data_about->description) ? $data_about->description : '' ?>" required>
                        <input type="hidden" name="slug1" value="about">
                        <input type="hidden" name="title1" value="<?= isset($data_about->title) ? $data_about->title : 'link about' ?>">
                        <input type="hidden" name="id1" value="<?= $data_about->id ?>">
                      </div>
                    </div>
                    <div class="form-group">
                      <label class="col-md-4 control-label text-left" for="inputDefault">Term & Condition</label>
                      <div class="col-md-8">
                        <input type="text" class="form-control" name="description2" placeholder="ex: https://revoapps.id/customer-suport" value="<?= isset($data_sk->description) ? $data_sk->description : '' ?>" required>
                        <input type="hidden" name="slug2" value="term_condition">
                        <input type="hidden" name="title2" value="<?= isset($data_sk->title) ? $data_sk->title : 'customer service' ?>">
                        <input type="hidden" name="id2" value="<?= $data_sk->id ?>">
                      </div>
                    </div>
                    <div class="form-group">
                      <label class="col-md-4 control-label text-left" for="inputDefault">Privacy Policy</label>
                      <div class="col-md-8">
                        <input type="text" class="form-control" name="description3" placeholder="ex: https://revoapps.id/privacy-policy" value="<?= isset($data_pp->description) ? $data_pp->description : '' ?>" required>
                        <input type="hidden" name="slug3" value="privacy_policy">
                        <input type="hidden" name="title3" value="<?= isset($data_pp->title) ? $data_pp->title : 'Privacy Policy' ?>">
                        <input type="hidden" name="id3" value="<?= $data_pp->id ?>">
                      </div>
                    </div>
                    <div class="form-group">
                      <div class="col-md-12 text-right">
                        <input type="hidden" name="slug" value="url">
                        <button type="submit" class="btn btn-primary">Update URL</button>
                      </div>
                    </div>
                  </form>
                </div>

                <div class="row border-bottom-primary">
                  <div class="col-md-12">
                    <h4 style="margin-bottom: 35px">Setting Splash Screen</h4>
                  </div>

                  <form class="col-md-8 form-horizontal form-bordered" method="POST" action="#" enctype="multipart/form-data">
                    <div class="form-group">
                      <label class="col-md-3 control-label text-left" for="inputDefault">Description</label>
                      <div class="col-md-9">
                        <input type="text" class="form-control" id="description" name="description" value="<?= isset($data_splash->description) ? $data_splash->description : 'Welcome' ?>" placeholder="title">
                      </div>
                    </div>

                    <div class="form-group">
                      <label class="col-md-3 control-label text-left" for="inputDefault">Image</label>
                      <div class="col-md-9">
                        <input class="form-control upload_file_button" placeholder="Select a Photo" required>
                        <small class="text-danger">Best Size : 450 x 1000 px</small>
                        <input type="hidden" name="fileUploadUrl">
                        <input type="hidden" name="fileUploadIds">
                        <!-- <input type="file" class="form-control" name="fileToUploadSplash" required> -->
                      </div>
                    </div>

                    <div class="form-group">
                      <div class="col-md-12 text-right">
                          <input type="hidden" name="typeQuery" value="fileToUploadSplash">
                        <button type="submit" class="btn btn-primary">Update Splash Screen</button>
                      </div>
                    </div>
                  </form>

                  <div class="col-md-4 text-center">
                    <div class="thumbnail-gallery my-auto text-center">
                      <a class="img-thumbnail lightbox my-auto w-75" style="border:unset;" href="<?= isset($data_splash->image) ? $data_splash->image : get_logo() ?>" data-plugin-options='{ "type":"image" }'>
                        <?php
                        $filename = basename($data_splash->image);
                        $ext = explode(".", $filename);
                        $ext = $ext[count($ext) - 1];
                        ?>
                        <?php if ($ext === 'mp4') : ?>
                          <video class="img-responsive w-75 mx-auto" controls src="<?= isset($data_splash->image) ? $data_splash->image : get_logo() ?>">
                            Your browser does not support the video tag.
                          </video>
                        <?php else : ?>
                          <img class="img-responsive w-75 mx-auto" src="<?= isset($data_splash->image) ? $data_splash->image : get_logo() ?>" style="width: 200px">
                        <?php endif; ?>
                        <p class="font-size-xl" style="color: black;margin-top: 15px" id="title"><?= isset($data_splash->description) ? $data_splash->description : 'Welcome' ?></p>
                      </a>
                    </div>
                  </div>
                </div>
              </div>
            </section>
          </section>
        </div>
      </section>
    </div>
  </body>
  <?php include(plugin_dir_path(__FILE__) . 'partials/_js.php'); ?>
  <script>
    function getExtFile(filename) {
      return (/[.]/.exec(filename)) ? /[^.]+$/.exec(filename) : undefined;
    }

    $(document).ready(function() {
      $("input[name=fileToUploadSplash]").change(function() {
        const fileUpload = this.files[0];
        const allowedExt = ['jpg', 'jpeg', 'gif', 'mp4', 'png'];
        const maxSize = 450 * 1000;
        check = allowedExt.includes(getExtFile(fileUpload.name)[0].toLowerCase()) && fileUpload.size <= maxSize;
        if (!check) {
          this.value = null;
          alert(`Only ${allowedExt.join(", ")} can be uploaded & 500kb max file size`);
        }
      })
    })
  </script>
</html>