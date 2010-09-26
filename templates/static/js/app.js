function toggle_tag_list() {
    $('#alpha').bind( 'click', 
        function(){ 
            $('#alpha').addClass("selected");
            $('#freq').removeClass("selected");
            sort_tags('#alpha');
        } 
    );
    $('#freq').bind( 'click', 
        function(){ 
            $('#freq').addClass("selected");
            $('#alpha').removeClass("selected");
            sort_tags('#freq');
        } 
    );
}

function sort_tags(field) {
    $.post( '/Ajax/sort_by',  
        { field: field },
        function(data){
            $('#tag_list').html(data);
        }
    );
}

function check_articles(field) {
    if ((field.value.length > 0 && field.value.length < 3) || field.value.length==0 ) {
        $('#search_board').css('display','none');
        return;
    }
    $.post( '/Ajax/check_articles',  
        { field: field.value },
        function(data) {
            $('#search_board').css( 'display', "block" );
            $('#search_board').html( data );
        }
    );
}



