 /* custom JS here */
  function responheight() {
	var hfoot = $(window).height();
	var hheader=$('.header').outerHeight();
	var hfooter = $('.footer').outerHeight();
	var hnavslider=$('.slider-nav').outerHeight();
	//$('.childpage .page').css({marginBottom:-hfooter});	
	$('.maincontent').css({paddingBottom:hfooter});
	$('.bgslider').css({height:hfoot-hnavslider});	
	$('.info-inner-banner').css({paddingTop:hheader});
	$('.pager-home').css({bottom:hnavslider+30});

}
$('.bgslider').each(function() {
			var imgUrl1 = $(this).find('.bgimg').attr('src');
			$(this).fixbg({ srcimg : imgUrl1});           
	});
$( ".scroll-add .item-sroll:nth-child(2n)" ).addClass( "otherbg" );




var $statushome = $('.pager-home');
	var $slickElementhome = $('.sliderhome');	
	$slickElementhome.on('init reInit afterChange', function(event, slick, currentSlide, nextSlide){
    //currentSlide is undefined on init -- set it to 0 in this case (currentSlide is 0 based)
	var ihome = (currentSlide ? currentSlide : 0) + 1;
		$statushome.html('<span class="text-nb"> 0'+ihome+'</span>' + ' / 0' + slick.slideCount);
	});
new WOW().init();
$(document).ready(function(){
	$('.menu-page').each(function(){
		var currentid = $(this).attr('href');
		$(this).click(function(e){
	        e.preventDefault();
			 $(this).toggleClass('active-menu');
			 $(currentid).toggleClass('open-sub');
			 $('body').toggleClass('open-page');
		});	
	});	
	
	 $('.slider-for').slick({
		  slidesToShow: 1,
		  slidesToScroll: 1,
		  arrows: true,
		  fade: true,
		  dots:false,
		  asNavFor: '.slider-nav'
		});
		$('.slider-nav').slick({
		  slidesToShow: 3,
		  slidesToScroll: 1,
		   arrows: false,
		  asNavFor: '.slider-for',
		  focusOnSelect: true
		});

		$('.slide-pro').slick({
		  infinite: true,
		  speed: 300,
		  arrows: true,
		  slidesToShow: 4,
		  slidesToScroll: 1,
		  responsive: [
		    {
		      breakpoint: 1024,
		      settings: {
		        slidesToShow: 3,
		        slidesToScroll: 3,
		        infinite: true,
		        dots: true
		      }
		    },
		    {
		      breakpoint: 800,
		      settings: {
		        slidesToShow: 2,
		        slidesToScroll: 2
		      }
		    }
		    // You can unslick at a given breakpoint now by adding:
		    // settings: "unslick"
		    // instead of a settings object
		  ]
});
		$('.slider-pro-ft').slick({
		  infinite: true,
		  
		  speed: 300,
		  arrows: true,
		  slidesToShow: 4,
		  variableWidth: true,
		  centerMode: true,
		  slidesToScroll: 1,
		  responsive: [
		    {
		      breakpoint: 1024,
		      settings: {
		        slidesToShow: 2,
		        slidesToScroll: 2,
		        infinite: true,
		      }
		    },
		    {
		      breakpoint: 700,
		      settings: {
		        slidesToShow: 1,
		        slidesToScroll: 1
		      }
		    },
		    {
		      breakpoint: 480,
		      settings: {
		        slidesToShow: 1,
		        slidesToScroll: 1
		      }
		    }
		    // You can unslick at a given breakpoint now by adding:
		    // settings: "unslick"
		    // instead of a settings object
		  ]
});
$('.grid-6').slick({
		  infinite: true,
		  
		  speed: 300,
		  arrows: false,
		  slidesToShow: 4,
		  slidesToScroll: 4,
		   autoplay: true,
 			autoplaySpeed: 3000,
		  responsive: [
		    {
		      breakpoint: 1024,
		      settings: {
		        slidesToShow: 3,
		        slidesToScroll: 3,
		        infinite: true,
		      }
		    },
		    {
		      breakpoint: 640,
		      settings: {
		        slidesToShow: 2,
		        slidesToScroll: 2
		      }
		    }
		    // You can unslick at a given breakpoint now by adding:
		    // settings: "unslick"
		    // instead of a settings object
		  ]
});
});
$('.selectpicker').selectpicker({});
$(window).scroll(function() {
		if ($(this).scrollTop()) {
			$('.to-top').css({bottom:0});
		} else {
			$('.to-top').css({bottom:-100});
		}
	});
	$('.to-top a').click(function(e){
		  var href = $(this).attr("href"),
			 offsetTop = href === "#" ? 0 : $(href).offset().top;
		  $('html, body').stop().animate({ 
			  scrollTop: offsetTop
		  }, 1000);
		  e.preventDefault();
		});
	$('.grid-6-item a.over-link').click(function(e){
		  var href = $(this).attr("href"),
			 offsetTop = href === "#" ? 0 : $(href).offset().top;
		  $('html, body').stop().animate({ 
			  scrollTop: offsetTop
		  }, 1000);
		  e.preventDefault();
		});

$('.btn-nav').each(function() {
		$(this).click(function(event){
			event.preventDefault();
			$(this).next().slideToggle();
			$(this).toggleClass('open-nav');			
		});
});	



/*$('.grid-4-item .over-link').each(function() {
		$(this).click(function(event){
			$('.item-product').addClass("show-item");
		});
});*/
$('.over-link').click(function(){
		var tab_id = $(this).attr('data-tab');

		//$(this).removeClass('show-work');
		$('.item-product').removeClass('show-item');

		//$(this).addClass('current');
		$("#"+tab_id).addClass('show-item');
	})



$('.close-btn').each(function() {
		$(this).click(function(event){
			$('.item-product').removeClass("show-item");
		});
});
$('.grid-4-item .over-link,.close-btn').click(function(e){
		  var href = $(this).attr("href"),
			 offsetTop = href === "#" ? 0 : $(href).offset().top-80;
		  $('html, body').stop().animate({ 
			  scrollTop: offsetTop
		  }, 1000);
		  e.preventDefault();
		});


$("input[placeholder]").focusin(function () {
    $(this).data('place-holder-text', $(this).attr('placeholder')).attr('placeholder', '');
	})
	.focusout(function () {
		$(this).attr('placeholder', $(this).data('place-holder-text'));
	});
$(window).load(function() {
	responheight();
	//$(".header").sticky({ topSpacing: 0 });
	$("#content_1").mCustomScrollbar({
					scrollButtons:{
						enable:true
					}
				});
});

$(window).resize(function(){
	responheight();
});
