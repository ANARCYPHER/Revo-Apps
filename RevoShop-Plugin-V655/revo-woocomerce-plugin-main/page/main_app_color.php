<?php
  require(plugin_dir_path(__FILE__) . '../helper.php');

  $query_app_color = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'app_color'";
  $data_app_color = $wpdb->get_results($query_app_color, OBJECT);

  function changeColor($title, $id_color, $color)
  {
    global $wpdb;

    $where = [
      'slug'  => 'app_color',
      'title' => $title
    ];

    $color = str_replace("#", "", $color);

    $query_update = insert_update_MV($where, $id_color, $color);
    $update_at = ['update_at' => date('Y-m-d H:i:s')];

    if ($query_update) {
      $wpdb->update('revo_mobile_variable', $update_at, ['id' => $id_color]);
    }

    return $query_update;
  }

  if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['typeQuery']) && $_POST['typeQuery'] === 'buynow_button_style') {
      header('Content-type: application/json');

      $status = $_POST["status"];
      $get = query_revo_mobile_variable('"buynow_button_style"', 'sort');

      if (empty($get)) {
        $wpdb->insert('revo_mobile_variable', array(
          'slug' => 'buynow_button_style',
          'title' => 'buynow button style',
          'description' => $status
        ));
      } else {
        $wpdb->query(
          $wpdb->prepare("UPDATE revo_mobile_variable SET description='$status' WHERE slug='buynow_button_style'")
        );
      }

      http_response_code(200);
      return json_encode(['kode' => 'S']);
      die(); 
    }

    if (@$_POST['slug'] && $_POST['slug'] == 'app_color') {
      $success = 0;

      if (isset($_POST['prim_color'])) {
        $success = changeColor('primary', $_POST['id_prim_color'], $_POST['prim_color']);
      }

      if (isset($_POST['sec_color'])) {
        $success = changeColor('secondary', $_POST['id_sec_color'], $_POST['sec_color']);
      }

      if (isset($_POST['btn_color'])) {
        $success = changeColor('button_color', $_POST['id_btn_color'], $_POST['btn_color']);
      }

      if (isset($_POST['txt_btn_color'])) {
        $success = changeColor('text_button_color', $_POST['id_txt_btn_color'], $_POST['txt_btn_color']);
      }

      if ($success > 0) {
        $data_app_color = $wpdb->get_results($query_app_color, OBJECT);
        $alert = array(
          'type' => 'success',
          'title' => 'Success !',
          'message' => 'App Theme Color Updated Successfully',
        );
      } else {
        $alert = array(
          'type' => 'error',
          'title' => 'error !',
          'message' => 'App Theme Color Failed to Update',
        );
      }

      $_SESSION["alert"] = $alert;
    }
  }

  $buynow_button_style = query_revo_mobile_variable('"buynow_button_style"', 'sort')[0]->description;
?>

<!doctype html>
<html class="fixed sidebar-light">
  <?php include(plugin_dir_path(__FILE__) . 'partials/_css.php'); ?>
  <style>
    .onoffswitch {
      position: relative;
      width: 71px;
      -webkit-user-select: none;
      -moz-user-select: none;
      -ms-user-select: none;
    }

    .onoffswitch-checkbox {
      position: absolute;
      opacity: 0;
      pointer-events: none;
    }

    .onoffswitch-label {
      display: block;
      overflow: hidden;
      cursor: pointer;
      border: 2px solid #999999;
      border-radius: 22px;
    }

    .onoffswitch-inner {
      display: block;
      width: 200%;
      margin-left: -100%;
      transition: margin 0.3s ease-in 0s;
    }

    .onoffswitch-inner:before,
    .onoffswitch-inner:after {
      display: block;
      float: left;
      width: 50%;
      height: 27px;
      padding: 0;
      line-height: 27px;
      font-size: 14px;
      color: white;
      font-family: Trebuchet, Arial, sans-serif;
      font-weight: bold;
      box-sizing: border-box;
    }

    .onoffswitch-inner:before {
      content: "ON";
      padding-left: 9px;
      background-color: #22AB01;
      color: #FFFFFF;
    }

    .onoffswitch-inner:after {
      content: "OFF";
      padding-right: 9px;
      background-color: #F0F0F0;
      color: #767876;
      text-align: right;
    }

    .onoffswitch-switch {
      display: block;
      width: 12px;
      margin: 7.5px;
      background: #FFFFFF;
      position: absolute;
      top: 0;
      bottom: 0;
      right: 40px;
      border: 2px solid #999999;
      border-radius: 22px;
      transition: all 0.3s ease-in 0s;
    }

    .onoffswitch-checkbox:checked+.onoffswitch-label .onoffswitch-inner {
      margin-left: 0;
    }

    .onoffswitch-checkbox:checked+.onoffswitch-label .onoffswitch-switch {
      right: 0px;
    }
  </style>

  <body>
    <?php include(plugin_dir_path(__FILE__) . 'partials/_header.php'); ?>
    <div class="container-fluid">
      <?php include(plugin_dir_path(__FILE__) . 'partials/_alert.php'); ?>
      <section class="panel">
        <div class="inner-wrapper pt-0">
          <!-- start: sidebar -->
          <?php include(plugin_dir_path(__FILE__) . 'partials/_new_sidebar.php'); ?>
          <!-- end: sidebar -->

          <section role="main" class="content-body p-0">
            <section class="panel mb-3">
              <div class="panel-body">
                <div class="row border-bottom-primary">
                  <div class="col-md-12">
                    <h4 style="margin-bottom: 35px">App Theme Color</h4>
                  </div>

                  <form class=" col-md-12 form-horizontal form-bordered" method="POST" action="#">
                    <div class="form-group">
                      <label class="col-md-2 control-label text-left" for="inputDefault">Primary Color</label>
                      <div class="col-md-10">
                        <?php
                        $id = 0;
                        $value = '';
                        if ($data_app_color) {
                          foreach ($data_app_color as $key) {
                            if ($key->title == 'primary') {
                              $id = $key->id;
                              $value = '#' . $key->description;
                            }
                          }
                        }
                        ?>
                        <input type="color" class="form-control" name="prim_color" placeholder="ex: ED1D1D" value="<?= $value ?>" required>
                        <input type="hidden" name="id_prim_color" value="<?php echo $id  ?>">
                        <?php

                        ?>
                      </div>
                    </div>

                    <div class="form-group">
                      <label class="col-md-2 control-label text-left" for="inputDefault">Secondary Color</label>
                      <div class="col-md-10">
                        <?php
                        $id = 0;
                        $value = '';
                        if ($data_app_color) {
                          foreach ($data_app_color as $key) {
                            if ($key->title == 'secondary') {
                              $id = $key->id;
                              $value = '#' . $key->description;
                            }
                          }
                        }
                        ?>
                        <input type="color" class="form-control" name="sec_color" placeholder="ex: 960000" value="<?= $value ?>" required>
                        <input type="hidden" name="id_sec_color" value="<?php echo $id ?>">
                      </div>
                    </div>

                    <div class="form-group pl-4">
                      <div class="d-flex align-items-center">
                        <h4>Buy Now Button with Solid Color</h4>
                        <div class="col-auto">
                          <div class="onoffswitch">
                            <input type="checkbox" name="button_buynow" onchange="buttonBuynow(event)" class="onoffswitch-checkbox" id="button_buynow" tabindex="0" <?= $buynow_button_style == 'solid' ? 'checked' : '' ?>>
                            <label class="onoffswitch-label" for="button_buynow">
                              <span class="onoffswitch-inner"></span>
                              <span class="onoffswitch-switch"></span>
                            </label>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="form-group">
                      <label class="col-md-2 control-label text-left" for="inputDefault">Buy Now Button Color</label>
                      <div class="col-md-10">
                        <?php
                        $id = 0;
                        $value = '';
                        if ($data_app_color) {
                          foreach ($data_app_color as $key) {
                            if ($key->title == 'button_color') {
                              $id = $key->id;
                              $value = '#' . $key->description;
                            }
                          }
                        }
                        ?>
                        <input type="color" class="form-control" name="btn_color" placeholder="ex: 960000" value="<?= $value ?>" required>
                        <input type="hidden" name="id_btn_color" value="<?php echo $id ?>">
                      </div>
                    </div>

                    <div class="form-group">
                      <label class="col-md-2 control-label text-left" for="inputDefault">Text Color on Buy Now Button</label>
                      <div class="col-md-10">
                        <?php
                        $id = 0;
                        $value = '';
                        if ($data_app_color) {
                          foreach ($data_app_color as $key) {
                            if ($key->title == 'text_button_color') {
                              $id = $key->id;
                              $value = '#' . $key->description;
                            }
                          }
                        }
                        ?>
                        <input type="color" class="form-control" name="txt_btn_color" placeholder="ex: 960000" value="<?= $value ?>" required>
                        <input type="hidden" name="id_txt_btn_color" value="<?php echo $id ?>">
                      </div>
                    </div>

                    <div class="form-group">
                      <div class="col-md-12 text-right">
                        <input type="hidden" name="slug" value="app_color">
                        <button type="submit" class="btn btn-primary">Update App Color</button>
                      </div>
                    </div>
                  </form>
                </div>
              </div>
            </section>
          </section>
        </div>
      </section>
    </div>
  </body>

  <script src="<?php echo revo_url() ?>assets/vendor/jquery/jquery.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@10"></script>
  <script>
    function buttonBuynow(e) {
      el = e.target;
      status = el.checked ? "solid" : "gradation";

      if (status === "solid") {
        swaltitle = "Are you sure to make buy now button with solid style?";
        swaltext = "";
      } else {
        swaltitle = "Are you sure to make buy now button with gradation style?";
        swaltext = "";
      }

      Swal.fire({
        icon: 'warning',
        title: swaltitle,
        text: swaltext,
        showDenyButton: true,
        showCancelButton: false,
        allowOutsideClick: false,
        confirmButtonText: `YES`,
        denyButtonText: `NO`,
      }).then((result) => {
        if (result.isConfirmed) {
          $.ajax({
            url: "#",
            method: "POST",
            data: {
              status: status,
              typeQuery: 'buynow_button_style',
            },
            datatype: "json",
            async: true,
            complete: () => {
              location.reload();
            }
          });
        } else if (result.isDenied) {
          el.checked = status == "solid" ? false : true;
        }
      })
    }
  </script>
</html>