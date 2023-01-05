<?php
  require (plugin_dir_path( __FILE__ ).'../helper.php');
  
  if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    if (@$_POST["typeQuery"] == 'insert') {
      
        $alert = array(
            'type' => 'error', 
            'title' => 'Query Error !',
            'message' => 'Failed to Add Data Categories Popular', 
        );

        
        $categories = json_encode($_POST['categories']);
        $wpdb->insert('revo_popular_categories',
        [
          'categories' => $categories,
          'title' => $_POST['title'],
        ]);

        if (@$wpdb->insert_id > 0) {
          $alert = array(
            'type' => 'success', 
            'title' => 'Success !',
            'message' => 'Categories Success Saved', 
          );
        }

        $_SESSION["alert"] = $alert;

    }elseif (@$_POST["typeQuery"] == 'update') {

        $categories = json_encode($_POST['categories']);
        
        $dataUpdate = array(
                        'categories' => $categories,
                        'title' => $_POST['title'],
                    );

        $where = array('id' => $_POST['id']);

        $alert = array(
            'type' => 'error', 
            'title' => 'Query Error !',
            'message' => 'Failed to Update Categories Popular '.$_POST['title'], 
        );

        $wpdb->update('revo_popular_categories',$dataUpdate,$where);
        
        if (@$wpdb->show_errors == false) {
          $alert = array(
            'type' => 'success', 
            'title' => 'Success !',
            'message' => 'Categories '.$_POST['title'].' Success Updated', 
          );
        }

        $_SESSION["alert"] = $alert;

    }elseif (@$_POST["typeQuery"] == 'hapus') {
        header('Content-type: application/json');

        $query = $wpdb->update( 
              'revo_popular_categories', ['is_deleted' =>  '1'], 
              array( 'id' => $_POST['id']), 
              array( '%s'), 
              array( '%d' ) 
            );

        $alert = array(
            'type' => 'error', 
            'title' => 'Query Error !',
            'message' => 'Failed to Delete  Categories Popular', 
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

  $data_banner = $wpdb->get_results("SELECT * FROM revo_popular_categories WHERE is_deleted = 0", OBJECT);

  $categories_list = json_decode(get_categorys());
?>

<!DOCTYPE html>
<html class="fixed">
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

        <section role="main" class="content-body p-0">
            <section class="panel">
              <div class="panel-body">
                <div class="row mb-2">
                  <div class="col-6 text-left">
                    <h4>
                      Popular Categories <?= buttonQuestion() ?>
                    </h4>
                  </div>
                  <div class="col-6 text-right">
                    <button class="btn btn-primary"  data-toggle="modal" data-target="#tambahCategories">
                      <i class="fa fa-plus"></i> Add Categories
                    </button>
                  </div>
                </div>
                <table class="table table-bordered table-striped mb-none" id="datatable-default">
                  <thead>
                    <tr>
                      <th>no</th>
                      <th>Title</th>
                      <th>list Categories</th>
                      <th class="hidden-xs">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <?php foreach ($data_banner as $key => $value): ?>
                      <tr>
                        <td><?= $key + 1; ?></td>
                        <td class="text-capitalize"><?= $value->title ?></td>
                        <td>
                          <?php 
                            $categories = json_decode($value->categories);
                            if (is_array($categories)) {
                              for ($i=0; $i < count($categories); $i++) {
                                echo '<span class="badge badge-success">'.
                                 get_categorys_detail($categories[$i])[0]->name.'</span> ';
                              }
                            }
                          ?>
                        </td>
                        <td>
                          <button class="btn btn-primary"  data-toggle="modal" data-target="#updateCategories<?= $value->id ?>">
                            <i class="fa fa-edit"></i> Update
                          </button>

                          <div class="modal fade" id="updateCategories<?= $value->id ?>" role="dialog" aria-hidden="true">
                            <div class="modal-dialog" role="document">
                              <div class="modal-content">
                                <div class="modal-header">
                                  <h5 class="modal-title font-weight-600" id="exampleModalLabel">Update  Categories</h5>
                                  <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                  </button>
                                </div>
                                <div class="modal-body py-5 px-4">
                                  <form method="post" action="#" enctype="multipart/form-data">
                                    <div class="form-group">
                                      <label class="control-label">Title <span class="required" aria-required="true">*</span></label>
                                      <input type="text" name="title" value="<?= $value->title ?>" class="form-control"  placeholder="Input Title" required="" aria-required="true">
                                      <input type="hidden" name="typeQuery" value="update">
                                      <input type="hidden" name="id" value="<?= $value->id ?>">
                                    </div>
                                    <div class="form-group">
                                      <label class="control-label">Select categories Product <span class="required" aria-required="true">*</span></label>
                                      <select name="categories[]" multiple data-plugin-selectTwo class="form-control populate" title="Please select Categories" required>
                                        <option value="">Choose a Categories</option>
                                        <?php foreach ($categories_list as $categories): ?>
                                          <option value="<?= $categories->id ?>"
                                            <?php
                                              $categories_update = json_decode($value->categories);
                                              if (is_array($categories_update)) {
                                                for ($i=0; $i < count($categories_update); $i++) {
                                                  if ($categories->id == $categories_update[$i]) {
                                                    echo "selected";
                                                  }
                                                }
                                              }
                                            ?>
                                            ><?= $categories->text ?></option>
                                        <?php endforeach ?>
                                      </select>
                                    </div>
                                    <div class="form-group text-right mt-5 pt-5">
                                      <button type="submit" class="btn btn-primary">
                                        <i class="fa fa-send"></i> Submit
                                      </button>
                                    </div>
                                  </form>
                                </div>
                              </div>
                            </div>
                          </div>

                          <button class="btn btn-danger" onclick="hapus('<?= $value->id ?>')">
                            <i class="fa fa-trash"></i> Delete
                          </button>
                        </td>
                      </tr>
                    <?php endforeach; ?>
                  </tbody>
                </table>
              </div>
            </section>
        </section>
    </div>
    </section>
  </div>
  <div class="modal fade" id="tambahCategories" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title font-weight-600" id="exampleModalLabel">Add Popular Categories</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body py-5 px-4">
          <form method="post" action="#" enctype="multipart/form-data">
            <div class="form-group">
              <label class="control-label">Title <span class="required" aria-required="true">*</span></label>
              <input type="text" name="title" class="form-control"  placeholder="Input Title" required="" aria-required="true">
            </div>
            <div class="form-group">
              <label class="control-label">Select categories Product <span class="required" aria-required="true">*</span></label>
              <input type="hidden" name="typeQuery" value="insert">
              <select name="categories[]" multiple data-plugin-selectTwo class="form-control populate" title="Please select Categories" required>
                <option value="">Choose a Categories</option>
                <?php foreach ($categories_list as $categories): ?>
                  <option value="<?= $categories->id ?>"><?= $categories->text ?></option>
                <?php endforeach ?>
              </select>
            </div>
            <div class="form-group text-right mt-5 pt-5">
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
    $img_example = revo_url().'/assets/extend/images/example_categories.jpg';
    include (plugin_dir_path( __FILE__ ).'partials/_modal_example.php'); 
    include (plugin_dir_path( __FILE__ ).'partials/_js.php'); 
  ?>

  <script>

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