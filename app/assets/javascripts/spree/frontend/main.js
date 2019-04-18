var page_visited = 0;
var timeout;




var lastScrollTop = 0;
var iScrollPos = 0;


$(window).scroll(function(e) {
    $cart = $('.cart-header');
    $cart.fadeOut() ;
    var widthWindow = $(window).width() ;
    st = $(this).scrollTop();
    var iCurScrollPos = $(this).scrollTop();

    if(st>50) {
        $('.scroll-top').addClass('active')
    } else {
        $('.scroll-top').removeClass('active')
    }

    if( widthWindow <= 1024 ) {
        if(iCurScrollPos < iScrollPos) {
            $('header').removeClass('mobileScroll') ;
        } else {
            $('header').addClass('mobileScroll') ;
        }
    }

    if ($(window).width() > 1239) {

        if (iCurScrollPos > iScrollPos) {
            $('.header').addClass('hidden-scroll') ;
        }
        else {
            if(iCurScrollPos == 0) {
                $('.header').removeClass('hidden-scroll') ;
            }
        }
    }


    iScrollPos = iCurScrollPos;


});

function openCart(){

    var widthWindow = $(window).width(),
        $cart = $('.cart-header');

    $cart.slideToggle(400, "linear");

    if( widthWindow <= 1024 ) {
        $cart.css('top', $('.header').height());
        $cart.css('right', 0);
    } else {
        if($('header').hasClass('hidden-scroll')) {
            $cart.css('top', $('.header').height());
            $cart.css('right', ($('.header-main-scrolled').outerWidth() - $('.header-main-scrolled').width()) / 2);
        } else {
            $cart.css('top', 35);
            $padding = ( ( $('.header-sub .wrapper').outerWidth() - $('.header-sub .wrapper').width() ) / 2) ;
            $cart.css('right', ($(document).width() - ($('.header-sub .wrapper').offset().left + $('.header-sub .wrapper').outerWidth())) + $padding) ;
        }
    }
}


function setup_select2(element){
    var $selected = $(element).find('option:selected');
    var $try = $(".try");
    var $container = $try.find("#div"+element.id).length ? $try.find("#div"+element.id) : $("<div id='div"+element.id+"'></div>").appendTo(".try");

    var $list = $('<ul>');
    $selected.each(function(k, v) {

        var $li = $('<li class="tag-selected">' + $(v).text() + '<a class="destroy-tag-selected">×</a></li>');
        $li.children('a.destroy-tag-selected')
            .off('click.select2-copy')
            .on('click.select2-copy', function(e) {

                var $opt = $(this).data('select2-opt');
                $opt.attr('selected', false);
                $opt.parents('select').trigger('change');
                $(this).parent("li").remove();
            }).data('select2-opt', $(v));
        $list.append($li);
    });
    $container.html('').append($list);


}
function setup_search_autocomplete(){

    $('.togglefilter select').on("select2-close", function() {
        $('.toggleaction').removeClass('active');
    });

    $('.toggleaction').click(function () {
        $('.toggleaction').removeClass('active');
        $(this).addClass('active');
        $selectId = $(this).siblings('.select-filter-container').first().children().first().attr('id') ;
        $selectId = $selectId.replace('s2id_', '');
        $('#' + $selectId ).select2("open");
    });

    $("#filters").find("select").each(function(i, e){
        console.log(e);
        $(e).select2({
            placeholder: $(this).attr('placeholder'),
            formatResult: function(c){console.log(c); return (c.text)},
            formatSelection: function(c){console.log(c); return (c.text)}

        });
        console.log($(e).attr("multiple"));
        if($(e).attr("multiple")=="multiple") {
            $(e).on("change", function (event) {
                if(! (typeof(event.added) == "undefined")){
                    if(event.added.id == ""){
                        $(this).val(null);
                    }
                }
                setup_select2(this);

            });
            setup_select2(e);
        }
    });

    $('#per_page_select').select2({
        placeholder: $(this).attr('placeholder'),
        dropdownCssClass: "number"
    });

    $('.order-filter select').select2({
            placeholder: $(this).attr('placeholder')
    });
    var changed = false;
    $("input.autocomplete:not(.ui-autocomplete-input)").autocomplete(
        {
            source: function(request, response) {
                $.ajax({
                    url: "/autocomplete",
                    data: {term: request.term},
                    dataType: "json",
                    success: function (data) {
                        response(data.products);
                    }
                })
            },
            select: function(event, ui) {
                $(this).val(ui.item.value);
                $(this).parents("form").submit();
            }
        });

    console.log($("input.autocomplete"));

}



function setup_range_input(){
    $(".input-range-min[type='checkbox']").change(function(event){
        $(this).parents("ul").find("[type='checkbox']").not($(this)).prop("checked", false);
        $(this).siblings("[type='checkbox']").prop("checked", $(this).prop("checked"));

        $(this).form().submit();


    });
    $("#per_page_select").change(function(e){
        $("#per_page").val($(this).val());
        $("#per_page").parents("form").submit();
    });

    $(".input-range").each(function(e) {
        var min = $(this).data('product-min');
        var max = $(this).data('product-max');
        var input_min = $(this).siblings(".input-range-min");
        var input_max = $(this).siblings(".input-range-max");

        $(this).slider({
            range: true,
            min: min,
            max: max,
            values: [logposition(parseInt(input_min.val()), min, max), logposition(parseInt(input_max.val()), min, max)],
            slide: function (event, ui) {
                if( $(this).data("log-sacle") == "true") {
                    var low = Math.round(expon(ui.values[0], min, max));
                    var high = Math.round(expon(ui.values[1], min, max));
                }
                else{
                    var low = ui.values[0];
                    var high = ui.values[1];

                }

                input_min.val(low);
                input_max.val(high);
            },
            change: function(event, ui){
                console.log($(this).data("remote"));
                if($(this).data("remote")){
                    var that = this;
                    submitIn2Seconds($(that).parents("form"));

                }
            }
        });


    });
}

// Fonctions pour que le slider de prix soit logarithmique
function expon(val, min, max){
    var minv = Math.log(min);
    if (minv < 0)
        minv = 0;
    var maxv = Math.log(max);
    var scale = (maxv-minv) / (max-min);
    return Math.exp(minv + scale*(val-min));
}

function logposition(val, min, max){
    var minv = Math.log(min);
    if (minv < 0)
        minv = 0;
    var maxv = Math.log(max);
    var scale = (maxv-minv) / (max-min);
    return (Math.log(val)-minv) / scale + min;
}
function submitIn2Seconds(form){
    clearTimeout(timeout);

    timeout = setTimeout(function(){
        form.submit();



    }, 500)

}
function setup_cart(){
    $cart = $('.cart-header');

    // Remove product
    $('#ajax_cart').on('click', 'a.delete-product', function(e) {
        e.preventDefault();

        var form = $("#update-cart");
        console.log("test");

        $(this).parents('.cart-products-list__single').find('input.line_item_quantity').val(0);
        $(this).html("<i class='fa fa-fw fa-refresh fa-spin'></i>");



        $.ajax({
            beforeSend : function(request)
            {
                request.setRequestHeader("Accept", "text/javascript");
            },
            data:  form.serializeArray(),
            type: 'POST',
            url: form.attr('action')
        });

    });



        // Open/Close cart
    $('.btn_cart').click(function(e){
        e.preventDefault();
        openCart() ;
    });

    $('.close-cart').click(function(e){
        e.preventDefault();
        $cart.slideUp(400);
    });
    //////////////////////////////
    // Cart

    var widthWindow = $(window).width(),
        heightWindow = $(window).height(),
        $cartButton = $('.cart_btn');

    $cart.hide() ;


    // Max height of products listing
    if( widthWindow <= 600 ) {

        var maxHeightCartProductList,
            $cartProductList = $('.cart-products-list'),
            heightMobileMenu = $('.mobile-menu').outerHeight(),
            heightCart = $cart.outerHeight(),
            heightCartProductList = $cartProductList.outerHeight();

        $cart.hide().css('right', 0);
        maxHeightCartProductList = heightWindow - ( heightMobileMenu + ( heightCart - heightCartProductList ) );
        $cartProductList.css( 'max-height', maxHeightCartProductList);

    }

}
function openCart(){


    var widthWindow = $(window).width(),
        $cart = $('.cart-header')

    $cart.slideToggle(400, "linear");

    if( widthWindow <= 1024 ) {
        $cart.css('top', $('.header').height());
        $cart.css('right', 0);
    } else {
        if($('header').hasClass('hidden-scroll')) {
            $cart.css('top', $('.header').height());
            $cart.css('right', ($('.header-main-scrolled').outerWidth() - $('.header-main-scrolled').width()) / 2);
        } else {
            $cart.css('top', 35);
            $padding = ( ( $('.header-sub .wrapper').outerWidth() - $('.header-sub .wrapper').width() ) / 2) ;
            $cart.css('right', ($(document).width() - ($('.header-sub .wrapper').offset().left + $('.header-sub .wrapper').outerWidth())) + $padding) ;
        }
    }

}

function setup_accordion(){

    $('.menu-title').click(function(){
        $currentMenuTitle = $(this);
        $(this).siblings('.menu-sidebar').slideToggle(function () {
            var check=$(this).is(":hidden");
            if(check == true) {
                $currentMenuTitle.addClass('closed').removeClass('open');
            } else  {
                $currentMenuTitle.removeClass('closed').addClass('open');
            }

        });
    });
    $(".filter_link_1").click(function(e){
        $(this).removeClass('open');
        //slide up all the link lists
        $(".nested-li ul ul").slideUp();
        //slide down the link list below the h3 clicked - only if its closed
        if(!$(this).next().is(":visible"))
        {
            $(this).next().slideDown();
            $(this).addClass('open');
        }

        e.preventDefault();
    });

    $("#accordian h3").click(function(){
        $(this).removeClass('open');
        //slide up all the link lists
        $("#accordian ul ul").slideUp();
        //slide down the link list below the h3 clicked - only if its closed
        if(!$(this).next().is(":visible"))
        {
            $(this).next().slideDown();
            $(this).addClass('open');
        }
    });

    $("#accordian h4").click(function(){
        $(this).removeClass('open');
        //slide up all the link lists
        $("#accordian ul ul ul").slideUp();
        //slide down the link list below the h3 clicked - only if its closed
        if(!$(this).next().is(":visible"))
        {
            $(this).next().slideDown();
            $(this).addClass('open');
        }
    });

    $("#accordian h5").click(function(){
        $(this).removeClass('open');
        //slide up all the link lists
        $("#accordian ul ul ul ul").slideUp();
        //slide down the link list below the h3 clicked - only if its closed
        if(!$(this).next().is(":visible"))
        {
            $(this).next().slideDown();
            $(this).addClass('open');
        }
    });

}

