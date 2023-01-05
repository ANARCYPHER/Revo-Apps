<?php
  require (plugin_dir_path( __FILE__ ).'../helper.php');
  
  $query = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'intro_page' AND is_deleted = 0 ORDER BY sort ASC";
  $data = $wpdb->get_results($query, OBJECT);

  if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $query_data = array(
      'slug'  => 'intro_page', 
      'title' => json_encode(['title' => $_POST['title'] ]), 
      'sort'  => $_POST['sort'], 
      'description' => json_encode(['description' => $_POST['description'] ]),  
    );

    if ($_FILES['fileToUpload']['name'] || $_POST['fileUploadUrl']) {
      $alert = array(
        'type' => 'error', 
        'title' => 'Failed to Intro Page !',
        'message' => 'Required Image', 
      );

      $max_size = 2 * 1024 * 1024;
      $allowed_mimes = ['jpg', 'png', 'jpeg'];

      if (!empty($_FILES['fileToUpload']['name'])) {
        $uploads_url = WP_CONTENT_URL . '/uploads/revo/';
        $target_dir = WP_CONTENT_DIR . '/uploads/revo/';
        $target_file = $target_dir . basename($_FILES['fileToUpload']['name']);
        $image_file_type = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
        $newname = md5(date('Y-m-d H:i:s')) . '.' . $image_file_type;
        $is_upload_error = 0;

        if ($_FILES['fileToUpload']['size'] > 0){
          if ($_FILES['fileToUpload']['size'] > $max_size) {
            $alert = array(
              'type' => 'error', 
              'title' => 'Uploads Error !',
              'message' => 'your file is too large. max 2Mb', 
            );

            $is_upload_error = 1;
          }

          if (!in_array($image_file_type, $allowed_mimes)) {
            $alert = array(
              'type' => 'error', 
              'title' => 'Uploads Error !',
              'message' => 'only JPG, JPEG & PNG files are allowed.', 
            );
            $is_upload_error = 1;
          }

          if ($is_upload_error == 0) {
            if ($_FILES['fileToUpload']['size'] > 500000) {
              compress($_FILES['fileToUpload']['tmp_name'],$target_dir.$newname,90);
              $query_data['image'] = $uploads_url.$newname;
            }else{
              move_uploaded_file($_FILES['fileToUpload']['tmp_name'], $target_dir.$newname);
              $query_data['image'] = $uploads_url.$newname;
            }
          }
        }
      } else if (!empty($_POST['fileUploadUrl'])) {
        $image_data = wp_get_attachment_metadata($_POST['fileUploadIds']);
        $image_file_type = pathinfo($_POST['fileUploadUrl'], PATHINFO_EXTENSION);
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
          $query_data['image'] = $_POST['fileUploadUrl'];
        }  
      }

      if ($query_data['image'] != '' && !isset($_POST['id'])) {
        $wpdb->insert('revo_mobile_variable',$query_data);

        if (@$wpdb->insert_id > 0) {
          $alert = array(
            'type' => 'success', 
            'title' => 'Success !',
            'message' => 'Intro Page Added Successfully', 
          );
        }
      }
    }

    if (@$_POST['id']) {
      $alert = array(
        'type' => 'error', 
        'title' => 'Failed to Change Intro Page !',
        'message' => 'Try Again Later', 
      );

      $id = $_POST['id'];
      $where = ['id' => $id, 'slug' => 'intro_page'];
      $wpdb->update('revo_mobile_variable',$query_data,$where);

      if (@$wpdb->show_errors == false) {
        $alert = array(
          'type' => 'success', 
          'title' => 'Success !',
          'message' => 'Intro Page with ID : '.$id.' Updated Successfully', 
        );
      }
    }

    $_SESSION['alert'] = $alert;

    $data = $wpdb->get_results($query, OBJECT);
  }

  if (@$_GET['id'] && @$_GET['is_deleted'] == 1) {
    $alert = array(
      'type' => 'error', 
      'title' => 'Intro page data failed to delete !',
      'message' => 'Try Again Later', 
    );

    $where = ['id' => $_GET['id'], 'slug' => 'intro_page'];
    $wpdb->update('revo_mobile_variable',['is_deleted' => '1'],$where);
    if (@$wpdb->show_errors == false) {
      $alert = array(
        'type' => 'success', 
        'title' => 'Success !',
        'message' => 'Intro Page Deleted Successfully', 
      );
    }

    $_SESSION["alert"] = $alert;

    $data = $wpdb->get_results($query, OBJECT);
    wp_redirect( admin_url( '/admin.php?page=revo-intro-page' ) );
    exit;
  }

  $query_IntroPageStatus = query_revo_mobile_variable('"intro_page_status"','sort');
  $introPageStatus = empty($query_IntroPageStatus) ? 'hide' : $query_IntroPageStatus[0]->description;
?>

<!DOCTYPE html>
<html class="fixed">
<?php include (plugin_dir_path( __FILE__ ).'partials/_css.php'); ?>
<body>
  <style>
    .onoffswitch {
        position: relative; width: 71px;
        -webkit-user-select:none; -moz-user-select:none; -ms-user-select: none;
    }
    .onoffswitch-checkbox {
        position: absolute;
        opacity: 0;
        pointer-events: none;
    }
    .onoffswitch-label {
        display: block; overflow: hidden; cursor: pointer;
        border: 2px solid #999999; border-radius: 22px;
    }
    .onoffswitch-inner {
        display: block; width: 200%; margin-left: -100%;
        transition: margin 0.3s ease-in 0s;
    }
    .onoffswitch-inner:before, .onoffswitch-inner:after {
        display: block; float: left; width: 50%; height: 27px; padding: 0; line-height: 27px;
        font-size: 14px; color: white; font-family: Trebuchet, Arial, sans-serif; font-weight: bold;
        box-sizing: border-box;
    }
    .onoffswitch-inner:before {
        content: "ON";
        padding-left: 9px;
        background-color: #22AB01; color: #FFFFFF;
    }
    .onoffswitch-inner:after {
        content: "OFF";
        padding-right: 9px;
        background-color: #F0F0F0; color: #767876;
        text-align: right;
    }
    .onoffswitch-switch {
        display: block; width: 12px; margin: 7.5px;
        background: #FFFFFF;
        position: absolute; top: 0; bottom: 0;
        right: 40px;
        border: 2px solid #999999; border-radius: 22px;
        transition: all 0.3s ease-in 0s; 
    }
    .onoffswitch-checkbox:checked + .onoffswitch-label .onoffswitch-inner {
        margin-left: 0;
    }
    .onoffswitch-checkbox:checked + .onoffswitch-label .onoffswitch-switch {
        right: 0px; 
    }
  </style>
  <?php include (plugin_dir_path( __FILE__ ).'partials/_header.php'); ?>
  <div class="container-fluid">
    <?php include (plugin_dir_path( __FILE__ ).'partials/_alert.php'); ?>
    <section class="panel">
          <div class="inner-wrapper pt-0">

            <!-- start: sidebar -->
            <?php include (plugin_dir_path( __FILE__ ).'partials/_new_sidebar.php'); ?>
            <!-- end: sidebar -->

            <section role="main" class="content-body p-0 pl-0">
                <div class="panel-body">
                  <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">Setting Intro Page</h4>

                    <div class="d-flex align-items-center">
                      <div class="d-flex align-items-center">
                        <span>Show Repeated Intros : </span>
                        <div class="col-auto">
                          <div class="onoffswitch mt-2">
                            <input type="checkbox" name="onoffswitch" onchange="showIntroPage(event)" class="onoffswitch-checkbox" id="myonoffswitch" tabindex="0" <?= $introPageStatus == 'show' ? 'checked' : '' ?>>
                            <label class="onoffswitch-label" for="myonoffswitch">
                                <span class="onoffswitch-inner"></span>
                                <span class="onoffswitch-switch"></span>
                            </label>
                          </div>
                        </div>
                      </div>

                      <div class="ml-5">
                        <button class="btn btn-primary" type="button" data-toggle="modal" data-target="#tambahintropage">
                          <i class="fa fa-plus"></i> Add Intro Page
                        </button>
                      </div>
                    </div>
                  </div>
                  
                  <div class="row">
                    <?php 
                      $urutan = 1;
                      if (!empty($data)){ ?>
                      <?php foreach ($data as $key): ?>
                        <div class="col-md-4 mb-4">
                            <div class="card border-secondary h-100 shadow">
                              <div class="card-body text-center">
                                <h5 class="card-title"><?php echo json_decode($key->title)->title ?></h5>
                                <img src="<?php echo $key->image ?>" class=" mx-auto my-3" style="height: 150px;">
                                <p class=" px-5 mt-2 card-text"><?php echo json_decode($key->description)->description ?></p>
                                <button 
                                  title="<?php echo json_decode($key->title)->title ?>" 
                                  description="<?php echo json_decode($key->description)->description ?>" 
                                  id="<?php echo $key->id; ?>" 
                                  sort="<?php echo $key->sort; ?>" 
                                  type="button" class="btn btn-primary ubah">Update</button>
                                <a href="<?php echo admin_url( '/admin.php?page=revo-intro-page')."&id=".$key->id."&is_deleted=1" ?>" class="btn btn-danger" onclick='return confirm("Are you sure ?")'>Delete</a>
                              </div>
                            </div>
                        </div>
                      <?php 
                        $urutan += 1;
                        endforeach;
                       ?>
                    <?php }else{ ?>
                      <div class="col-12 text-center mt-10">
                        <img src="<?php echo get_logo() ?>" class="img-fluid mr-3" style="width: 150px">
                        <h4 class="mb-0 mt-3">Empty !</h4>
                      </div>
                    <?php } ?>
                  </div>
                </div>
            </section>
        </div>
    </section>

    <div class="modal fade" id="tambahintropage" role="dialog" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title font-weight-600" id="exampleModalLabel">Add Intro Page</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body pt-4 pb-5 px-4">
            <form method="POST" action="#" enctype="multipart/form-data">
              <div class="form-group">
                <span>Title</span>
                <input type="text" class="form-control" name="title"  placeholder="*Input Title" required>
              </div>
              <div class="form-group">
                <span>Description</span>
                <textarea placeholder="*Input Description" name="description" rows="2" class="form-control" required></textarea>
              </div>
              <div class="form-group">
                <span>Sort To</span>
                <input type="number" class="form-control" name="sort" value="<?php echo $urutan ?>" placeholder="*Input Order" required>
              </div>
              <div class="form-group">
                <span>Image</span>
                <input class="form-control upload_file_button" placeholder="Select a Photo" required>
                <input type="hidden" name="fileUploadUrl">
                <input type="hidden" name="fileUploadIds">
                <!-- <input type="file" class="form-control" name="fileToUpload" required> -->
                <div class="text-right">
                  <small class="text-danger">Best Size : 450 x 450 px</small>
                </div>
              </div>
              <div class="mt-5 text-right">
                <button type="submit" class="btn btn-primary">Submit</button>
              </div>
             </form>
          </div>
        </div>
      </div>
    </div>

    <div class="modal fade" id="ubahintropage" role="dialog" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title font-weight-600" id="titleModal"></h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body pt-4 pb-5 px-4">
            <form method="POST" action="#" enctype="multipart/form-data">
              <div class="form-group">
                <span>Title</span>
                <input type="text" class="form-control" name="title" id="title" placeholder="*Input Title" required>
                <input type="hidden" class="form-control" name="id" id="id" required>
              </div>
              <div class="form-group">
                <span>Description</span>
                <textarea placeholder="*Input Description" name="description" id="description" rows="2" class="form-control" required></textarea>
              </div>
              <div class="form-group">
                <span>Sort To</span>
                <input type="number" class="form-control" name="sort" id="sort" placeholder="*Input Order" required>
              </div>
              <div class="form-group">
                <span>Image</span>
                <input class="form-control upload_file_button" placeholder="Select a Photo">
                <input type="hidden" name="fileUploadUrl">
                <input type="hidden" name="fileUploadIds">
                <!-- <input type="file" class="form-control" name="fileToUpload"> -->
                <div class="text-right">
                  <small class="text-danger">Best Size : 450 x 450 px</small>
                </div>
              </div>
              <div class="mt-5 text-right">
                <button type="submit" class="btn btn-primary">Submit</button>
              </div>
             </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
<?php include (plugin_dir_path( __FILE__ ).'partials/_js.php');  ?>
<script>
  $('.ubah').click(function () {
    var title = $(this).attr('title');
    var id = $(this).attr('id');
    var sort = $(this).attr('sort');
    var description = $(this).attr('description');

    $("#titleModal").html("Update Intro Page " + id);
    $("#title").val(title);
    $("#id").val(id);
    $("#description").val(description);
    $("#sort").val(sort);

    $('#ubahintropage').modal('show');
  });

  function showIntroPage(e) {
    el = e.target;
    status = el.checked ? "show" : "hide";
    url = `<?= get_site_url(null,'wp-json/revo-admin/v1/set-intro-page'); ?>?status=${status}`;
    $.get(url,response=>{
      console.log(response);
    })
  }
</script>
</html>