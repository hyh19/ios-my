
var allImageStr="";
//给html内图片添加点击手势响应
function setImageClickFunction(){
    var imgs = document.getElementsByTagName("img");
    for (var i=0;i<imgs.length;i++){
        var src = imgs[i].src;
        imgs[i].setAttribute("onclick","clickCurImg(this)");
        imgs[i].setAttribute("onload","loadCurImgFinish(this)");
    }
}

function setWordExplainClickFunction()
{
    var tag_link = document.getElementsByClassName("tag-link");
    for (var i=0;i<tag_link.length;i++)
    {
        tag_link[i].setAttribute("onclick","clickCurTagLink(this)");
    }
}

//获取词条信息
function clickCurTagLink(obj)
{
    var wordStr="";
    var explain ="http://"+ window.location.host + '/wordTag.html?tagId=';
    var link_word_id=obj.getAttribute('data-id');
    explain+=link_word_id;
    wordStr+=explain;
    wordStr+="*&*";
    var link_word_title=obj.innerText;
    wordStr+=link_word_title;
    wordStr+="*&*";
    var link_word_img=obj.getAttribute('data-img');
    wordStr+=link_word_img;
    wordStr+="*&*";
    var link_word_src=obj.getAttribute('data-src');
    wordStr+=link_word_src;
    document.location =wordStr;
}

//获取视频信息
function getVideoInfo()
{
    
    var parent = document.getElementById('J_cont');
    parent.addEventListener('click',function(e)
                            {
                               var e = e || window.event;
                              var target = e.target || e.srcElement;
                              if (target.className == 'bingdu-video')
                               {
                                 var videoStr=target.getAttribute('data-src');
                                  videoStr+="*&&*";
                                 document.location =videoStr;
                               }
                            },
                            false);
//    var videoObj = document.querySelectorAll(".bingdu-video");
//    if(videoObj)
//    {
//        for(var i=0;i<videoObj.length;i++)
//        {
//            
//            videoObj[i].onclick=function()
//            {
//                var videoStr=this.getAttribute('data-src');
//                videoStr+="*&&*";
//                document.location =videoStr;
//            }
//            
//        }
//    }
}

//点击了某个视频
function clickCurVideo(obj)
{
    var src=obj.getAttribute('src');
    var videoStr=src;
    if(!src)
    {
        src=obj.getElementsByTagName('source')[0].src;
    }
    var title=obj.getAttribute('title');
    videoStr+="*&&*";
    videoStr+=title;
    document.location =videoStr;
}
//判读有没有图片
function isHaveImage(){
    var btn=document.getElementById("J_cont");
    var imgs = btn.getElementsByTagName('img');
    if(imgs.length>0)
    {
        return '1';
    }
    else
        return '0';
}

//获取所有图片的信息
function getAllImageInfo()
{
    return allImageStr;
}

//图片已加载完
function loadCurImgFinish(obj)
{
     var  selectedImgUrls ='finishimageurl:';
     var src = obj.getAttribute('data-url');
     selectedImgUrls+=src;
     selectedImgUrls+= '&frame:';
     var frame=MyAppGetImageFrameAtPoint(obj)
     selectedImgUrls+= frame;
     allImageStr+=selectedImgUrls;
     allImageStr+="#";
     document.location = selectedImgUrls;
    
}

//图片已加载完
function getElementsInfoAtPoint(x,y)
{
    var e = document.elementFromPoint(x,y);
    var  selectedImgUrls ='finishimageurl:';
    var src = e.getAttribute('data-url');
    selectedImgUrls+=src;
    selectedImgUrls+= '&frame:';
    var frame=MyAppGetImageFrameAtPoint(e)
    selectedImgUrls+= frame;
    return selectedImgUrls;

}

function getElementAtPoint(x,y)
{
    var tags = "";
    var e = document.elementFromPoint(x,y);
     while (e)
     {
        if (e.tagName) {
            tags += e.tagName + ',';
        }
        e = e.parentNode;
    }
       return tags;
}
function MyAppGetImageFrameAtPoint(e)
{
    var tags = "";
    while (e)
    {
        if (e.offsetTop)
        {
            tags += e.offsetTop+",";
        }
        if (e.offsetLeft)
        {
            tags += e.offsetLeft+",";
        }
        if (e.width)
        {
            tags += e.width+",";
        }
        if (e.height/2)
        {
            tags += e.height+",";
            
        }
        if(tags.length>5)
        break;
        e = e.parentNode;
    }
    return tags;
}
//获取html网页图片与标题方法
function clickCurImg(obj){

    var imageTitle = document.getElementsByTagName("title")[0];
    var imageTitles = 'imageTitles:';
        imageTitles +=imageTitle;
    var imageurls = 'imgUrls:';
    var btn=document.getElementById("J_cont");
    var imgs = btn.getElementsByTagName('img');
    for (var i=0;i<imgs.length;i++){
        var src = imgs[i].getAttribute('data-url');
        if(i!=(imgs.length-1))
            imageurls+= src +',';
        else
            imageurls+= src;
    }
    var selectedImgUrls = 'selectedImgUrls:';
    var src = obj.getAttribute('data-url');
    selectedImgUrls+=src;
    document.location = imageurls + imageTitles + selectedImgUrls;
}
//判断是否是新的新闻（就是默认图片和实际图片一样大）
function isNewNews()
{
    var btn=document.getElementById("J_cont");
    var imgs = btn.getElementsByTagName('img');
    for (var i=0;i<imgs.length;i++)
    {
        var src = imgs[i].getAttribute('data-origin-height');
        if(src)
        {
            return '1';
        }
        else
            return '0';
    }

}
//获取网页内容文字
function getHtmlBody(){
    var hisBodyText = document.getElementById("J_cont");
    return hisBodyText.innerText;
}

//获取网页内容LOGO图片
function getHtmlBodyImg(){
    var btn=document.getElementById("J_cont");
    var imgs = btn.getElementsByTagName('img');
    if (imgs.length==0)
        return  '';
    else if(imgs.length>=1)
    {
        var src=imgs[0].getAttribute('data-url');
        return src;
    }
}

//此方法为解决iOS监控不到webview滚动事件，参数'top'为iOS端监听到客户端滚动的距离，用来模拟webview层滚动所产生的距离实现图片延迟加载
function webScroll(top){
    var sTop = top;
    for(var i = 0; i < len; i++){
        var top = img[i].offsetTop,
        lazy_src = img[i].getAttribute('data-src');
        if (winH + sTop > top - 100 && lazy_src != null) {
            img[i].src = lazy_src;
            img[i].removeAttribute('data-src');
        }
    }
}


////IOS8以后监测视频播放
//(function () {
// var scheme = 'videohandler://';
// 
// var videos = document.getElementsByTagName('video');
// 
// for (var i = 0; i < videos.length; i++) {
// videos[i].addEventListener('webkitbeginfullscreen', onBeginFullScreen, false);
// videos[i].addEventListener('webkitendfullscreen', onEndFullScreen, false);
// }
// 
// function onBeginFullScreen() {
// window.location = scheme + 'video-beginfullscreen';
// }
// 
// function onEndFullScreen() {
// window.location = scheme + 'video-endfullscreen';
// }
// })();
