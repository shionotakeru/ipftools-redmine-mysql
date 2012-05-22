<%-----------------------------------------------------------------------------
    <Quantitative project management tool.>
    Copyright (C) 2012 IPA, Japan.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------------%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="/ipf.tld" prefix="ipf" %>

<bean:define id="CONTEXT_PATH">${pageContext.request.contextPath}</bean:define>
<bean:define id="E_USER_NAME"><bean:write name="USER_NAME"/></bean:define>
<bean:define id="CSS_LOCALE" name="result" property="cssLocale"></bean:define>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>${result.title}</title>
<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
<link href="${CONTEXT_PATH}/css/subWindow.css" rel="stylesheet" type="text/css" />
<script src="${CONTEXT_PATH}/jquery/jquery-1.6.2.js"></script>
<script src="${CONTEXT_PATH}/js/subWindow.js"></script>
</head>
<body>

<div id="top_nav">
<form name="mainForm" action="${CONTEXT_PATH}/dashboard" method=get>
    <div id="logo" class="left"><img src="${CONTEXT_PATH}/images/ipf_logo${CSS_LOCALE}.png" alt="IPF(In Process Feedback) - 定量的分析診断機能" />
    <!-- /logo --></div>
    <div id="top_nav_right">
        
        <div id="project_name" class="left"><ipf:message key="top.navi.project"/>：${PROJECT_NAME}</div>
        <div class="header_spacer"><img src="${pageContext.request.contextPath}/images/header_spacer.png" alt="" /></div>
        <div id="user_name" class="left"><ipf:message key="top.navi.user"/>：${E_USER_NAME}</div>
        <div class="header_spacer"><img src="${pageContext.request.contextPath}/images/header_spacer.png" alt="" /></div>
        <div id="help" class="left">
            <a class="icon_help" href="javascript:void(0)" 
                onclick="javascript:helpWindowOpen('${CONTEXT_PATH}/${result.helpFilePath}',
                'globalHelp', 1200, 750); return false;" ><ipf:message key="top.navi.help"/></a>
        </div>
    <!-- top_nav_right --></div>
    <html:hidden name="result" property="t" />
</form>
<!-- top_nav --></div>

<div id="container">

    <div id="left_col">
        <div id="menu_list">
            
            <!-- 定量管理ダッシュボード -->
            <div class="graph_group">
               <div class="graph_group_name add_icon_01" style="font-size:<ipf:message key="group.name.font.size"/>;"><ipf:message key="graph.group.1"/></div>
               <div class="graph_list">
                   <ipf:authDisp permissions="IPF_ANALYZE"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:mainWindowOpen('${CONTEXT_PATH}/dashboard?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}', 'mainFrame');">
                       <ipf:message key="R_M01"/></a></div></ipf:authDisp>
               </div>
            </div>
            
            <!-- 複数プロジェクト確認 -->
            <div class="graph_group">
               <div class="graph_group_name add_icon_02" style="font-size:<ipf:message key="group.name.font.size"/>;"><ipf:message key="graph.group.2"/></div>
               <div class="graph_list">
                   <ipf:authDisp permissions="IPF_GRAPH_M02"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:mainWindowOpen('${CONTEXT_PATH}/report/R_M02.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}', 'mainFrame');">
                       <ipf:message key="R_M02"/></a></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_M03"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:mainWindowOpen('${CONTEXT_PATH}/report/R_M03.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}', 'mainFrame');">
                       <ipf:message key="R_M03"/></a></div></ipf:authDisp>
               </div>
            </div>

            <!-- WBS管理・品質管理 -->
            <div class="graph_group">
               <div class="graph_group_name add_icon_03" style="font-size:<ipf:message key="group.name.font.size"/>;"><ipf:message key="graph.group.3"/></div>
               <div class="graph_list">
                   <ipf:authDisp permissions="IPF_GRAPH_S01"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S01.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S01"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S02"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S02.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S02"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S03"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S03.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S03"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S04"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S04.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S04"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S05"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S05.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S05"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S06"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S06.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S06"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S07"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S07.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S07"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S15"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S15.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S15"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
               </div>
            </div>

            <!-- 障害管理 -->
            <div class="graph_group">
               <div class="graph_group_name add_icon_04" style="font-size:<ipf:message key="group.name.font.size"/>;"><ipf:message key="graph.group.4"/></div>
               <div class="graph_list">
                   <ipf:authDisp permissions="IPF_GRAPH_S08"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S08.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S08"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S13"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S13.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S13"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S09"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S09.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S09"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S10"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S10.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S10"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
                   <ipf:authDisp permissions="IPF_GRAPH_S11"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S11.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S11"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
               </div>
            </div>

            <!-- 課題管理 -->
            <div class="graph_group">
               <div class="graph_group_name add_icon_05" style="font-size:<ipf:message key="group.name.font.size"/>;"><ipf:message key="graph.group.5"/></div>
               <div class="graph_list">
                   <ipf:authDisp permissions="IPF_GRAPH_S14"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S14.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S14"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
               </div>
            </div>

            <!-- 要員負荷管理 -->
            <div class="graph_group">
               <div class="graph_group_name add_icon_06" style="font-size:<ipf:message key="group.name.font.size"/>;"><ipf:message key="graph.group.6"/></div>
               <div class="graph_list">
                   <ipf:authDisp permissions="IPF_GRAPH_S12"><div class="graph_name" style="font-size:<ipf:message key="graph.name.font.size"/>;">
                       <a href="javascript:void(0)" onclick="javascript:subWindowOpen('${CONTEXT_PATH}/report/R_S12.rptdesign?PROJECT_ID=${result.PROJECT_ID}&t=${result.t}');">
                       <ipf:message key="R_S12"/></a><img src="${CONTEXT_PATH}/images/newwindow.png"/></div></ipf:authDisp>
               </div>
            </div>
        <!-- menu_list --></div>
        
    <!-- left_col --></div>

    <div id="page_content">
        <div id="menu_show_hide">
            <div id="menu_hide"><a id="menu_hide_link" href="javascript:void(0)">
                <img src="${CONTEXT_PATH}/images/menu_hide.png" /></a></div>
            <div id="menu_show" style="display:none;"><a id="menu_show_link" href="javascript:void(0)">
                <img src="${CONTEXT_PATH}/images/menu_show.png" /></a></div>
        </div>
        </a>
        <div id="page_content_main">
            <%-- JSPインクルード --%>
            <jsp:include page="${result.includeFilePath}"></jsp:include>
        <!-- page_content_main --></div>
   <!-- page_content --></div>

<!-- container --></div>

</body>
</html>