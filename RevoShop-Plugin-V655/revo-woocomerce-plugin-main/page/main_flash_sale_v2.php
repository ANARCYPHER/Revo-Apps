<?php

require(plugin_dir_path(__FILE__) . '../helper.php');


if ($_SERVER['REQUEST_METHOD'] === 'POST') {

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

    if (@$_POST["jenis"] == 'file' || @$_POST["jenis"] == 'link') {

      $alert = array(
        'type' => 'error',
        'title' => 'Query Error !',
        'message' => 'Failed to Add Data Flash Sale',
      );

      $images_url = '';

      if ($_POST["jenis"] == 'file') {
        $uploads_url = WP_CONTENT_URL . "/uploads/revo/";
        $target_dir = WP_CONTENT_DIR . "/uploads/revo/";
        $target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
        $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
        $newname =  md5(date("Y-m-d H:i:s")) . "." . $imageFileType;
        $is_upload_error = 0;
        if ($_FILES["fileToUpload"]["size"] > 0) {

          if ($_FILES["fileToUpload"]["size"] > 2000000) {
            $alert = array(
              'type' => 'error',
              'title' => 'Uploads Error !',
              'message' => 'your file is too large. max 2Mb',
            );
            $is_upload_error = 1;
          }

          if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg") {
            $alert = array(
              'type' => 'error',
              'title' => 'Uploads Error !',
              'message' => 'only JPG, JPEG & PNG files are allowed.',
            );
            $is_upload_error = 1;
          }

          if ($is_upload_error == 0) {
            if ($_FILES["fileToUpload"]["size"] > 500000) {
              compress($_FILES["fileToUpload"]["tmp_name"], $target_dir . $newname, 90);
              $images_url = $uploads_url . $newname;
            } else {
              move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_dir . $newname);
              $images_url = $uploads_url . $newname;
            }
          }
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

        $wpdb->insert('revo_flash_sale', $data);

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
  } elseif (@$_POST["typeQuery"] == 'update') {

    if (@$_POST["jenis"] == 'file' || @$_POST["jenis"] == 'link') {

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
        'message' => 'Failed to Update Flash Sale ' . $_POST['title'],
      );

      $images_url = '';

      if ($_POST["jenis"] == 'file') {
        $uploads_url = WP_CONTENT_URL . "/uploads/revo/";
        $target_dir = WP_CONTENT_DIR . "/uploads/revo/";
        $target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
        $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
        $newname =  md5(date("Y-m-d H:i:s")) . "." . $imageFileType;
        $is_upload_error = 0;
        if ($_FILES["fileToUpload"]["size"] > 0) {

          if ($_FILES["fileToUpload"]["size"] > 2000000) {
            $alert = array(
              'type' => 'error',
              'title' => 'Uploads Error !',
              'message' => 'your file is too large. max 2Mb',
            );
            $is_upload_error = 1;
          }

          if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg") {
            $alert = array(
              'type' => 'error',
              'title' => 'Uploads Error !',
              'message' => 'only JPG, JPEG & PNG files are allowed.',
            );
            $is_upload_error = 1;
          }

          if ($is_upload_error == 0) {
            if ($_FILES["fileToUpload"]["size"] > 500000) {

              compress($_FILES["fileToUpload"]["tmp_name"], $target_dir . $newname, 90);
              $dataUpdate['image'] = $uploads_url . $newname;
            } else {

              move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_dir . $newname);
              $dataUpdate['image'] = $uploads_url . $newname;
            }
          }
        }
      } else {

        $dataUpdate['image'] = $_POST['url_link'];
      }

      $wpdb->update('revo_flash_sale', $dataUpdate, $where);

      if (@$wpdb->show_errors == false) {
        $alert = array(
          'type' => 'success',
          'title' => 'Success !',
          'message' => 'Flash Sale ' . $_POST['title'] . ' Success Updated',
        );
      }

      $_SESSION["alert"] = $alert;
    }
  } elseif (@$_POST["typeQuery"] == 'hapus') {
    header('Content-type: application/json');

    $query = $wpdb->update(
      'revo_flash_sale',
      ['is_deleted' =>  '1'],
      array('id' => $_POST['id'])
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

// $product_list = json_decode(get_product_varian());

cek_flash_sale_end();
?>

<!doctype html>
<html class="fixed">
<?php include(plugin_dir_path(__FILE__) . 'partials/_css.php'); ?>
<link href="<?php echo revo_url(); ?>assets/datepicker/daterangepicker.css" rel="stylesheet" />
<style type="text/css">
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

  .applyBtn,
  .cancelBtn {
    padding: 10px;
  }

  dd,
  li {
    margin-bottom: 0px;
  }
</style>

<body>
  <?php include(plugin_dir_path(__FILE__) . 'partials/_header.php'); ?>

  <?php include(plugin_dir_path(__FILE__) . 'partials/_js.php');  ?>
  <script type="text/javascript" src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
  <script src="<?php echo revo_url(); ?>assets/datepicker/daterangepicker.js"></script>
  <div class="container-fluid">
    <section class="panel">
      <?php include(plugin_dir_path(__FILE__) . 'partials/_alert.php'); ?>
      <section class="panel">
        <div class="inner-wrapper pt-0">

          <!-- start: sidebar -->
          <?php include(plugin_dir_path(__FILE__) . 'partials/_new_sidebar.php'); ?>
          <!-- end: sidebar -->

          <section role="main" class="content-body p-0 pl-0">
            <div class="panel-body">
              <div class="row mb-2">
                <div class="col-6 text-left">
                  <h4>
                    Home Flash Sale <?php echo buttonQuestion() ?>
                  </h4>
                </div>
                <div class="col-6 text-right">
                  <button class="btn btn-primary" data-toggle="modal" data-target="#tambahFlashSale">
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
                    <th class="hidden-xs">Action</th>
                  </tr>
                </thead>
                <tbody>
                  <?php
                  $res_data_flash_sale = [];
                  foreach ($data_flash_sale as $key => $value) : ?>
                    <tr>
                      <td><?php echo $key + 1 ?></td>
                      <td>
                        Title : <span class="font-weight-600 mb-0 text-capitalize"><?php echo $value->title ?></span><br>
                        Start : <span class="font-weight-600 mb-0 text-capitalize"><?php echo formatted_date($value->start) ?></span><br>
                        End : <span class="font-weight-600 mb-0 text-capitalize"><?php echo formatted_date($value->end) ?></span><br>
                        Status : <?php echo cek_is_active($value->is_active) ?>
                      </td>
                      <td>
                        <img src="<?php echo $value->image ?>" class="img-fluid" style="width: 100px">
                      </td>
                      <td>
                        <?php
                        $list_products = json_decode($value->products);
                        $show = 0;
                        if (!empty($list_products) && $list_products != NULL) {
                          if (is_array($list_products)) {
                            $detail_res_data_flash_sale = [];
                            for ($i = 0; $i < count($list_products); $i++) {
                              if (!empty(get_product_varian_detail($list_products[$i]))) {
                                echo '<span class="badge badge-primary p-2">' . get_product_varian_detail($list_products[$i])[0]->get_title() . '</span> ';
                                $show += 1;

                                array_push($detail_res_data_flash_sale, [
                                  'id' => $list_products[$i],
                                  'text' => get_product_varian_detail($list_products[$i])[0]->get_title()
                                ]);
                              }
                            }

                            array_push($res_data_flash_sale, $detail_res_data_flash_sale);
                          } else {
                            if (!empty(get_product_varian_detail($list_products[0]))) {
                              echo '<span class="badge badge-primary p-2">' . get_product_varian_detail($list_products)[0]->get_title() . '</span> ';
                              $show += 1;
                            }
                          }
                        } else {
                          echo '<span class="badge badge-danger p-2">Empty !</span>';
                        }

                        if ($show == 0) {
                          echo '<span class="badge badge-danger p-2">Empty !</span>';
                        }
                        ?>
                      </td>
                      <td>
                        <button class="btn btn-primary mb-2" data-toggle="modal" data-target="#updateFlashSale<?php echo $value->id ?>" onclick="update(this)" data-key="<?= $key ?>">
                          <i class="fa fa-edit"></i> Update
                        </button><br>
                        <div class="modal fade" fd-id="<?= $value->id ?>" id="updateFlashSale<?= $value->id ?>" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                          <div class="modal-dialog" role="document">
                            <div class="modal-content">
                              <div class="modal-header">
                                <h5 class="modal-title font-weight-600" id="exampleModalLabel">Update <?php echo $value->title ?></h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                  <span aria-hidden="true">&times;</span>
                                </button>
                              </div>
                              <div class="modal-body">
                                <form method="post" action="#" enctype="multipart/form-data">
                                  <div class="panel-body">
                                    <div class="form-group">
                                      <label class="col-sm-4 pl-0 control-label">Title <span class="required" aria-required="true">*</span></label>
                                      <div class="col-sm-8">
                                        <input type="text" name="title" value="<?php echo $value->title ?>" class="form-control" placeholder="eg.: New Flash Sale" required="" aria-required="true">
                                        <input type="hidden" value="<?php echo $value->id ?>" name="id" required>
                                      </div>
                                    </div>
                                    <div class="form-group">
                                      <label class="col-sm-4 pl-0 control-label">Product To Show <span class="required" aria-required="true">*</span></label>
                                      <div class="col-sm-8">
                                        <input type="hidden" name="typeQuery" value="update">
                                        <select name="products[]" multiple class="form-control populate" title="Please select Product" required>
                                        </select>
                                      </div>
                                    </div>
                                    <div class="form-group">
                                      <label class="col-sm-4 pl-0 control-label">Start - End <span class="required" aria-required="true">*</span></label>
                                      <div class="col-sm-8">
                                        <input type="text" class="form-control" id="inputTanggalflashSale<?php echo $value->id ?>" name="date" readonly>
                                      </div>
                                    </div>
                                    <div class="form-group">
                                      <label class="col-sm-4 pl-0 control-label">Icon Side <span class="required" aria-required="true">*</span></label>
                                      <div class="col-sm-8">
                                        <div class="d-flex">
                                          <div class="radio-custom radio-primary mr-4">
                                            <input class="updateFile" FlashSaleID="<?php echo $value->id ?>" id="link<?php echo $value->id ?>" name="jenis" type="radio" value="link" checked>
                                            <label class="font-size-14" for="link<?php echo $value->id ?>">Link / URL</label>
                                          </div>
                                          <div class="radio-custom radio-primary mb-2">
                                            <input class="updateFile" FlashSaleID="<?php echo $value->id ?>" id="uploadsImage<?php echo $value->id ?>" name="jenis" type="radio" value="file">
                                            <label class="font-size-14" for="uploadsImage<?php echo $value->id ?>">Upload Image</label>
                                          </div>
                                        </div>
                                      </div>
                                    </div>
                                    <div class="form-group">
                                      <label class="col-sm-4 pl-0 control-label">Select Image <span class="required" aria-required="true">*</span></label>
                                      <div class="col-sm-8">
                                        <input type="text" name="url_link" value="<?php echo $value->image ?>" class="form-control" id="linkInput<?php echo $value->id ?>" placeholder="eg.: google.co.id/Flash Sale.jpeg" required>
                                        <input type="file" name="fileToUpload" class="form-control" id="fileinput<?php echo $value->id ?>" style="display: none;">
                                        <img src="<?php echo $value->image ?>" class="img-fluid my-2" style="width: 100px">
                                        <p class="mb-0 mt-2" style="line-height: 15px">
                                          <small class="text-danger">Best Size : 72 X 72px</small> <br>
                                          <small class="text-danger">Max File Size : 2MB</small>
                                        </p>
                                      </div>
                                    </div>
                                    <div class="form-group text-right mt-5">
                                      <div class="col-sm-12">
                                        <button type="submit" class="btn btn-primary">
                                          <i class="fa fa-send"></i> Submit
                                        </button>
                                      </div>
                                    </div>
                                  </div>
                                </form>
                              </div>
                            </div>
                          </div>
                        </div>
                        <script type="text/javascript">
                          $(document).ready(function() {

                            $('#inputTanggalflashSale<?php echo $value->id ?>').daterangepicker({
                              "timePicker": true,
                              "startDate": '<?php echo date("d/m/Y H:i", strtotime($value->start)) ?>',
                              "endDate": '<?php echo date("d/m/Y H:i", strtotime($value->end)) ?>',
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
                        </script>
                        <button class="btn btn-danger" onclick="hapus('<?php echo $value->id ?>')">
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
  <div class="modal fade" id="tambahFlashSale" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title font-weight-600" id="exampleModalLabel">Add Home Flash Sale</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <form method="post" action="#" enctype="multipart/form-data">
            <div class="panel-body">
              <div class="form-group">
                <label class="col-sm-4 pl-0 control-label">Title <span class="required" aria-required="true">*</span></label>
                <div class="col-sm-8">
                  <input type="text" name="title" class="form-control" placeholder="eg.: New Flash Sale" required="" aria-required="true">
                </div>
              </div>
              <div class="form-group">
                <label class="col-sm-4 pl-0 control-label">Product To Show <span class="required" aria-required="true">*</span></label>
                <div class="col-sm-8">
                  <input type="hidden" name="typeQuery" value="insert">
                  <select name="products[]" multiple class="form-control populate" title="Please select Product" required>
                  </select>
                </div>
              </div>
              <div class="form-group">
                <label class="col-sm-4 pl-0 control-label">Start - End <span class="required" aria-required="true">*</span></label>
                <div class="col-sm-8">
                  <input type="text" class="form-control inputTanggalflashSale" name="date" readonly>
                </div>
              </div>
              <div class="form-group">
                <label class="col-sm-4 pl-0 control-label">Icon Side <span class="required" aria-required="true">*</span></label>
                <div class="col-sm-8">
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
                <div class="col-sm-8">
                  <input type="text" name="url_link" class="form-control" id="linkInput" placeholder="eg.: google.co.id/Flash Sale.jpeg" required>
                  <input type="file" name="fileToUpload" class="form-control" id="fileinput" style="display: none;">
                  <p class="mb-0 mt-2" style="line-height: 15px">
                    <small class="text-danger">Best Size : 72 x 72px</small> <br>
                    <small class="text-danger">Max File Size : 2MB</small>
                  </p>
                </div>
              </div>
              <div class="form-group text-right mt-5">
                <div class="col-sm-12">
                  <button type="submit" class="btn btn-primary">
                    <i class="fa fa-send"></i> Submit
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>

  <?php
  include(plugin_dir_path(__FILE__) . 'partials/_modal_example.php');
  ?>

  <script type="text/javascript">
    $(document).ready(function() {
      getProductDatas($('#tambahFlashSale').find('select[name="products[]"]'));
    });

    function update(el) {
      const target = $(el).data('target');
      const key = $(el).data('key');
      const res_data_flash_sale = <?= json_encode($res_data_flash_sale) ?>;
      const select2Parent = $(target).find('select[name="products[]"]');

      let data = res_data_flash_sale[key];

      getProductDatas(select2Parent);

      let newOption = '';
      data.map(elo => {
        newOption += `<option value='${elo.id}' selected>${elo.text}</option>`
      });

      select2Parent.append(newOption).trigger('change');
    }

    function getProductDatas(element) {
      let url = location.origin;

      if (location.hostname === 'localhost') {
        url = url + '/' + location.pathname.split('/')[1];
      }

      element.select2({
        ajax: {
          type: 'GET',
          url: url + '/wp-json/wc/v3/products',
          dataType: 'json',
          delay: 250,
          cache: true,
          data: function(params) {
            let query = {
              search: params.term,
              fromAdmin: true
            }

            return query;
          },
          processResults: function(data, params) {
            let res = [];
            data.map(val => {
              res.push({
                id: val.id,
                text: val.name
              });
            });

            return {
              results: res,
            };
          }
        },
        minimumInputLength: 1,
        placeholder: "Choose Products"
      });
    }

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

  <script type="text/javascript">
    $(document).ready(function() {

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
  </script>
</body>

</html>