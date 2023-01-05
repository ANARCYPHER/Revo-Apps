<?php 

  require (plugin_dir_path( __FILE__ ).'../helper.php');
  
  if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $isProductItem = $_POST['directtype'] == 'Product' ? true : false;
    
    if (@$_POST["typeQuery"] == 'insert') {

      if(@$_POST["jenis"] == 'file' || @$_POST["jenis"] == 'link') {

        $alert = array(
            'type' => 'error', 
            'title' => 'Query Error !',
            'message' => 'Failed to Add Data Slider', 
        );

        $images_url = '';

        if ($_POST["jenis"] == 'file') {
            $uploads_url = WP_CONTENT_URL."/uploads/revo/";
            $target_dir = WP_CONTENT_DIR."/uploads/revo/";
            $target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
            $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
            $newname =  md5(date("Y-m-d H:i:s")) . "." . $imageFileType;
            $is_upload_error = 0;
            if($_FILES["fileToUpload"]["size"] > 0){

                if ($_FILES["fileToUpload"]["size"] > 2000000) {
                  $alert = array(
                    'type' => 'error', 
                    'title' => 'Uploads Error !',
                    'message' => 'your file is too large. max 2Mb', 
                  );
                  $is_upload_error = 1;
                }

                if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg" ) {
                  $alert = array(
                    'type' => 'error', 
                    'title' => 'Uploads Error !',
                    'message' => 'only JPG, JPEG & PNG files are allowed.', 
                  );
                  $is_upload_error = 1;
                }

                if ($is_upload_error == 0) {
                  if ($_FILES["fileToUpload"]["size"] > 500000) {
                    compress($_FILES["fileToUpload"]["tmp_name"],$target_dir.$newname,90);
                    $images_url = $uploads_url.$newname;
                  }else{
                    move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_dir.$newname);
                    $images_url = $uploads_url.$newname;
                  }
                }
            }
        }else{
          $images_url = $_POST['url_link'];
        }

        if ($images_url != '') {

          switch ($_POST['directtype']) {
            case 'Category':
              $product_name = "cat|".get_categorys_detail($_POST['idproduct'])[0]->name;
              break;
            case 'Blog':
                $product_name = "blog|".get_post($_POST['idproduct'])->post_title;
              break;
            default:
                $product_name = get_product_varian_detail($_POST['idproduct'])[0]->get_title();
              break;
          }
          
          $wpdb->insert('revo_mobile_slider',                  
          [
            'order_by' => $_POST['order_by'],
            'product_id' => $_POST['idproduct'],
            'title' => $_POST['title'],
            'product_name' => $product_name,
            'images_url' => $images_url 
          ],[
              '%s',
              '%d',
              '%s',
              '%s',
              '%s'
          ]);

          if (@$wpdb->insert_id > 0) {
            $alert = array(
              'type' => 'success', 
              'title' => 'Success !',
              'message' => 'Slider Success Saved', 
            );
          }
        }

        $_SESSION["alert"] = $alert;
        
      }

    }elseif (@$_POST["typeQuery"] == 'update') {

      if(@$_POST["jenis"] == 'file' || @$_POST["jenis"] == 'link') {
        
        switch ($_POST['directtype']) {
          case 'Category':
            $product_name = "cat|".get_categorys_detail($_POST['idproduct'])[0]->name;
            break;
          case 'Blog':
              $product_name = "blog|".get_post($_POST['idproduct'])->post_title;
            break;
          default:
              $product_name = get_product_varian_detail($_POST['idproduct'])[0]->get_title();
            break;
        }

        $product = get_product_varian_detail($_POST['idproduct']);
        
        $dataUpdate = array(
                        'order_by' => $_POST['order_by'],
                        'product_id' => $_POST['idproduct'],
                        'title' => $_POST['title'],
                        'product_name' => $product_name,
                    );

        $where = array('id' => $_POST['id']);

        $alert = array(
            'type' => 'error', 
            'title' => 'Query Error !',
            'message' => 'Failed to Update Slider '.$_POST['title'], 
        );

        $images_url = '';

        if ($_POST["jenis"] == 'file') {
            $uploads_url = WP_CONTENT_URL."/uploads/revo/";
            $target_dir = WP_CONTENT_DIR."/uploads/revo/";
            $target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
            $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
            $newname =  md5(date("Y-m-d H:i:s")) . "." . $imageFileType;
            $is_upload_error = 0;
            if($_FILES["fileToUpload"]["size"] > 0){

                if ($_FILES["fileToUpload"]["size"] > 2000000) {
                  $alert = array(
                    'type' => 'error', 
                    'title' => 'Uploads Error !',
                    'message' => 'your file is too large. max 2Mb', 
                  );
                  $is_upload_error = 1;
                }

                if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg" ) {
                  $alert = array(
                    'type' => 'error', 
                    'title' => 'Uploads Error !',
                    'message' => 'only JPG, JPEG & PNG files are allowed.', 
                  );
                  $is_upload_error = 1;
                }

                if ($is_upload_error == 0) {
                  if ($_FILES["fileToUpload"]["size"] > 500000) {
                    
                    compress($_FILES["fileToUpload"]["tmp_name"],$target_dir.$newname,90);
                    $dataUpdate['images_url'] = $uploads_url.$newname; 

                  }else{

                    move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_dir.$newname);
                    $dataUpdate['images_url'] = $uploads_url.$newname; 

                  }
                }
            }

        }else{

          $dataUpdate['images_url'] = $_POST['url_link']; 

        }

        $wpdb->update('revo_mobile_slider',$dataUpdate,$where);
        
        if (@$wpdb->show_errors == false) {
          $alert = array(
            'type' => 'success', 
            'title' => 'Success !',
            'message' => 'Slider '.$_POST['title'].' Success Updated', 
          );
        }

        $_SESSION["alert"] = $alert;
        
      }

    }elseif (@$_POST["typeQuery"] == 'hapus') {
        header('Content-type: application/json');

        $query = $wpdb->update( 
              'revo_mobile_slider', ['is_deleted' =>  '1'], 
              array( 'id' => $_POST['id']), 
              array( '%s'), 
              array( '%d' ) 
            );

        $alert = array(
            'type' => 'error', 
            'title' => 'Query Error !',
            'message' => 'Failed to Delete  Slider', 
        );

        if ($query) {
          $alert = array(
            'type' => 'success', 
            'title' => 'Success !',
            'message' => 'Slider Success Deleted', 
          );
        }

        $_SESSION["alert"] = $alert;

        http_response_code(200);
        return json_encode(['kode' => 'S']);
        die();
    }

  }

  $data_banner = $wpdb->get_results("SELECT * FROM revo_mobile_slider WHERE is_deleted = 0", OBJECT);

  $product_list = json_decode(get_product_varian());
  $categories = json_decode(get_categorys());
  // $blogs = array_map(function($v){
  //       return [
  //           'id'=>$v['ID'],
  //           'text'=>$v['post_title']
  //           ];
  //   },get_posts_fields(['fields' => array('ID','post_title')
  // ],ARRAY_A));

  $product_list = json_decode(get_product_varian());
?>

<!doctype html>
<html class="fixed">
<?php include (plugin_dir_path( __FILE__ ).'partials/_css.php'); ?>
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

              <section role="main" class="content-body p-0 pl-0">
                  <div class="panel-body">
                    <div class="row mb-2">
                      <div class="col-6 text-left">
                        <h4>
                          Sliding Banner <?php echo buttonQuestion() ?>
                        </h4>
                      </div>
                      <div class="col-6 text-right">
                        <button class="btn btn-primary"  data-toggle="modal" data-target="#tambahSlider">
                          <i class="fa fa-plus"></i> Add Slider
                        </button>
                      </div>
                    </div>
                    <table class="table table-bordered table-striped mb-none" id="datatable-default">
                      <thead>
                        <tr>
                          <th>Sort</th>
                          <th>Title Slider</th>
                          <th>Image</th>
                          <th>Link To</th>
                          <th class="hidden-xs">Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        <?php 
                        foreach ($data_banner as $key => $value): ?>
                          <?php
                            $xplode = explode("|",$value->product_name);
                            $is_product = $xplode[0] == 'cat' || $xplode[0] == 'blog' ? false : true;
                            $is_blog = $xplode[0] == 'blog' ? true : false;
                            $indexIP = $is_product ? 0 : 1;
                            $title_item = $is_product ? "Product" : ($is_blog ? "Blog" : "Category"); 
                          ?>
                          <tr>
                            <td><?php echo $value->order_by ?></td>
                            <td><?php echo $value->title ?></td>
                            <td>
                              <img src="<?php echo $value->images_url ?>" class="img-fluid" style="width: 100px">
                            </td>
                            <!-- <td><?php echo $value->product_name ?></td> -->
                            <td>
                              <?= "<strong>$title_item</strong> : $xplode[$indexIP]" ?>
                            </td>
                            <td>
                              <button class="btn btn-primary"  data-toggle="modal" data-target="#updateSlider<?php echo $value->id ?>">
                                <i class="fa fa-edit"></i> Update
                              </button>
                                  <div class="modal fade" id="updateSlider<?php echo $value->id ?>" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
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
                                                  <label class="col-sm-4 pl-0 control-label">Title Slider <span class="required" aria-required="true">*</span></label>
                                                  <div class="col-sm-8">
                                                    <input type="text" name="title" class="form-control" title="Please enter a name." placeholder="ex.: Slider Main" required="" value="<?php echo $value->title ?>" aria-required="true">
                                                  </div>
                                                </div>
                                                <div class="form-group">
                                                <label class="col-sm-4 pl-0 control-label">Link To <span class="required" aria-required="true">*</span></label>
                                                <div class="col-sm-8">
                                                  <div class="d-flex">
                                                    <div class="radio-custom radio-primary mr-2">
                                                      <input id="directToPrdct<?= $value->id ?>" onchange="directType(event)" name="directtype" type="radio" value="Product" <?= $title_item=='Product' ? 'checked' : '' ?>>
                                                      <label class="font-size-14" for="directToPrdct<?= $value->id ?>">Product</label>
                                                    </div>
                                                    <div class="radio-custom radio-primary mr-2">
                                                      <input id="directToCat" onchange="directType(event)" name="directtype" type="radio" value="Category" <?php  echo $title_item=='Category' ? 'checked' : '' ?>>
                                                      <label class="font-size-14" for="directToCat<?php echo $value->id ?>">Category</label>
                                                    </div>
                                                    <!-- <div class="radio-custom radio-primary mb-2">
                                                      <input id="directToBlog<?= $value->id ?>" onchange="directType(event)" name="directtype" type="radio" value="Blog" <?= $title_item=='Blog' ? 'checked' : '' ?>>
                                                      <label class="font-size-14" for="directToBlog<?= $value->id ?>">Blog</label>
                                                    </div> -->
                                                  </div>
                                                </div>
                                              </div>
                                              <div class="form-group">
                                                <label class="col-sm-4 pl-0 control-label">
                                                    <!-- Link To Product
                                                    <span class="required" aria-required="true">*</span> -->
                                                </label>
                                                <div class="col-sm-8">
                                                  <select id="states" selectedid="<?= $value->product_id ?>" is-product="<?= $is_product ? 'true' : 'false' ?>" val-type="<?= $title_item ?>" name="idproduct" data-plugin-selectTwo class="form-control populate" title="Please select Product" required>
                                                      <option value="">Choose a Product</option>
                                                      <?php foreach ($product_list as $product): ?>
                                                        <option value="<?php echo $product->id ?>" <?php echo $value->product_id == $product->id ? 'selected' : '' ?>><?php echo $product->text ?></option>
                                                      <?php endforeach ?>
                                                    </select>
                                                  </div>
                                                </div>
                                                <div class="form-group">
                                                  <label class="col-sm-4 pl-0 control-label">Sort to <span class="required" aria-required="true">*</span></label>
                                                  <div class="col-sm-8">
                                                    <input type="number" value="<?php echo $value->order_by ?>" name="order_by" class="form-control"  placeholder="Number Only" required="" aria-required="true">
                                                    <input type="hidden" value="<?php echo $value->id ?>" name="id" required>
                                                  </div>
                                                </div>
                                                <div class="form-group">
                                                  <label class="col-sm-4 pl-0 control-label">Type Image Banner <span class="required" aria-required="true">*</span></label>
                                                  <div class="col-sm-8">
                                                    <div class="d-flex">
                                                      <div class="radio-custom radio-primary mr-4">
                                                        <input id="link<?php echo $value->id ?>" BannerID="<?php echo $value->id ?>" class="updateFile" name="jenis" type="radio" value="link" checked>
                                                        <label class="font-size-14" for="link<?php echo $value->id ?>">Link / URL</label>
                                                      </div>
                                                      <div class="radio-custom radio-primary mb-2">
                                                        <input id="uploadsImage<?php echo $value->id ?>" BannerID="<?php echo $value->id ?>" class="updateFile" name="jenis" type="radio" value="file">
                                                        <label class="font-size-14" for="uploadsImage<?php echo $value->id ?>">Upload Image</label>
                                                      </div>
                                                    </div>
                                                  </div>
                                                </div>
                                                <div class="form-group">
                                                  <label class="col-sm-4 pl-0 control-label">Select Image <span class="required" aria-required="true">*</span></label>
                                                  <div class="col-sm-8">
                                                    <input type="hidden" name="typeQuery" value="update">
                                                    <input type="text" name="url_link" class="form-control" id="linkInput<?php echo $value->id ?>" placeholder="eg.: google.co.id/slider.jpeg" value="<?php echo $value->images_url ?>" required>
                                                    <input type="file" name="fileToUpload" class="form-control" id="fileinput<?php echo $value->id ?>" style="display: none;">
                                                    <img src="<?php echo $value->images_url ?>" class="img-fluid my-2" style="width: 100px">
                                                    <p class="mb-0 mt-2" style="line-height: 15px">
                                                      <small class="text-danger">Best Size : 1050 x 425 px</small> <br>
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
                              <button class="btn btn-danger" onclick="hapus('<?php echo $value->id ?>')">
                                <i class="fa fa-trash"></i> Delete
                              </button>
                            </td>
                          </tr>
                        <?php 
                          endforeach;
                          if (!empty($data_banner)) {
                            $key = $key + 2;
                          }else{
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
  <div class="modal fade" id="tambahSlider" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title font-weight-600" id="exampleModalLabel">Add Sliding Banner</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <form method="post" action="#" enctype="multipart/form-data">
              <div class="panel-body">
                <div class="form-group">
                  <label class="col-sm-4 pl-0 control-label">Title Slider <span class="required" aria-required="true">*</span></label>
                  <div class="col-sm-8">
                    <input type="text" name="title" class="form-control" title="Please enter a name." placeholder="ex.: Slider Main" required="" aria-required="true">
                  </div>
                </div>
                <div class="form-group">
                <label class="col-sm-4 pl-0 control-label">Link To <span class="required" aria-required="true">*</span></label>
                  <div class="col-sm-8">
                    <div class="d-flex">
                      <div class="radio-custom radio-primary mr-4">
                        <input id="directToPrdct" onchange="directType(event)" name="directtype" type="radio" value="Product">
                        <label class="font-size-14" for="directToPrdct">Product</label>
                      </div>
                      <div class="radio-custom radio-primary mb-2">
                        <input id="directToCat" onchange="directType(event)" name="directtype" type="radio" value="Category">
                        <label class="font-size-14" for="directToCat">Category</label>
                      </div>
                      <!-- <div class="radio-custom radio-primary mb-2">
                        <input id="directToBlog" onchange="directType(event)" name="directtype" type="radio" value="Blog">
                        <label class="font-size-14" for="directToBlog">Blog</label>
                      </div> -->
                    </div>
                  </div>
                </div>
                <div class="form-group">
                  <label class="col-sm-4 pl-0 control-label">
                      <!-- Link To Product
                      <span class="required" aria-required="true">*</span> -->
                  </label>
                  <div class="col-sm-8">
                    <input type="hidden" name="typeQuery" value="insert">
                    <select id="states" name="idproduct" data-plugin-selectTwo class="form-control populate" title="Please select Product" required>
                      <option value="">Choose a Product</option>
                      <?php foreach ($product_list as $product): ?>
                        <option value="<?php echo $product->id ?>"><?php echo $product->text ?></option>
                      <?php endforeach ?>
                    </select>
                  </div>
                </div>
                <div class="form-group">
                  <label class="col-sm-4 pl-0 control-label">Sort to <span class="required" aria-required="true">*</span></label>
                  <div class="col-sm-8">
                    <input type="number" value="<?php echo $key ?>" name="order_by" class="form-control"  placeholder="Number Only" required="" aria-required="true">
                  </div>
                </div>
                <div class="form-group">
                  <label class="col-sm-4 pl-0 control-label">Type Image Banner <span class="required" aria-required="true">*</span></label>
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
                    <input type="text" name="url_link" class="form-control" id="linkInput" placeholder="eg.: google.co.id/slider.jpeg" required>
                    <input type="file" name="fileToUpload" class="form-control" id="fileinput" style="display: none;">
                    <p class="mb-0 mt-2" style="line-height: 15px">
                      <small class="text-danger">Best Size : 1050 x 425 px</small> <br>
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
    $img_example = revo_url().'/assets/extend/images/example_slider.jpg';
    include (plugin_dir_path( __FILE__ ).'partials/_modal_example.php'); 
    include (plugin_dir_path( __FILE__ ).'partials/_js.php'); 
  ?>
  <script type="text/javascript">
    selectItem = $('select.populate');

    $.each(selectItem,function (i,selectEl) {
      const Ele = $(selectEl);
      const param = Ele.attr('val-type');
      toggleValue(Ele,param)
    })

    function directType(e) {
      const target = $(e.target)
      const directType = target.parents('.modal-body').find('input[name=directtype]:checked');
      const selectOpt = target.parents('.modal-body').find('#states');
      const param = directType.val();
      toggleValue(selectOpt,param);
    }

    function toggleValue(element,param) {
      if (param == 'Product') {
        items = JSON.parse(`<?= json_encode($product_list) ?>`);
      }else if(param == 'Blog'){
        items = JSON.parse(`<?= json_encode($blogs) ?>`);
      }else if(param == 'Category'){
        items = JSON.parse(`<?= json_encode($categories) ?>`);
      }
      
      let content = `<option value="">Choose a ${param}</option>`;
      items.forEach(item => {
        let check = element.attr('selectedid') == item.id;
        content += `<option value="${item.id}" ${check ? 'selected' : '' }>${item.text}</option>`;
      });
      element.html(content);
      element.select2();
    }

    function clickedEditModal(e) {
      e.preventDefault()
      const target = $(e.target)
      const modalBody = $(target.attr('data-target')).find('.modal-body')
      const selectOpt = modalBody.find('#states');
      const param = selectOpt.attr('val-type');
      toggleValue(modalBody.find('select.populate'),param);
    }

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