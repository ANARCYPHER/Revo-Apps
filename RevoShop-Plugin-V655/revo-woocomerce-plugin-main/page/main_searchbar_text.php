<!doctype html>
<?php
  require (plugin_dir_path( __FILE__ ).'../helper.php');

  $query_searchbar = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'searchbar_text' limit 1";

  $data = $wpdb->get_row($query_searchbar, OBJECT);
  $data_searchbar = json_decode($data->description);

  $slug = 'searchbar_text';
  $title = 'Search Bar Text';


  if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    if (@$_POST['slug']) {

      if ($_POST['slug'] == 'searchbar_text') {
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

          $data = $wpdb->get_row($query_searchbar, OBJECT);
          $data_searchbar = json_decode($data->description);

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
                  <h4>Search Bar Text</h4>
                  <span>This texts will be appeared inside search bar on home page (maximum 20 character)</span>
                </div>
                <form class=" col-md-12 form-horizontal form-bordered" method="POST" action="#" enctype="multipart/form-data">
                    <!-- <h5 style="margin-bottom: 25px">URL Setting</h5> -->
                    <div class="form-group">
                        <label class="col-md-1 control-label text-left" for="inputDefault">Text 1</label>
                        <div class="col-md-11">
                            <input type="text" maxlength="20" class="form-control" name="description1" placeholder="ex: Coca Cola" value="<?= isset($data_searchbar->text_1)? $data_searchbar->text_1 : '' ?>">
                            <input type="hidden" name="label1" value="text_1">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-1 control-label text-left" for="inputDefault">Text 2</label>
                        <div class="col-md-11">
                            <input type="text" maxlength="20" class="form-control" name="description2" placeholder="ex: Chicken Burger" value="<?= isset($data_searchbar->text_2)? $data_searchbar->text_2 : '' ?>">
                            <input type="hidden" name="label2" value="text_2">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-1 control-label text-left" for="inputDefault">Text 3</label>
                        <div class="col-md-11">
                            <input type="text" maxlength="20" class="form-control" name="description3" placeholder="ex: Vegetables Salad" value="<?= isset($data_searchbar->text_3)? $data_searchbar->text_3 : '' ?>">
                            <input type="hidden" name="label3" value="text_3">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-1 control-label text-left" for="inputDefault">Text 4</label>
                        <div class="col-md-11">
                            <input type="text" maxlength="20" class="form-control" name="description4" placeholder="ex: Strawberry Fruit" value="<?= isset($data_searchbar->text_4)? $data_searchbar->text_4 : '' ?>">
                            <input type="hidden" name="label4" value="text_4">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-1 control-label text-left" for="inputDefault">Text 5</label>
                        <div class="col-md-11">
                            <input type="text" maxlength="20" class="form-control" name="description5" placeholder="ex: Toyoya Steering Wheel" value="<?= isset($data_searchbar->text_5)? $data_searchbar->text_5 : '' ?>">
                            <input type="hidden" name="label5" value="text_5">
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-12 text-right">
                            <input type="hidden" name="slug" value="<?= $slug ?>">
                            <input type="hidden" name="id" value="<?= $data->id ?>">
                            <button type="submit" class="btn btn-primary">Update Search Bar Text</button>
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
