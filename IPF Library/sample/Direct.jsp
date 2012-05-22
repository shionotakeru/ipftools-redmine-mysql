<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="org.eclipse.birt.report.session.ViewingSessionUtil" %>
<%
ViewingSessionUtil.createSession(request);
String contextPath = request.getContextPath();
String url = request.getQueryString();
%>
<html>
    <head>
        <title>&nbsp;</title>
        <script type="text/javascript">
        <!--
        function link() {
            location.href = '<%= url.replace("URL=", "") %>';
        }
        // -->
        </script>
    </head>
    <body onload="link();return false;">
    </body>
</html>