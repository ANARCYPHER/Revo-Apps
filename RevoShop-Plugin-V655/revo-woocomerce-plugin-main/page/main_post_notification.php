<?php
  require (plugin_dir_path( __FILE__ ).'../helper.php');

  $send_notif = false;

  function notif() {
    global $wpdb;

    $query_notif = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'firebase_notification' limit 1";
    return $wpdb->get_row($query_notif, OBJECT);
  }

  $data = access_key();
  $data_notif = notif();

  $dev_mode = $wpdb->get_row("SELECT id, slug, description FROM revo_mobile_variable WHERE slug = 'firebase_dev_mode' ORDER BY id DESC LIMIT 1");

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

    if ($_POST['type'] == 'firebase_key') {
      $query_data = array(
        "firebase_servey_key" => $_POST["firebase_servey_key"],
        "firebase_api_key" => $_POST["firebase_api_key"],
        "firebase_auth_domain" => $_POST["firebase_auth_domain"],
        "firebase_database_url" => $_POST["firebase_database_url"],
        "firebase_project_id" => $_POST["firebase_project_id"],
        "firebase_storage_bucket" => $_POST["firebase_storage_bucket"],
        "firebase_messaging_sender_id" => $_POST["firebase_messaging_sender_id"],
        "firebase_app_id" => $_POST["firebase_app_id"],
        "firebase_measurement_id" => $_POST["firebase_measurement_id"],
      );

      $alert = array(
        'type' => 'error', 
        'title' => 'Firebase KEY update failed!',
        'message' => 'Try Again Later', 
      );

      $success = false;
      if (@$_POST['id']) {
        $wpdb->update('revo_access_key',$query_data,['id' => $_POST['id']]);
        if (@$wpdb->show_errors == false) {
          $success = true;
        }
      } else {
        $wpdb->insert('revo_access_key',$query_data);
        if (@$wpdb->show_errors == false) {
          $success = true;
        }
      }

      if ($success) {
        $alert = array(
          'type' => 'success', 
          'title' => 'Success !',
          'message' => 'KEY Firebase Update Successfully', 
        );
      }
    }

    if ($_POST['type'] == 'firebase_notification') {
      $query_data = array(
        'slug' => $_POST['type'], 
        'title' => json_encode(['title' => $_POST['title'] ]), 
        'image' => '', 
        'description' => json_encode(['description' => str_replace(array("\r", "\n"), '', $_POST['description']), 'link_to' => $_POST['link_to'] ]), 
      );

      if ($_POST["jenis"] == 'file') {
        $max_size = 2 * 1024 * 1024; // 2mb
        $allowed_mimes = ['jpg', 'png', 'jpeg'];

        if (!empty($_FILES['fileToUpload']['name'])) {
          $res_upload = uploadImage($_FILES['fileToUpload'], $allowed_mimes, $max_size);
        } else if (!empty($_POST['fileUploadUrl'])) {
          $res_upload = checkImage($_POST['fileUploadUrl'], $_POST['fileUploadIds'], $allowed_mimes, $max_size);
        }

        if ($res_upload['type'] === 'success') {
          $images_url = $res_upload['message'];
        } else {
          $alert = $res_upload;
        }
      } else {
        $images_url = $_POST['url_link'];
      }

      $query_data['image'] = $images_url;
      if ($query_data['image'] != '') {
        if ($data_notif == NULL || empty($data_notif)) {
          $wpdb->insert('revo_mobile_variable', $query_data);

          if (@$wpdb->insert_id > 0) {
            $send_notif = true;
            $alert = array(
              'type' => 'success', 
              'title' => 'Success !',
              'message' => 'Notification Successfully Sent', 
            );
          }
        } else {
          $where = ['id' => $data_notif->id];
          $wpdb->update('revo_mobile_variable', $query_data, $where);

          if (@$wpdb->show_errors == false) {
            $send_notif = true;
            $alert = array(
              'type' => 'success', 
              'title' => 'Success !',
              'message' => 'Notification Successfully Sent', 
            );
          }
        }
      }
    }

    if ($_POST['type'] == 'dev_mode') {
      if (empty($dev_mode)) {
        $wpdb->insert('revo_mobile_variable', [
          'slug'  => 'firebase_dev_mode',
          'title' => 'firebase_dev_mode',
          'description' => json_encode([
            'status' => $_POST['devStatus'],
            'users'  => $_POST['devRecipientId']
          ])
        ]);

        $dev_message = 'Dev Mode Insert Successfully';
      } else {
        $dev_data_update = [
          'description' => json_encode([
            'status' => $_POST['devStatus'],
            'users'  => $_POST['devRecipientId']
          ])
        ];

        $wpdb->update('revo_mobile_variable', $dev_data_update, ['id' => $dev_mode->id]);

        $dev_message = 'Dev Mode Update Successfully';
      }

      $dev_mode = $wpdb->get_row("SELECT id, slug, description FROM revo_mobile_variable WHERE slug = 'firebase_dev_mode' ORDER BY id DESC LIMIT 1");

      $alert = [
        'type' => 'success', 
        'title' => 'Success !',
        'message' => $dev_message
      ];
    }

    $_SESSION["alert"] = $alert;

    $data = access_key();
    $data_notif = notif();
  }

  $show_notification = false;
  if (!empty($data->firebase_servey_key)) {
    $show_notification = true;
  }

  if (isset($data_notif->description)) {
    $description = json_decode($data_notif->description);
  }

  if (isset($send_notif) && $send_notif) {

    $insert_query = "INSERT INTO `revo_push_notification` SET type = 'push_notif'";

    $wpdb->prepare($wpdb->query( $insert_query ));

    $lastid_notif = $wpdb->insert_id;

    $notification = array(
      'title' => json_decode($data_notif->title)->title, 
      'body'  => (isset($description->description) ? $description->description : ''), 
      'icon'  => get_logo(), 
      'image' => (isset($data_notif->image) ? $data_notif->image : get_logo())
    );

    $extend['id'] = "$lastid_notif";
    $extend['type'] = "all";
    $extend['click_action'] = (isset($description->link_to) ? $description->link_to : '');

    $get = get_user_token();
    $receivers_id = [];
    $dev_mode_decode = json_decode($dev_mode->description);

    if (!empty($dev_mode) && $dev_mode_decode->status === 'on') {
      $dev_users_xplode = explode(',', $dev_mode_decode->users);
    }
    
    foreach ($get as $key => $val) {

      if (isset($dev_users_xplode)) {
        if (!in_array($val->user_id, $dev_users_xplode)) {
          continue;
        }

        $status_send = send_FCM($val->token, $notification, $extend);
      } else {
        $status_send = send_FCM($val->token, $notification, $extend);
      }

      if ($status_send === 'error') {
        $alert = array(
            'type' => 'error', 
            'title' => 'Failed to Send Notification !',
            'message' => "Try Again Later", 
        );
      } else if (!is_null($val->user_id) && $val->user_id >= 1) {

        if (!in_array($val->user_id, $receivers_id)) {
          array_push($receivers_id, $val->user_id);
        }
        
      }

      $_SESSION["alert"] = $alert;      
    }

    // $data_description  = json_encode(['title' => $_POST['title'], 'link_to' => $_POST['link_to'], 'description' => base64_encode( str_replace(array("\r", "\n"), '', $_POST['description']) ), 'image' => $notification['image']]);
    $data_description  = serialize(['title' => $_POST['title'], 'link_to' => $_POST['link_to'], 'description' => base64_encode( str_replace(array("\r", "\n"), '', $_POST['description']) ), 'image' => $notification['image']]);
    
    $receivers_id = json_encode(["users" => $receivers_id]);

    $date = new DateTime('now', new DateTimeZone(wp_timezone()->getName()));

    $delete_query = "DELETE FROM `revo_push_notification` WHERE id = $lastid_notif";

    $wpdb->prepare($wpdb->query( $delete_query ));
        
    $insert_query = "INSERT INTO `revo_push_notification` SET id = $lastid_notif, type = 'push_notif', description = '$data_description', user_id = '$receivers_id'";

    $wpdb->prepare($wpdb->query( $insert_query ));

    $wpdb->update('revo_push_notification',['created_at' => $date->format('Y-m-d H:i:s')],['id' => $lastid_notif]);
  }

  if (!empty($dev_mode)) {
    $dev_mode = json_decode($dev_mode->description);
  }
?>

<!DOCTYPE html>
<style type="text/css">
  .modal-dialog {
    margin-top: 18% !important;
  }
</style>

<html class="fixed">
<?php include(plugin_dir_path(__FILE__) . 'partials/_css.php'); ?>

<body>
  <?php include(plugin_dir_path(__FILE__) . 'partials/_header.php'); ?>
  <div class="container-fluid">
    <?php include(plugin_dir_path(__FILE__) . 'partials/_alert.php'); ?>

    <?php if (!$show_notification) : ?>
      <div class="alert text-capitalize alert-danger">
        <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
        <strong>Cannot Send Notifications ! </strong> Please Input Firebase <strong>SERVER KEY</strong> First
      </div>
    <?php endif; ?>

    <section class="panel">
      <div class="inner-wrapper pt-0">
        <!-- start: sidebar -->
        <?php include(plugin_dir_path(__FILE__) . 'partials/_new_sidebar.php'); ?>
        <!-- end: sidebar -->

        <section role="main" class="content-body p-0 pl-0">
          <section class="panel">
            <div class="panel-body">
              <div class="row mb-2">
                <div class="col-6 text-left">
                  <h4>
                    Push Notification
                  </h4>
                </div>

                <div class="col-6 text-right">
                  <?php if ($show_notification) : ?>
                    <button class="btn <?= empty($dev_mode) || $dev_mode->status === 'off' ? 'btn-secondary' : 'btn-danger' ?>" type="button" data-toggle="modal" data-target="#devModeModal">
                      <i class="fa fa-cogs"></i> Dev Mode
                    </button>
                  <?php endif; ?>

                  <button class="btn btn-primary" type="button" data-toggle="modal" data-target="#tambahintropage">
                    <i class="fa fa-cogs"></i> Setting Firebase Key
                  </button>
                </div>
              </div>

              <?php $title_pushnotif = json_decode($data_notif->title); ?>

              <div class="row">
                <div class="col-12">
                  <form method="post" action="#" enctype="multipart/form-data">
                    <div class="form-group">
                      <span>Title</span>
                      <input type="text" class="form-control" name="title" placeholder="*Input Title" <?= $show_notification == true ? '' : 'disabled' ?> value="<?= @$title_pushnotif->title ?>" required>
                      <input type="hidden" name="type" value="firebase_notification" required>
                    </div>
                    <div class="form-group">
                      <span>Link To</span>
                      <input type="text" class="form-control" name="link_to" value="<?= @$description->link_to ?>" placeholder="*Input Title" <?= $show_notification == true ? '' : 'disabled' ?> required>
                    </div>
                    <div class="form-group">
                      <span>Description</span>
                      <textarea placeholder="*Input Description" name="description" rows="3" class="form-control" <?= $show_notification == true ? '' : 'disabled' ?> required><?= @$description->description ?></textarea>
                    </div>
                    <div class="form-group">
                      <span>Image</span>
                      <div class="d-flex">
                        <div class="radio-custom radio-primary mr-4">
                          <input class="typeInsert" id="link" name="jenis" type="radio" value="link" checked>
                          <label class="font-size-14" for="link">Link / URL</label>
                        </div>
                        <div class="radio-custom radio-primary mb-2">
                          <input class="typeInsert" id="uploadsImage" name="jenis" type="radio" value="file">
                          <label class="font-size-14" for="uploadsImage">Upload Image</label>
                        </div>
                      </div>
                      <div class="form-group">
                        <label class="control-label">Select Image <span class="required" aria-required="true">*</span></label>
                        <input type="text" name="url_link" value="<?= $data_notif->image ?>" class="form-control" id="linkInput" placeholder="eg.: google.co.id/Banner.jpeg" <?= $show_notification == true ? '' : 'disabled' ?>>

                        <div id="fileinput" style="display: none">
                          <input class="form-control upload_file_button" placeholder="Select a Photo" <?= $show_notification == true ? '' : 'disabled' ?>>
                          <input type="hidden" name="fileUploadUrl">
                          <input type="hidden" name="fileUploadIds">
                        </div>
                        <!-- <input type="file" name="fileToUpload" class="form-control" <?= $show_notification == true ? '' : 'disabled' ?> id="fileinput" style="display: none;"> -->

                        <?php if ($data_notif->image) : ?>
                          <img src="<?= $data_notif->image ?>" class="img-fluid mt-3" style="width: 100px">
                        <?php endif ?>
                        <p class="mb-0 mt-2" style="line-height: 15px">
                          <small class="text-danger">Best Size : 100 X 100px</small> <br>
                          <small class="text-danger">Max File Size : 2MB</small>
                        </p>
                      </div>
                    </div>
                    <div class="mt-2 text-right">
                      <button type="submit" class="btn btn-primary send-notif" <?= $show_notification == true ? '' : 'disabled' ?> data-dev="<?= empty($dev_mode) || $dev_mode->status === 'off' ? 'off' : 'on' ?>" >Submit</button>
                    </div>
                  </form>
                </div>
              </div>
            </div>
          </section>
        </section>
      </div>
    </section>
  </div>

  <div class="modal fade" id="tambahintropage" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title font-weight-600" id="exampleModalLabel">Form Input API KEY Firebase</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <form method="POST" action="#">
            <div class="form-group">
              <span>Server KEY <span class="text-danger font-size-12">*Required Push Notification</span></span>
              <input type="text" class="form-control" value="<?= $data->firebase_servey_key ?>" name="firebase_servey_key" placeholder="*ex : AAAAL4gX-Xo:APA91bEpfkLw0F8ju_11FVw8RYuleoIve9uUP7QvoYJbT-q4kT7wjBxqN_2gBHhTl*******">
            </div>
            <div class="form-group">
              <span>Messaging Sender Id <span class="text-danger font-size-12">*Required Push Notification</span></span>
              <input type="text" class="form-control" value="<?= $data->firebase_messaging_sender_id ?>" name="firebase_messaging_sender_id" placeholder="*ex : 123456789">
            </div>
            <div class="form-group">
              <span>Api key <span class="text-danger font-size-12">*Required OTP Login & Register</span></span>
              <input type="hidden" name="id" value="<?= $data->id ?>" required>
              <input type="hidden" name="type" value="firebase_key" required>
              <input type="text" class="form-control" value="<?= $data->firebase_api_key ?>" name="firebase_api_key" placeholder="*Input AIzaSyCYkikCSaf91MbO6f3xE********">
            </div>
            <div class="form-group">
              <span>Auth Domain <span class="text-danger font-size-12">*Required OTP Login & Register</span></span>
              <input type="text" class="form-control" value="<?= $data->firebase_auth_domain ?>" name="firebase_auth_domain" placeholder="*ex : project-id.firebaseapp.com">
            </div>
            <div class="form-group">
              <span>Database URL <span class="text-danger font-size-12">*Required OTP Login & Register</span></span>
              <input type="text" class="form-control" value="<?= $data->firebase_database_url ?>" name="firebase_database_url" placeholder="*ex : https://project-id.firebaseio.com">
            </div>
            <div class="form-group">
              <span>Project Id <span class="text-danger font-size-12">*Required OTP Login & Register</span></span>
              <input type="text" class="form-control" value="<?= $data->firebase_project_id ?>" name="firebase_project_id" placeholder="*ex : projek-revo">
            </div>
            <div class="form-group">
              <span>Storage Bucket <span class="text-danger font-size-12">*Required OTP Login & Register</span></span>
              <input type="text" class="form-control" value="<?= $data->firebase_storage_bucket ?>" name="firebase_storage_bucket" placeholder="*ex : project-id.appspot.com">
            </div>
            <div class="form-group">
              <span>AppId <span class="text-danger font-size-12">*Required OTP Login & Register</span></span>
              <input type="text" class="form-control" value="<?= $data->firebase_app_id ?>" name="firebase_app_id" placeholder="*ex : 1:2019186***:web:dda924d*******">
            </div>
            <div class="form-group">
              <span>MeasurementId <span class="text-danger font-size-12">*Required OTP Login & Register</span></span>
              <input type="text" class="form-control" value="<?= $data->firebase_measurement_id ?>" name="firebase_measurement_id" placeholder="*ex : G-HNR4*****">
            </div>
            <div class="mt-2 text-right">
              <button type="submit" class="btn btn-primary">Submit</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>

  <div class="modal fade" id="devModeModal" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title font-weight-600">Dev Mode</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>

        <div class="modal-body">
          <form method="POST" action="#">
            <div class="form-group">
              <label for="devStatus">Dev Status</label>
              <select class="form-control" name="devStatus" id="devStatus" required>
                <option disabled <?= empty($dev_mode) ? 'selected' : '' ?> >Choose Status</option>
                <option value="on" <?= $dev_mode->status === 'on' ? 'selected' : '' ?> >On</option>
                <option value="off" <?= $dev_mode->status === 'off' ? 'selected' : '' ?> >Off</option>
              </select>
            </div>

            <div class="form-group">
              <label for="recipientId">Recipient ID <small class="text-danger pl-1">*separate with comma</small></label>
              <input class="form-control" id="recipientId" type="text" name="devRecipientId" placeholder="1, 2, 3" value="<?= $dev_mode->users ?>">
            </div>

            <div class="mt-3 py-3 text-right">
              <input type="hidden" name="type" value="dev_mode">
              <button type="submit" class="btn btn-primary">Submit</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</body>
<?php include(plugin_dir_path(__FILE__) . 'partials/_js.php');  ?>
<script>
  $('body').on('keyup', '.modal form input', function() {
    const inputValue = $(this).val().replaceAll(' ', '');

    const end = inputValue.slice(-1);
    const start = inputValue.charAt(0);

    if (start == '{' && end == '}') {
      const reference_key = {
        "apiKey": "firebase_api_key",
        "appId": "firebase_app_id",
        "authDomain": "firebase_auth_domain",
        "databaseUrl": "firebase_database_url",
        "measurementId": "firebase_measurement_id",
        "messagingSenderId": "firebase_messaging_sender_id",
        "projectId": "firebase_project_id",
        "serverKey": "firebase_servey_key",
        "storageBucket": "firebase_storage_bucket"
      }

      let datas = inputValue.replace('{', '').replace('}', '').split(',');
      $(this).val('');

      for (const data of datas) {
        let key = data.split(':')[0];
        let val = data.split(':"')[1];

        if (key in reference_key && key != 'databaseUrl') {
          $(`.modal form input[name="${reference_key[key]}"]`).val(val.replace('"', ''));

          if (key == 'projectId') {
            $(`.modal form input[name="firebase_database_url"]`).val('https://' + val.replace('"', '') + ".firebaseio.com");
          }
        }
      }
    }
  });

  $('body').on('click', '.send-notif', function (el) {
    const dev_status = $(this).data('dev');

    if (dev_status === 'on') {
      el.preventDefault();

      Swal.fire({
        title: "Dev mode is running",
        text: "This push notification will only be sent to the user you have selected",
        icon: "info",
        showCancelButton: false,
        confirmButtonText: "Confirm",
      }).then((result) => {
        if (result.isConfirmed) {
          $(this).parent().parent().submit();
        }
      });
    }
  });
</script>

</html>