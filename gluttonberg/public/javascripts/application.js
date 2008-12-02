var AssetBrowser = {
  overlay: null,
  dialog: null,
  load: function(p, link, markup) {
    // Set everthing up
    AssetBrowser.showOverlay();
    $("body").append(markup);
    AssetBrowser.browser = $("#assetsDialog");
    AssetBrowser.target = $("#" + $(link).attr("rel"));
    AssetBrowser.nameDisplay = p.find("strong");
    // Grab the various nodes we need
    AssetBrowser.display = AssetBrowser.browser.find("#assetsDisplay");
    AssetBrowser.offsets = AssetBrowser.browser.find("> *:not(#assetsDisplay)");
    AssetBrowser.backControl = AssetBrowser.browser.find("#back a");
    AssetBrowser.backControl.css({display: "none"});
    // Calculate the offsets
    AssetBrowser.offsetHeight = 0;
    AssetBrowser.offsets.each(function(i, element) {
      AssetBrowser.offsetHeight += $(element).outerHeight();
    });
    // Initialize
    AssetBrowser.resizeDisplay();
    $(window).resize(AssetBrowser.resizeDisplay);
    // Cancel button
    AssetBrowser.browser.find("#cancel").click(AssetBrowser.close);
    // Capture anchor clicks
    AssetBrowser.display.find("a").click(AssetBrowser.click);
    AssetBrowser.backControl.click(AssetBrowser.back);
  },
  resizeDisplay: function() {
    var newHeight = AssetBrowser.browser.innerHeight() - AssetBrowser.offsetHeight;
    AssetBrowser.display.height(newHeight);
  },
  showOverlay: function() {
    if (!AssetBrowser.overlay) {
      AssetBrowser.overlay = $('<div id="assetsDialogOverlay">&nbsp</div>');
      $("body").append(AssetBrowser.overlay);
    }
    else {
      AssetBrowser.overlay.css({display: "block"});
    }
  },
  close: function() {
    AssetBrowser.overlay.css({display: "none"});
    AssetBrowser.browser.remove();
  },
  handleJSON: function(json) {
    if (json.backURL) {
      AssetBrowser.backURL = json.backURL;
      AssetBrowser.backControl.css({display: "block"});
    }
    AssetBrowser.updateDisplay(json.markup);
  },
  updateDisplay: function(markup) {
    AssetBrowser.display.html(markup);
    AssetBrowser.display.find("a").click(AssetBrowser.click);
  },
  click: function() {
    var target = $(this);
    if (target.is(".assetLink")) {
      var id = target.attr("href").match(/\d+$/);
      console.log(AssetBrowser.target[0])
      AssetBrowser.target.attr("value", id);
      var name = target.find("h2").html();
      AssetBrowser.nameDisplay.html(name);
      AssetBrowser.close();
    }
    else if (target.is("#previous") || target.is("#next")) {
      if (target.attr("href") != '') {
        $.getJSON(target.attr("href") + ".json", null, AssetBrowserEx.handleJSON);
      }
    }
    else {
      $.getJSON(target.attr("href") + ".json", null, AssetBrowser.handleJSON);
    }
    return false;
  },
  back: function() {
    if (AssetBrowser.backURL) {
      $.get(AssetBrowser.backURL, null, AssetBrowser.updateDisplay);
      AssetBrowser.backURL = null;
      AssetBrowser.backControl.css({display: "none"});
    }
    return false;
  }
};

var AssetBrowserEx = {
  overlay: null,
  dialog: null,
  rootPageUrl: null,
  onAssetSelect: null,
  show: function(){
    // display the dialog and do it's stuff
    var self = this;
    $("body").append('<div id="asset_load_point">&nbsp</div>');
   //  $.get(this.root_page_url, null, function(markup){
   $("#asset_load_point").load(this.rootPageUrl + ' #assetsDialog', null, function(){
      //$("body").append(markup);
      self.load();
    });

  },
  load: function(/*p, link, markup */) {
    var self = this;
    // Set everthing up
    this.showOverlay();
    
    this.browser = $("#assetsDialog");

    // Grab the various nodes we need
    this.display = this.browser.find("#assetsDisplay");
    // $("#assetsDialog").dialog({height: 500, width: 500});
    //$('#assetsDialog').jqm({modal: true});
    //$.jqmShow();
    this.offsets = this.browser.find("> *:not(#assetsDisplay)");
    this.backControl = this.browser.find("#back a");
    this.backControl.css({display: "none"});
    // Calculate the offsets
    this.offsetHeight = 0;
    this.offsets.each(function(i, element) {
      self.offsetHeight += $(element).outerHeight();
    });
    // Initialize
    this.resizeDisplay();
    $(window).resize(this.resizeDisplay);
    $(window).scroll(this.resizeDisplay);
    // Cancel button
    this.browser.find("#cancel").click(this.close);
    // Capture anchor clicks
    this.display.find("a").click(this.click);
    this.backControl.click(this.back);
  },
  resizeDisplay: function() {
    var newHeight = AssetBrowserEx.browser.innerHeight() - AssetBrowserEx.offsetHeight;
    AssetBrowserEx.display.height(newHeight);
  },
  getScrollXY: function() {
    var scrOfX = 0, scrOfY = 0;
    if( typeof( window.pageYOffset ) == 'number' ) {
      //Netscape compliant
      scrOfY = window.pageYOffset;
      scrOfX = window.pageXOffset;
    } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
      //DOM compliant
      scrOfY = document.body.scrollTop;
      scrOfX = document.body.scrollLeft;
    } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
      //IE6 standards compliant mode
      scrOfY = document.documentElement.scrollTop;
      scrOfX = document.documentElement.scrollLeft;
    }
    return [ scrOfX, scrOfY ];
  },
  showOverlay: function() {
    if (!AssetBrowserEx.overlay) {
      AssetBrowserEx.overlay = $('<div id="assetsDialogOverlay">&nbsp</div>');
      $("body").append(AssetBrowserEx.overlay);
    }
    else {
      AssetBrowserEx.overlay.css({display: "block"});
    }
  },
  close: function() {
    AssetBrowserEx.overlay.css({display: "none"});
    AssetBrowserEx.browser.remove();
  },
  handleJSON: function(json) {
    if (json.backURL) {
      AssetBrowserEx.backURL = json.backURL;
      AssetBrowserEx.backControl.css({display: "block"});
    }
    AssetBrowserEx.updateDisplay(json.markup);
  },
  updateDisplay: function(markup) {
    AssetBrowserEx.display.html(markup);
    AssetBrowserEx.display.find("a").click(AssetBrowserEx.click);
  },
  click: function() {
    // "this" is the item being clicked!
    var target = $(this);
    if (target.is(".assetLink")) {
      var id = target.attr("href").match(/\d+$/);
      AssetBrowserEx.onAssetSelect(id);
      AssetBrowserEx.close();
    }
    else if (target.is("#previous") || target.is("#next")) {
      if (target.attr("href") != '') {
        $.getJSON(target.attr("href") + ".json", null, AssetBrowserEx.handleJSON);
      }
    }
    else {
      $.getJSON(target.attr("href") + ".json", null, AssetBrowserEx.handleJSON);
    }
    return false;
  },
  back: function() {
    if (AssetBrowserEx.backURL) {
      $.get(AssetBrowserEx.backURL, null, AssetBrowserEx.updateDisplay);
      AssetBrowserEx.backURL = null;
      AssetBrowserEx.backControl.css({display: "none"});
    }
    return false;
  }
};

// Displays the Asset Browser popup. This allows the user to select an asset from the asset library
//   @config.rootUrl = The url to retieve the HTML for rendering the root library page (showing collections and asset types)
//   @config.onSelect = the function to execute when somone clicks an asset
function showAssetBrowser(config){
  AssetBrowserEx.rootPageUrl = config.rootUrl;
  AssetBrowserEx.onAssetSelect = config.onSelect;
  AssetBrowserEx.show();
}

function writeAssetToField(fieldId){
  field = $("#" + fieldId);
  field.attr("value", id);
}

function writeAssetToAssetCollection(assetId, assetCollectionUrl){
 $.ajax({
   type: "POST",
   url: assetCollectionUrl,
   data: "asset_id=" + assetId,
   success: function(){
     window.location.reload();
   },
   error: function(){
     alert('Adding the Asset failed, sorry.');
     window.location.reload();
   }
 });
}

DM_NONE          = null;
DM_INSERT_BEFORE = {};
DM_INSERT_AFTER  = {};
DM_INSERT_CHILD  = {};

var PageOrganiser = {
  init: function(){
    var po = this;
    var dragManager = {
      dropSite: null,
      dragMode: DM_NONE
    };

    $("#pages_table").treeTable({
	    expandable: false
    });

    // Configure draggable rows
    $("#pages_table .page-node").draggable({
      helper: "clone",
      opacity: .75,
      revert: "invalid",
      revertDuration: 300,
      scroll: true,
      drag: function(e, ui){
        if (dragManager.dropSite) {
          var top = dragManager.dropSite.offset({padding: true, border: true, margin: true}).top;
          var height = dragManager.dropSite.outerHeight({padding: false, border: false, margin: true});
          var mouseTop = e.pageY;
          if (mouseTop < (top + 10)){
            dragManager.dropSite.addClass("insert_before").removeClass("insert_child insert_after");
            dragManager.dragMode = DM_INSERT_BEFORE;
          } else if (mouseTop > (top + height - 4)) {
            dragManager.dropSite.addClass("insert_after").removeClass("insert_before insert_child");
            dragManager.dragMode = DM_INSERT_AFTER;
          } else {
            dragManager.dropSite.addClass("insert_child").removeClass("insert_after insert_before");
            dragManager.dragMode = DM_INSERT_CHILD;
          }
        }
      }
    });

    // Configure droppable rows
    $("#pages_table .page-node").each(function() {
      $(this).parents("tr").droppable({
        accept: ".page-node:not(selected)",
        drop: function(e, ui) {
          var sourceNode = $(ui.draggable).parents("tr")
          var targetNode = this;

          if (dragManager.dragMode == DM_INSERT_CHILD) {
            $(sourceNode).appendBranchTo(targetNode,
              function(){
                po.remote_move_node(sourceNode, targetNode, 'INSERT');
              }
            );                        
          }
          if (dragManager.dragMode == DM_INSERT_BEFORE) {
            $(sourceNode).insertBranchBefore(targetNode,
              function(){
                po.remote_move_node(sourceNode, targetNode, 'BEFORE');
              }
            );
          }
          if (dragManager.dragMode == DM_INSERT_AFTER) {
            $(sourceNode).insertBranchAfter(targetNode,
              function(){
                po.remote_move_node(sourceNode, targetNode, 'AFTER');
              }
            );
          }

          $(sourceNode).effect("highlight", {}, 2000);
          $("#pages_table").find("tr").removeClass("insert_child insert_before insert_after");
          dragManager.dropSite = null;
          dragManager.dragMode = DM_NONE;
        },
        hoverClass: "accept",
        over: function(e, ui) {
          if (ui.draggable.parents("tr") != dragManager.dropSite) {
            dragManager.dropSite = ui.element;
          }
          // Make the droppable branch expand when a draggable node is moved over it.
          if(this.id != ui.draggable.parents("tr")[0].id && !$(this).is(".expanded")) {
            $(this).expand();
          }
        },
        out: function(e, ui){
          ui.element.removeClass("insert_child insert_before insert_after");
          if (dragManager.dropSite == ui.element) {            
            dragManager.dropSite = null;
            dragManager.dragMode = DM_NONE;
          }
        }
      });
    });

    // Make visible that a row is clicked
    $("table#pages_table tbody tr").mousedown(function() {
      $("tr.selected").removeClass("selected"); // Deselect currently selected rows
      $(this).addClass("selected");
    });

    // Make sure row is selected when span is clicked
    $("table#pages_table tbody tr span").mousedown(function() {
      $($(this).parents("tr")[0]).trigger("mousedown");
    });

  },
  remote_move_node: function(source, destination, mode){
    $.ajax({
      type: "POST",
      url: $("#pages_table").attr("rel"),
      data: "source_page_id=" + source[0].id.match(/\d+$/) + ";dest_page_id=" + destination.id.match(/\d+$/) + ";mode=" + mode,      
      error: function(){
        alert('Moving page failed.');
        window.location.reload();
      }
    });
  }
}

$(document).ready(function() {
  // Temporary hack called by old Asset Browser code until it is updated to
  // use the new code
  $("#wrapper .assetBrowserLink").click(function() {
    var p = $(this);
    var link = p.find("a");
    $.get(link.attr("href"), null, function(markup) {AssetBrowser.load(p, link, markup);});
    return false;
  });
  
  
  $("#templateSections").click(function(e) {
    var target = $(e.target);
    if (target.is("a")) {
      // Ewwww, heaps dodgy
      var entry = target.parent().parent().parent();
      if (target.hasClass("plus")) {
        // Set the index on these correctly. Use a regex to find the number in the ID and increment it.
        // Do the same for all the following entries.
        var clonedEntry = entry.clone();
        clonedEntry.find("input").val("");
        clonedEntry.insertAfter(entry);
      }
      else {
        entry.remove();
      }
      return false;
    }
  });

  PageOrganiser.init();
});