<!doctype html>
<?php
  require (plugin_dir_path( __FILE__ ).'../helper.php');

  if ($_SERVER['REQUEST_METHOD'] === 'POST') {
      $update_at = array('update_at' => date('Y-m-d H:i:s'),'message' => 'coloumn update at is expired_at' );
      $data = array(
                    'title' => $_POST['type'], 
                    'description' => $_POST['code'], 
                    'image' => json_encode($update_at), 
                  );

      $cek_code = cek_license_code($data);

      if ($cek_code->status == 'success') {
        $data['description'] = json_encode($cek_code->data);
        $data['update_at'] = $cek_code->data->expired_at;
        $wpdb->update('revo_mobile_variable',$data,['slug' => 'license_code']);
        if (@$wpdb->insert_id > 0) {
          $alert = array(
            'type' => 'success', 
            'title' => 'Success !',
            'message' => 'License Successfully validate', 
          );
          $_SESSION["alert"] = $alert;
          wp_redirect( admin_url( '/admin.php?page=revo-apps-setting' ) );
          exit;
        }
        echo "<script>window.location.href='".admin_url( '/admin.php?page=revo-apps-setting')."';</script>";
      }else{
        $alert = array(
              'type' => 'error', 
              'title' => $cek_code->message,
              'message' => 'try again later', 
        );
      }

      $_SESSION["alert"] = $alert;
  }

?>
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

      <section role="main" class="content-body p-0 pl-0">
          <section class="panel mb-3">
            <div class="panel-body">
              <div class="row border-bottom-primary">
                <div class="col-md-12">
                  <h4 style="margin-bottom: 35px">License Code</h4>
                </div>
                <form class=" col-md-12 form-horizontal form-bordered" method="POST" action="#">
                    <div class="form-group">
                        <label class="col-md-3 control-label text-left" for="inputDefault">Select For License</label>
                        <div class="col-md-9">
                            <select class="form-control w-100" name="type" style="max-width: 100%;height: 40px" onchange="verifierTypeCheck(event)" id="verifierType">
                              <option value="revo_server" selected>Revo Server</option>
                              <option value="envato">Envato</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label text-left" for="inputDefault">Input License Code</label>
                        <div class="col-md-9">
                            <input type="text" class="form-control" id="license_code" name="code" style="height: 40px" name="title" placeholder="****-****-****-****" maxlength="19" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-12 text-right">
                            <button type="submit" class="btn btn-primary">Active Now</button>
                        </div>
                    </div>
                </form>
              </div>
              <div class="w-100 text-right mt-md-3">
                <a href="#" class="text-primary">Need Help  ?  Visit our website</a>
              </div>
            </div>
          </section>
      </section>
    </div>
    </section>
  </div>
</body>
<?php include (plugin_dir_path( __FILE__ ).'partials/_js.php'); ?>
<script type="text/javascript">
  var license_code = document.getElementById('license_code');
  license_code.addEventListener('keyup', function(e){
    license_code.value = formatlicense_code(this.value);
  });

  function formatlicense_code(input){
        const verifierType = document.getElementById("verifierType").value;
        if (verifierType == 'envato' ) return input;

        input = input.substring(0,19);
        var size = input.length;
        if(size < 4){
                input = input;
        }else if(size < 7 && size > 4){
          alert(input.substring(4,8));
            input = input.substring(0,4)+'-'+input.substring(4,8);
        }else if(size < 12 && size > 8){
            input = input+'-'+input.substring(8,13);
        }else if(size < 17 && size > 13){
            input = input+'-'+input.substring(13,18);
        }else{
            input = input
        }
        return input; 
  }

  function verifierTypeCheck(e) {
    licenseCode = $("#license_code");
    if (e.target.value == 'envato') {
      licenseCode.attr("maxLength",36);
      return;
    }

    licenseCode.attr("maxLength",19);
  }
</script>
</html>
