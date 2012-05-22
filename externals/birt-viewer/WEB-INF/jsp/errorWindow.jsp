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
<%@page import="org.apache.log4j.Level"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="/ipf.tld" prefix="ipf" %>

<bean:define id="CONTEXT_PATH">${pageContext.request.contextPath}</bean:define>
<bean:define id="DEBUG_INT"><%= Level.DEBUG_INT  %></bean:define>
<bean:define id="CSS_LOCALE" name="result" property="cssLocale"></bean:define>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><ipf:message key="error.window.title"/></title>
<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
<link href="${CONTEXT_PATH}/css/errorWindow.css" rel="stylesheet" type="text/css" />
<script src="${CONTEXT_PATH}/js/errorWindow.js"></script>
</head>
<body>

<div id="top_nav">
    <div id="logo" class="left"><img src="${CONTEXT_PATH}/images/ipf_logo${CSS_LOCALE}.png" alt="IPF(In Process Feedback) - 定量的分析診断機能" />
    <!-- /logo --></div>
    <div id="top_nav_right">
        <div id="help" class="left">
            <a class="icon_help" href="javascript:void(0)" 
                onclick="javascript:helpWindowOpen('${CONTEXT_PATH}/report/help/IPF_TOP/IPF_HELP.html',
                'globalHelp', 1200, 750); return false;" ><ipf:message key="top.navi.help"/></a>
        </div>
    <!-- top_nav_right --></div>
<!-- top_nav --></div>

<div id="container">
    
    <div id="error_msg_area">
        <div id="error_title"><ipf:message key="error.window.title"/></div>
        <logic:notEmpty name="result">
	        <div id="error_msg"><bean:write name="result" property="errMsg" /></div>
	        <logic:lessEqual name="result" property="logLevel" value="${DEBUG_INT}">
	            <div id="error_statck_trace"><pre><bean:write name="result" property="stackTrace" /></pre></div>
	        </logic:lessEqual>
        </logic:notEmpty>
    <!-- error_msg_area --></div>

<!-- container --></div>

</body>
</html>
