<?php

require(plugin_dir_path(__FILE__) . '../helper.php');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

  $products = array();

  if ($_POST['products']) {
    $products = $_POST['products'];
  }

  $products = json_encode($products);

  if (@$_POST["typeQuery"] == 'update') {

    $dataUpdate = array(
      'title' => $_POST['title'],
      'description' => $_POST['description'],
      'products' => $products,
    );

    $where = array('id' => $_POST['id']);

    $alert = array(
      'type' => 'error',
      'title' => 'Query Error !',
      'message' => 'Failed to Update Additional Products ' . $_POST['title'],
    );

    $wpdb->update('revo_extend_products', $dataUpdate, $where);

    if (@$wpdb->show_errors == false) {
      $alert = array(
        'type' => 'success',
        'title' => 'Success !',
        'message' => 'Additional Products ' . $_POST['title'] . ' Success Updated',
      );
    }

    $_SESSION["alert"] = $alert;
  }
}

$data_extend_products = $wpdb->get_results("SELECT * FROM revo_extend_products WHERE is_deleted = 0", OBJECT);

// $product_list = json_decode(get_product_varian());

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
                    Home Additional Products <?php echo buttonQuestion() ?>
                  </h4>
                </div>
                <div class="col-6 text-right">
                </div>
              </div>
              <table class="table table-bordered table-striped mb-none" id="datatable-default">
                <thead>
                  <tr>
                    <th>No</th>
                    <th>Details</th>
                    <th style="width: 35%">List Product</th>
                    <th class="hidden-xs">Action</th>
                  </tr>
                </thead>
                <tbody>
                  <?php
                  $res_data_flash_sale = [];
                  foreach ($data_extend_products as $key => $value) : ?>
                    <tr>
                      <td><?php echo $key + 1 ?></td>
                      <td>
                        Title : <span class="font-weight-600 mb-0 text-capitalize"><?php echo $value->title ?></span><br>
                        Description : <span class="font-weight-600 mb-0 text-capitalize"><?php echo $value->description ?></span><br>
                        Show In : <span class="font-weight-600 mb-0 text-capitalize">
                          <?php
                          $type =  cek_type($value->type)['text'];
                          $type = str_replace("Pannel", "panel", $type);
                          echo $type;
                          ?>
                        </span><br>
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
                          // echo '<span class="badge badge-danger p-2">empty !</span>';
                        }

                        if ($show == 0) {
                          echo '<span class="badge badge-danger p-2">empty !</span>';
                        }
                        ?>
                      </td>
                      <td>
                        <button class="btn btn-primary mb-2" data-toggle="modal" data-target="#updateFlashSale<?php echo $value->id ?>" onclick="update(this)" data-key="<?= $key ?>">
                          <i class="fa fa-edit"></i> Update
                        </button><br>
                        <div class="modal fade" id="updateFlashSale<?php echo $value->id ?>" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
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
                                        <input type="text" name="title" value="<?php echo $value->title ?>" class="form-control" placeholder="eg.: New Additional Products" required="" aria-required="true">
                                        <input type="hidden" value="<?php echo $value->id ?>" name="id" required>
                                      </div>
                                    </div>
                                    <div class="form-group">
                                      <label class="col-sm-4 pl-0 control-label">Description <span class="required" aria-required="true">*</span></label>
                                      <div class="col-sm-8">
                                        <input type="text" name="description" value="<?php echo $value->description ?>" class="form-control" placeholder="eg.: New Additional Products" aria-required="true">
                                        <input type="hidden" value="<?php echo $value->id ?>" name="id" required>
                                      </div>
                                    </div>
                                    <div class="form-group">
                                      <label class="col-sm-4 pl-0 control-label">Product To Show <span class="required" aria-required="true">*</span></label>
                                      <div class="col-sm-8">
                                        <input type="hidden" name="typeQuery" value="update">
                                        <select name="products[]" multiple class="form-control populate" title="Please select Product" required>
                                          <?php foreach ($product_list as $product) : ?>
                                            <option value="<?php echo $product->id ?>" <?php
                                                                                        if (is_array($list_products)) {
                                                                                          for ($i = 0; $i < count($list_products); $i++) {
                                                                                            echo $product->id == $list_products[$i] ? 'selected' : '';
                                                                                          }
                                                                                        } else {
                                                                                          echo $product->id == $list_products ? 'selected' : '';
                                                                                        }
                                                                                        ?>><?php echo $product->text ?></option>
                                          <?php endforeach ?>
                                        </select>
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

  <div class="modal fade" id="question" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title font-weight-600" id="exampleModalLabel">Show In Mobile Pannel</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="row mx-0">
            <div class="col-6 px-1">
              <div class="card p-3 mt-1">
                <label class="control-label pb-2"><?php echo cek_type('special')['text'] ?></label>
                <img src="<?php echo cek_type('special')['image'] ?>" style="height: 150px;width: auto;">
              </div>
            </div>
            <div class="col-6 px-1">
              <div class="card p-3 mt-1">
                <label class="control-label pb-2"><?php echo cek_type('our_best_seller')['text'] ?></label>
                <img src="<?php echo cek_type('our_best_seller')['image'] ?>" style="height: 150px;width: auto;">
              </div>
            </div>
            <div class="col-6 px-1">
              <div class="card p-3 mt-1">
                <label class="control-label pb-2"><?php echo cek_type('recomendation')['text'] ?></label>
                <img src="<?php echo cek_type('recomendation')['image'] ?>" class="img-fluid">
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <?php include(plugin_dir_path(__FILE__) . 'partials/_js.php'); ?>

  <script type="text/javascript">
    $(document).ready(function() {

      $('.updateFile, input[type=radio][name=jenis]').change(function() {
        var id = $(this).attr("FlashSaleID");
        if (this.value == 'file') {
          $('#linkInput' + id).css("display", "none");
          $('#linkInput' + id).removeAttr("required");
          $('#fileinput' + id).css("display", "block");
          $('#fileinput' + id).attr("required", "");
        } else if (this.value == 'link') {
          $('#linkInput' + id).css("display", "block");
          $('#linkInput' + id).attr("required", "");
          $('#fileinput' + id).css("display", "none");
          $('#fileinput' + id).removeAttr("required");
        }
      });
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

  <script type="text/javascript" src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
  <script src="<?php echo revo_url(); ?>assets/datepicker/daterangepicker.js"></script>

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
          "daysOfWeek": [
            "Sen",
            "Sel",
            "Rab",
            "Kam",
            "Jum",
            "Sab",
            "Min"
          ],
          "monthNames": [
            "Januari",
            "Februari",
            "Maret",
            "April",
            "Mei",
            "Juni",
            "Juli",
            "Augustus",
            "September",
            "October",
            "November",
            "December"
          ],
          "firstDay": 1
        }
      }, function(start, end, label) {

      });



    });
  </script>
</body>

</html>