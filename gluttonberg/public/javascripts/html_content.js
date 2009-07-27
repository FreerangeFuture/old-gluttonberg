function enable_tinyMCE_on(ids)
{
tinyMCE.init({
                // General options
                mode : "exact",
                elements : ids,
                theme : "advanced",
                plugins : "safari,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",

                // Theme options
                theme_advanced_buttons1 : "fullscreen,|,cleanup,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,styleselect,|,bullist,numlist,|,blockquote,|,sub,sup,",
                theme_advanced_buttons2 : "search,replace,|,undo,redo,|,link,unlink,anchor,|,tablecontrols",
                theme_advanced_buttons3 : "",
                theme_advanced_toolbar_location : "top",
                theme_advanced_toolbar_align : "left",
                theme_advanced_statusbar_location : "bottom",
                theme_advanced_resizing : true,
               
                content_css : "/stylesheets/user-styles.css",
        });
        
 }    