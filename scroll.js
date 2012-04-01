(function() {

    var h1;
    var aw;
    
    var scrollPos = function(){
        var x = 0, y = 0;
        if (typeof(window.pageYOffset) == 'number') {
            y = window.pageYOffset;
            x = window.pageXOffset;
        } else if (document.body && (document.body.scrollLeft || document.body.scrollTop)) {
            y = document.body.scrollTop;
            x = document.body.scrollLeft;
        }
        return { x: x, y: y };
    };
    
    window.onscroll = function () {
        if (!h1) {
            h1 = document.getElementsByTagName('h1')[0];
            aw = document.getElementById('articlewrap');
            if (!h1) {
                return;
            }
        }
        var rel = scrollPos().y / h1.parentNode.parentNode.offsetHeight
        console.log(rel);
        var over = false;
        if (!rel) {
            rel = 0;
        } else if (rel > 0.8) {
            rel = 0.8;
            over = true;
        }
        var sz = 1 - rel;
        h1.parentNode.style.fontSize = sz + 'em';
        if (over) {
            h1.style.top = '-0.7em';
            h1.style.position = 'fixed';
        } else {
            h1.style.top = '';
            h1.style.position = '';
        }
    };

}());
