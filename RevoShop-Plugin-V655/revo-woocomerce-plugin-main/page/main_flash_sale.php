<?php
  require (plugin_dir_path( __FILE__ ).'../helper.php');

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
    
    $products = array();
    if ($_POST['products']) {
      $products = $_POST['products'];
    }

    $products = json_encode($products);

    $tanggal_flash_sale = str_replace('/', '-', $_POST['date']);
    $new_tanggal = explode(' - ', $tanggal_flash_sale);
    $start_flash_sale = date("Y/m/d H:i:s", strtotime($new_tanggal[0]));
    $end_flash_sale = date("Y/m/d H:i:s", strtotime($new_tanggal[1]));

    if (@$_POST["typeQuery"] == 'insert') {

      if(@$_POST["jenis"] == 'file' || @$_POST["jenis"] == 'link') {
        $alert = array(
          'type' => 'error', 
          'title' => 'Query Error !',
          'message' => 'Failed to Add Data Flash Sale', 
        );

        $images_url = '';

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

        if ($images_url != '') {
          $data = array(
            'title' => $_POST['title'], 
            'start' => $start_flash_sale, 
            'end' => $end_flash_sale, 
            'products' => $products, 
            'image' => $images_url, 
          );

          $wpdb->insert('revo_flash_sale',$data);

          if (@$wpdb->insert_id > 0) {
            $alert = array(
              'type' => 'success', 
              'title' => 'Success !',
              'message' => 'Flash Sale Success Saved', 
            );
          }
        }

        $_SESSION["alert"] = $alert;
      }

    } else if (@$_POST["typeQuery"] == 'update') {

      if(@$_POST["jenis"] == 'file' || @$_POST["jenis"] == 'link') {

        $dataUpdate = array(
          'title' => $_POST['title'], 
          'products' => $products, 
          'start' => $start_flash_sale, 
          'end' => $end_flash_sale, 
          'is_active' => 1, 
        );

        $where = array('id' => $_POST['id']);

        $alert = array(
          'type' => 'error', 
          'title' => 'Query Error !',
          'message' => 'Failed to Update Flash Sale '.$_POST['title'], 
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
            $dataUpdate['image'] = $res_upload['message'];
          }
        } else {
          $dataUpdate['image'] = $_POST['url_link']; 
        }

        if (isset($res_upload) && $res_upload['type'] === 'error') {
          $alert = $res_upload;
        } else {
          $wpdb->update('revo_flash_sale',$dataUpdate,$where);
          
          if (@$wpdb->show_errors == false) {
            $alert = array(
              'type' => 'success', 
              'title' => 'Success !',
              'message' => 'Flash Sale '.$_POST['title'].' Success Updated', 
            );
          }
        }

        $_SESSION["alert"] = $alert;
        
      }

    } else if (@$_POST["typeQuery"] == 'hapus') {
        header('Content-type: application/json');

        $query = $wpdb->update( 
              'revo_flash_sale', ['is_deleted' =>  '1'], 
              array( 'id' => $_POST['id'])
            );

        $alert = array(
            'type' => 'error', 
            'title' => 'Query Error !',
            'message' => 'Failed to Delete  Flash Sale', 
        );

        if ($query) {
          $alert = array(
            'type' => 'success', 
            'title' => 'Success !',
            'message' => 'Flash Sale Success Deleted', 
          );
        }

        $_SESSION["alert"] = $alert;

        http_response_code(200);
        return json_encode(['kode' => 'S']);
        die();
    }
  }

  $data_flash_sale = $wpdb->get_results("SELECT * FROM revo_flash_sale WHERE is_deleted = 0", OBJECT);

  $product_list = json_decode(get_product_varian());

  cek_flash_sale_end();
?>

<!DOCTYPE html>
<html class="fixed">
<?php include (plugin_dir_path( __FILE__ ).'partials/_css.php'); ?>
<link href="<?= revo_url(); ?>assets/datepicker/daterangepicker.css" rel="stylesheet"/>
<style>
  .wp-core-ui select {
    font-size: 12px;
    height: 25px;
    border-radius: 3px;
    padding: 0 24px 0 8px;
    min-height: 7px;
    max-width: 25rem;
    background-size: 10px 10px;
  }
  .daterangepicker .calendar-time {
    text-align: left;
    padding-left: 35px;
  }
  .applyBtn, .cancelBtn{
    padding: 10px;
  }
  dd, li {
    margin-bottom: 0px; 
  }
</style>
<body>
  <?php include (plugin_dir_path( __FILE__ ).'partials/_header.php'); ?>

  <div class="container-fluid">
    <section class="panel">
      <?php include (plugin_dir_path( __FILE__ ).'partials/_alert.php'); ?>
      <section class="panel">
          <div class="inner-wrapper pt-0">
              <!-- start: sidebar -->
              <?php include (plugin_dir_path( __FILE__ ).'partials/_new_sidebar.php'); ?>
              <!-- end: sidebar -->

              <section role="main" class="content-body p-0">
                  <div class="panel-body">
                      <div class="row mb-2">
                        <div class="col-6 text-left">
                          <h4>
                            Home Flash Sale <?= buttonQuestion() ?>
                          </h4>
                        </div>
                        <div class="col-6 text-right">
                          <button class="btn btn-primary"  data-toggle="modal" data-target="#tambahFlashSale">
                            <i class="fa fa-plus"></i> Add Flash Sale
                          </button>
                        </div>
                      </div>
                      <table class="table table-bordered table-striped mb-none" id="datatable-default">
                        <thead>
                          <tr>
                            <th>No</th>
                            <th>Details</th>
                            <th>Icon Side</th>
                            <th style="width: 35%">List Products</th>
                            <th class="text-center hidden-xs">Action</th>
                          </tr>
                        </thead>
                        <tbody>
                          <?php foreach ($data_flash_sale as $key => $value): ?>
                            <tr>
                              <td><?= $key + 1 ?></td>
                              <td>
                                Title  : <span class="font-weight-600 mb-0 text-capitalize"><?= $value->title ?></span><br>
                                Start  : <span class="font-weight-600 mb-0 text-capitalize"><?= formatted_date($value->start) ?></span><br>
                                End    : <span class="font-weight-600 mb-0 text-capitalize"><?= formatted_date($value->end) ?></span><br> 
                                Status : <?= cek_is_active($value->is_active) ?>
                              </td>
                              <td>
                                <img src="<?= $value->image ?>" class="img-fluid" style="width: 100px">
                              </td>
                              <td>
                                  <?php 
                                    $list_products = json_decode($value->products);
                                    $show = 0;
                                    if (!empty($list_products) && $list_products != NULL) {
                                      if (is_array($list_products)) {
                                        for ($i=0; $i < count($list_products); $i++) { 
                                          if (!empty(get_product_varian_detail($list_products[$i]))) {
                                            echo '<span class="badge badge-primary p-2">'.get_product_varian_detail($list_products[$i])[0]->get_title().'</span> ';
                                            $show += 1;
                                          }
                                        }
                                      }else{
                                        if (!empty(get_product_varian_detail($list_products[0]))) {
                                         echo '<span class="badge badge-primary p-2">'.get_product_varian_detail($list_products)[0]->get_title().'</span> ';  
                                         $show += 1;
                                      }
                                      }
                                    }else{
                                      echo '<span class="badge badge-danger p-2">Empty !</span>';
                                    }

                                    if ($show == 0) {
                                      echo '<span class="badge badge-danger p-2">Empty !</span>';
                                    }
                                  ?>
                              </td>
                              <td>
                                <button class="btn btn-block btn-primary mb-2"  data-toggle="modal" data-target="#updateFlashSale<?= $value->id ?>">
                                  <i class="fa fa-edit"></i> Update
                                </button>
                                <div class="modal modal-update fade" fd-id="<?= $value->id ?>" id="updateFlashSale<?= $value->id ?>" role="dialog" aria-hidden="true">
                                  <div class="modal-dialog" role="document">
                                    <div class="modal-content">
                                      <div class="modal-header">
                                        <h5 class="modal-title font-weight-600" id="exampleModalLabel">Update <?= $value->title ?></h5>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                          <span aria-hidden="true">&times;</span>
                                        </button>
                                      </div>
                                      <div class="modal-body py-5 px-4">
                                        <form method="post" action="#" enctype="multipart/form-data">
                                          <div class="form-group">
                                            <label class="col-sm-4 pl-0 control-label">Title <span class="required" aria-required="true">*</span></label>
                                            <div class="col-sm-8 pr-4">
                                              <input type="text" name="title" value="<?= $value->title ?>" class="form-control"  placeholder="eg.: New Flash Sale" required="" aria-required="true">
                                              <input type="hidden" value="<?= $value->id ?>" name="id" required>
                                            </div>
                                          </div>
                                          <div class="form-group">
                                            <label class="col-sm-4 pl-0 control-label">Product To Show <span class="required" aria-required="true">*</span></label>
                                            <div class="col-sm-8 pr-4">
                                              <input type="hidden" name="typeQuery" value="update">
                                              <select name="products[]" multiple data-plugin-selectTwo class="form-control populate" title="Please select Product" required>
                                                <?php foreach ($product_list as $product): ?>
                                                  <option 
                                                      value="<?= $product->id ?>" 
                                                      <?php 
                                                        if (is_array($list_products)) {
                                                          for ($i=0; $i < count($list_products); $i++) { 
                                                            echo $product->id == $list_products[$i] ? 'selected' : '';
                                                          }
                                                        }else{
                                                          echo $product->id == $list_products ? 'selected' : '';
                                                        }
                                                      ?>
                                                  ><?= $product->text ?></option>
                                                <?php endforeach ?>
                                              </select>
                                            </div>
                                          </div>
                                          <div class="form-group">
                                            <label class="col-sm-4 pl-0 control-label">Start - End <span class="required" aria-required="true">*</span></label>
                                            <div class="col-sm-8 pr-4">
                                              <input type="text" class="form-control updateFlashSaleDate" data-start="<?= date("d/m/Y H:i", strtotime($value->start)) ?>" data-end="<?= date("d/m/Y H:i", strtotime($value->end)) ?>" name="date" readonly>
                                            </div>
                                          </div>
                                          <div class="form-group">
                                            <label class="col-sm-4 pl-0 control-label">Icon Side <span class="required" aria-required="true">*</span></label>
                                            <div class="col-sm-8 pr-4">
                                              <div class="d-flex">
                                                <div class="radio-custom radio-primary mr-4">
                                                  <input class="updateFile" BannerID="<?= $value->id ?>" id="link<?= $value->id ?>" name="jenis" type="radio" value="link" checked>
                                                  <label class="font-size-14" for="link<?= $value->id ?>">Link / URL</label>
                                                </div>
                                                <div class="radio-custom radio-primary mb-2">
                                                  <input class="updateFile" BannerID="<?= $value->id ?>" id="uploadsImage<?= $value->id ?>" name="jenis" type="radio" value="file">
                                                  <label class="font-size-14" for="uploadsImage<?= $value->id ?>">Upload Image</label>
                                                </div>
                                              </div>
                                            </div>
                                          </div>
                                          <div class="form-group">
                                            <label class="col-sm-4 pl-0 control-label">Select Image <span class="required" aria-required="true">*</span></label>
                                            <div class="col-sm-8 pr-4">
                                              <input type="text" name="url_link" value="<?= $value->image ?>" class="form-control" id="linkInput<?= $value->id ?>" placeholder="eg.: google.co.id/Flash Sale.jpeg" required>
                                              <div id="fileinput<?= $value->id ?>" style="display: none">
                                                  <input class="form-control upload_file_button" placeholder="Select a Photo">
                                                  <input type="hidden" name="fileUploadUrl">
                                                  <input type="hidden" name="fileUploadIds">
                                              </div>
                                              <!-- <input type="file" name="fileToUpload" class="form-control" id="fileinput<?= $value->id ?>" style="display: none;"> -->
                                              <img src="<?= $value->image ?>" class="img-fluid my-2" style="width: 100px">
                                              <p class="mb-0 mt-2" style="line-height: 15px">
                                                <small class="text-danger">Best Size : 72 X 72px</small> <br>
                                                <small class="text-danger">Max File Size : 2MB</small>
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
                                <button class="btn btn-block btn-danger" onclick="hapus('<?= $value->id ?>')">
                                  <i class="fa fa-trash"></i> Delete
                                </button>
                              </td>
                            </tr>
                          <?php endforeach; ?>
                        </tbody>
                      </table>
                  </div>
              </section>
          </div>
      </section>
    </section>
  </div>
  <div class="modal fade" id="tambahFlashSale" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title font-weight-600" id="exampleModalLabel">Add Home Flash Sale</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body py-5 px-4">
          <form method="post" action="#" enctype="multipart/form-data">
            <div class="form-group">
              <label class="col-sm-4 pl-0 control-label">Title <span class="required" aria-required="true">*</span></label>
              <div class="col-sm-8 pr-0">
                <input type="text" name="title" class="form-control"  placeholder="eg.: New Flash Sale" required="" aria-required="true">
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 pl-0 control-label">Product To Show <span class="required" aria-required="true">*</span></label>
              <div class="col-sm-8 pr-0">
                <input type="hidden" name="typeQuery" value="insert">
                <select name="products[]" multiple data-plugin-selectTwo class="form-control populate" title="Please select Product" required>
                  <?php foreach ($product_list as $product): ?>
                    <option value="<?= $product->id ?>"><?= $product->text ?></option>
                  <?php endforeach ?>
                </select>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 pl-0 control-label">Start - End <span class="required" aria-required="true">*</span></label>
              <div class="col-sm-8 pr-0">
                <input type="text" class="form-control inputTanggalflashSale" name="date" readonly>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-4 pl-0 control-label">Icon Side <span class="required" aria-required="true">*</span></label>
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
                <input type="text" name="url_link" class="form-control" id="linkInput" placeholder="eg.: google.co.id/Flash Sale.jpeg" required>
                <div id="fileinput" style="display: none">
                    <input class="form-control upload_file_button" placeholder="Select a Photo">
                    <input type="hidden" name="fileUploadUrl">
                    <input type="hidden" name="fileUploadIds">
                </div>
                <!-- <input type="file" name="fileToUpload" class="form-control" id="fileinput" style="display: none;"> -->
                <p class="mb-0 mt-2" style="line-height: 15px">
                  <small class="text-danger">Best Size : 72 x 72px</small> <br>
                  <small class="text-danger">Max File Size : 2MB</small>
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

  <?php include (plugin_dir_path( __FILE__ ).'partials/_modal_example.php'); ?>

  <?php include (plugin_dir_path( __FILE__ ).'partials/_js.php');  ?>
  <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
  <script src="<?= revo_url(); ?>assets/datepicker/daterangepicker.js"></script>
  
  <script>
    $(document).ready(function(){
      $('.inputTanggalflashSale').daterangepicker({
        "timePicker": true,
        "timePicker24Hour": true,
        "locale": {
            "format": 'DD/MM/YYYY H:mm',
            "separator": " - ",
            "applyLabel": "Apply",
            "cancelLabel": "Cancel",
            "fromLabel": "From",
            "toLabel": "To",
            "customRangeLabel": "Custom",
            "weekLabel": "W",
            "firstDay": 1
        }

        // "daysOfWeek": [
        //         "Sen",
        //         "Sel",
        //         "Rab",
        //         "Kam",
        //         "Jum",
        //         "Sab",
        //         "Min"
        //     ],
        //     "monthNames": [
        //         "Januari",
        //         "Februari",
        //         "Maret",
        //         "April",
        //         "Mei",
        //         "Juni",
        //         "Juli",
        //         "Augustus",
        //         "September",
        //         "October",
        //         "November",
        //         "December"
        //     ],
      }, function(start, end, label) {
      });
    });

    $('.updateFlashSaleDate').daterangepicker({
      "timePicker": true,
      "timePicker24Hour": true,
      "locale": {
          "format": 'DD/MM/YYYY H:mm',
          "separator": " - ",
          "applyLabel": "Apply",
          "cancelLabel": "Cancel",
          "fromLabel": "From",
          "toLabel": "To",
          "customRangeLabel": "Custom",
          "weekLabel": "W",
          "firstDay": 1
      }
    });

    $('body').on('show.bs.modal', '.modal-update', function () {
      const start = $(this).find('.updateFlashSaleDate').data('start');
      const end = $(this).find('.updateFlashSaleDate').data('end');

      $('.updateFlashSaleDate').data('daterangepicker').setStartDate(start);
      $('.updateFlashSaleDate').data('daterangepicker').setEndDate(end);
    });

    function hapus(id){
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
                success: function (data) {
                  location.reload();
                },
                error: function (data) {
                  location.reload();
                }
            });
        }
      })
    }
  </script>
</body>
</html>