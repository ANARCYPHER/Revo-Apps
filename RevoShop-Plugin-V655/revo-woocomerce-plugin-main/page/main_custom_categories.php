<?php
  require(plugin_dir_path(__FILE__) . '../helper.php');

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

    if (@$_POST["typeQuery"] == 'insert') {
      if (@$_POST["jenis"] == 'file' || @$_POST["jenis"] == 'link') {
        $alert = array(
          'type' => 'error',
          'title' => 'Query Error !',
          'message' => 'Failed to Add Data Categories',
        );

        $image = '';

        if ($_POST["jenis"] == 'file') {
          $max_size = 2 * 1024 * 1024; // 2mb
          $allowed_mimes = ['jpg', 'png', 'jpeg'];

          if (!empty($_FILES['fileToUpload']['name'])) {
            $res_upload = uploadImage($_FILES['fileToUpload'], $allowed_mimes, $max_size);
          } else if (!empty($_POST['fileUploadUrl'])) {
            $res_upload = checkImage($_POST['fileUploadUrl'], $_POST['fileUploadIds'], $allowed_mimes, $max_size);
          }

          if ($res_upload['type'] === 'success') {
            $image = $res_upload['message'];
          } else {
            $alert = $res_upload;
          }
        } else {
          $image = $_POST['url_link'];
        }

        if ($image != '') {
          $categories = get_categorys_detail($_POST['category_id']);
          $wpdb->insert(
            'revo_list_categories',
            [
              'order_by' => $_POST['order_by'],
              'category_id' => $_POST['category_id'],
              'category_name' => json_encode(['title' => $categories[0]->name]),
              'image' => $image
            ]
          );

          if (@$wpdb->insert_id > 0) {
            $alert = array(
              'type' => 'success',
              'title' => 'Success !',
              'message' => 'Categories Success Saved',
            );
          }
        }

        $_SESSION["alert"] = $alert;
      }
    }

    if (@$_POST["typeQuery"] == 'update') {
      if (@$_POST["jenis"] == 'file' || @$_POST["jenis"] == 'link') {

        $categories = get_categorys_detail($_POST['category_id']);

        $dataUpdate = array(
          'order_by' => $_POST['order_by'],
          'category_id' => $_POST['category_id'],
          'category_name' => json_encode(['title' => $categories[0]->name]),
        );

        $where = array('id' => $_POST['id']);

        $alert = array(
          'type' => 'error',
          'title' => 'Query Error !',
          'message' => 'Failed to Update Categories ' . $_POST['title'],
        );

        $image = '';

        if ($_POST["jenis"] == 'file') {
          $max_size = 2 * 1024 * 1024; // 2mb
          $allowed_mimes = ['jpg', 'png', 'jpeg'];

          if (!empty($_FILES['fileToUpload']['name'])) {
            $res_upload = uploadImage($_FILES['fileToUpload'], $allowed_mimes, $max_size);
          } else if (!empty($_POST['fileUploadUrl'])) {
            $res_upload = checkImage($_POST['fileUploadUrl'], $_POST['fileUploadIds'], $allowed_mimes, $max_size);
          }

          if ($res_upload['type'] === 'success') {
            $dataUpdate['image'] = $res_upload['message'];
          }
        } else {
          $dataUpdate['image'] = $_POST['url_link'];
        }

        if (isset($res_upload) && $res_upload['type'] === 'error') {
          $alert = $res_upload;
        } else {
          $wpdb->update('revo_list_categories', $dataUpdate, $where);

          if (@$wpdb->show_errors == false) {
            $alert = array(
              'type' => 'success',
              'title' => 'Success !',
              'message' => 'Categories ' . $_POST['title'] . ' Success Updated',
            );
          }
        }

        $_SESSION["alert"] = $alert;
      }
    }

    if (@$_POST["typeQuery"] == 'hapus') {
      header('Content-type: application/json');

      $query = $wpdb->update(
        'revo_list_categories',
        ['is_deleted' =>  '1'],
        array('id' => $_POST['id']),
        array('%s'),
        array('%d')
      );

      $alert = array(
        'type' => 'error',
        'title' => 'Query Error !',
        'message' => 'Failed to Delete  Categories',
      );

      if ($query) {
        $alert = array(
          'type' => 'success',
          'title' => 'Success !',
          'message' => 'Categories Success Deleted',
        );
      }

      $_SESSION["alert"] = $alert;

      http_response_code(200);
      return json_encode(['kode' => 'S']);
      die();
    }
  }

  $data_banner = $wpdb->get_results("SELECT * FROM revo_list_categories WHERE is_deleted = 0", OBJECT);
  $categories_list = json_decode(get_categorys());
?>

<!DOCTYPE html>
<html class="fixed">
<?php include(plugin_dir_path(__FILE__) . 'partials/_css.php'); ?>

<body>
  <?php include(plugin_dir_path(__FILE__) . 'partials/_header.php'); ?>
  <div class="container-fluid">
    <section class="panel">
      <?php include(plugin_dir_path(__FILE__) . 'partials/_alert.php'); ?>
      <section class="panel">
        <div class="inner-wrapper pt-0">
          <!-- start: sidebar -->
          <?php include(plugin_dir_path(__FILE__) . 'partials/_new_sidebar.php'); ?>
          <!-- end: sidebar -->

          <section role="main" class="content-body p-0">
            <div class="panel-body">
              <div class="row mb-2">
                <div class="col-6 text-left">
                  <h4>
                    Custom Categories <?php echo buttonQuestion() ?>
                  </h4>
                </div>
                <div class="col-6 text-right">
                  <button class="btn btn-primary" data-toggle="modal" data-target="#tambahCategories">
                    <i class="fa fa-plus"></i> Add Categories
                  </button>
                </div>
              </div>
              <table class="table table-bordered table-striped mb-none" id="datatable-default">
                <thead>
                  <tr>
                    <th>Sort</th>
                    <th>Title Categories</th>
                    <th>Icon</th>
                    <th class="hidden-xs">Action</th>
                  </tr>
                </thead>
                <tbody>
                  <?php foreach ($data_banner as $key => $value): ?>
                    <tr>
                      <td><?php echo $value->order_by ?></td>
                      <td><?php echo json_decode($value->category_name)->title ?></td>
                      <td>
                        <img src="<?php echo $value->image ?>" class="img-fluid" style="width: 100px">
                      </td>
                      <td>
                        <button class="btn btn-primary" data-toggle="modal" data-target="#updateCategories<?= $value->id ?>">
                          <i class="fa fa-edit"></i> Update
                        </button>
                        <div class="modal fade" id="updateCategories<?= $value->id ?>" role="dialog" aria-hidden="true">
                          <div class="modal-dialog" role="document">
                            <div class="modal-content">
                              <div class="modal-header">
                                <h5 class="modal-title font-weight-600" id="exampleModalLabel">Update Categories</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                  <span aria-hidden="true">&times;</span>
                                </button>
                              </div>
                              <div class="modal-body py-5 px-4">
                                <form method="post" action="#" enctype="multipart/form-data">
                                  <div class="form-group">
                                    <label class="col-sm-4 pl-0 control-label">Select categories Product <span class="required" aria-required="true">*</span></label>
                                    <div class="col-sm-8 pr-0">
                                      <select id="states" name="category_id" data-plugin-selectTwo class="form-control populate" title="Please select Categories" required>
                                        <option value="">Choose a Categories</option>
                                        <?php foreach ($categories_list as $categories) : ?>
                                          <option value="<?php echo $categories->id ?>" <?php echo $value->category_id == $categories->id ? 'selected' : '' ?>><?php echo $categories->text ?></option>
                                        <?php endforeach ?>
                                      </select>
                                    </div>
                                  </div>
                                  <div class="form-group">
                                    <label class="col-sm-4 pl-0 control-label">Sort to <span class="required" aria-required="true">*</span></label>
                                    <div class="col-sm-8 pr-0">
                                      <input type="number" value="<?php echo $value->order_by ?>" name="order_by" class="form-control" placeholder="Number Only" required="" aria-required="true">
                                      <input type="hidden" value="<?php echo $value->id ?>" name="id" required>
                                    </div>
                                  </div>
                                  <div class="form-group">
                                    <label class="col-sm-4 pl-0 control-label">Type Upload Icon <span class="required" aria-required="true">*</span></label>
                                    <div class="col-sm-8 pr-0">
                                      <div class="d-flex">
                                        <div class="radio-custom radio-primary mr-4">
                                          <input id="link<?= $value->id ?>" BannerID="<?= $value->id ?>" class="updateFile" name="jenis" type="radio" value="link" checked>
                                          <label class="font-size-14" for="link<?= $value->id ?>">Link / URL</label>
                                        </div>
                                        <div class="radio-custom radio-primary mb-2">
                                          <input id="uploadsImage<?= $value->id ?>" BannerID="<?= $value->id ?>" class="updateFile" name="jenis" type="radio" value="file">
                                          <label class="font-size-14" for="uploadsImage<?= $value->id ?>">Upload Image</label>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                  <div class="form-group">
                                    <label class="col-sm-4 pl-0 control-label">Select Image <span class="required" aria-required="true">*</span></label>
                                    <div class="col-sm-8 pr-0">
                                      <input type="hidden" name="typeQuery" value="update">
                                      <input type="text" name="url_link" class="form-control" id="linkInput<?= $value->id ?>" placeholder="eg.: google.co.id/Categories.jpeg" value="<?= $value->image ?>" required>
                                      <div id="fileinput<?= $value->id ?>" style="display: none;">
                                        <input class="form-control upload_file_button" placeholder="Select a Photo">
                                        <input type="hidden" name="fileUploadUrl">
                                        <input type="hidden" name="fileUploadIds">
                                      </div>
                                      <!-- <input type="file" name="fileToUpload" class="form-control" id="fileinput" style="display: none;"> -->
                                      <img src="<?= $value->image ?>" class="img-fluid my-2" style="width: 100px">
                                      <p class="mb-0 mt-2" style="line-height: 15px">
                                        <small class="text-danger">Best Size : 75 x 75 px</small> <br>
                                        <small class="text-danger">Max File Size : 500kb</small>
                                      </p>
                                    </div>
                                  </div>
                                  <div class="form-group text-right mt-5">
                                    <button type="submit" class="btn btn-primary">
                                      <i class="fa fa-send"></i> Submit
                                    </button>
                                  </div>
                                </form>
                              </div>
                            </div>
                          </div>
                        </div>
                        <button class="btn btn-danger" onclick="hapus('<?php echo $value->id ?>')">
                          <i class="fa fa-trash"></i> Delete
                        </button>
                      </td>
                    </tr>
                  <?php endforeach; ?>

                  <?php
                    if (!empty($data_banner)) {
                      $key = $key + 2;
                    } else {
                      $key = 1;
                    }
                  ?>
                </tbody>
              </table>
            </div>
          </section>
        </div>
      </section>
    </section>
  </div>
  <div class="modal fade" id="tambahCategories" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title font-weight-600" id="exampleModalLabel">Add Custom Categories</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body py-5 px-4">
          <form method="post" action="#" enctype="multipart/form-data">
            <div class="form-group">
              <label class="col-sm-4 pl-0 control-label">Select categories Product <span class="required" aria-required="true">*</span></label>
              <div class="col-sm-8 pr-0">
                <input type="hidden" name="typeQuery" value="insert">
                <select id="states" name="category_id" data-plugin-selectTwo class="form-control populate" title="Please select Categories" required>
                  <option value="">Choose a Categories</option>
                  <?php foreach ($categories_list as $categories) : ?>
                    <option value="<?php echo $categories->id ?>"><?php echo $categories->text ?></option>
                  <?php endforeach ?>
                </select>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 pl-0 control-label">Sort to <span class="required" aria-required="true">*</span></label>
              <div class="col-sm-8 pr-0">
                <input type="number" value="<?php echo $key ?>" name="order_by" class="form-control" placeholder="Number Only" required="" aria-required="true">
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 pl-0 control-label">Type Image Banner <span class="required" aria-required="true">*</span></label>
              <div class="col-sm-8 pr-0">
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
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 pl-0 control-label">Select Image <span class="required" aria-required="true">*</span></label>
              <div class="col-sm-8 pr-0">
                <input type="text" name="url_link" class="form-control" id="linkInput" placeholder="eg.: google.co.id/Categories.jpeg" required>
                <div id="fileinput" style="display: none;">
                  <input class="form-control upload_file_button" placeholder="Select a Photo">
                  <input type="hidden" name="fileUploadUrl">
                  <input type="hidden" name="fileUploadIds">
                </div>
                <!-- <input type="file" name="fileToUpload" class="form-control" id="fileinput" style="display: none;"> -->

                <p class="mb-0 mt-2" style="line-height: 15px">
                  <small class="text-danger">Best Size : 75 x 75 px</small> <br>
                  <small class="text-danger">Max File Size : 500kb</small>
                </p>
              </div>
            </div>
            <div class="form-group text-right mt-5">
              <button type="submit" class="btn btn-primary">
                <i class="fa fa-send"></i> Submit
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>

  <?php
    $img_example = revo_url() . '/assets/extend/images/example_categories.jpg';
    include(plugin_dir_path(__FILE__) . 'partials/_modal_example.php');
    include(plugin_dir_path(__FILE__) . 'partials/_js.php');
  ?>
  <script>
    function hapus(id) {
      Swal.fire({
        title: 'Are you sure you want to delete this ?',
        showDenyButton: true,
        showCancelButton: false,
        confirmButtonText: `delete`,
        denyButtonText: `cancel`,
      }).then((result) => {
        /* Read more about isConfirmed, isDenied below */
        if (result.isConfirmed) {
          $.ajax({
            url: "#",
            method: "POST",
            data: {
              id: id,
              typeQuery: 'hapus',
            },
            datatype: "json",
            async: true,
            success: function(data) {
              location.reload();
            },
            error: function(data) {
              location.reload();
            }
          });
        }
      })

    }
  </script>
</body>

</html>