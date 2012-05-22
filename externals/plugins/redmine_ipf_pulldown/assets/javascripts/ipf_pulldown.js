window.onload = function()
{
    links = document.getElementsByClassName('ipf-has-children');
    for(cnt = 0; cnt < links.length; cnt++)
    {
        parentElement = links[cnt].parentNode;
        parentElement.setAttribute('class', 'ipf-has-submenu-off');
        parentElement.setAttribute('onmouseover', "this.className='ipf-has-submenu-on'");
        parentElement.setAttribute('onmouseout', "this.className='ipf-has-submenu-off'");
    }
}
