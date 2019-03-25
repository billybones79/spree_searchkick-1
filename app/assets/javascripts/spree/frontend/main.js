var page_visited = 0;
var timeout;
SITENAME = {
    common: {
        init: function() {



            //setup_range_input();
            //setup_accordion();

            /* Refonte */


            $('#toggleview').click(function(){
                if($(this).hasClass('grid')) {
                    $(this).find('.font-icon').removeClass('icon-mc-grid').addClass('icon-mc-list');
                    $(this).find('span').html('liste');
                    $(this).removeClass('grid').addClass('liste');

                    $('.products-list').removeClass('cols-1-860 cols-1-800 cols-1-640 cols-1-480').addClass('cols-2-860 cols-2-800 cols-2-640 cols-2-480');
                    $('.products-list .single-product').removeClass('liste').addClass('grid');
                } else {
                    $(this).find('.font-icon').removeClass('icon-mc-list').addClass('icon-mc-grid');
                    $(this).find('span').html('grille');
                    $(this).removeClass('liste').addClass('grid');

                    $('.products-list').removeClass('cols-2-860 cols-2-800 cols-2-640 cols-2-480').addClass('cols-1-860 cols-1-800 cols-1-640 cols-1-480');
                    $('.products-list .single-product').removeClass('grid').addClass('liste');
                }

            });



            $('#togglefilter').click(function(){
                $('.filter-toggle .article-title').trigger('click') ;
            });


            $('.scroll-top').click(function(){
                $('.header').removeClass('mobileScroll') ;
                $('.header').removeClass('hidden-scroll') ;
                $('.scroll-top').removeClass('active')
                $("html, body").animate({ scrollTop: 0 }, "500");
                return false;
            });


            $('.menu-mobile-container').css('padding-top',$('header').height());


            $('body').on('mousewheel', function(e){



            });

            $('.open-form-scrolled').on('click', function(){
                $('html').toggleClass('no-scroll');
                if ( $('.scrolled-form').hasClass('open') ) {
                    $('.scrolled-form').removeClass('open', 500) ;
                }
                else {
                    $('.scrolled-form').addClass('open') ;
                    $('.scrolled-form > form > input[type="search"]').focus();
                }
            });

            $('.scrolled-form').on('click keyup', function(event) {
                $('html').toggleClass('no-scroll');
                if (event.target == this || event.keyCode == 27) {
                    $(this).removeClass('open');
                }
            });



            var Accordion = function(el, multiple) {
                this.el = el || {};
                this.multiple = multiple || false;

                var links = this.el.find('.article-title');
                links.on('click', {
                    el: this.el,
                    multiple: this.multiple
                }, this.dropdown)
            };

            Accordion.prototype.dropdown = function(e) {
                var $el = e.data.el;
                $this = $(this),
                    $next = $this.next();

                $next.slideToggle();
                $this.parent().toggleClass('open');

                if (!e.data.multiple) {
                    $el.find('.accordion-content').not($next).slideUp().parent().removeClass('open');
                };
            };
            var accordion = new Accordion($('.accordion-container'), false);


            var $window = $(window);

            /* End Refonte */

            $(".change_format").click(function(){
                $("#products").toggleClass("width-1");
            });
            $(".accordion_open").click(function(e){
                $(this).parent().children("ul").children("li").toggleClass("hidden");
            });


            $( 'select.cs-select-store' ).change(
                function(e) {
                    var val = $(e.target).val();
                    if (val == "" || val <= 0) {
                        $(".accordeon-group.accordeon-stores").show();
                    }
                    else {
                        $(".accordeon-stores.accordeon-group").hide();
                        var stores = $("[data-store=" + val + "]");

                        stores.show();
                    }
                }
            );

            $( 'select.cs-select-domain' ).change(
                function(e) {
                    var val = $(e.target).val();
                    if (val == "" || val <= 0) {
                        $(".accordeon-group.accordeon-domains").show();
                    }
                    else {
                        $(".accordeon-domains.accordeon-group").hide();
                        var stores = $("[data-domain=" + val + "]");

                        stores.show();
                    }
                }
            );

            if ($('.career').length > 0 && window.location.hash) {
              var id = window.location.hash.substr(1);
              if($('[data-opening='+id+']').length > 0) {
                var opening = $('[data-opening='+id+']');
                opening.parents('.accordeon-group').show();
                opening.find('.open').toggleClass('active');
                opening.find('.accordeon-content').slideToggle();
              }
            }





            var $cart = $(".cart-header");

            var $form = $('.add_to_cart_form');

            var $form2 = $('#cart_form_without_email');

            var $form3 = $('#cart_form_with_email');

            var $msg_box = $("#status_msg");
            var TIMEOUT = 2000;

            $(".chat_button").on('click', function(e) {

                e.preventDefault();
                LC_API.open_chat_window();
            });

            var default_msg = [];
            default_msg['en'] = "An error prevented the request from fulfilling";
            default_msg['fr'] = "Une erreur a empêché la requête d'aboutir";

            function toggleClass(state)
            {
                $($msg_box).removeClass();
                $($msg_box).addClass("status");
                $($msg_box).addClass(state);
            }

            $form.on('ajax:error', function(event, xhr, status, error) {

                //ga('ec:setAction', 'add_to_cart_fail');
                //ga('send', 'event', 'add_to_cart_fail', 'click', 'add_to_cart_fail');


                toggleClass('error');

                $msg_box.fadeIn();

                var response = xhr.responseText.toString();
                var lang = $('html').attr("lang");

                if (!response.trim() && response.length > 10)
                {
                    default_msg[lang] = response;
                }

                $msg_box.html(response);

                setTimeout(function(){
                    $msg_box.fadeOut();
                }, TIMEOUT);

            });

            $form.on('ajax:success', function(event, xhr, status, error) {

                //ga('ec:setAction', 'add_to_cart');
                //ga('send', 'event', 'add_to_cart', 'click', 'add_to_cart');

                $cart.slideToggle(650);
                $('body').toggleClass('block-scroll');

                setTimeout(function(){
                    $cart.slideToggle(650);
                    $('body').toggleClass('block-scroll');
                }, 3000);

            });

            $form2.on('ajax:error', function(event, xhr, status, error) {

                //ga('ec:setAction', 'add_to_cart_fail');
                //ga('send', 'event', 'add_to_cart_fail', 'click', 'add_to_cart_fail');


                toggleClass('error');

                $msg_box.fadeIn();

                var response = xhr.responseText.toString();
                var lang = $('html').attr("lang");

                if (!response.trim() && response.length > 10)
                {
                    default_msg[lang] = response;
                }

                $msg_box.html(response);

                setTimeout(function(){
                    $msg_box.fadeOut();
                }, TIMEOUT);

            });

            $form2.on('ajax:success', function(event, xhr, status, error) {

                //ga('ec:setAction', 'add_to_cart');
                //ga('send', 'event', 'add_to_cart', 'click', 'add_to_cart');

                $cart.slideToggle(650);
                $('body').toggleClass('block-scroll');

                setTimeout(function(){
                    $cart.slideToggle(650);
                    $('body').toggleClass('block-scroll');
                }, 3000);

            });

            $form3.on('ajax:error', function(event, xhr, status, error) {

                //ga('ec:setAction', 'add_to_cart_fail');
                //ga('send', 'event', 'add_to_cart_fail', 'click', 'add_to_cart_fail');


                toggleClass('error');

                $msg_box.fadeIn();

                var response = xhr.responseText.toString();
                var lang = $('html').attr("lang");

                if (!response.trim() && response.length > 10)
                {
                    default_msg[lang] = response;
                }

                $msg_box.html(response);

                setTimeout(function(){
                    $msg_box.fadeOut();
                }, TIMEOUT);

            });

            $form3.on('ajax:success', function(event, xhr, status, error) {

                //ga('ec:setAction', 'add_to_cart');
                //ga('send', 'event', 'add_to_cart', 'click', 'add_to_cart');

                $cart.slideToggle(650);
                $('body').toggleClass('block-scroll');

                setTimeout(function(){
                    $cart.slideToggle(650);
                    $('body').toggleClass('block-scroll');
                }, 3000);

            });


            $("#chk_shared").click(function(e){
                e.preventDefault();
                FB.ui({
                    method: 'share',
                    mobile_iframe: true,
                    display:'iframe',
                    href: $(this).data("href")

                }, function(response){
                    console.log( response );
                    if ( response !== null) {
                        // ajax call to save response
                        $("#participation_shared").prop('checked', 'true');
                        $("#participation_facebook_shared").val('t');
                    }
                });
            });


            $(".next_step").on('click', function(e) {

                e.preventDefault();

                var inputs = $("#new_participation").find(".required");

                var error = 0;

                $.each(inputs, function() {

                    var $el = $(this);
                    var $val = $el.val();

                    if($val.length)
                    {
                        $el.removeClass("error");

                    }
                    else
                    {
                        $el.addClass("error");
                        error = 1;
                    }
                });

                if ($("#terms").prop('checked')) {
                    $("#chk_newsletter span").removeClass("error");
                }
                else {
                    $("#chk_newsletter span").addClass("error");
                }

                if(error !== 1) {

                    var parent = $(this).parents(".step");

                    parent.hide();
                    parent.next().show();

                }


            });



            if( $('select').length) {
              //:not(.hasCustomSelect) pour par customselecter en double
             $('select:not(.hasCustomSelect .select2-input)').customSelect();
            }

            $( ".manage_gift_cards_button" ).click(function() {
                $( ".manage_gift_cards" ).toggle( "slow" );
            });
            $( ".show_virtualcard_button" ).click(function() {
                $( ".show_virtualcard" ).toggle( "slow" );
            });


            $('.modal').on('click','.close-modal',function(e){
                e.preventDefault();
                $('div.modal').trigger('hide');
            });

            $('.btn_payment_card').click(function(e) {
                e.preventDefault();
                $('.open_payment_card').slideToggle("slow");
                $(this).toggleClass("open");
            });



            $(window).bind("load", function() {
                var timeout = setTimeout(function() {
                    $("img.deferred_img").trigger("sporty")
                }, 100);
            });

            //////////////////////////////////////////
            // Slidebars

            //$.slidebars({
            //    disableOver: 1025,
            //    hideControlClasses: true,
            //    scrollLock: true
            //});
            //
            ////hack parceque slidebars c'est de la shit pis que l'API est mal faite
            //$('html').removeClass('sb-active');
            //$('html').removeClass('sb-active-right');

            //////////////////////////////////////////
            // Menu accordéon







            setup_cart();
            var widthWindow = $(window).width();

                if( widthWindow > 768 ){

                $('.accordion__content:not(:first)').hide();
                $('.accordion__title:first-child').addClass('active');

            } else {
                $('.accordion__content').hide();
            }


            $('.accordion__title').on('click', function() {
                $('.accordion__content').hide();
                $(this).next().show().prev().addClass('active').siblings().removeClass('active');
            });


            if ($('#infinite_scroll').size() > 0) {
                $("#sb-site").scroll( function() {

                    var more_posts_url;
                    more_posts_url = $('.pagination a[rel=next]').attr('href');

                    if (more_posts_url && $("#sb-site").scrollTop() > $('#infinite_scroll').position().top - $("#sb-site").height() - 200) {
                        $('.pagination').html('<img src=/assets/loading.svg" alt="Loading..." title="Loading..." />');
                        $.getScript(more_posts_url);
                    }
                });
            }

        }

    },

    home: {
        init: function() {
            HOME_CONTROLLER.init();
        }
    },

    job_applications: {
        init: function() {
            JOB_CONTROLLER.init();
        }
    },


    pages: {
        init: function() {

        },

        show: function() {
            PAGES_CONTROLLER.show();
        }
    },

    store_locations: {
        init: function() {

        },

        show: function() {
            STORE_LOCATION_CONTROLLER.show();
        }
    },

    products: {
        init: function() {

        },

        show: function() {
            PRODUCT_CONTROLLER.show();
        }
    },
    taxons: {
        init: function() {

        },

        show: function() {
            TAXON_CONTROLLER.show();
        }
    },

    checkout: {
        init: function() {

        },

        edit: function() {
            CHECKOUT_CONTROLLER.edit();
        },

        update: function() {
            CHECKOUT_CONTROLLER.edit();
        }

    },

    gift_cards: {
        init: function() {

        },

        new: function() {
            GIFT_CARDS_CONTROLLER.new();
        }
    }

};

UTIL = {
    exec: function( controller, action ) {
        var ns = SITENAME,
            action = ( action === undefined ) ? "init" : action;

        if ( controller !== "" && ns[controller] && typeof ns[controller][action] == "function" ) {
            ns[controller][action]();
        }
    },

    init: function() {
        var body = document.body,
            controller = body.getAttribute( "data-controller" ),
            action = body.getAttribute( "data-action" );

        UTIL.exec( "common" );
        UTIL.exec( controller );
        UTIL.exec( controller, action );
    }
};

var ready;
ready = function() {

    UTIL.init();

};

$(document).ready(ready);
$(document).on('page:load', ready);

$(window).click(function(e){

    clicks = click_number();
    if(isNaN(clicks)){
        clicks=0;
    }
    document.cookie = "clicks="+(clicks+1);
    if(e.target.nodeName != "A" ) {
        try_popup();
    }
    console.log(e);
    console.log(click_number());

});

$(window).resize(function(e) {
    $cart = $('.cart-header');
    $cart.fadeOut() ;
    $('.main-container, .menu-mobile-container').css('padding-top',$('header').height());
    var widthWindow = $(window).width() ;
    if( widthWindow <= 1024 ) {
        $('header').removeClass('hidden-scroll') ;
    } else {
        $('header').removeClass('mobileScroll') ;
    }
});

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


function try_popup(){



    $(".newsletter_popup_master").each(function(div){
        if( (!readCookie('mchoc_popup' + $( this ).data("id")) && click_number()>=$( this ).data("clicks")) ||  $(this).data("show") )
        {
            $(this).fadeIn();
            console.log("was");
            if($( this ).data("time")>0) {
                createCookie('mchoc_popup'+ $( this ).data("id"), true, $(this).data("time"));
            }
        }

    });

}


function try_popup_2(){



    $(".newsletter_popup_master_2").each(function(div){
        if( (!readCookie('mchoc_popup_2' + $( this ).data("id")) && click_number()>=$( this ).data("clicks")) ||  $(this).data("show") )
        {
            $(this).fadeIn();
            console.log("was");
            if($( this ).data("time")>0) {
                createCookie('mchoc_popup_2'+ $( this ).data("id"), true, $(this).data("time"));
            }
        }

    });

}

function click_number(){
    cookie = document.cookie;
    index = cookie.indexOf("clicks");
    if(index >=0){
        index2 = cookie.indexOf(";", index+6);
        if(index2>=0) {
            return parseInt(cookie.substring(index + 7,index2));
        } else {
            return parseInt(cookie.substring(index + 7));

        }
    }
    else{
        return 0;
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

    $("input.autocomplete:not(.ui-autocomplete-input)").autocomplete(
        {
            open: function(event, ui) {
                $(this).autocomplete("widget").css({
                    "width": ($(this).width() + 20 + "px")
                });
            },
            source:"/autocomplete"}).change(function(e){$this.parents("form").submit();
        }
    );

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

