<!doctype html>
<?php
  require (plugin_dir_path( __FILE__ ).'../helper.php');

  $query_sosmed_setting = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'sosmed_link' limit 1";

  $data = $wpdb->get_row($query_sosmed_setting, OBJECT);
  $data_sosmed_setting = json_decode($data->description);

  $slug = 'sosmed_link';
  $title = 'Social Media Link';


  if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    if (@$_POST['slug']) {

      if ($_POST['slug'] == 'sosmed_link') {
        $success = 0;

        for ($i=1; $i < 6; $i++) { 
          if ($_POST['description'.$i] != '') {
            $query_data_description[$_POST['label'.$i]] = $_POST['description'.$i];
          } else {
            $query_data_description[$_POST['label'.$i]] = '';
          }
        }

        $query_data = array(
          'slug' => $slug,
          'title' => $title,
          'description' => json_encode($query_data_description),
        );

        if ($_POST['id'] != 0) {
          $where = ['id' => $_POST['id']];
          $wpdb->update('revo_mobile_variable',$query_data,$where);
          if (@$wpdb->show_errors == false) {
            $success = 1;
          }
        }else{
          $wpdb->insert('revo_mobile_variable',$query_data);
          if (@$wpdb->insert_id > 0) {
            $success = 1;
          }
        }

        if ($success) {

          $data = $wpdb->get_row($query_sosmed_setting, OBJECT);
          $data_sosmed_setting = json_decode($data->description);

          $alert = array(
            'type' => 'success',
            'title' => 'Success !',
            'message' => $title.' Success to Update',
          );
        }else{
          $alert = array(
            'type' => 'error',
            'title' => 'error !',
            'message' => $title.' Failed to Update',
          );
        }

        $_SESSION["alert"] = $alert;
      }
    }
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
                <div class="col-md-12" style="margin-bottom: 35px">
                  <h4>Social Media Link</h4>
                  <span>Make sure your link is correct</span>
                </div>
                <form class=" col-md-12 form-horizontal form-bordered" method="POST" action="#" enctype="multipart/form-data">
                    <!-- <h5 style="margin-bottom: 25px">URL Setting</h5> -->
                    <div class="form-group">
                        <label class="col-md-1 control-label text-left" for="inputDefault">Whatsapp</label>
                        <div class="col-md-11">
                            <input type="text" class="form-control" name="description1" placeholder="ex: https://wa.me/62811369000" value="<?= isset($data_sosmed_setting->whatsapp)? $data_sosmed_setting->whatsapp : '' ?>">
                            <input type="hidden" name="label1" value="whatsapp">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-1 control-label text-left" for="inputDefault">Facebook</label>
                        <div class="col-md-11">
                            <input type="text" class="form-control" name="description2" placeholder="ex: https://www.facebook.com/revoapps/" value="<?= isset($data_sosmed_setting->facebook)? $data_sosmed_setting->facebook : '' ?>">
                            <input type="hidden" name="label2" value="facebook">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-1 control-label text-left" for="inputDefault">Instagram</label>
                        <div class="col-md-11">
                            <input type="text" class="form-control" name="description3" placeholder="ex: https://www.instagram.com/revoapps/" value="<?= isset($data_sosmed_setting->instagram)? $data_sosmed_setting->instagram : '' ?>">
                            <input type="hidden" name="label3" value="instagram">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-1 control-label text-left" for="inputDefault">Youtube</label>
                        <div class="col-md-11">
                            <input type="text" class="form-control" name="description4" placeholder="ex: https://www.youtube.com/channel/UC3SQYzZxtODJ8fJU7L_CnGQ/videos" value="<?= isset($data_sosmed_setting->youtube)? $data_sosmed_setting->youtube : '' ?>">
                            <input type="hidden" name="label4" value="youtube">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-1 control-label text-left" for="inputDefault">Tiktok</label>
                        <div class="col-md-11">
                            <input type="text" class="form-control" name="description5" placeholder="ex: https://www.youtube.com/watch?v=7S3ISgvEh5Y&t=6s" value="<?= isset($data_sosmed_setting->tiktok)? $data_sosmed_setting->tiktok : '' ?>">
                            <input type="hidden" name="label5" value="tiktok">
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-12 text-right">
                            <input type="hidden" name="slug" value="<?= $slug ?>">
                            <input type="hidden" name="id" value="<?= $data->id ?>">
                            <button type="submit" class="btn btn-primary">Update Social Media Link</button>
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
<?php include (plugin_dir_path( __FILE__ ).'partials/_js.php'); ?>
<script type="text/javascript">
  function getExtFile(filename) {
    return (/[.]/.exec(filename)) ? /[^.]+$/.exec(filename) : undefined;
  }

  $(document).ready(function(){
    $("input[name=fileToUploadSplash]").change(function(){
      const fileUpload = this.files[0];
      const allowedExt = ['jpg','jpeg','gif','mp4','png'];
      const maxSize = 1024*500;
      check = allowedExt.includes(getExtFile(fileUpload.name)[0].toLowerCase()) && fileUpload.size <= maxSize;
      if (!check) {
        this.value = null;
        alert(`Only ${allowedExt.join(", ")} can be uploaded & 500kb max file size`);
      }
    })
  })
</script>
</html>
